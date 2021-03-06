import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:repository/src/cache_client.dart';
import 'package:repository/src/exceptions/exceptions.dart';
import 'package:repository/src/exceptions/sign_up_with_email_password_failure.dart';
import 'package:repository/src/models/models.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class UserRepository {
  UserRepository({
    CacheClient? cache,
    FirebaseAuth? firebaseAuth,
  })  : _cache = cache ?? CacheClient(),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    _streamUser();
  }

  final CacheClient _cache;
  final FirebaseAuth _firebaseAuth;
  final _usersCollection =
      FirebaseFirestore.instance.collection('users').withConverter(
            fromFirestore: (snapshot, _) => AppUser.fromJson(snapshot.data()!),
            toFirestore: (affirmation, _) => affirmation.fieldValues,
          );

  CollectionReference<Letter> _lettersCollection(String userId) {
    return _usersCollection.doc(userId).collection('letters').withConverter(
          fromFirestore: (snapshot, _) => Letter.fromJson(snapshot.data()!),
          toFirestore: (letter, _) => letter.fieldValues,
        );
  }

  @visibleForTesting
  static const userCacheKey = '__user_cache_key__';

  @visibleForTesting
  static const statusCacheKey = '__status_cache_key__';

  final _statusController = StreamController<AuthenticationStatus>();
  final _userController = StreamController<AppUser>();
  late StreamSubscription<AppUser> _userStreamSub;

  AppUser get currentUser {
    return _cache.read<AppUser>(key: userCacheKey) ?? AppUser.empty;
  }

  AuthenticationStatus get currentStatus {
    final status = _cache.read(key: statusCacheKey) as int?;
    return status != null
        ? AuthenticationStatus.values[status]
        : AuthenticationStatus.unknown;
  }

  void _streamUser() {
    if (_firebaseAuth.currentUser != null) {
      _userStreamSub = _usersCollection
          .doc(_firebaseAuth.currentUser!.uid)
          .snapshots()
          .map((event) => event.data()!)
          .listen((event) {
        _cache.write(key: userCacheKey, value: event);
        _userController.add(event);

        _cache.write(
          key: statusCacheKey,
          value: AuthenticationStatus.authenticated,
        );
        _statusController.add(AuthenticationStatus.authenticated);
      });
    }
  }

  /// Stream of [AppUser] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [AppUser.empty] if the user is not authenticated.
  Stream<AppUser> get user async* {
    yield* _userController.stream;
  }

  Stream<AuthenticationStatus> get status async* {
    yield* _statusController.stream;
  }

  void disposeStatus() => _statusController.close();

  void disposeUser() => _userController.close();

  Future<AppUser> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    String? nickName,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      AppUser newUser = AppUser(
        id: userCredential.user?.uid ?? AppUser.empty.id,
        name: name,
        email: userCredential.user?.email ?? AppUser.empty.email,
        nickName: nickName != null ? nickName.trim() : '',
        emailVerified: userCredential.user?.emailVerified ?? false,
      );
      await _usersCollection.doc(newUser.id).set(newUser);
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.sendEmailVerification();
      _streamUser();
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw SignUpWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      debugPrint(_.toString());
      throw const SignUpWithEmailAndPasswordFailure();
    }
  }

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _streamUser();
    } on FirebaseAuthException catch (e) {
      throw LogInWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const LogInWithEmailAndPasswordFailure();
    }
  }

  Future<void> resendVerificationCode() async {
    final User? currentFirebaseUser = _firebaseAuth.currentUser;

    if (currentFirebaseUser != null && !currentFirebaseUser.emailVerified) {
      final actionCodeSettings = ActionCodeSettings(
        url:
            'https://affirmations.hrahimy.com/?email=${currentFirebaseUser.email}',
        dynamicLinkDomain: 'affirmations.hrahimy.com',
        androidPackageName: 'com.positiveaffirmations.mobile_app',
        androidInstallApp: true,
        androidMinimumVersion: '12',
        iOSBundleId: 'com.positiveaffirmations.mobile_app',
        handleCodeInApp: true,
      );
      await currentFirebaseUser.sendEmailVerification(actionCodeSettings);
    }
  }

  Future<void> checkIfVerified() async {
    try {
      await _firebaseAuth.currentUser!.reload();
      final user = _firebaseAuth.currentUser!;
      if (user.emailVerified != currentUser.emailVerified &&
          user.emailVerified == true) {
        await _usersCollection
            .doc(currentUser.id)
            .set(currentUser.copyWith(emailVerified: true));
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<void> editUser({
    String? name,
    String? nickName,
  }) async {
    final User? currentFirebaseUser = _firebaseAuth.currentUser;

    if (currentFirebaseUser == null) return;

    if (name != null) {
      await currentFirebaseUser.updateDisplayName(name);
    }
    final updatedUser = currentUser.copyWith(
      name: name ?? currentUser.name,
      nickName: nickName ?? currentUser.nickName,
    );
    await _usersCollection.doc(currentUser.id).set(currentUser.copyWith(
          name: name ?? currentUser.name,
          nickName: nickName ?? currentUser.nickName,
        ));
  }

  Future<AppUser> updateProfilePicture(String base64Picture) async {
    String dataUrl = 'data:image/jpeg;base64,$base64Picture';
    try {
      final url = await FirebaseStorage.instance
          .ref('users/${currentUser.id}/picture.jpg')
          .putString(dataUrl, format: PutStringFormat.dataUrl)
          .then((p0) => p0.ref.getDownloadURL());
      await _firebaseAuth.currentUser!.updatePhotoURL(url);
      final updatedUser = currentUser.copyWith(pictureUrl: url);
      await _usersCollection
          .doc(_firebaseAuth.currentUser!.uid)
          .set(updatedUser);
      return _firebaseAuth.currentUser!.toUser;
    } on FirebaseException catch (_) {
      // e.g, e.code == 'canceled'
      rethrow;
    }
  }

  Future<void> updateLetterSchedule(LetterCreationSchedule schedule) async {
    await _usersCollection
        .doc(currentUser.id)
        .set(currentUser.copyWith(letterSchedule: schedule));
  }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await _userStreamSub.cancel();
      await Future.wait([
        _firebaseAuth.signOut().then((value) {
          _cache.write(
            key: statusCacheKey,
            value: AuthenticationStatus.unauthenticated.index,
          );
          _statusController.add(AuthenticationStatus.unauthenticated);

          _cache.write(key: userCacheKey, value: AppUser.empty);
          _userController.add(AppUser.empty);
        }),
      ]);
    } catch (_) {
      throw LogOutFailure();
    }
  }

  Future<List<Letter>> getLetters() async {
    return await _lettersCollection(currentUser.id)
        .get()
        .then((value) => value.docs.map((e) => e.data()).toList());
  }
}

extension on User {
  AppUser get toUser {
    return AppUser(
      id: uid,
      email: email ?? '',
      name: displayName ?? '',
      pictureUrl: photoURL ?? '',
      emailVerified: emailVerified,
    );
  }
}
