import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/core/storage/prefs.dart';

class BlockedAppsNotifier extends Notifier<Set<String>> {
  static const _defaults = ['Instagram', 'TikTok', 'Facebook', 'YouTube'];

  @override
  Set<String> build() {
    final saved = ref.read(prefsProvider).getString(PrefKeys.blockedApps);
    return saved == null
        ? {..._defaults}
        : Set<String>.from(jsonDecode(saved) as List);
  }

  void toggle(String app) {
    state = state.contains(app) ? ({...state}..remove(app)) : {...state, app};
    ref
        .read(prefsProvider)
        .setString(PrefKeys.blockedApps, jsonEncode(state.toList()));
  }
}

final blockedAppsProvider = NotifierProvider<BlockedAppsNotifier, Set<String>>(
  BlockedAppsNotifier.new,
);
