import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/core/utils/time_format.dart';
import 'package:waqt/features/prayer_times/data/prayer_calculator.dart';
import 'package:waqt/features/prayer_times/data/prayer_entry.dart';
import 'package:waqt/features/prayer_times/providers/prayer_times_provider.dart';
import 'package:waqt/features/tracking/providers/prayer_log_provider.dart';

final todayPrayersProvider = Provider<List<PrayerEntry>>((ref) {
  final today = ref.watch(todayProvider);
  final now = ref.watch(nowProvider).value ?? DateTime.now();
  final slots = prayerSlots(ref.watch(prayerTimesProvider(today)));
  final next = ref.watch(nextPrayerProvider);
  final log = ref.watch(prayerLogProvider);

  return [
    for (final slot in slots)
      PrayerEntry(
        name: slot.name,
        time: formatTime(slot.time),
        logKey: logKey(today, slot.name),
        started: !slot.time.isAfter(now),
        status: log.contains(logKey(today, slot.name))
            ? PrayerStatus.prayed
            : slot.time == next.time
            ? PrayerStatus.next
            : PrayerStatus.pending,
      ),
  ];
});
