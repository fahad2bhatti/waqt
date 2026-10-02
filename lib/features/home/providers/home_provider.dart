import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/core/utils/time_format.dart';
import 'package:waqt/features/prayer_times/data/prayer_calculator.dart';
import 'package:waqt/features/prayer_times/data/prayer_entry.dart';
import 'package:waqt/features/prayer_times/providers/prayer_times_provider.dart';

final todayPrayersProvider = Provider<List<PrayerEntry>>((ref) {
  final slots = prayerSlots(
    ref.watch(prayerTimesProvider(ref.watch(todayProvider))),
  );
  final next = ref.watch(nextPrayerProvider);

  return [
    for (final slot in slots)
      PrayerEntry(
        name: slot.name,
        time: formatTime(slot.time),
        status: slot.time == next.time
            ? PrayerStatus.next
            : PrayerStatus.pending,
      ),
  ];
});
