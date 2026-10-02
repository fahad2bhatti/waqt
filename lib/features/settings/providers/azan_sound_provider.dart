import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/core/storage/prefs.dart';

typedef AzanSoundState = ({String sound, bool differentFajr});

class AzanSoundNotifier extends Notifier<AzanSoundState> {
  @override
  AzanSoundState build() {
    final prefs = ref.read(prefsProvider);
    return (
      sound: prefs.getString(PrefKeys.azanSound) ?? 'Makkah',
      differentFajr: prefs.getBool(PrefKeys.differentFajr) ?? true,
    );
  }

  void select(String sound) {
    state = (sound: sound, differentFajr: state.differentFajr);
    ref.read(prefsProvider).setString(PrefKeys.azanSound, sound);
  }

  void setDifferentFajr(bool value) {
    state = (sound: state.sound, differentFajr: value);
    ref.read(prefsProvider).setBool(PrefKeys.differentFajr, value);
  }
}

final azanSoundProvider = NotifierProvider<AzanSoundNotifier, AzanSoundState>(
  AzanSoundNotifier.new,
);
