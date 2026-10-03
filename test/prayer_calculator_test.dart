import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/features/prayer_times/data/prayer_calculator.dart';
import 'package:waqt/features/prayer_times/data/cities.dart';
import 'package:waqt/features/tracking/providers/prayer_log_provider.dart';

void main() {
  final city = City(
    name: 'Karachi',
    country: 'Pakistan',
    timezone: 'PKT',
    latitude: 24.8607,
    longitude: 67.0011,
  );
  final adjustments = <String, int>{};

  group('prayerSlots Jummah logic', () {
    test('Friday slots contain Jummah and no Dhuhr, and exactly 5 slots', () {
      final friday = DateTime(2026, 10, 2); // Friday
      final times = calculatePrayerTimes(
        city: city,
        adjustments: adjustments,
        date: friday,
      );
      final slots = prayerSlots(times);

      expect(slots.length, 5);
      expect(slots.any((s) => s.name == 'jummah'), isTrue);
      expect(slots.any((s) => s.name == 'Dhuhr'), isFalse);
    });

    test(
      'non-Friday slots contain Dhuhr and no Jummah, and exactly 5 slots',
      () {
        final saturday = DateTime(2026, 10, 3); // Saturday
        final times = calculatePrayerTimes(
          city: city,
          adjustments: adjustments,
          date: saturday,
        );
        final slots = prayerSlots(times);

        expect(slots.length, 5);
        expect(slots.any((s) => s.name == 'Dhuhr'), isTrue);
        expect(slots.any((s) => s.name == 'jummah'), isFalse);
      },
    );

    test('log key for Jummah slot is "Dhuhr"', () {
      final friday = DateTime(2026, 10, 2);
      expect(logKey(friday, 'jummah'), equals(logKey(friday, 'Dhuhr')));
    });
  });
}
