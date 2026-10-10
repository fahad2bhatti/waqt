import 'package:adhan_dart/adhan_dart.dart';
import 'package:waqt/features/prayer_times/data/calculation_options.dart';
import 'package:waqt/features/prayer_times/data/cities.dart';

typedef PrayerSlot = ({String name, DateTime time});

const _adjustedPrayers = {
  'Fajr': Prayer.fajr,
  'Dhuhr': Prayer.dhuhr,
  'Asr': Prayer.asr,
  'Maghrib': Prayer.maghrib,
  'Isha': Prayer.isha,
};

PrayerTimes calculatePrayerTimes({
  required City city,
  required Map<String, int> adjustments,
  required DateTime date,
  CalcMethod method = CalcMethod.karachi,
  Madhab madhab = Madhab.hanafi,
}) {
  final params = method.parameters()..madhab = madhab;
  for (final MapEntry(:key, :value) in _adjustedPrayers.entries) {
    params.adjustments[value] = adjustments[key] ?? 0;
  }
  return PrayerTimes(
    coordinates: Coordinates(city.latitude, city.longitude),
    date: date,
    calculationParameters: params,
  );
}

List<PrayerSlot> prayerSlots(PrayerTimes times) {
  final date = times.date;
  final isFriday = date.weekday == DateTime.friday;

  final slots = [
    (name: 'Fajr', time: times.fajr.toLocal()),
    (name: isFriday ? 'jummah' : 'Dhuhr', time: times.dhuhr.toLocal()),
    (name: 'Asr', time: times.asr.toLocal()),
    (name: 'Maghrib', time: times.maghrib.toLocal()),
    (name: 'Isha', time: times.isha.toLocal()),
  ];

  return slots;
}
