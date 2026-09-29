import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/features/prayer_times/data/prayer_entry.dart';

final todayPrayersProvider = Provider<List<PrayerEntry>>((ref) {
  return const [
    PrayerEntry(name: 'Fajr', time: '4:45 AM', status: PrayerStatus.prayed),
    PrayerEntry(name: 'Dhuhr', time: '12:06 PM', status: PrayerStatus.prayed),
    PrayerEntry(name: 'Asr', time: '4:25 PM', status: PrayerStatus.prayed),
    PrayerEntry(name: 'Maghrib', time: '6:05 PM', status: PrayerStatus.next),
    PrayerEntry(name: 'Isha', time: '7:24 PM', status: PrayerStatus.pending),
  ];
});
