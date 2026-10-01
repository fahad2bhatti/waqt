import 'package:flutter_riverpod/flutter_riverpod.dart';

class CityNotifier extends Notifier<String> {
  @override
  String build() => 'Faisalabad';

  void select(String city) => state = city;
}

final cityProvider = NotifierProvider<CityNotifier, String>(CityNotifier.new);
