import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:waqt/features/prayer_times/data/cities.dart';
import 'package:waqt/features/prayer_times/data/countries.dart';

class LocationService {
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // Cached fix first (instant). A city only needs a rough position,
      // so a fix from the last few hours is fine.
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null &&
            DateTime.now().difference(last.timestamp) <
                const Duration(hours: 6)) {
          return last;
        }
      } catch (_) {
        // No cached fix: fall through to a fresh one.
      }
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 20),
      );
    }

    return null;
  }

  /// Current position -> nearest supported city. Null if location is off,
  /// denied, timed out, or no supported city is near.
  Future<City?> detectCity() async {
    try {
      final position = await getCurrentPosition();
      if (position == null) return null;
      return findNearestCity(position.latitude, position.longitude, cities);
    } catch (_) {
      return null;
    }
  }

  City? findNearestCity(double lat, double lng, List<City> cities) {
    if (cities.isEmpty) return null;

    City nearest = cities.first;
    double minDistance = _calculateDistance(lat, lng, nearest.lat, nearest.lng);

    for (final city in cities) {
      final distance = _calculateDistance(lat, lng, city.lat, city.lng);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = city;
      }
    }

    // 300 km se door ho to null
    if (minDistance > 300) return null;
    return nearest;
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // km

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) => degree * pi / 180;
}
