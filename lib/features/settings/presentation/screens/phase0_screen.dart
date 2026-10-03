import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_page.dart';

class Phase0Screen extends StatelessWidget {
  const Phase0Screen({super.key});

  static const _channel = MethodChannel('com.waqt/phase0');

  Future<void> _schedule(int seconds) async {
    try {
      await _channel.invokeMethod('scheduleAlarm', seconds);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        Text("Native Prototype (Debug)", style: AppText.title),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
          onPressed: () => _schedule(30),
          child: const Text("Alarm in 30 Seconds"),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
          onPressed: () => _schedule(600),
          child: const Text("Alarm in 10 Minutes"),
        ),
      ],
    );
  }
}
