import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum WaqtPermission {
  notifications,
  exactAlarms,
  battery,
  usageAccess,
  overlay,
  fullScreenIntent,
}

/// Outcome of the Android notification dialog. [blocked] means Android will
/// not show it again, so the only way left is the system settings page.
enum NotificationAnswer { granted, denied, blocked }

class DeviceHealth {
  static const _channel = MethodChannel('com.fahadapps.waqt/health');

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Map<WaqtPermission, bool> get _allGranted => {
    for (final permission in WaqtPermission.values) permission: true,
  };

  Future<Map<WaqtPermission, bool>> status() async {
    if (!_supported) return _allGranted;
    try {
      final raw =
          await _channel.invokeMapMethod<String, bool>('status') ??
          const <String, bool>{};
      return {
        for (final permission in WaqtPermission.values)
          permission: raw[permission.name] ?? false,
      };
    } on MissingPluginException {
      return _allGranted;
    } on PlatformException catch (error) {
      debugPrint('DeviceHealth.status failed: ${error.message}');
      return _allGranted;
    }
  }

  Future<NotificationAnswer> requestNotifications() async {
    if (!_supported) return NotificationAnswer.granted;
    try {
      final raw = await _channel.invokeMethod<String>('requestNotifications');
      return NotificationAnswer.values.asNameMap()[raw] ??
          NotificationAnswer.denied;
    } on MissingPluginException {
      return NotificationAnswer.granted;
    } on PlatformException catch (error) {
      debugPrint('DeviceHealth.requestNotifications failed: ${error.message}');
      return NotificationAnswer.denied;
    }
  }

  Future<void> openSettings(WaqtPermission permission) async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod<void>('openSettings', {
        'key': permission.name,
      });
    } on MissingPluginException {
      // Running in a test / non-native host.
    } on PlatformException catch (error) {
      debugPrint('DeviceHealth.openSettings failed: ${error.message}');
    }
  }

  Future<DateTime?> lastAzanFired() async {
    if (!_supported) return null;
    try {
      final millis = await _channel.invokeMethod<int>('lastAzanFired');
      return millis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(millis);
    } on MissingPluginException {
      return null;
    } on PlatformException catch (error) {
      debugPrint('DeviceHealth.lastAzanFired failed: ${error.message}');
      return null;
    }
  }
}
