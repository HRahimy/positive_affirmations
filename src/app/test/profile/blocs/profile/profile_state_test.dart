import 'package:flutter_test/flutter_test.dart';
import 'package:app/profile/blocs/profile/profile_bloc.dart';

void main() {
  group('[ProfileState]', () {
    test('supports value comparisons', () {
      expect(ProfileState(), ProfileState());
    });
  });
}
