import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/core/storage/prefs.dart';
import 'package:waqt/features/prayer_times/data/calculation_options.dart';

class CalcMethodNotifier extends Notifier<CalcMethod> {
  @override
  CalcMethod build() {
    final saved = ref.read(prefsProvider).getString(PrefKeys.calcMethod);
    return CalcMethod.values.firstWhere(
      (method) => method.name == saved,
      orElse: () => CalcMethod.karachi,
    );
  }

  void select(CalcMethod method) {
    state = method;
    ref.read(prefsProvider).setString(PrefKeys.calcMethod, method.name);
  }
}

final calcMethodProvider = NotifierProvider<CalcMethodNotifier, CalcMethod>(
  CalcMethodNotifier.new,
);

class AsrNotifier extends Notifier<Madhab> {
  @override
  Madhab build() {
    final saved = ref.read(prefsProvider).getString(PrefKeys.asr);
    return saved == Madhab.shafi.name ? Madhab.shafi : Madhab.hanafi;
  }

  void select(Madhab madhab) {
    state = madhab;
    ref.read(prefsProvider).setString(PrefKeys.asr, madhab.name);
  }
}

final asrProvider = NotifierProvider<AsrNotifier, Madhab>(AsrNotifier.new);
