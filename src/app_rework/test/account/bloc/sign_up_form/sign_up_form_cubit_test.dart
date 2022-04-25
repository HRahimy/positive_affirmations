import 'package:api_client/api_client.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:positive_affirmations/account/bloc/sign_up_form/sign_up_form_cubit.dart';
import 'package:positive_affirmations/common/models/form_fields/form_fields.dart';
import 'package:repository/repository.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockAuthRepo extends Mock implements AuthenticationRepository {}

void main() {
  const validNameString = 'Valid Name';
  // const invalidSpecialNameString = '.@#.\$%^&*()\\/';
  const invalidNumericNameString = 'Valid1 Name2';
  const validEmailString = 'test@email.com';
  const validPasswordString = '1234567As';
  late ApiClient apiClient;
  late AuthenticationRepository authRepo;
  late SignUpFormCubit cubit;

  setUp(() {
    authRepo = MockAuthRepo();
    apiClient = MockApiClient();
    cubit = SignUpFormCubit(
      apiClient: apiClient,
      authRepo: authRepo,
    );
  });

  group('[SignUpFormCubit]', () {
    test('initial state is `SignUpFormState()`', () {
      expect(cubit.state, equals(const SignUpFormState()));
    });

    group('[UpdateName]', () {
      blocTest<SignUpFormCubit, SignUpFormState>(
        'emits updated name',
        build: () => cubit,
        act: (cubit) {
          cubit.updateName(validNameString);
        },
        expect: () => <SignUpFormState>[
          const SignUpFormState(
            name: PersonNameField.dirty(validNameString),
            status: FormzStatus.invalid,
          )
        ],
      );

      blocTest<SignUpFormCubit, SignUpFormState>(
        'given all other fields are valid and valid value is supplied, emits [valid] state',
        seed: () => const SignUpFormState(
          email: EmailField.dirty(validEmailString),
          password: PasswordField.dirty(validPasswordString),
          confirmPassword: PasswordField.dirty(validPasswordString),
          status: FormzStatus.invalid,
        ),
        build: () => cubit,
        act: (cubit) => cubit.updateName(validNameString),
        expect: () => <SignUpFormState>[
          const SignUpFormState(
            name: PersonNameField.dirty(validNameString),
            email: EmailField.dirty(validEmailString),
            password: PasswordField.dirty(validPasswordString),
            confirmPassword: PasswordField.dirty(validPasswordString),
            status: FormzStatus.valid,
          ),
        ],
      );

      blocTest<SignUpFormCubit, SignUpFormState>(
        'given all other fields are valid and invalid value is supplied, emits [invalid] state',
        seed: () => const SignUpFormState(
          email: EmailField.dirty(validEmailString),
          password: PasswordField.dirty(validPasswordString),
          confirmPassword: PasswordField.dirty(validPasswordString),
          status: FormzStatus.invalid,
        ),
        build: () => cubit,
        act: (cubit) => cubit.updateName(invalidNumericNameString),
        expect: () => <SignUpFormState>[
          const SignUpFormState(
            name: PersonNameField.dirty(invalidNumericNameString),
            email: EmailField.dirty(validEmailString),
            password: PasswordField.dirty(validPasswordString),
            confirmPassword: PasswordField.dirty(validPasswordString),
            status: FormzStatus.invalid,
          ),
        ],
      );
    });
  });
}
