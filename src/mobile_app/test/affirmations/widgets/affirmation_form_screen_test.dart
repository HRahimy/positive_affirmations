import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mobile_app/affirmations/blocs/affirmation_form/affirmation_form_bloc.dart';
import 'package:mobile_app/affirmations/blocs/affirmations/affirmations_bloc.dart';
import 'package:mobile_app/consts.dart';
import 'package:mobile_app/models/affirmation.dart';
import 'package:mobile_app/positive_affirmations_keys.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/affirmation_form_bloc_mock.dart';
import '../../mocks/affirmations_bloc_mock.dart';
import '../fixtures/affirmation_form_screen_fixture.dart';

void main() {
  late AffirmationsBloc affirmationsBloc;
  late AffirmationFormBloc affirmationFormBloc;
  final Affirmation toUpdateAffirmation =
      PositiveAffirmationsConsts.seedAffirmations[1];

  const String validTitleInput = 'valid title';
  const String invalidTitleInput = '!nv@l%dTitle';
  const String validSubtitleInput = 'valid subtitle';
  const String invalidSubtitleInput = '!nv@l%dSubtitle';

  setUpAll(() {
    registerFallbackValue<AffirmationsState>(FakeAffirmationsState());
    registerFallbackValue<AffirmationsEvent>(FakeAffirmationsEvent());
    registerFallbackValue<AffirmationFormState>(FakeAffirmationFormState());
    registerFallbackValue<AffirmationFormEvent>(FakeAffirmationFormEvent());
  });

  setUp(() {
    affirmationsBloc = MockAffirmationsBloc();
    affirmationFormBloc = MockAffirmationFormBloc();
  });

  AffirmationFormScreenFixture _buildNewForm() {
    return AffirmationFormScreenFixture(
      affirmationsBloc: affirmationsBloc,
      affirmationFormBloc: affirmationFormBloc,
    );
  }

  AffirmationFormScreenFixture _buildEditForm() {
    return AffirmationFormScreenFixture(
      affirmationsBloc: affirmationsBloc,
      affirmationFormBloc: affirmationFormBloc,
      toUpdateAffirmation: toUpdateAffirmation,
    );
  }

  group('[AffirmationFormScreen]', () {
    testWidgets('components exist for new affirmation form', (tester) async {
      await tester.pumpWidget(_buildNewForm());

      expect(find.byKey(PositiveAffirmationsKeys.affirmationFormBackButton),
          findsOneWidget);
      expect(find.byKey(PositiveAffirmationsKeys.newAffirmationFormAppbarTitle),
          findsOneWidget);
      expect(
          find.byKey(PositiveAffirmationsKeys.affirmationForm), findsOneWidget);
      expect(find.byKey(PositiveAffirmationsKeys.affirmationFormTitleField),
          findsOneWidget);
      expect(
          find.byKey(PositiveAffirmationsKeys.affirmationFormTitleFieldLabel),
          findsOneWidget);
      expect(find.byKey(PositiveAffirmationsKeys.affirmationFormSubtitleField),
          findsOneWidget);
      expect(
          find.byKey(
              PositiveAffirmationsKeys.affirmationFormSubtitleFieldLabel),
          findsOneWidget);
      expect(find.byKey(PositiveAffirmationsKeys.affirmationFormSaveButton),
          findsOneWidget);
    });

    testWidgets('components exist for edit affirmation form', (tester) async {
      await tester.pumpWidget(_buildEditForm());

      expect(find.byKey(PositiveAffirmationsKeys.affirmationFormBackButton),
          findsOneWidget);
      expect(
          find.byKey(PositiveAffirmationsKeys.editAffirmationFormAppbarTitle),
          findsOneWidget);
      expect(
          find.byKey(PositiveAffirmationsKeys.affirmationForm), findsOneWidget);
      expect(find.byKey(PositiveAffirmationsKeys.affirmationFormTitleField),
          findsOneWidget);
      expect(
          find.byKey(PositiveAffirmationsKeys.affirmationFormTitleFieldLabel),
          findsOneWidget);
      expect(find.byKey(PositiveAffirmationsKeys.affirmationFormSubtitleField),
          findsOneWidget);
      expect(
          find.byKey(
              PositiveAffirmationsKeys.affirmationFormSubtitleFieldLabel),
          findsOneWidget);
      expect(find.byKey(PositiveAffirmationsKeys.affirmationFormSaveButton),
          findsOneWidget);
      expect(
          find.byKey(PositiveAffirmationsKeys
              .affirmationFormDeactivateDeactivateButton(
                  '${toUpdateAffirmation.id}')),
          findsOneWidget);
    });

    group('Bloc Integration', () {
      testWidgets('title input triggers TitleUpdated event', (tester) async {
        await tester.pumpWidget(_buildNewForm());

        await tester.enterText(
          find.byKey(PositiveAffirmationsKeys.affirmationFormTitleField),
          validTitleInput,
        );

        verify(() => affirmationFormBloc.add(TitleUpdated(validTitleInput)))
            .called(1);
      });
      testWidgets('subtitle input triggers SubtitleTitleUpdated event',
          (tester) async {
        await tester.pumpWidget(_buildNewForm());

        await tester.enterText(
          find.byKey(PositiveAffirmationsKeys.affirmationFormSubtitleField),
          validSubtitleInput,
        );

        verify(() => affirmationFormBloc.add(TitleUpdated(validSubtitleInput)))
            .called(1);
      });
      testWidgets('submit button is disabled when form is invalid',
          (tester) async {
        when(() => affirmationFormBloc.state.status)
            .thenReturn(FormzStatus.invalid);

        await tester.pumpWidget(_buildNewForm());
        expect(
          tester
              .widget<ElevatedButton>(find
                  .byKey(PositiveAffirmationsKeys.affirmationFormSaveButton))
              .enabled,
          isFalse,
        );
      });
      testWidgets('submit button is disabled when form is pure',
          (tester) async {
        when(() => affirmationFormBloc.state.status)
            .thenReturn(FormzStatus.pure);

        await tester.pumpWidget(_buildNewForm());
        expect(
          tester
              .widget<ElevatedButton>(find
                  .byKey(PositiveAffirmationsKeys.affirmationFormSaveButton))
              .enabled,
          isFalse,
        );
      });
    });
  });
}
