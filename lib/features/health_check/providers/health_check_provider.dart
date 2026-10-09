import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waqt/core/config/features.dart';
import 'package:waqt/core/native/device_health.dart';
import 'package:waqt/core/utils/time_format.dart';

final deviceHealthProvider = Provider<DeviceHealth>((ref) => DeviceHealth());

/// Real permission status. Refreshes whenever the app returns to the
/// foreground, so changes made in system settings show up immediately.
class PermissionsNotifier extends AsyncNotifier<Map<WaqtPermission, bool>> {
  @override
  Future<Map<WaqtPermission, bool>> build() {
    final listener = AppLifecycleListener(onResume: () => unawaited(refresh()));
    ref.onDispose(listener.dispose);
    return ref.read(deviceHealthProvider).status();
  }

  Future<void> refresh() async {
    final latest = await ref.read(deviceHealthProvider).status();
    if (!ref.mounted) return;
    state = AsyncData(latest);
  }
}

final permissionsProvider =
    AsyncNotifierProvider<PermissionsNotifier, Map<WaqtPermission, bool>>(
      PermissionsNotifier.new,
    );

typedef HealthCheck = ({WaqtPermission permission, String label, bool ok});

final healthChecksProvider = Provider<List<HealthCheck>>((ref) {
  final status = ref.watch(permissionsProvider).value;

  HealthCheck check(WaqtPermission permission, String label) => (
    permission: permission,
    label: label,
    // While the first status is loading, do not flash a warning.
    ok: status?[permission] ?? true,
  );

  return [
    check(WaqtPermission.notifications, 'Notifications'),
    check(WaqtPermission.exactAlarms, 'Exact alarms'),
    check(WaqtPermission.battery, 'Battery: no restrictions'),
    if (kPrayerModeEnabled) check(WaqtPermission.usageAccess, 'Usage access'),
    check(WaqtPermission.overlay, 'Display over other apps'),
    check(WaqtPermission.fullScreenIntent, 'Full-screen notifications'),
  ];
});

/// The permission currently stopping Prayer Mode from working, or null.
final prayerModeBlockerProvider = Provider<WaqtPermission?>((ref) {
  final status = ref.watch(permissionsProvider).value;
  if (status == null) return null;
  if (status[WaqtPermission.usageAccess] != true) {
    return WaqtPermission.usageAccess;
  }
  if (status[WaqtPermission.overlay] != true) return WaqtPermission.overlay;
  return null;
});

final lastAzanFiredProvider = FutureProvider<DateTime?>((ref) {
  ref.watch(permissionsProvider); // re-read together with permissions
  return ref.read(deviceHealthProvider).lastAzanFired();
});

String formatLastFired(DateTime? fired, DateTime now) {
  if (fired == null) return 'No Azan fired yet';
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(fired.year, fired.month, fired.day);
  final diff = today.difference(day).inDays;
  final when = diff == 0
      ? 'today'
      : diff == 1
      ? 'yesterday'
      : DateFormat('d MMM').format(fired);
  return 'Last Azan fired: $when, ${formatTime(fired)}';
}
