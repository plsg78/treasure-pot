import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  group('vehicleForStep', () {
    test('five steps map one-to-one', () {
      expect(vehicleForStep(1, 5), '🛹');
      expect(vehicleForStep(2, 5), '🚲');
      expect(vehicleForStep(3, 5), '🚗');
      expect(vehicleForStep(4, 5), '🚙');
      expect(vehicleForStep(5, 5), '✈️');
    });

    test('twenty steps use groups of four', () {
      expect(vehicleForStep(1, 20), '🛹');
      expect(vehicleForStep(4, 20), '🛹');
      expect(vehicleForStep(5, 20), '🚲');
      expect(vehicleForStep(8, 20), '🚲');
      expect(vehicleForStep(9, 20), '🚗');
      expect(vehicleForStep(12, 20), '🚗');
      expect(vehicleForStep(13, 20), '🚙');
      expect(vehicleForStep(16, 20), '🚙');
      expect(vehicleForStep(17, 20), '✈️');
      expect(vehicleForStep(20, 20), '✈️');
    });
  });
}
