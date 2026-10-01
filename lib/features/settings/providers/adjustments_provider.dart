import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdjustmentsNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {
    'Fajr': 0,
    'Dhuhr': 0,
    'Asr': 0,
    'Maghrib': 0,
    'Isha': 0,
  };

  void change(String prayer, int delta) {
    state = {...state, prayer: (state[prayer]! + delta).clamp(-30, 30).toInt()};
  }
}

final adjustmentsProvider =
    NotifierProvider<AdjustmentsNotifier, Map<String, int>>(
      AdjustmentsNotifier.new,
    );
