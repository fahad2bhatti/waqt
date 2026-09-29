enum PrayerStatus { prayed, next, pending }

class PrayerEntry {
  const PrayerEntry({
    required this.name,
    required this.time,
    required this.status,
  });

  final String name;
  final String time;
  final PrayerStatus status;
}
