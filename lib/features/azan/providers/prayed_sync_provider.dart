import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/core/native/azan_scheduler.dart';
import 'package:waqt/features/tracking/providers/prayer_log_provider.dart';

/// Pulls "I prayed" taps made on the Azan notification into the prayer log,
/// on app start and every time the app comes back to the foreground.
final prayedSyncProvider = Provider<void>((ref) {
  final scheduler = ref.read(azanSchedulerProvider);

  Future<void> sync() async {
    final keys = await scheduler.takePendingPrayed();
    if (keys.isNotEmpty) {
      ref.read(prayerLogProvider.notifier).markPrayed(keys);
    }
  }

  unawaited(sync());
  final listener = AppLifecycleListener(onResume: () => unawaited(sync()));
  ref.onDispose(listener.dispose);
});
