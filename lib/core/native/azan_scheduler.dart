import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:waqt/features/prayer_times/data/prayer_calculator.dart';

class AzanScheduler {
  static const _channel = MethodChannel('com.fahadapps.waqt/azan');
  static const _iosMaxPending = 60; // iOS keeps at most 64 pending.
  static const _iosTestId = 9999;

  static bool get isIos =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  final FlutterLocalNotificationsPlugin _ios =
      FlutterLocalNotificationsPlugin();
  bool _iosReady = false;

  /// iOS: called with the payload ("Fajr|millis") when the user taps an
  /// Azan notification while the app is running.
  void Function(String? payload)? onTap;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  bool get _supported => _isAndroid;

  Future<void> _initIos() async {
    if (_iosReady) return;
    tzdata.initializeTimeZones();
    await _ios.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) =>
          onTap?.call(response.payload),
    );
    _iosReady = true;
  }

  /// iOS: payload of the notification that launched the app, if any.
  Future<String?> launchPayload() async {
    if (!isIos) return null;
    try {
      await _initIos();
      final details = await _ios.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp ?? false) {
        return details?.notificationResponse?.payload;
      }
    } catch (error) {
      debugPrint('AzanScheduler iOS launch details failed: $error');
    }
    return null;
  }

  Future<void> _iosZoned(
    int id,
    String title,
    String body,
    int millis,
    String name,
  ) {
    return _ios.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.fromMillisecondsSinceEpoch(tz.UTC, millis),
      const NotificationDetails(
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: '$name|$millis',
    );
  }

  Future<void> schedule(List<PrayerSlot> slots) async {
    if (isIos) {
      try {
        await _initIos();
        await _ios.cancelAll();
        final sorted = [...slots]..sort((a, b) => a.time.compareTo(b.time));
        var id = 0;
        for (final slot in sorted.take(_iosMaxPending)) {
          await _iosZoned(
            id++,
            slot.name,
            'Time for ${slot.name}',
            slot.time.millisecondsSinceEpoch,
            slot.name,
          );
        }
      } catch (error) {
        debugPrint('AzanScheduler iOS schedule failed: $error');
      }
      return;
    }
    await _call('schedule', {
      'slots': [
        for (final slot in slots)
          {'name': slot.name, 'millis': slot.time.millisecondsSinceEpoch},
      ],
    });
  }

  /// Fires a test notification after [seconds]. Use it to verify the alarm
  /// works with the app killed and the screen off.
  Future<void> scheduleTest({int seconds = 60}) async {
    if (isIos) {
      try {
        await _initIos();
        await _iosZoned(
          _iosTestId,
          'Waqt test',
          'Test notification',
          DateTime.now().add(Duration(seconds: seconds)).millisecondsSinceEpoch,
          'Test',
        );
      } catch (error) {
        debugPrint('AzanScheduler iOS test failed: $error');
      }
      return;
    }
    await _call('scheduleTest', {'seconds': seconds});
  }

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

  /// Tells native which prayers are already marked as prayed, so it stops
  /// reminding for them (for example after a tick on Home).
  Future<void> syncPrayed(List<String> keys) =>
      _call('syncPrayed', {'keys': keys});

  Future<void> requestNotificationPermission() async {
    if (isIos) {
      try {
        await _initIos();
        await _ios
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, sound: true, badge: false);
      } catch (error) {
        debugPrint('AzanScheduler iOS permission failed: $error');
      }
      return;
    }
    await _call('requestNotificationPermission');
  }

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
