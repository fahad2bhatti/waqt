import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef AzanSoundState = ({String sound, bool differentFajr});

class AzanSoundNotifier extends Notifier<AzanSoundState> {
  @override
  AzanSoundState build() => (sound: 'Makkah', differentFajr: true);

  void select(String sound) =>
      state = (sound: sound, differentFajr: state.differentFajr);

  void setDifferentFajr(bool value) =>
      state = (sound: state.sound, differentFajr: value);
}

final azanSoundProvider = NotifierProvider<AzanSoundNotifier, AzanSoundState>(
  AzanSoundNotifier.new,
);
