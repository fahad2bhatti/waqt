import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/core/storage/prefs.dart';

String logKey(DateTime day, String prayer) =>
    '${day.toIso8601String().substring(0, 10)}|$prayer';

class PrayerLogNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() =>
      (ref.read(prefsProvider).getStringList(PrefKeys.prayerLog) ??
              const <String>[])
          .toSet();

  void toggle(String key) {
    state = state.contains(key) ? ({...state}..remove(key)) : {...state, key};
    ref.read(prefsProvider).setStringList(PrefKeys.prayerLog, state.toList());
  }
}

final prayerLogProvider = NotifierProvider<PrayerLogNotifier, Set<String>>(
  PrayerLogNotifier.new,
);
