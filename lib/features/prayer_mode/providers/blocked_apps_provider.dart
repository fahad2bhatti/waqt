import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlockedAppsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {'Instagram', 'TikTok', 'Facebook', 'YouTube'};

  void toggle(String app) {
    state = state.contains(app) ? ({...state}..remove(app)) : {...state, app};
  }
}

final blockedAppsProvider = NotifierProvider<BlockedAppsNotifier, Set<String>>(
  BlockedAppsNotifier.new,
);
