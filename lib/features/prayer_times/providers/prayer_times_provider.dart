import 'package:flutter_riverpod/flutter_riverpod.dart';

final dayTimesProvider = Provider<List<(String, String)>>((ref) {
  return const [
    ('Fajr', '4:45 AM'),
    ('Sunrise', '6:08 AM'),
    ('Dhuhr', '12:06 PM'),
    ('Asr', '4:25 PM'),
    ('Maghrib', '6:05 PM'),
    ('Isha', '7:24 PM'),
  ];
});
