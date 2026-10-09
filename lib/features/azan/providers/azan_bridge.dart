import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/features/azan/providers/azan_playback_provider.dart';

const _channel = MethodChannel('com.fahadapps.waqt/azan');

/// True while the Azan screen is on screen, so it is never pushed twice.
bool azanScreenOpen = false;

class AzanBridge {
  /// [ready] is false while the router is still on the splash screen.
  static void init(
    WidgetRef ref, {
    required VoidCallback onOpen,
    required bool Function() ready,
  }) {
    final notifier = ref.read(azanPlaybackProvider.notifier);

    Future<void> open() async {
      final snapshot = await _channel.invokeMethod<Map<Object?, Object?>>(
        'azanState',
      );
      if (snapshot != null) notifier.apply(snapshot);

      // Cold start: splash would replace the Azan screen, so wait for it.
      for (var i = 0; i < 50 && !ready(); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      debugPrint(
        'WaqtAzan open: active=${ref.read(azanPlaybackProvider).active} '
        'ready=${ready()} screenOpen=$azanScreenOpen',
      );
      if (!azanScreenOpen && ref.read(azanPlaybackProvider).active) onOpen();
    }

    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onAzanState':
          notifier.apply(call.arguments as Map<Object?, Object?>);
        case 'onAzanOpen':
          await open();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final launched =
          await _channel.invokeMethod<bool>('consumeAzanLaunch') ?? false;
      if (launched) await open();
    });
  }

  static Future<void> toggle() => _channel.invokeMethod('azanToggle');
  static Future<void> stop() => _channel.invokeMethod('azanStop');
  static Future<void> prayed() => _channel.invokeMethod('azanPrayed');
  static Future<void> screenClosed() =>
      _channel.invokeMethod('azanScreenClosed');
}
