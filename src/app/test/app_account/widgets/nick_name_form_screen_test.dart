import 'package:app/app_account/blocs/sign_up/sign_up_bloc.dart';
import 'package:app/models/models.dart';
import 'package:app/models/name_field.dart';
import 'package:app/positive_affirmations_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repository/repository.dart';

import '../../mocks/sign_up_bloc_mock.dart';
import '../../mocks/user_repository_mock.dart';
import '../fixtures/fixtures.dart';

class MockNickNameField extends Mock implements NameField {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  const mockValidName = 'validName';
  const mockValidNickName = 'validNickName';
  const mockInvalidNickName = '35.n\'fwe342-';
  const mockValidSignUpState = SignUpState(
    name: NameField.dirty(mockValidName),
    nameStatus: FormzStatus.submissionSuccess,
  );

  group('[NickNameForm]', () {
    late UserRepository userRepository;
    late SignUpBloc signUpBloc;
    // late PositiveAffirmationsNavigatorObserver navigatorObserver;

    setUpAll(() {
      registerFallbackValue<SignUpEvent>(FakeSignUpEvent());
      registerFallbackValue<SignUpState>(FakeSignUpState());
      registerFallbackValue<SignUpBloc>(MockSignUpBloc());
    });

    setUp(() {
      userRepository = MockUserRepository();
      signUpBloc = MockSignUpBloc();
      // navigatorObserver = PositiveAffirmationsNavigatorObserver();
    });

    testWidgets('components are rendered', (tester) async {
      // Setup
      when(() => signUpBloc.state).thenReturn(mockValidSignUpState);
      await tester.pumpWidget(NickNameFormFixture(
        signUpBloc,
        userRepository: userRepository,
      ));

      // Assert
      expect(
        find.byKey(PositiveAffirmationsKeys.nickNameFieldLabel),
        findsOneWidget,
      );
      expect(
        find.byKey(PositiveAffirmationsKeys.nickNameField),
        findsOneWidget,
      );
      expect(
        find.byKey(PositiveAffirmationsKeys.nickNameSubmitButton),
        findsOneWidget,
      );
      expect(
        find.byKey(PositiveAffirmationsKeys.changeNameButton),
        findsOneWidget,
      );
      expect(
        find.byKey(PositiveAffirmationsKeys.alreadyHaveAccountLabel),
        findsOneWidget,
      );
      expect(
        find.byKey(PositiveAffirmationsKeys.alreadyHaveAccountSignInButton),
        findsOneWidget,
      );
    });

    testWidgets('pure and empty nickname does not show error', (tester) async {
      when(() => signUpBloc.state).thenReturn(mockValidSignUpState.copyWith(
        nickName: const NickNameField.pure(),
        nickNameStatus: FormzStatus.pure,
      ));

      await tester.pumpWidget(NickNameFormFixture(
        signUpBloc,
        userRepository: userRepository,
      ));

      expect(
        tester
            .widget<TextField>(
                find.byKey(PositiveAffirmationsKeys.nickNameField))
            .decoration!
            .errorText,
        isNull,
      );
    });

    // TODO: Reimplement this test once new signup flow is implemented
    // testWidgets('pressing back button pops back to name form', (tester) async {
    //   // Reference https://medium.com/@harsha973/widget-testing-pushing-a-new-page-13cd6a0bb055
    //   var isNickNameFormPushed = false;
    //   var isNickNameFormPopped = false;
    //
    //   when(() => signUpBloc.state).thenReturn(const SignUpState(
    //     name: const NameField.dirty(mockValidName),
    //     nameStatus: FormzStatus.submissionSuccess,
    //   ));
    //
    //   await tester.pumpWidget(NameFormFixture(
    //     signUpBloc,
    //     userRepository: userRepository,
    //     navigatorObserver: navigatorObserver,
    //   ));
    //   navigatorObserver.attachPushRouteObserver(
    //     NickNameFormScreen.routeName,
    //     () {
    //       isNickNameFormPushed = true;
    //     },
    //   );
    //   navigatorObserver.attachPopRouteObserver(
    //     NickNameFormScreen.routeName,
    //     () {
    //       isNickNameFormPopped = true;
    //     },
    //   );
    //
    //   await tester.enterText(
    //     find.byKey(PositiveAffirmationsKeys.nameField),
    //     mockValidName,
    //   );
    //
    //   await tester.tap(find.byKey(PositiveAffirmationsKeys.nameSubmitButton));
    //
    //   await tester.pumpAndSettle();
    //
    //   expect(isNickNameFormPushed, true);
    //
    //   await tester.tap(find.byKey(PositiveAffirmationsKeys.changeNameButton));
    //
    //   await tester.pumpAndSettle();
    //
    //   expect(isNickNameFormPopped, true);
    // });

    group('[FormWiredToBloc]', () {
      testWidgets('entering nickname updates state', (tester) async {
        /// Setup
        when(() => signUpBloc.state).thenReturn(mockValidSignUpState);
        await tester.pumpWidget(NickNameFormFixture(
          signUpBloc,
          userRepository: userRepository,
        ));

        /// Act
        await tester.enterText(
          find.byKey(PositiveAffirmationsKeys.nickNameField),
          mockValidNickName,
        );

        /// Assert
        verify(() => signUpBloc.add(const NickNameUpdated(mockValidNickName)))
            .called(1);
      });

      testWidgets('error shows when nickname field is invalid', (tester) async {
        when(() => signUpBloc.state).thenReturn(mockValidSignUpState.copyWith(
          nickName: const NickNameField.dirty(mockInvalidNickName),
          nickNameStatus: FormzStatus.invalid,
        ));

        await tester.pumpWidget(NickNameFormFixture(
          signUpBloc,
          userRepository: userRepository,
        ));

        expect(
          tester
              .widget<TextField>(
                  find.byKey(PositiveAffirmationsKeys.nickNameField))
              .decoration!
              .errorText,
          isA<String>(),
        );
      });

      testWidgets('valid label text is rendered', (tester) async {
        when(() => signUpBloc.state).thenReturn(mockValidSignUpState);

        await tester.pumpWidget(NickNameFormFixture(
          signUpBloc,
          userRepository: userRepository,
        ));

        // Reference https://stackoverflow.com/a/41153547/5472560
        expect(
          find.byWidgetPredicate((widget) =>
              widget is RichText &&
              widget.key == PositiveAffirmationsKeys.nickNameFieldLabel &&
              widget.text.toPlainText() ==
                  'Nice to meet you $mockValidName\nOne more question.\nWhat would you like me to call you? ????'),
          findsOneWidget,
        );
      });

      testWidgets('submit button is disabled when form is errored',
          (tester) async {
        when(() => signUpBloc.state).thenReturn(mockValidSignUpState.copyWith(
            nickName: const NickNameField.dirty(mockInvalidNickName),
            nickNameStatus: FormzStatus.invalid));

        await tester.pumpWidget(NickNameFormFixture(
          signUpBloc,
          userRepository: userRepository,
        ));

        expect(
          tester
              .widget<ElevatedButton>(
                  find.byKey(PositiveAffirmationsKeys.nickNameSubmitButton))
              .enabled,
          isFalse,
        );
      });

      testWidgets('submit button is enabled when form is pure', (tester) async {
        when(() => signUpBloc.state).thenReturn(mockValidSignUpState.copyWith(
          nickName: const NickNameField.pure(),
          nickNameStatus: FormzStatus.pure,
        ));

        await tester.pumpWidget(NickNameFormFixture(
          signUpBloc,
          userRepository: userRepository,
        ));

        expect(
          tester
              .widget<ElevatedButton>(
                  find.byKey(PositiveAffirmationsKeys.nickNameSubmitButton))
              .enabled,
          isTrue,
        );
      });

      testWidgets('submit button is enabled when form is valid',
          (tester) async {
        when(() => signUpBloc.state).thenReturn(mockValidSignUpState.copyWith(
          // nickName: const NickNameField.dirty(mockValidNickName),
          nickNameStatus: FormzStatus.valid,
        ));

        await tester.pumpWidget(NickNameFormFixture(
          signUpBloc,
          userRepository: userRepository,
        ));

        expect(
          tester
              .widget<ElevatedButton>(
                  find.byKey(PositiveAffirmationsKeys.nickNameSubmitButton))
              .enabled,
          isTrue,
        );
      });

      testWidgets('tapping submit button is enabled when form is valid',
          (tester) async {
        when(() => signUpBloc.state).thenReturn(mockValidSignUpState.copyWith(
          // nickName: const NickNameField.dirty(mockValidNickName),
          nickNameStatus: FormzStatus.valid,
        ));

        await tester.pumpWidget(NickNameFormFixture(
          signUpBloc,
          userRepository: userRepository,
        ));

        await tester
            .tap(find.byKey(PositiveAffirmationsKeys.nickNameSubmitButton));

        verify(() => signUpBloc.add(const NickNameSubmitted())).called(1);
      });
    });
  });
}
