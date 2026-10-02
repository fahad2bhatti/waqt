import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/core/storage/prefs.dart';

class AdjustmentsNotifier extends Notifier<Map<String, int>> {
  static const _defaults = {
    'Fajr': 0,
    'Dhuhr': 0,
    'Asr': 0,
    'Maghrib': 0,
    'Isha': 0,
  };

  @override
  Map<String, int> build() {
    final saved = ref.read(prefsProvider).getString(PrefKeys.adjustments);
    if (saved == null) return {..._defaults};
    return {..._defaults, ...Map<String, int>.from(jsonDecode(saved) as Map)};
  }

  void change(String prayer, int delta) {
    state = {...state, prayer: (state[prayer]! + delta).clamp(-30, 30).toInt()};
    ref.read(prefsProvider).setString(PrefKeys.adjustments, jsonEncode(state));
  }
}

final adjustmentsProvider =
    NotifierProvider<AdjustmentsNotifier, Map<String, int>>(
      AdjustmentsNotifier.new,
    );
