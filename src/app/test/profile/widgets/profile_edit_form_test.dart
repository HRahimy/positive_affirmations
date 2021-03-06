import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:app/consts.dart';
import 'package:app/models/models.dart';
import 'package:app/positive_affirmations_keys.dart';
import 'package:app/profile/blocs/profile/profile_bloc.dart';
import 'package:app/profile/blocs/profile_edit/profile_edit_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repository/repository.dart';

import '../../mocks/profile_bloc_mock.dart';
import '../../mocks/profile_edit_bloc_mock.dart';
import '../fixtures/profile_edit_form_fixture.dart';

void main() {
  late ProfileEditBloc profileEditBloc;
  late ProfileBloc profileBloc;

  const mockUser = PositiveAffirmationsRepositoryConsts.seedUser;

  const validName = 'mockName';
  const invalidName = 'mock-name.invalid';
  const validNickName = 'mockNickName';
  const invalidNickName = 'mock-invalid.nickname';

  group('[ProfileEditForm]', () {
    group('widget composition', () {
      setUpAll(() {
        registerFallbackValue<ProfileEditEvent>(FakeProfileEditEvent());
        registerFallbackValue<ProfileEditState>(FakeProfileEditState());
        registerFallbackValue<ProfileEvent>(FakeProfileEvent());
        registerFallbackValue<ProfileState>(FakeProfileState());
      });

      setUp(() {
        profileBloc = MockProfileBloc();
        when(() => profileBloc.state).thenReturn(ProfileState(user: mockUser));
        profileEditBloc = MockProfileEditBloc();
        when(() => profileEditBloc.profileBloc).thenReturn(profileBloc);
        when(() => profileEditBloc.state).thenReturn(ProfileEditState(
          name: NameField.dirty(mockUser.name),
          nickName: NickNameField.dirty(mockUser.nickName),
          status: FormzStatus.pure,
        ));
      });

      testWidgets('all components are composed', (tester) async {
        await tester.pumpWidget(ProfileEditFormFixture(
          profileBloc: profileBloc,
          profileEditBloc: profileEditBloc,
        ));

        expect(
          find.byKey(PositiveAffirmationsKeys.profileEditScreen),
          findsOneWidget,
        );
        expect(
          find.byKey(PositiveAffirmationsKeys.profileEditScreenTitle),
          findsOneWidget,
        );
        expect(
          find.byKey(PositiveAffirmationsKeys.profileEditForm(mockUser.id)),
          findsOneWidget,
        );

        // Reference https://stackoverflow.com/a/41153547/5472560
        expect(
          find.byWidgetPredicate((widget) =>
              widget is Text &&
              widget.key ==
                  PositiveAffirmationsKeys.profileEditNameFieldLabel &&
              widget.data ==
                  PositiveAffirmationsConsts.profileEditNameFieldLabel),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate((widget) =>
              widget is TextField &&
              widget.key ==
                  PositiveAffirmationsKeys.profileEditNameField(mockUser.id) &&
              widget.controller!.value.text == mockUser.name),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate((widget) =>
              widget is Text &&
              widget.key ==
                  PositiveAffirmationsKeys.profileEditNickNameFieldLabel &&
              widget.data ==
                  PositiveAffirmationsConsts.profileEditNickNameFieldLabel),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate((widget) =>
              widget is TextField &&
              widget.key ==
                  PositiveAffirmationsKeys.profileEditNickNameField(
                      mockUser.id) &&
              widget.controller!.value.text == mockUser.nickName),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is ElevatedButton &&
                widget.key ==
                    PositiveAffirmationsKeys.profileEditSaveButton(mockUser.id),
          ),
          findsOneWidget,
        );
      });
    });

    group('[form wired to bloc]', () {
      setUpAll(() {
        registerFallbackValue<ProfileEditEvent>(FakeProfileEditEvent());
        registerFallbackValue<ProfileEditState>(FakeProfileEditState());
        registerFallbackValue<ProfileEvent>(FakeProfileEvent());
        registerFallbackValue<ProfileState>(FakeProfileState());
      });

      setUp(() {
        profileBloc = MockProfileBloc();
        when(() => profileBloc.state).thenReturn(ProfileState(user: mockUser));
        profileEditBloc = MockProfileEditBloc();
        when(() => profileEditBloc.profileBloc).thenReturn(profileBloc);
      });

      testWidgets('updating name and nickname triggers state events',
          (tester) async {
        when(() => profileEditBloc.state).thenReturn(ProfileEditState(
          name: NameField.dirty(mockUser.name),
          nickName: NickNameField.dirty(mockUser.nickName),
          status: FormzStatus.pure,
        ));

        await tester.pumpWidget(ProfileEditFormFixture(
          profileBloc: profileBloc,
          profileEditBloc: profileEditBloc,
        ));

        await tester.enterText(
          find.byKey(
              PositiveAffirmationsKeys.profileEditNameField(mockUser.id)),
          validName,
        );

        verify(() => profileEditBloc.add(NameUpdated(validName))).called(1);

        await tester.enterText(
          find.byKey(
              PositiveAffirmationsKeys.profileEditNickNameField(mockUser.id)),
          validNickName,
        );

        verify(() => profileEditBloc.add(NickNameUpdated(validNickName)))
            .called(1);
      });

      testWidgets('invalid name shows error', (tester) async {
        when(() => profileEditBloc.state).thenReturn(ProfileEditState(
          name: NameField.dirty(invalidName),
          nickName: NickNameField.dirty(mockUser.nickName),
          status: FormzStatus.invalid,
        ));

        await tester.pumpWidget(ProfileEditFormFixture(
          profileBloc: profileBloc,
          profileEditBloc: profileEditBloc,
        ));

        expect(
          tester
              .widget<TextField>(find.byKey(
                  PositiveAffirmationsKeys.profileEditNameField(mockUser.id)))
              .decoration!
              .errorText,
          PositiveAffirmationsConsts.nameFieldInvalidError,
        );
      });

      testWidgets('empty name shows error', (tester) async {
        when(() => profileEditBloc.state).thenReturn(ProfileEditState(
          name: NameField.dirty(''),
          nickName: NickNameField.dirty(mockUser.nickName),
          status: FormzStatus.invalid,
        ));

        await tester.pumpWidget(ProfileEditFormFixture(
          profileBloc: profileBloc,
          profileEditBloc: profileEditBloc,
        ));

        expect(
          tester
              .widget<TextField>(find.byKey(
                  PositiveAffirmationsKeys.profileEditNameField(mockUser.id)))
              .decoration!
              .errorText,
          PositiveAffirmationsConsts.nameFieldEmptyError,
        );
      });

      testWidgets('invalid nickname shows error', (tester) async {
        when(() => profileEditBloc.state).thenReturn(ProfileEditState(
          name: NameField.dirty(mockUser.name),
          nickName: NickNameField.dirty(invalidNickName),
          status: FormzStatus.invalid,
        ));

        await tester.pumpWidget(ProfileEditFormFixture(
          profileBloc: profileBloc,
          profileEditBloc: profileEditBloc,
        ));

        expect(
          tester
              .widget<TextField>(find.byKey(
                  PositiveAffirmationsKeys.profileEditNickNameField(
                      mockUser.id)))
              .decoration!
              .errorText,
          PositiveAffirmationsConsts.nickNameFieldInvalidError,
        );
      });

      testWidgets('save button is disabled when form is pure', (tester) async {
        when(() => profileEditBloc.state).thenReturn(ProfileEditState(
          name: NameField.dirty(mockUser.name),
          nickName: NickNameField.dirty(mockUser.nickName),
          status: FormzStatus.pure,
        ));

        await tester.pumpWidget(ProfileEditFormFixture(
          profileBloc: profileBloc,
          profileEditBloc: profileEditBloc,
        ));

        expect(
          tester
              .widget<ElevatedButton>(find.byKey(
                  PositiveAffirmationsKeys.profileEditSaveButton(mockUser.id)))
              .enabled,
          isFalse,
        );
      });
      testWidgets('save button is disabled when form is invalid',
          (tester) async {
        when(() => profileEditBloc.state).thenReturn(ProfileEditState(
          name: NameField.dirty(invalidNickName),
          nickName: NickNameField.dirty(mockUser.nickName),
          status: FormzStatus.invalid,
        ));

        await tester.pumpWidget(ProfileEditFormFixture(
          profileBloc: profileBloc,
          profileEditBloc: profileEditBloc,
        ));

        expect(
          tester
              .widget<ElevatedButton>(find.byKey(
                  PositiveAffirmationsKeys.profileEditSaveButton(mockUser.id)))
              .enabled,
          isFalse,
        );
      });
      testWidgets('save button works when form is valid', (tester) async {
        when(() => profileEditBloc.state).thenReturn(ProfileEditState(
          name: NameField.dirty(mockUser.nickName + ' edited'),
          nickName: NickNameField.dirty(mockUser.nickName),
          status: FormzStatus.valid,
        ));

        await tester.pumpWidget(ProfileEditFormFixture(
          profileBloc: profileBloc,
          profileEditBloc: profileEditBloc,
        ));

        expect(
          tester
              .widget<ElevatedButton>(find.byKey(
                  PositiveAffirmationsKeys.profileEditSaveButton(mockUser.id)))
              .enabled,
          true,
        );

        await tester.tap(find.byKey(
            PositiveAffirmationsKeys.profileEditSaveButton(mockUser.id)));

        verify(() => profileEditBloc.add(ProfileEditSubmitted())).called(1);
      });
    });
  });
}
