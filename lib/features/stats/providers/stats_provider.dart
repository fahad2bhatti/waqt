import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/features/prayer_times/providers/prayer_times_provider.dart';
import 'package:waqt/features/tracking/providers/prayer_log_provider.dart';

const _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
const _prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

int _prayedOn(Set<String> log, DateTime day) =>
    _prayers.where((prayer) => log.contains(logKey(day, prayer))).length;

final lastSevenDaysProvider = Provider<List<DateTime>>((ref) {
  final today = ref.watch(todayProvider);
  return [
    for (var i = 6; i >= 0; i--)
      DateTime(today.year, today.month, today.day - i),
  ];
});

final weekBarsProvider = Provider<List<(String, double)>>((ref) {
  final log = ref.watch(prayerLogProvider);
  return [
    for (final day in ref.watch(lastSevenDaysProvider))
      (_letters[day.weekday - 1], 10.0 + 14 * _prayedOn(log, day)),
  ];
});

final weekPercentProvider = Provider<int>((ref) {
  final log = ref.watch(prayerLogProvider);
  final days = ref.watch(lastSevenDaysProvider);
  final prayed = days.fold(0, (sum, day) => sum + _prayedOn(log, day));
  return (prayed * 100 / (days.length * _prayers.length)).round();
});

final perPrayerProvider = Provider<List<(String, String)>>((ref) {
  final log = ref.watch(prayerLogProvider);
  final days = ref.watch(lastSevenDaysProvider);
  return [
    for (final prayer in _prayers)
      (
        prayer,
        '${days.where((day) => log.contains(logKey(day, prayer))).length}/7',
      ),
  ];
});
