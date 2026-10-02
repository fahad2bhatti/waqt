class City {
  const City({
    required this.name,
    required this.country,
    required this.timezone,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String country;
  final String timezone;
  final double latitude;
  final double longitude;
}

const cities = [
  City(
    name: 'Faisalabad',
    country: 'Pakistan',
    timezone: 'PKT',
    latitude: 31.4504,
    longitude: 73.1350,
  ),
  City(
    name: 'Lahore',
    country: 'Pakistan',
    timezone: 'PKT',
    latitude: 31.5204,
    longitude: 74.3587,
  ),
  City(
    name: 'Karachi',
    country: 'Pakistan',
    timezone: 'PKT',
    latitude: 24.8607,
    longitude: 67.0011,
  ),
  City(
    name: 'Islamabad',
    country: 'Pakistan',
    timezone: 'PKT',
    latitude: 33.6844,
    longitude: 73.0479,
  ),
];
