import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:app/affirmations/blocs/affirmation_form/affirmation_form_bloc.dart';
import 'package:app/affirmations/blocs/affirmations/affirmations_bloc.dart';
import 'package:app/affirmations/models/subtitle_field.dart';
import 'package:app/affirmations/models/title_field.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repository/repository.dart';

import '../../../mocks/affirmations_bloc_mock.dart';

/// 7. submit event emits new state only if form is valid

void main() {
  const String mockValidTitle = 'valid title';
  const String mockInvalidTitle = 'fwef47*';
  const String mockValidSubtitle = 'valid subtitle';
  const String mockInvalidSubtitle = 'invalid-subtitle**';

  late AffirmationsBloc affirmationsBloc;
  late AffirmationFormBloc formBloc;
  late AffirmationFormBloc initializedBloc;
  // late AffirmationFormBloc subtitleInitFormBloc;

  final toUpdateAffirmation =
      PositiveAffirmationsRepositoryConsts.seedAffirmations[1];

  setUpAll(() {
    registerFallbackValue<AffirmationsState>(FakeAffirmationsState());
    registerFallbackValue<AffirmationsEvent>(FakeAffirmationsEvent());
  });

  setUp(() {
    affirmationsBloc = MockAffirmationsBloc();
    formBloc = AffirmationFormBloc(affirmationsBloc: affirmationsBloc);
    initializedBloc = AffirmationFormBloc(
      affirmationsBloc: affirmationsBloc,
      toUpdateAffirmation: toUpdateAffirmation,
    );
  });

  group('[AffirmationFormBloc]', () {
    test('initial state is AffirmationFormState', () {
      expect(formBloc.state, AffirmationFormState());
    });
    test('initial state supplied dirty title', () {
      expect(
        initializedBloc.state,
        AffirmationFormState(
          title: TitleField.dirty(toUpdateAffirmation.title),
          subtitle: SubtitleField.dirty(toUpdateAffirmation.subtitle),
        ),
      );
    });

    group('[TitleUpdated]', () {
      blocTest<AffirmationFormBloc, AffirmationFormState>(
        'supplying valid title emits valid status',
        build: () => formBloc,
        act: (bloc) {
          bloc..add(TitleUpdated(mockValidTitle));
        },
        expect: () => <AffirmationFormState>[
          const AffirmationFormState(
            title: TitleField.dirty(mockValidTitle),
            status: FormzStatus.valid,
          ),
        ],
      );
      blocTest<AffirmationFormBloc, AffirmationFormState>(
        'supplying invalid title emits invalid status',
        build: () => formBloc,
        act: (bloc) {
          bloc..add(TitleUpdated(mockInvalidTitle));
        },
        expect: () => <AffirmationFormState>[
          const AffirmationFormState(
            title: TitleField.dirty(mockInvalidTitle),
            status: FormzStatus.invalid,
          ),
        ],
      );
    });

    group('[SubtitleUpdated]', () {
      blocTest<AffirmationFormBloc, AffirmationFormState>(
        'supplying valid subtitle emits valid status',
        build: () => formBloc,
        act: (bloc) {
          bloc..add(SubtitleUpdated(mockValidSubtitle));
        },
        seed: () => AffirmationFormState(
          title: TitleField.dirty(mockValidTitle),
          status: FormzStatus.valid,
        ),
        expect: () => <AffirmationFormState>[
          const AffirmationFormState(
            title: TitleField.dirty(mockValidTitle),
            subtitle: SubtitleField.dirty(mockValidSubtitle),
            status: FormzStatus.valid,
          ),
        ],
      );
      blocTest<AffirmationFormBloc, AffirmationFormState>(
        'supplying invalid subtitle emits invalid status',
        build: () => formBloc,
        act: (bloc) {
          bloc..add(SubtitleUpdated(mockInvalidSubtitle));
        },
        seed: () => AffirmationFormState(
          title: TitleField.dirty(mockValidTitle),
          status: FormzStatus.valid,
        ),
        expect: () => <AffirmationFormState>[
          const AffirmationFormState(
            title: TitleField.dirty(mockValidTitle),
            subtitle: SubtitleField.dirty(mockInvalidSubtitle),
            status: FormzStatus.invalid,
          ),
        ],
      );
    });

    group('[AffirmationSubmitted]', () {
      blocTest<AffirmationFormBloc, AffirmationFormState>(
          'affirmation is not created if form state is invalid',
          build: () => formBloc,
          seed: () => AffirmationFormState(
                title: TitleField.dirty(mockInvalidTitle),
                subtitle: SubtitleField.dirty(mockInvalidSubtitle),
                status: FormzStatus.invalid,
              ),
          act: (bloc) {
            bloc..add(AffirmationSubmitted());
          },
          verify: (_) {
            verifyNever(() => affirmationsBloc.add(
                AffirmationCreated(mockInvalidTitle, mockInvalidSubtitle)));
          });
      blocTest<AffirmationFormBloc, AffirmationFormState>(
          'affirmation is only created if form state is valid',
          build: () => formBloc,
          seed: () => AffirmationFormState(
                title: TitleField.dirty(mockValidTitle),
                subtitle: SubtitleField.dirty(mockValidSubtitle),
                status: FormzStatus.valid,
              ),
          act: (bloc) {
            bloc..add(AffirmationSubmitted());
          },
          expect: () => <AffirmationFormState>[
                AffirmationFormState(
                  title: TitleField.dirty(mockValidTitle),
                  subtitle: SubtitleField.dirty(mockValidSubtitle),
                  status: FormzStatus.submissionInProgress,
                ),
                AffirmationFormState(
                  title: TitleField.dirty(mockValidTitle),
                  subtitle: SubtitleField.dirty(mockValidSubtitle),
                  status: FormzStatus.submissionSuccess,
                ),
              ],
          verify: (_) {
            verify(() => affirmationsBloc
                    .add(AffirmationCreated(mockValidTitle, mockValidSubtitle)))
                .called(1);
          });
      blocTest<AffirmationFormBloc, AffirmationFormState>(
          'affirmation update event is triggered if toUpdateAffirmation was initialized in the bloc',
          build: () => initializedBloc,
          seed: () => AffirmationFormState(
                title: TitleField.dirty(toUpdateAffirmation.title),
                subtitle: SubtitleField.dirty(mockValidSubtitle),
                status: FormzStatus.valid,
              ),
          act: (bloc) {
            bloc..add(AffirmationSubmitted());
          },
          expect: () => <AffirmationFormState>[
                AffirmationFormState(
                  title: TitleField.dirty(toUpdateAffirmation.title),
                  subtitle: SubtitleField.dirty(mockValidSubtitle),
                  status: FormzStatus.submissionInProgress,
                ),
                AffirmationFormState(
                  title: TitleField.dirty(toUpdateAffirmation.title),
                  subtitle: SubtitleField.dirty(mockValidSubtitle),
                  status: FormzStatus.submissionSuccess,
                ),
              ],
          verify: (_) {
            verify(() => affirmationsBloc.add(AffirmationUpdated(
                toUpdateAffirmation.id,
                toUpdateAffirmation.title,
                mockValidSubtitle))).called(1);
          });
    });
  });
}
