import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/features/prayer_times/data/cities.dart';

class CityNotifier extends Notifier<City> {
  @override
  City build() => cities.first;

  void select(City city) => state = city;
}

final cityProvider = NotifierProvider<CityNotifier, City>(CityNotifier.new);
