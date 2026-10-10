import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/core/native/azan_scheduler.dart';
import 'package:waqt/features/tracking/providers/prayer_log_provider.dart';

/// Log keys ("2026-10-03|Maghrib") from the last [days] days.
List<String> recentPrayedKeys(Set<String> log, DateTime now, {int days = 3}) {
  final from = DateTime(now.year, now.month, now.day - days);
  final cutoff = from.toIso8601String().substring(0, 10);
  return [
    for (final key in log)
      if (key.compareTo(cutoff) >= 0) key,
  ];
}

/// Tells native which prayers are already prayed, so it stops reminding
/// for them (for example after a tick on Home).
final prayedNativeSyncProvider = Provider<void>((ref) {
  final scheduler = ref.read(azanSchedulerProvider);

  void push(Set<String> log) {
    unawaited(scheduler.syncPrayed(recentPrayedKeys(log, DateTime.now())));
  }

  push(ref.read(prayerLogProvider));
  ref.listen(prayerLogProvider, (_, next) => push(next));
});
