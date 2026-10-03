import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/core/storage/prefs.dart';

String logKey(DateTime day, String prayer) {
  final key = prayer == 'jummah' ? 'Dhuhr' : prayer;
  return '${day.toIso8601String().substring(0, 10)}|$key';
}

class PrayerLogNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() =>
      (ref.read(prefsProvider).getStringList(PrefKeys.prayerLog) ??
              const <String>[])
          .toSet();

  void toggle(String key) {
    state = state.contains(key) ? ({...state}..remove(key)) : {...state, key};
    _save();
  }

  /// Adds [keys] as prayed. Never un-marks, so it is safe to call repeatedly.
  void markPrayed(Iterable<String> keys) {
    final merged = {...state, ...keys};
    if (merged.length == state.length) return;
    state = merged;
    _save();
  }

  void _save() =>
      ref.read(prefsProvider).setStringList(PrefKeys.prayerLog, state.toList());
}

final prayerLogProvider = NotifierProvider<PrayerLogNotifier, Set<String>>(
  PrayerLogNotifier.new,
);
