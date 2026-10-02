import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/features/tracking/providers/prayer_log_provider.dart';
import 'package:waqt/features/tracking/providers/streak_provider.dart';

Set<String> _fullDay(DateTime day) => {
  for (final prayer in dailyPrayers) logKey(day, prayer),
};

void main() {
  final today = DateTime(2026, 10, 3);

  group('currentStreak', () {
    test('counts consecutive full days including today', () {
      final log = {
        ..._fullDay(DateTime(2026, 10, 3)),
        ..._fullDay(DateTime(2026, 10, 2)),
        ..._fullDay(DateTime(2026, 10, 1)),
      };
      expect(currentStreak(log, today), 3);
    });

    test('incomplete today does not break the streak', () {
      final log = {
        logKey(today, 'Fajr'),
        ..._fullDay(DateTime(2026, 10, 2)),
        ..._fullDay(DateTime(2026, 10, 1)),
      };
      expect(currentStreak(log, today), 2);
    });

    test('a missed day ends the streak', () {
      final log = {
        ..._fullDay(DateTime(2026, 10, 3)),
        ..._fullDay(DateTime(2026, 10, 1)),
      };
      expect(currentStreak(log, today), 1);
    });

    test('empty log is zero', () {
      expect(currentStreak(<String>{}, today), 0);
    });
  });
}
