import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/core/utils/translations.dart';
import 'package:waqt/features/azan/providers/azan_bridge.dart';
import 'package:waqt/features/azan/providers/azan_playback_provider.dart';

class AzanScreen extends ConsumerStatefulWidget {
  const AzanScreen({super.key});

  @override
  ConsumerState<AzanScreen> createState() => _AzanScreenState();
}

class _AzanScreenState extends ConsumerState<AzanScreen> {
  @override
  void initState() {
    super.initState();
    azanScreenOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !ref.read(azanPlaybackProvider).active) _close();
    });
  }

  @override
  void dispose() {
    azanScreenOpen = false;
    super.dispose();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationProvider);
    final azan = ref.watch(azanPlaybackProvider);

    ref.listen(azanPlaybackProvider, (_, next) {
      if (!next.active && mounted) _close();
    });

    final paused = azan.state == 'paused';
    final silent = azan.state == 'silent';
    final time = TimeOfDay.fromDateTime(
      DateTime.fromMillisecondsSinceEpoch(azan.millis),
    ).format(context);
    final status = silent
        ? 'Phone is silent'
        : paused
        ? 'Paused'
        : t('azan_playing');

    return Scaffold(
      backgroundColor: AppColors.overlayBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              const Spacer(),
              Text(
                '${t(azan.name)}  $time'.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
              Text(
                t('prayer_started'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textMuted,
                ),
              ),
              FilledButton(
                onPressed: AzanBridge.prayed,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(t('i_prayed')),
              ),
              if (!silent)
                Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: AzanBridge.toggle,
                        child: Text(paused ? 'Resume' : 'Pause'),
                      ),
                    ),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: AzanBridge.stop,
                        child: Text(t('stop_azan')),
                      ),
                    ),
                  ],
                ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
