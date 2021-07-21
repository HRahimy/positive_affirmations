import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mobile_app/account_setup/blocs/sign_up/sign_up_bloc.dart';
import 'package:mobile_app/account_setup/models/models.dart';
import 'package:mobile_app/account_setup/widgets/app_summary_screen.dart';
import 'package:mobile_app/account_setup/widgets/nick_name_form_screen.dart';
import 'package:mobile_app/blocs/authentication/authentication_bloc.dart';
import 'package:mobile_app/nav_observer.dart';
import 'package:mobile_app/positive_affirmations_keys.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/authentication_bloc_mock.dart';
import '../fixtures/app_summary_screen_fixture.dart';
import '../fixtures/fixtures.dart';

class FakeSignUpEvent extends Fake implements SignUpEvent {}

class FakeSignUpState extends Fake implements SignUpState {}

class MockSignUpBloc extends MockBloc<SignUpEvent, SignUpState>
    implements SignUpBloc {}

class MockNameField extends Mock implements NameField {}

void main() {
  const mockValidName = 'validName';
  const mockValidNickName = 'validNickName';
  // const mockInvalidNickName = '35.n\'fwe342-';
  const mockValidSignUpState = SignUpState(
    name: const NameField.dirty(mockValidName),
    nameStatus: FormzStatus.submissionSuccess,
    nickName: const NickNameField.dirty(mockValidNickName),
    nickNameStatus: FormzStatus.submissionSuccess,
  );
  group('[AppSummaryScreen]', () {
    late SignUpBloc signUpBloc;
    late AuthenticationBloc authBloc;
    late PositiveAffirmationsNavigatorObserver navigatorObserver;

    setUpAll(() {
      registerFallbackValue<SignUpEvent>(FakeSignUpEvent());
      registerFallbackValue<SignUpState>(FakeSignUpState());
      registerFallbackValue<AuthenticationEvent>(FakeAuthenticationEvent());
      registerFallbackValue<AuthenticationState>(FakeAuthenticationState());
    });

    setUp(() {
      signUpBloc = MockSignUpBloc();
      authBloc = MockAuthenticationBloc();
      navigatorObserver = PositiveAffirmationsNavigatorObserver();
    });

    testWidgets('all components exist', (tester) async {
      when(() => authBloc.state)
          .thenReturn(const AuthenticationState.unknown());
      when(() => signUpBloc.state).thenReturn(mockValidSignUpState);
      await tester.pumpWidget(AppSummaryScreenFixture(
        signUpBloc,
        authBloc: authBloc,
      ));

      expect(
        find.byKey(PositiveAffirmationsKeys.appSummaryScreen),
        findsOneWidget,
      );
      expect(
        find.byKey(PositiveAffirmationsKeys.appSummaryHeader),
        findsOneWidget,
      );
      expect(
        find.byKey(PositiveAffirmationsKeys.appSummarySubheader),
        findsOneWidget,
      );
      expect(
        find.byKey(PositiveAffirmationsKeys.appSummaryUserNameHeader),
        findsOneWidget,
      );
      expect(
        find.byKey(PositiveAffirmationsKeys.appSummaryAnimatedBody),
        findsOneWidget,
      );
      expect(
        find.byKey(PositiveAffirmationsKeys.skipAppSummaryButton),
        findsOneWidget,
      );
      expect(
        find.byKey(PositiveAffirmationsKeys.changeNickNameButton),
        findsOneWidget,
      );
    });

    testWidgets('is routable', (tester) async {
      // Reference https://medium.com/@harsha973/widget-testing-pushing-a-new-page-13cd6a0bb055
      var isNickNameFormPushed = false;
      var isAppSummaryScreenPushed = false;

      when(() => authBloc.state)
          .thenReturn(const AuthenticationState.unknown());
      when(() => signUpBloc.state).thenReturn(const SignUpState(
        name: const NameField.dirty(mockValidName),
        nameStatus: FormzStatus.submissionSuccess,
      ));

      await tester.pumpWidget(NameFormFixture(
        signUpBloc,
        navigatorObserver: navigatorObserver,
        authBloc: authBloc,
      ));
      navigatorObserver.attachPushRouteObserver(
        NickNameFormScreen.routeName,
        () {
          isNickNameFormPushed = true;
        },
      );

      await tester.enterText(
        find.byKey(PositiveAffirmationsKeys.nameField),
        mockValidName,
      );

      await tester.tap(find.byKey(PositiveAffirmationsKeys.nameSubmitButton));

      await tester.pumpAndSettle();

      expect(isNickNameFormPushed, true);

      navigatorObserver.attachPushRouteObserver(
        AppSummaryScreen.routeName,
        () {
          isAppSummaryScreenPushed = true;
        },
      );

      await tester
          .tap(find.byKey(PositiveAffirmationsKeys.nickNameSubmitButton));

      await tester.pumpAndSettle();

      expect(isAppSummaryScreenPushed, true);
    });

    testWidgets('back button works', (tester) async {
      // Reference https://medium.com/@harsha973/widget-testing-pushing-a-new-page-13cd6a0bb055
      var isNickNameFormPushed = false;
      var isAppSummaryScreenPushed = false;
      var isAppSummaryScreenPopped = false;

      when(() => authBloc.state)
          .thenReturn(const AuthenticationState.unknown());
      when(() => signUpBloc.state).thenReturn(const SignUpState(
        name: const NameField.dirty(mockValidName),
        nameStatus: FormzStatus.submissionSuccess,
      ));

      await tester.pumpWidget(NameFormFixture(
        signUpBloc,
        navigatorObserver: navigatorObserver,
        authBloc: authBloc,
      ));
      navigatorObserver.attachPushRouteObserver(
        NickNameFormScreen.routeName,
        () {
          isNickNameFormPushed = true;
        },
      );

      await tester.enterText(
        find.byKey(PositiveAffirmationsKeys.nameField),
        mockValidName,
      );

      await tester.tap(find.byKey(PositiveAffirmationsKeys.nameSubmitButton));

      await tester.pumpAndSettle();

      expect(isNickNameFormPushed, true);

      navigatorObserver.attachPushRouteObserver(
        AppSummaryScreen.routeName,
        () {
          isAppSummaryScreenPushed = true;
        },
      );
      navigatorObserver.attachPopRouteObserver(
        AppSummaryScreen.routeName,
        () {
          isAppSummaryScreenPopped = true;
        },
      );

      await tester
          .tap(find.byKey(PositiveAffirmationsKeys.nickNameSubmitButton));

      await tester.pumpAndSettle();

      expect(isAppSummaryScreenPushed, true);

      await tester
          .tap(find.byKey(PositiveAffirmationsKeys.changeNickNameButton));

      await tester.pumpAndSettle();

      expect(isAppSummaryScreenPopped, true);
    });

    testWidgets('skipping summary screen saves user details', (tester) async {
      when(() => authBloc.state)
          .thenReturn(const AuthenticationState.unknown());
      when(() => signUpBloc.state).thenReturn(mockValidSignUpState);
      await tester.pumpWidget(AppSummaryScreenFixture(
        signUpBloc,
        authBloc: authBloc,
      ));

      await tester
          .tap(find.byKey(PositiveAffirmationsKeys.skipAppSummaryButton));
    });
  });
}
