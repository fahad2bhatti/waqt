import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/features/prayer_times/providers/prayer_times_provider.dart';
import 'package:waqt/features/tracking/providers/prayer_log_provider.dart';

const dailyPrayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

int prayersLoggedOn(Set<String> log, DateTime day) =>
    dailyPrayers.where((prayer) => log.contains(logKey(day, prayer))).length;

/// Consecutive days with all 5 prayers logged, ending today. If today is not
/// complete yet, the streak is counted from yesterday so it does not reset
/// until the day is actually over.
int currentStreak(Set<String> log, DateTime today) {
  var day = today;
  if (prayersLoggedOn(log, day) < dailyPrayers.length) {
    day = DateTime(day.year, day.month, day.day - 1);
  }
  var streak = 0;
  while (prayersLoggedOn(log, day) == dailyPrayers.length) {
    streak++;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return streak;
}

final streakProvider = Provider<int>(
  (ref) =>
      currentStreak(ref.watch(prayerLogProvider), ref.watch(todayProvider)),
);
