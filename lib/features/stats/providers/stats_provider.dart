import 'package:flutter_riverpod/flutter_riverpod.dart';

final weekBarsProvider = Provider<List<(String, double)>>((ref) {
  return const [
    ('M', 70),
    ('T', 80),
    ('W', 80),
    ('T', 50),
    ('F', 80),
    ('S', 70),
    ('S', 40),
  ];
});

final perPrayerProvider = Provider<List<(String, String)>>((ref) {
  return const [
    ('Fajr', '6/7'),
    ('Dhuhr', '7/7'),
    ('Asr', '5/7'),
    ('Maghrib', '7/7'),
    ('Isha', '6/7'),
  ];
});
