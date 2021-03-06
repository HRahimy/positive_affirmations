import 'package:app/affirmations/blocs/affirmations/affirmations_bloc.dart';
import 'package:app/app_account/blocs/authentication/authentication_bloc.dart';
import 'package:app/positive_affirmations_keys.dart';
import 'package:app/profile/blocs/profile/profile_bloc.dart';
import 'package:app/profile/blocs/profile_tab/profile_tab_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repository/repository.dart';

import '../../mocks/affirmations_bloc_mock.dart';
import '../../mocks/authentication_bloc_mock.dart';
import '../../mocks/profile_bloc_mock.dart';
import '../../mocks/profile_tab_bloc_mock.dart';
import '../fixtures/profile_details_body_fixture.dart';

void main() {
  final mockUser = PositiveAffirmationsRepositoryConsts.seedUser;
  final mockUserWithPicture =
      PositiveAffirmationsRepositoryConsts.seedUserWithPicture;
  final mockAffirmations =
      PositiveAffirmationsRepositoryConsts.seedAffirmations;
  // final mockAffirmations = PositiveAffirmationsRepositoryConsts.seedAffirmations;

  late AffirmationsBloc affirmationsBloc;
  late AuthenticationBloc authBloc;
  late ProfileTabBloc profileTabBloc;
  late ProfileBloc profileBloc;

  group('[ProfileDetailsBody]', () {
    setUpAll(() {
      registerFallbackValue<AffirmationsState>(FakeAffirmationsState());
      registerFallbackValue<AffirmationsEvent>(FakeAffirmationsEvent());
      registerFallbackValue<AuthenticationState>(FakeAuthenticationState());
      registerFallbackValue<AuthenticationEvent>(FakeAuthenticationEvent());
      registerFallbackValue<ProfileTabEvent>(FakeProfileTabEvent());
      registerFallbackValue<ProfileEvent>(FakeProfileEvent());
      registerFallbackValue<ProfileState>(FakeProfileState());
      registerFallbackValue<ProfileTab>(ProfileTab.affirmations);
    });

    setUp(() {
      affirmationsBloc = MockAffirmationsBloc();
      authBloc = MockAuthenticationBloc();
      profileTabBloc = MockProfileTabBloc();
      profileBloc = MockProfileBloc();
    });

    group('[PictureAvatar]', () {
      testWidgets('initials are rendered as label when no picture',
          (tester) async {
        when(() => authBloc.state)
            .thenReturn(const AuthenticationState.authenticated());
        when(() => affirmationsBloc.authenticatedUser).thenReturn(mockUser);
        when(() => affirmationsBloc.state).thenReturn(AffirmationsState(
            affirmations:
                PositiveAffirmationsRepositoryConsts.seedAffirmations));
        when(() => profileBloc.state).thenReturn(ProfileState(user: mockUser));

        await tester.pumpWidget(ProfileDetailsBodyFixture(
          affirmationsBloc: affirmationsBloc,
          authBloc: authBloc,
          profileBloc: profileBloc,
        ));

        expect(
          find.byKey(
              PositiveAffirmationsKeys.profilePictureEmptyLabel(mockUser.id)),
          findsOneWidget,
        );
        expect(
          find.byKey(PositiveAffirmationsKeys.profilePictureImage(mockUser.id)),
          findsNothing,
        );
      });
      testWidgets('initials are rendered as label when there is a picture',
          (tester) async {
        when(() => authBloc.state)
            .thenReturn(const AuthenticationState.authenticated());
        when(() => affirmationsBloc.authenticatedUser)
            .thenReturn(mockUserWithPicture);
        when(() => affirmationsBloc.state).thenReturn(AffirmationsState(
            affirmations:
                PositiveAffirmationsRepositoryConsts.seedAffirmations));
        when(() => profileBloc.state)
            .thenReturn(ProfileState(user: mockUserWithPicture));

        await tester.pumpWidget(ProfileDetailsBodyFixture(
          affirmationsBloc: affirmationsBloc,
          authBloc: authBloc,
          profileBloc: profileBloc,
        ));

        expect(
          find.byKey(PositiveAffirmationsKeys.profilePictureEmptyLabel(
              mockUserWithPicture.id)),
          findsNothing,
        );
        expect(
          find.byKey(PositiveAffirmationsKeys.profilePictureImage(
              mockUserWithPicture.id)),
          findsOneWidget,
        );
      });
    });

    group('all widgets are composed', () {
      setUp(() {
        when(() => authBloc.state)
            .thenReturn(const AuthenticationState.authenticated());

        when(() => affirmationsBloc.authenticatedUser).thenReturn(mockUser);
        when(() => affirmationsBloc.state)
            .thenReturn(AffirmationsState(affirmations: mockAffirmations));
      });

      testWidgets('base widgets are composed', (tester) async {
        when(() => profileBloc.state).thenReturn(ProfileState(user: mockUser));
        await tester.pumpWidget(ProfileDetailsBodyFixture(
          affirmationsBloc: affirmationsBloc,
          authBloc: authBloc,
          profileBloc: profileBloc,
        ));

        expect(
          find.byKey(PositiveAffirmationsKeys.profilePicture(mockUser.id)),
          findsOneWidget,
        );
        expect(
          find.byKey(PositiveAffirmationsKeys.profilePictureCameraIndicator),
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
        when(() => profileBloc.state).thenReturn(ProfileState(user: mockUser));
        await tester.pumpWidget(ProfileDetailsBodyFixture(
          affirmationsBloc: affirmationsBloc,
          authBloc: authBloc,
          profileTabBloc: profileTabBloc,
          profileBloc: profileBloc,
        ));

        expect(
          find.byKey(PositiveAffirmationsKeys.profileAffirmationsSubtabBody(
              mockUser.id)),
          findsOneWidget,
        );

        for (int i = 0; i < mockAffirmations.length; i++) {
          expect(
            find.byKey(PositiveAffirmationsKeys.profileAffirmationItem(
                '${mockAffirmations[i].id}')),
            findsOneWidget,
          );
          expect(
            find.byKey(PositiveAffirmationsKeys.profileAffirmationItemTitle(
                '${mockAffirmations[i].id}')),
            findsOneWidget,
          );
          expect(
            find.byKey(PositiveAffirmationsKeys.profileAffirmationItemTrailing(
                '${mockAffirmations[i].id}')),
            findsOneWidget,
          );
        }
      });

      testWidgets('letters tab body is rendered when letters tab is selected',
          (tester) async {
        when(() => profileTabBloc.state).thenReturn(ProfileTab.letters);
        when(() => profileBloc.state).thenReturn(ProfileState(user: mockUser));
        await tester.pumpWidget(ProfileDetailsBodyFixture(
          affirmationsBloc: affirmationsBloc,
          authBloc: authBloc,
          profileTabBloc: profileTabBloc,
          profileBloc: profileBloc,
        ));

        expect(
          find.byKey(
              PositiveAffirmationsKeys.profileLettersSubtabBody(mockUser.id)),
          findsOneWidget,
        );
      });
    });
  });
}
