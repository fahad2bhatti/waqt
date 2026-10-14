import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/features/prayer_times/data/cities.dart';
import 'package:waqt/features/prayer_times/data/countries.dart';

final selectedCountryProvider = StateProvider<Country?>((ref) {
  return countries.firstWhere((c) => c.code == 'PK');
});

final selectedCityProvider = StateProvider<City?>((ref) {
  return pakistanCities.firstWhere((c) => c.name == 'Faisalabad');
});

final isUsingCurrentLocationProvider = StateProvider<bool>((ref) => false);
