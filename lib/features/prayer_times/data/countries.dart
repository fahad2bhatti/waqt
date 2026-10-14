import 'cities.dart';

class Country {
  final String code;
  final String name;
  final String defaultMethod;
  final String defaultMadhab;
  final List<City> cities;

  const Country({
    required this.code,
    required this.name,
    required this.defaultMethod,
    required this.defaultMadhab,
    required this.cities,
  });
}

const List<Country> countries = [
  Country(
    code: 'PK',
    name: 'Pakistan',
    defaultMethod: 'Karachi',
    defaultMadhab: 'Hanafi',
    cities: pakistanCities,
  ),
  Country(
    code: 'SA',
    name: 'Saudi Arabia',
    defaultMethod: 'UmmAlQura',
    defaultMadhab: 'Shafi',
    cities: saudiCities,
  ),
  Country(
    code: 'AE',
    name: 'United Arab Emirates',
    defaultMethod: 'Dubai',
    defaultMadhab: 'Shafi',
    cities: uaeCities,
  ),
  Country(
    code: 'IN',
    name: 'India',
    defaultMethod: 'Karachi',
    defaultMadhab: 'Hanafi',
    cities: indiaCities,
  ),
];
