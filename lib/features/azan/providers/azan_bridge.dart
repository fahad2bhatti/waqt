import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/core/native/azan_scheduler.dart';
import 'package:waqt/features/azan/providers/azan_playback_provider.dart';

const _channel = MethodChannel('com.fahadapps.waqt/azan');

/// True while the Azan screen is on screen, so it is never pushed twice.
bool azanScreenOpen = false;

AzanPlaybackNotifier? _notifier;

class AzanBridge {
  /// [ready] is false while the router is still on the splash screen.
  static void init(
    WidgetRef ref, {
    required VoidCallback onOpen,
    required bool Function() ready,
  }) {
    final notifier = ref.read(azanPlaybackProvider.notifier);
    _notifier = notifier;

    if (AzanScheduler.isIos) {
      _initIos(ref, notifier, onOpen: onOpen, ready: ready);
      return;
    }

    Future<void> open() async {
      final snapshot = await _channel.invokeMethod<Map<Object?, Object?>>(
        'azanState',
      );
      if (snapshot != null) notifier.apply(snapshot);

      // Cold start: splash would replace the Azan screen, so wait for it.
      for (var i = 0; i < 50 && !ready(); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
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

  /// iOS: tapping a prayer notification opens the Azan screen. There is no
  /// azan audio on iOS yet, so the screen shows in the "notice" state.
  static void _initIos(
    WidgetRef ref,
    AzanPlaybackNotifier notifier, {
    required VoidCallback onOpen,
    required bool Function() ready,
  }) {
    final scheduler = ref.read(azanSchedulerProvider);

    Future<void> open(String? payload) async {
      final parts = (payload ?? '').split('|');
      if (parts.length != 2) return;
      notifier.apply({
        'state': 'notice',
        'name': parts[0],
        'millis':
            int.tryParse(parts[1]) ?? DateTime.now().millisecondsSinceEpoch,
      });
      for (var i = 0; i < 50 && !ready(); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      if (!azanScreenOpen) onOpen();
    }

    scheduler.onTap = (payload) => unawaited(open(payload));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final payload = await scheduler.launchPayload();
      if (payload != null) await open(payload);
    });
  }

  static Future<void> toggle() async {
    if (AzanScheduler.isIos) return;
    await _channel.invokeMethod('azanToggle');
  }

  static Future<void> stop() async {
    if (AzanScheduler.isIos) {
      _notifier?.apply(const {'state': 'stopped'});
      return;
    }
    await _channel.invokeMethod('azanStop');
  }

  static Future<void> prayed() async {
    if (AzanScheduler.isIos) {
      _notifier?.apply(const {'state': 'stopped'});
      return;
    }
    await _channel.invokeMethod('azanPrayed');
  }

  /// "Remind me in N min": native schedules the reminder and stops the Azan.
  static Future<void> remind(int minutes) async {
    if (AzanScheduler.isIos) {
      _notifier?.apply(const {'state': 'stopped'});
      return;
    }
    await _channel.invokeMethod('azanRemind', {'minutes': minutes});
  }

  static Future<void> screenClosed() async {
    if (AzanScheduler.isIos) return;
    await _channel.invokeMethod('azanScreenClosed');
  }
}
