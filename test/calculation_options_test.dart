import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/features/prayer_times/data/calculation_options.dart';
import 'package:waqt/features/prayer_times/data/cities.dart';
import 'package:waqt/features/prayer_times/data/prayer_calculator.dart';

void main() {
  final date = DateTime(2026, 10, 3);
  const none = <String, int>{};

  test('Muslim World League Isha is earlier than Karachi Isha', () {
    final karachi = calculatePrayerTimes(
      city: cities.first,
      adjustments: none,
      date: date,
    );
    final mwl = calculatePrayerTimes(
      city: cities.first,
      adjustments: none,
      date: date,
      method: CalcMethod.muslimWorldLeague,
    );
    expect(mwl.isha.isBefore(karachi.isha), isTrue);
  });

  test('Shafi Asr is earlier than Hanafi Asr', () {
    final hanafi = calculatePrayerTimes(
      city: cities.first,
      adjustments: none,
      date: date,
    );
    final shafi = calculatePrayerTimes(
      city: cities.first,
      adjustments: none,
      date: date,
      madhab: Madhab.shafi,
    );
    expect(shafi.asr.isBefore(hanafi.asr), isTrue);
  });
}
