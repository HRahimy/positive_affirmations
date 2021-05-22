import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/account_setup/blocs/sign_up/sign_up_bloc.dart';
import 'package:mobile_app/account_setup/models/models.dart';
import 'package:mocktail/mocktail.dart';

class FakeSignUpEvent extends Fake implements SignUpEvent {}

class FakeSignUpState extends Fake implements SignUpState {}

class MockSignUpBloc extends MockBloc<SignUpEvent, SignUpState>
    implements SignUpBloc {}

class MockNameField extends Mock implements NameField {}

void main() {
  group('[AppSummaryScreen]', () {
    // late SignUpBloc signUpBloc;

    setUpAll(() {
      registerFallbackValue<SignUpEvent>(FakeSignUpEvent());
      registerFallbackValue<SignUpState>(FakeSignUpState());
    });

    setUp(() {
      // signUpBloc = MockSignUpBloc();
    });
  });
}