import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/features/prayer_times/providers/city_provider.dart';
import 'package:waqt/features/qibla/data/qibla_math.dart';

typedef CompassReading = ({double heading, int accuracy});

const _channel = EventChannel('com.fahadapps.waqt/compass');

/// Live true-north heading from the phone's rotation-vector sensor.
final compassProvider = StreamProvider.autoDispose<CompassReading>((ref) {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    return const Stream<CompassReading>.empty();
  }
  final city = ref.watch(cityProvider);
  return _channel
      .receiveBroadcastStream({'lat': city.latitude, 'lon': city.longitude})
      .map((event) {
        final map = event as Map;
        return (
          heading: (map['heading'] as num).toDouble(),
          accuracy: (map['accuracy'] as num).toInt(),
        );
      });
});

final qiblaBearingProvider = Provider<double>((ref) {
  final city = ref.watch(cityProvider);
  return qiblaBearing(city.latitude, city.longitude);
});
