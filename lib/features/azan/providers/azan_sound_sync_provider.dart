import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/features/settings/providers/azan_sound_provider.dart';

const _channel = MethodChannel('com.fahadapps.waqt/azan');

/// Pushes the chosen Azan sound to native, which reads it when the alarm fires.
final azanSoundSyncProvider = Provider<void>((ref) {
  final sound = ref.watch(azanSoundProvider);
  unawaited(_push(sound.sound, sound.differentFajr));
});

Future<void> _push(String sound, bool differentFajr) async {
  try {
    await _channel.invokeMethod('setSound', {
      'sound': sound,
      'differentFajr': differentFajr,
    });
  } catch (_) {
    // Native side not ready; the next change pushes again.
  }
}
