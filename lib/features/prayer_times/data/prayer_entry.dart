enum PrayerStatus { prayed, next, pending }

class PrayerEntry {
  const PrayerEntry({
    required this.name,
    required this.time,
    required this.status,
    required this.logKey,
    required this.started,
  });

  final String name;
  final String time;
  final PrayerStatus status;
  final String logKey;
  final bool started;
}
