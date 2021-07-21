part of 'sign_up_bloc.dart';

class SignUpState extends Equatable {
  const SignUpState({
    this.name = const NameField.pure(),
    this.nickName = const NickNameField.pure(),
    this.nameStatus = FormzStatus.pure,
    this.nickNameStatus = FormzStatus.pure,
    this.submissionStatus = FormzStatus.pure,
  });

  final NameField name;
  final NickNameField nickName;
  final FormzStatus nameStatus;
  final FormzStatus nickNameStatus;
  final FormzStatus submissionStatus;

  SignUpState copyWith({
    NameField? name,
    NickNameField? nickName,
    FormzStatus? nameStatus,
    FormzStatus? nickNameStatus,
    FormzStatus? submissionStatus,
  }) {
    return SignUpState(
      name: name ?? this.name,
      nickName: nickName ?? this.nickName,
      nameStatus: nameStatus ?? this.nameStatus,
      nickNameStatus: nickNameStatus ?? this.nickNameStatus,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }

  /// props MUST be defined as a non-nullable object list to avoid breaking tests
  @override
  List<Object> get props => [
        name,
        nickName,
        nameStatus,
        nickNameStatus,
        submissionStatus,
      ];
}
