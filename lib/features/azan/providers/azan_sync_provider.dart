import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/core/native/azan_scheduler.dart';
import 'package:waqt/core/storage/prefs.dart';
import 'package:waqt/features/prayer_times/data/prayer_calculator.dart';
import 'package:waqt/features/prayer_times/providers/city_provider.dart';
import 'package:waqt/features/prayer_times/providers/prayer_times_provider.dart';
import 'package:waqt/features/settings/providers/adjustments_provider.dart';

const _daysAhead = 7;
bool _askedNotificationPermission = false;

/// Keeps native alarms in sync with the calculated prayer times.
/// Re-runs when the city, adjustments or the day changes.
final azanSyncProvider = Provider<void>((ref) {
  final scheduler = ref.read(azanSchedulerProvider);
  final today = ref.watch(todayProvider);
  ref.watch(cityProvider);
  ref.watch(adjustmentsProvider);

  final now = DateTime.now();
  final slots = <PrayerSlot>[];
  for (var i = 0; i < _daysAhead; i++) {
    final day = DateTime(today.year, today.month, today.day + i);
    final times = ref.watch(prayerTimesProvider(day));
    slots.addAll(prayerSlots(times).where((slot) => slot.time.isAfter(now)));
  }

  final onboarded =
      ref.read(prefsProvider).getBool(PrefKeys.onboarded) ?? false;
  if (onboarded && !_askedNotificationPermission) {
    _askedNotificationPermission = true;
    unawaited(scheduler.requestNotificationPermission());
  }

  unawaited(scheduler.schedule(slots));
});
