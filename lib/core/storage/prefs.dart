import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class PrefKeys {
  static const onboarded = 'onboarded';
  static const city = 'city';
  static const adjustments = 'adjustments';
  static const azanSound = 'azan_sound';
  static const differentFajr = 'azan_different_fajr';
  static const language = 'language';
  static const blockedApps = 'blocked_apps';
  static const prayerLog = 'prayer_log';
}

final prefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('prefsProvider must be overridden in main'),
);
