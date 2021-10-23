import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.name,
    this.nickName = '',
    this.email = '',
    this.pictureB64Enc = '',
    this.accountCreated = false,
    this.emailVerified = false,
  });

  final String id;
  final String name;
  final String nickName;
  final String pictureB64Enc;
  final String email;
  final bool accountCreated;
  final bool emailVerified;

  // Reference for working solution https://stackoverflow.com/a/61289387
  String nameInitials() {
    List<String> names = name.split(' ');
    String initials = '';
    int numWords = 2;

    if (numWords >= names.length) {
      numWords = names.length;
    }
    for (var i = 0; i < numWords; i++) {
      initials += '${names[i][0]}';
    }
    return initials;
  }

  // Reference for working solution https://stackoverflow.com/a/61289387
  String nickNameInitials() {
    List<String> names = nickName.split(' ');
    String initials = '';
    int numWords = 2;

    if (numWords >= names.length) {
      numWords = names.length;
    }
    for (var i = 0; i < numWords; i++) {
      initials += '${names[i][0]}';
    }
    return initials;
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? nickName,
    String? pictureB64Enc,
    String? email,
    bool? accountCreated,
    bool? emailVerified,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      nickName: nickName ?? this.nickName,
      pictureB64Enc: pictureB64Enc ?? this.pictureB64Enc,
      email: email ?? this.email,
      accountCreated: accountCreated ?? this.accountCreated,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nickName,
        email,
        pictureB64Enc,
        accountCreated,
        emailVerified,
      ];

  static const empty = AppUser(
    id: '-',
    name: 'name',
    nickName: 'nickName',
    email: '-',
    pictureB64Enc: '-',
  );
  static const String fieldId = 'id';
  static const String fieldName = 'name';
  static const String fieldNickName = 'nickName';
  static const String fieldEmail = 'email';
  static const String fieldPictureB64Enc = 'pictureB64Enc';
  static const String fieldAccountCreated = 'accountCreated';
  static const String fieldEmailVerified = 'emailVerified';

  Map<String, dynamic> get fieldValues => {
        fieldId: this.id,
        fieldName: this.name,
        fieldNickName: this.nickName,
        fieldEmail: this.email,
        fieldPictureB64Enc: this.pictureB64Enc,
        fieldAccountCreated: this.accountCreated,
        fieldEmailVerified: this.emailVerified,
      };

  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json[AppUser.fieldId],
      name: json[AppUser.fieldName],
      nickName: json[AppUser.fieldNickName] ?? '',
      email: json[AppUser.fieldEmail] ?? '',
      pictureB64Enc: json[AppUser.fieldPictureB64Enc] ?? '',
      accountCreated: json[AppUser.fieldAccountCreated] ?? false,
      emailVerified: json[AppUser.fieldEmailVerified] ?? false,
    );
  }
}
