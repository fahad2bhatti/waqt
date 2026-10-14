import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:waqt/features/prayer_times/data/cities.dart';
import 'package:waqt/features/prayer_times/data/countries.dart';

final selectedCountryProvider = StateProvider<Country?>((ref) {
  return countries.firstWhere((c) => c.code == 'PK');
});

final selectedCityProvider = StateProvider<City?>((ref) {
  return pakistanCities.firstWhere((c) => c.name == 'Faisalabad');
});

final isUsingCurrentLocationProvider = StateProvider<bool>((ref) => false);

/// Compat: purani files ke liye (read-only City)
final cityProvider = Provider<City>(
  (ref) => ref.watch(selectedCityProvider) ?? pakistanCities.first,
);
