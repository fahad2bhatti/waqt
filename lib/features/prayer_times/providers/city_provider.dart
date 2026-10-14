import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:waqt/core/storage/prefs.dart';
import 'package:waqt/features/prayer_times/data/cities.dart';
import 'package:waqt/features/prayer_times/data/countries.dart';

class CityNotifier extends Notifier<City> {
  @override
  City build() {
    final saved = ref.read(prefsProvider).getString(PrefKeys.city);
    return cities.firstWhere(
      (city) => city.name == saved,
      orElse: () => pakistanCities.first,
    );
  }

  void select(City city) {
    state = city;
    ref.read(prefsProvider).setString(PrefKeys.city, city.name);
  }
}

/// Asal (saved) city
final cityProvider = NotifierProvider<CityNotifier, City>(CityNotifier.new);

/// Alias: naye code ke liye (read-only)
final selectedCityProvider = Provider<City?>((ref) => ref.watch(cityProvider));

/// Country: 'last_country' pref se load hota hai
final selectedCountryProvider = StateProvider<Country?>((ref) {
  final code = ref.read(prefsProvider).getString('last_country') ?? 'PK';
  return countryByCode(code) ?? countryByCode('PK');
});

final isUsingCurrentLocationProvider = StateProvider<bool>((ref) => false);
