import 'package:flutter_test/flutter_test.dart';
import 'package:treasure_pot/main.dart';

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

  group('progressPercent', () {
    test('returns a percentage between 0 and 100', () {
      expect(progressPercent(0, 20), 0);
      expect(progressPercent(10, 20), 50);
      expect(progressPercent(20, 20), 100);
      expect(progressPercent(25, 20), 100);
    });
  });
}
