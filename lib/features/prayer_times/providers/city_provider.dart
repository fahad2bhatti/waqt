import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/core/storage/prefs.dart';
import 'package:waqt/features/prayer_times/data/cities.dart';

class CityNotifier extends Notifier<City> {
  @override
  City build() {
    final saved = ref.read(prefsProvider).getString(PrefKeys.city);
    return cities.firstWhere(
      (city) => city.name == saved,
      orElse: () => cities.first,
    );
  }

  void select(City city) {
    state = city;
    ref.read(prefsProvider).setString(PrefKeys.city, city.name);
  }
}

final cityProvider = NotifierProvider<CityNotifier, City>(CityNotifier.new);
