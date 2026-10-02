import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/features/prayer_times/data/prayer_calculator.dart';

class AzanScheduler {
  static const _channel = MethodChannel('com.fahadapps.waqt/azan');

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> schedule(List<PrayerSlot> slots) => _call('schedule', {
    'slots': [
      for (final slot in slots)
        {'name': slot.name, 'millis': slot.time.millisecondsSinceEpoch},
    ],
  });

  /// Fires a test notification after [seconds]. Use it to verify the alarm
  /// works with the app killed and the screen off.
  Future<void> scheduleTest({int seconds = 60}) =>
      _call('scheduleTest', {'seconds': seconds});

  /// Log keys ("2026-10-03|Maghrib") of prayers marked "I prayed" from the
  /// notification while the app was closed. Clears them on the native side.
  Future<List<String>> takePendingPrayed() async {
    if (!_supported) return const [];
    try {
      final result = await _channel.invokeListMethod<String>(
        'takePendingPrayed',
      );
      return result ?? const [];
    } on MissingPluginException {
      return const [];
    } on PlatformException catch (error) {
      debugPrint('AzanScheduler.takePendingPrayed failed: ${error.message}');
      return const [];
    }
  }

  Future<void> requestNotificationPermission() =>
      _call('requestNotificationPermission');

  Future<void> _call(String method, [Map<String, Object?>? args]) async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod<void>(method, args);
    } on MissingPluginException {
      // Running in a test / non-native host.
    } on PlatformException catch (error) {
      debugPrint('AzanScheduler.$method failed: ${error.message}');
    }
  }
}

final azanSchedulerProvider = Provider<AzanScheduler>((ref) => AzanScheduler());
