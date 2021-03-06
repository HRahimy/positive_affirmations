import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:repository/repository.dart';
import 'package:uuid/uuid.dart';

class AffirmationsRepository {
  AffirmationsRepository({
    required this.userRepository,
  });

  final UserRepository userRepository;

  final _affirmationsCollection = FirebaseFirestore.instance
      .collection('affirmations')
      .withConverter(
        fromFirestore: (snapshot, _) => Affirmation.fromJson(snapshot.data()!),
        toFirestore: (affirmation, _) => affirmation.fieldValues,
      );
  final _usersCollection =
      FirebaseFirestore.instance.collection('users').withConverter(
            fromFirestore: (snapshot, _) => AppUser.fromJson(snapshot.data()!),
            toFirestore: (affirmation, _) => affirmation.fieldValues,
          );

  CollectionReference<AffirmationLike> likesCollection(String affirmationId) {
    return _affirmationsCollection
        .doc(affirmationId)
        .collection('likes')
        .withConverter(
          fromFirestore: (snapshot, _) =>
              AffirmationLike.fromJson(snapshot.data()!),
          toFirestore: (like, _) => like.fieldValues,
        );
  }

  CollectionReference<Reaffirmation> reaffirmationCollection(
      String affirmationId) {
    return _affirmationsCollection
        .doc(affirmationId)
        .collection('reaffirmations')
        .withConverter(
          fromFirestore: (snapshot, _) =>
              Reaffirmation.fromJson(snapshot.data()!),
          toFirestore: (reaffirmation, _) => reaffirmation.fieldValues,
        );
  }

  Future<void> saveAffirmation(Affirmation affirmation) async {
    await _affirmationsCollection.doc(affirmation.id).set(affirmation);
    final user = await _usersCollection
        .doc(userRepository.currentUser.id)
        .get()
        .then((value) => value.data()!);
    await _usersCollection
        .doc(userRepository.currentUser.id)
        .set(user.copyWith(affirmationCount: user.affirmationCount + 1));
  }

  Future<List<Affirmation>> getAffirmations({
    int? skip,
    int? take,
    String? searchQuery,
    String? userId,
  }) async {
    var query = _affirmationsCollection
        .orderBy(Affirmation.fieldCreatedOn)
        .startAt([skip ?? 0]).limit(take ?? 10);
    if (userId != null) {
      query = query.where(Affirmation.fieldCreatedById, isEqualTo: userId);
    } else {
      query = query.where(Affirmation.fieldActive, isEqualTo: true);
    }
    return await query.get().then((value) {
      return value.docs.map((snapshot) {
        if (snapshot.data().likes.any(
            (element) => element.byUserId == userRepository.currentUser.id)) {
          return snapshot.data().copyWith(liked: true);
        } else {
          return snapshot.data();
        }
      }).toList();
    });
  }

  Future<Affirmation?> toggleLiked({
    required String affirmationId,
    required String userId,
  }) async {
    Affirmation? affirmation = await _affirmationsCollection
        .doc(affirmationId)
        .get()
        .then((snap) => snap.data());

    if (affirmation == null) return null;

    // Create new like if none exist by the given user, increment likes count for the given affirmation, return updated affirmation with liked set to true
    // Else delete all likes by the given user, decrement likes count for given affirmation, return updated affirmation with liked set to false
    if (affirmation.likes.isEmpty ||
        !affirmation.likes.any((element) => element.byUserId == userId)) {
      final newLike = AffirmationLike(
        id: const Uuid().v4(),
        byUserId: userId,
      );
      affirmation = affirmation.copyWith(
        likeCount: affirmation.likeCount + 1,
        likes: [...affirmation.likes, newLike],
        liked: true,
      );
    } else {
      List<AffirmationLike> likes = [...affirmation.likes];
      likes.removeWhere((element) => element.byUserId == userId);
      affirmation = affirmation.copyWith(
        likeCount: affirmation.likeCount - 1,
        liked: false,
        likes: [...likes],
      );
    }

    await _affirmationsCollection.doc(affirmationId).set(affirmation);

    return affirmation;
  }

  Future<Affirmation> createReaffirmation({
    required String affirmationId,
    required Reaffirmation reaffirmation,
  }) async {
    reaffirmationCollection(affirmationId)
        .doc(reaffirmation.id)
        .set(reaffirmation);

    return _affirmationsCollection.doc(affirmationId).get().then((value) async {
      Affirmation fetchedAffirmation = value.data()!.copyWith(
            totalReaffirmations:
                Affirmation.fromSnapshot(value).totalReaffirmations + 1,
          );
      if (fetchedAffirmation.likes.any(
          (element) => element.byUserId == userRepository.currentUser.id)) {
        fetchedAffirmation = fetchedAffirmation.copyWith(liked: true);
      }
      await _affirmationsCollection.doc(affirmationId).set(fetchedAffirmation);
      final affirmationUser = await _usersCollection
          .doc(fetchedAffirmation.createdById)
          .get()
          .then((value) => value.data()!);
      await _usersCollection.doc(affirmationUser.id).set(
          affirmationUser.copyWith(
              reaffirmationCount: affirmationUser.reaffirmationCount + 1));
      return fetchedAffirmation;
    });
  }

  Future<Affirmation?> editAffirmation(
    String affirmationId, {
    String? title,
    String? subtitle,
  }) async {
    Affirmation? toUpdateAffirmation = await _affirmationsCollection
        .doc(affirmationId)
        .get()
        .then((snap) => snap.data());

    if (toUpdateAffirmation == null) return null;

    toUpdateAffirmation = toUpdateAffirmation.copyWith(
      title: title ?? toUpdateAffirmation.title,
      subtitle: subtitle ?? toUpdateAffirmation.subtitle,
      liked: toUpdateAffirmation.likes
          .any((element) => element.byUserId == userRepository.currentUser.id),
    );

    await _affirmationsCollection.doc(affirmationId).set(toUpdateAffirmation);

    return toUpdateAffirmation;
  }

  Future<Affirmation> toggleActivated(String affirmationId) async {
    Affirmation toUpdate = await _affirmationsCollection
        .doc(affirmationId)
        .get()
        .then((snap) => Affirmation.fromSnapshot(snap));

    toUpdate = toUpdate.copyWith(active: !toUpdate.active);

    await _affirmationsCollection.doc(affirmationId).set(toUpdate);

    return toUpdate;
  }

  Future<void> deleteAffirmation(String affirmationId) async {
    reaffirmationCollection(affirmationId).snapshots().forEach((element) {
      for (DocumentSnapshot ds in element.docs) {
        ds.reference.delete();
      }
    });
    await _affirmationsCollection.doc(affirmationId).delete();
  }
}
