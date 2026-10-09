import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/features/qibla/data/qibla_math.dart';

void main() {
  group('qiblaBearing', () {
    test('Karachi', () {
      expect(qiblaBearing(24.8607, 67.0011), closeTo(267.7, 1));
    });

    test('Faisalabad', () {
      expect(qiblaBearing(31.4504, 73.1350), closeTo(259.5, 1));
    });

    test('London', () {
      expect(qiblaBearing(51.5074, -0.1278), closeTo(119.0, 1));
    });
  });

  group('angleDelta', () {
    test('wraps clockwise across north', () {
      expect(angleDelta(350, 10), closeTo(20, 0.001));
    });

    test('wraps counter-clockwise across north', () {
      expect(angleDelta(10, 350), closeTo(-20, 0.001));
    });

    test('same angle is zero', () {
      expect(angleDelta(90, 90), closeTo(0, 0.001));
    });
  });
}
