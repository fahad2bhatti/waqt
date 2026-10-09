import 'dart:async';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/core/utils/time_format.dart';
import 'package:waqt/core/utils/translations.dart';
import 'package:waqt/features/prayer_times/data/prayer_calculator.dart';
import 'package:waqt/features/prayer_times/providers/city_provider.dart';
import 'package:waqt/features/settings/providers/adjustments_provider.dart';

final nowProvider = StreamProvider<DateTime>((ref) {
  final controller = StreamController<DateTime>();
  Timer? timer;

  void tick() {
    final now = DateTime.now();
    controller.add(now);
    timer = Timer(Duration(seconds: 60 - now.second), tick);
  }

  tick();
  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });
  return controller.stream;
});

final todayProvider = Provider<DateTime>((ref) {
  final now = ref.watch(nowProvider).value ?? DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final prayerTimesProvider = Provider.family<PrayerTimes, DateTime>((ref, date) {
  return calculatePrayerTimes(
    city: ref.watch(cityProvider),
    adjustments: ref.watch(adjustmentsProvider),
    date: date,
  );
});

final nextPrayerProvider = Provider<PrayerSlot>((ref) {
  final now = ref.watch(nowProvider).value ?? DateTime.now();
  final today = ref.watch(todayProvider);

  for (final slot in prayerSlots(ref.watch(prayerTimesProvider(today)))) {
    if (slot.time.isAfter(now)) return slot;
  }
  final tomorrow = DateTime(today.year, today.month, today.day + 1);
  return prayerSlots(ref.watch(prayerTimesProvider(tomorrow))).first;
});

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => ref.watch(todayProvider);

  void select(DateTime date) => state = date;
}

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(
  SelectedDateNotifier.new,
);

final dayTimesProvider = Provider<List<(String, String)>>((ref) {
  final times = ref.watch(prayerTimesProvider(ref.watch(selectedDateProvider)));
  final slots = prayerSlots(times);
  final t = ref.watch(translationProvider);

  return [
    for (final slot in slots) (t(slot.name), formatTime(slot.time.toLocal())),
  ];
});
