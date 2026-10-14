class City {
  final String name;
  final double lat;
  final double lng;
  final String timezone;

  const City({
    required this.name,
    required this.lat,
    required this.lng,
    required this.timezone,
  });
}

const List<City> pakistanCities = [
  City(name: 'Faisalabad', lat: 31.4504, lng: 73.1350, timezone: 'Asia/Karachi'),
  City(name: 'Lahore', lat: 31.5204, lng: 74.3587, timezone: 'Asia/Karachi'),
  City(name: 'Karachi', lat: 24.8607, lng: 67.0011, timezone: 'Asia/Karachi'),
  City(name: 'Islamabad', lat: 33.6844, lng: 73.0479, timezone: 'Asia/Karachi'),
  City(name: 'Rawalpindi', lat: 33.5651, lng: 73.0169, timezone: 'Asia/Karachi'),
  City(name: 'Multan', lat: 30.1575, lng: 71.5249, timezone: 'Asia/Karachi'),
  City(name: 'Peshawar', lat: 34.0151, lng: 71.5249, timezone: 'Asia/Karachi'),
  City(name: 'Quetta', lat: 30.1798, lng: 66.9750, timezone: 'Asia/Karachi'),
  City(name: 'Sialkot', lat: 32.4945, lng: 74.5229, timezone: 'Asia/Karachi'),
  City(name: 'Gujranwala', lat: 32.1877, lng: 74.1945, timezone: 'Asia/Karachi'),
];

const List<City> saudiCities = [
  City(name: 'Makkah', lat: 21.3891, lng: 39.8579, timezone: 'Asia/Riyadh'),
  City(name: 'Madinah', lat: 24.5247, lng: 39.5692, timezone: 'Asia/Riyadh'),
  City(name: 'Riyadh', lat: 24.7136, lng: 46.6753, timezone: 'Asia/Riyadh'),
  City(name: 'Jeddah', lat: 21.4858, lng: 39.1925, timezone: 'Asia/Riyadh'),
  City(name: 'Dammam', lat: 26.4207, lng: 50.0888, timezone: 'Asia/Riyadh'),
];

const List<City> uaeCities = [
  City(name: 'Dubai', lat: 25.2048, lng: 55.2708, timezone: 'Asia/Dubai'),
  City(name: 'Abu Dhabi', lat: 24.4539, lng: 54.3773, timezone: 'Asia/Dubai'),
  City(name: 'Sharjah', lat: 25.3463, lng: 55.4209, timezone: 'Asia/Dubai'),
];

const List<City> indiaCities = [
  City(name: 'Delhi', lat: 28.6139, lng: 77.2090, timezone: 'Asia/Kolkata'),
  City(name: 'Mumbai', lat: 19.0760, lng: 72.8777, timezone: 'Asia/Kolkata'),
  City(name: 'Hyderabad', lat: 17.3850, lng: 78.4867, timezone: 'Asia/Kolkata'),
  City(name: 'Bangalore', lat: 12.9716, lng: 77.5946, timezone: 'Asia/Kolkata'),
  City(name: 'Lucknow', lat: 26.8467, lng: 80.9462, timezone: 'Asia/Kolkata'),
];
