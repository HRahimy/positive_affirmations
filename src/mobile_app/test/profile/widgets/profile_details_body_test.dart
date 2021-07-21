import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/affirmations/blocs/affirmations/affirmations_bloc.dart';
import 'package:mobile_app/blocs/authentication/authentication_bloc.dart';
import 'package:mobile_app/consts.dart';
import 'package:mobile_app/positive_affirmations_keys.dart';
import 'package:mobile_app/profile/blocs/profile_tab/profile_tab_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/affirmations_bloc_mock.dart';
import '../../mocks/authentication_bloc_mock.dart';
import '../../mocks/profile_tab_bloc_mock.dart';
import '../fixtures/profile_details_body_fixture.dart';

void main() {
  final mockUser = PositiveAffirmationsConsts.seedUser;
  final mockAffirmations = PositiveAffirmationsConsts.seedAffirmations;

  late AffirmationsBloc affirmationsBloc;
  late AuthenticationBloc authBloc;
  late ProfileTabBloc profileTabBloc;

  group('[ProfileDetailsBody]', () {
    setUpAll(() {
      registerFallbackValue<AffirmationsState>(FakeAffirmationsState());
      registerFallbackValue<AffirmationsEvent>(FakeAffirmationsEvent());
      registerFallbackValue<AuthenticationState>(FakeAuthenticationState());
      registerFallbackValue<AuthenticationEvent>(FakeAuthenticationEvent());
      registerFallbackValue<ProfileTabEvent>(FakeProfileTabEvent());
      registerFallbackValue<ProfileTab>(ProfileTab.affirmations);
    });

    setUp(() {
      affirmationsBloc = MockAffirmationsBloc();
      authBloc = MockAuthenticationBloc();
      profileTabBloc = MockProfileTabBloc();

      when(() => authBloc.state)
          .thenReturn(AuthenticationState.authenticated(mockUser));

      when(() => affirmationsBloc.authenticatedUser).thenReturn(mockUser);
    });

    group('all widgets are composed', () {
      testWidgets('base widgets are composed', (tester) async {
        await tester.pumpWidget(ProfileDetailsBodyFixture(
          affirmationsBloc: affirmationsBloc,
          authBloc: authBloc,
        ));

        expect(
          find.byKey(PositiveAffirmationsKeys.profilePicture(mockUser.id)),
          findsOneWidget,
        );
        expect(
          find.byKey(PositiveAffirmationsKeys.profileName(mockUser.id)),
          findsOneWidget,
        );
        expect(
          find.byKey(PositiveAffirmationsKeys.profileNickName(mockUser.id)),
          findsOneWidget,
        );
        expect(
          find.byKey(
              PositiveAffirmationsKeys.profileAffirmationsCount(mockUser.id)),
          findsOneWidget,
        );
        expect(
          find.byKey(PositiveAffirmationsKeys.profileLettersCount(mockUser.id)),
          findsOneWidget,
        );
        expect(
          find.byKey(
              PositiveAffirmationsKeys.profileReaffirmationsCount(mockUser.id)),
          findsOneWidget,
        );
        expect(
          find.byKey(
              PositiveAffirmationsKeys.profileAffirmationsSubtab(mockUser.id)),
          findsOneWidget,
        );
        expect(
          find.byKey(
              PositiveAffirmationsKeys.profileLettersSubtab(mockUser.id)),
          findsOneWidget,
        );
      });

      testWidgets(
          'affirmations tab body is rendered when affirmations tab is selected',
          (tester) async {
        when(() => profileTabBloc.state).thenReturn(ProfileTab.affirmations);
        await tester.pumpWidget(ProfileDetailsBodyFixture(
          affirmationsBloc: affirmationsBloc,
          authBloc: authBloc,
          profileTabBloc: profileTabBloc,
        ));

        expect(
          find.byKey(PositiveAffirmationsKeys.profileAffirmationsSubtabBody(
              mockUser.id)),
          findsOneWidget,
        );
      });

      testWidgets('letters tab body is rendered when letters tab is selected',
          (tester) async {
        when(() => profileTabBloc.state).thenReturn(ProfileTab.letters);
        await tester.pumpWidget(ProfileDetailsBodyFixture(
          affirmationsBloc: affirmationsBloc,
          authBloc: authBloc,
          profileTabBloc: profileTabBloc,
        ));

        expect(
          find.byKey(PositiveAffirmationsKeys.profileAffirmationsSubtabBody(
              mockUser.id)),
          findsOneWidget,
        );
      });
    });
  });
}