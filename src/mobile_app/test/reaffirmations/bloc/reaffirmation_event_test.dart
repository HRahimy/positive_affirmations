import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/reaffirmation/bloc/reaffirmation_bloc.dart';
import 'package:repository/repository.dart';

void main() {
  group('[ReaffirmationEvent]', () {
    group('[ValueSelected]', () {
      test('supports value comparisons', () {
        expect(
          ValueSelected(value: ReaffirmationValue.goodWork),
          equals(ValueSelected(value: ReaffirmationValue.goodWork)),
        );
      });
    });
    group('[GraphicSelected]', () {
      test('supports value comparisons', () {
        expect(
          GraphicSelected(graphic: ReaffirmationGraphic.medal),
          equals(GraphicSelected(graphic: ReaffirmationGraphic.medal)),
        );
      });
    });
    group('[ReaffirmationSubmitted]', () {
      test('supports value comparisons', () {
        expect(
          ReaffirmationSubmitted(),
          equals(ReaffirmationSubmitted()),
        );
      });
    });
  });
}
