import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:mobile_app/reaffirmation/bloc/reaffirmation_bloc.dart';
import 'package:mobile_app/reaffirmation/models/reaffirmation_font_field.dart';
import 'package:mobile_app/reaffirmation/models/reaffirmation_graphic_field.dart';
import 'package:mobile_app/reaffirmation/models/reaffirmation_value_field.dart';
import 'package:repository/repository.dart';

void main() {
  late ReaffirmationBloc reaffirmationBloc;

  setUp(() {
    reaffirmationBloc = ReaffirmationBloc();
  });

  group('[ReaffirmationBloc]', () {
    group('[ValueSelected]', () {
      blocTest<ReaffirmationBloc, ReaffirmationState>(
        'emits updated value when new value submitted',
        build: () => reaffirmationBloc,
        act: (bloc) {
          bloc
            ..add(new ValueSelected(value: ReaffirmationValue.goodWork))
            ..add(new ValueSelected(value: ReaffirmationValue.goodWork))
            ..add(new ValueSelected(value: ReaffirmationValue.braveOn));
        },
        expect: () => <ReaffirmationState>[
          ReaffirmationState(
            value: ReaffirmationValueField.dirty(ReaffirmationValue.goodWork),
            submissionStatus: FormzStatus.invalid,
          ),
          ReaffirmationState(
            value: ReaffirmationValueField.dirty(ReaffirmationValue.empty),
            submissionStatus: FormzStatus.invalid,
          ),
          ReaffirmationState(
            value: ReaffirmationValueField.dirty(ReaffirmationValue.braveOn),
            submissionStatus: FormzStatus.invalid,
          )
        ],
      );
    });
    group('[FontSelected]', () {
      blocTest<ReaffirmationBloc, ReaffirmationState>(
        'emits updated font when new font submitted',
        build: () => reaffirmationBloc,
        act: (bloc) {
          bloc
            ..add(new FontSelected(font: ReaffirmationFont.bonheurRoyale))
            ..add(new FontSelected(font: ReaffirmationFont.birthstone));
        },
        expect: () => <ReaffirmationState>[
          ReaffirmationState(
            font: ReaffirmationFontField.dirty(ReaffirmationFont.bonheurRoyale),
            submissionStatus: FormzStatus.invalid,
          ),
          ReaffirmationState(
            font: ReaffirmationFontField.dirty(ReaffirmationFont.birthstone),
            submissionStatus: FormzStatus.invalid,
          )
        ],
      );
      blocTest<ReaffirmationBloc, ReaffirmationState>(
        'emits [none] font when same font submitted',
        build: () => reaffirmationBloc,
        act: (bloc) {
          bloc
            ..add(new FontSelected(font: ReaffirmationFont.bonheurRoyale))
            ..add(new FontSelected(font: ReaffirmationFont.bonheurRoyale));
        },
        expect: () => <ReaffirmationState>[
          ReaffirmationState(
            font: ReaffirmationFontField.dirty(ReaffirmationFont.bonheurRoyale),
            submissionStatus: FormzStatus.invalid,
          ),
          ReaffirmationState(
            font: ReaffirmationFontField.dirty(ReaffirmationFont.none),
            submissionStatus: FormzStatus.invalid,
          )
        ],
      );
    });
    group('[StampSelected]', () {
      blocTest<ReaffirmationBloc, ReaffirmationState>(
        'emits updated stamp when new stamp submitted',
        build: () => reaffirmationBloc,
        act: (bloc) {
          bloc
            ..add(new StampSelected(stamp: ReaffirmationStamp.medal))
            ..add(new StampSelected(stamp: ReaffirmationStamp.medal))
            ..add(new StampSelected(stamp: ReaffirmationStamp.takeOff));
        },
        expect: () => <ReaffirmationState>[
          ReaffirmationState(
            stamp: ReaffirmationStampField.dirty(ReaffirmationStamp.medal),
            submissionStatus: FormzStatus.invalid,
          ),
          ReaffirmationState(
            stamp: ReaffirmationStampField.dirty(ReaffirmationStamp.empty),
            submissionStatus: FormzStatus.invalid,
          ),
          ReaffirmationState(
            stamp: ReaffirmationStampField.dirty(ReaffirmationStamp.takeOff),
            submissionStatus: FormzStatus.invalid,
          )
        ],
      );
    });
    group('[Validation]', () {
      blocTest<ReaffirmationBloc, ReaffirmationState>(
        'submission status is invalid if only value is selected',
        build: () => reaffirmationBloc,
        act: (bloc) {
          bloc..add(new ValueSelected(value: ReaffirmationValue.goodWork));
        },
        expect: () => <ReaffirmationState>[
          ReaffirmationState(
            value: ReaffirmationValueField.dirty(ReaffirmationValue.goodWork),
            submissionStatus: FormzStatus.invalid,
          )
        ],
      );
      blocTest<ReaffirmationBloc, ReaffirmationState>(
        'submission status is invalid if only font is selected',
        build: () => reaffirmationBloc,
        act: (bloc) {
          bloc..add(new FontSelected(font: ReaffirmationFont.bonheurRoyale));
        },
        expect: () => <ReaffirmationState>[
          ReaffirmationState(
            font: ReaffirmationFontField.dirty(ReaffirmationFont.bonheurRoyale),
            submissionStatus: FormzStatus.invalid,
          )
        ],
      );
      blocTest<ReaffirmationBloc, ReaffirmationState>(
        'submission status is invalid if only stamp is selected',
        build: () => reaffirmationBloc,
        act: (bloc) {
          bloc..add(new StampSelected(stamp: ReaffirmationStamp.medal));
        },
        expect: () => <ReaffirmationState>[
          ReaffirmationState(
            stamp: ReaffirmationStampField.dirty(ReaffirmationStamp.medal),
            submissionStatus: FormzStatus.invalid,
          )
        ],
      );
      blocTest<ReaffirmationBloc, ReaffirmationState>(
        'submission status is valid if stamp, font, and value are selected',
        build: () => reaffirmationBloc,
        act: (bloc) {
          bloc
            ..add(new StampSelected(stamp: ReaffirmationStamp.medal))
            ..add(new FontSelected(font: ReaffirmationFont.bonheurRoyale))
            ..add(new ValueSelected(value: ReaffirmationValue.goodWork));
        },
        expect: () => <ReaffirmationState>[
          ReaffirmationState(
            stamp: ReaffirmationStampField.dirty(ReaffirmationStamp.medal),
            submissionStatus: FormzStatus.invalid,
          ),
          ReaffirmationState(
            stamp: ReaffirmationStampField.dirty(ReaffirmationStamp.medal),
            font: ReaffirmationFontField.dirty(ReaffirmationFont.bonheurRoyale),
            submissionStatus: FormzStatus.invalid,
          ),
          ReaffirmationState(
            stamp: ReaffirmationStampField.dirty(ReaffirmationStamp.medal),
            font: ReaffirmationFontField.dirty(ReaffirmationFont.bonheurRoyale),
            value: ReaffirmationValueField.dirty(ReaffirmationValue.goodWork),
            submissionStatus: FormzStatus.valid,
          )
        ],
      );
    });
  });
}
