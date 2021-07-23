part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class UserCreated extends ProfileEvent {
  const UserCreated({required this.user});

  final User user;

  @override
  List<Object?> get props => [user];
}

class ProfileEdited extends ProfileEvent {
  const ProfileEdited({
    required this.name,
    required this.nickName,
  });

  final String name;
  final String nickName;

  @override
  List<Object> get props => [name, nickName];
}

class PictureUpdated extends ProfileEvent {
  const PictureUpdated({required this.pictureB64Enc});
  final String pictureB64Enc;

  @override
  List<Object?> get props => [pictureB64Enc];
}