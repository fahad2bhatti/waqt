import 'package:waqt/core/native/device_health.dart';

/// Permissions the Azan needs, in the order they are asked.
const alertPermissions = [
  WaqtPermission.notifications,
  WaqtPermission.exactAlarms,
  WaqtPermission.fullScreenIntent,
  WaqtPermission.battery,
];

/// The first Azan permission that is not granted yet, or null when all are.
/// A permission missing from [status] counts as not granted.
WaqtPermission? nextMissingAlert(Map<WaqtPermission, bool> status) {
  for (final permission in alertPermissions) {
    if (status[permission] != true) return permission;
  }
  return null;
}
