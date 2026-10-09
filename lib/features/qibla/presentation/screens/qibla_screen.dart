import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/utils/translations.dart';
import 'package:waqt/features/qibla/data/qibla_math.dart';
import 'package:waqt/features/qibla/providers/compass_provider.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  bool _aligned = false;

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationProvider);
    final bearing = ref.watch(qiblaBearingProvider);
    final compass = ref.watch(compassProvider);
    final reading = compass.value;

    // Where the Qibla is relative to the top of the phone (clockwise degrees).
    final delta = reading == null ? null : angleDelta(reading.heading, bearing);

    // Small hysteresis so the state does not flicker at the edge.
    final aligned = delta != null && delta.abs() <= (_aligned ? 6 : 3);
    if (aligned != _aligned) {
      _aligned = aligned;
      if (aligned) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => HapticFeedback.mediumImpact(),
        );
      }
    }

    final String status;
    var statusColor = AppColors.textMuted;
    if (compass.hasError) {
      status = t('compass_unavailable');
    } else if (aligned) {
      status = t('qibla_found');
      statusColor = AppColors.green;
    } else if (reading != null && reading.accuracy < 2) {
      status = t('compass_calibrate');
    } else {
      status = t('qibla_turn');
    }

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 24,
          children: [
            Text(t('qibla'), style: AppText.title),
            SizedBox(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: _DialPainter(angle: delta, aligned: aligned),
              ),
            ),
            Text(
              '${bearing.round()}°',
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(color: statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  const _DialPainter({required this.angle, required this.aligned});

  /// Qibla direction relative to the top of the phone, clockwise degrees.
  final double? angle;
  final bool aligned;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 1.5;
    final accent = aligned ? AppColors.green : AppColors.gold;

    // Ring.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Fixed notch at the top: the marker must reach it.
    canvas.drawLine(
      Offset(center.dx, center.dy - radius - 6),
      Offset(center.dx, center.dy - radius + 14),
      Paint()
        ..color = AppColors.textPrimary
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Centre pivot.
    canvas.drawCircle(center, 10, Paint()..color = AppColors.gold);

    final a = angle;
    if (a == null) return;

    final radians = a * math.pi / 180;
    final marker =
        center + Offset(math.sin(radians), -math.cos(radians)) * radius;

    canvas.drawLine(
      center,
      center + (marker - center) * 0.6,
      Paint()
        ..color = accent.withValues(alpha: 0.5)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(marker, aligned ? 15 : 12, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.angle != angle || old.aligned != aligned;
}
