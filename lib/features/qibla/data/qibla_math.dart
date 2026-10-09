import 'dart:math' as math;

const kaabaLatitude = 21.4225;
const kaabaLongitude = 39.8262;

/// Initial great-circle bearing from a location to the Kaaba,
/// in degrees clockwise from true north (0..360).
double qiblaBearing(double latitude, double longitude) {
  final phi1 = latitude * math.pi / 180;
  final phi2 = kaabaLatitude * math.pi / 180;
  final deltaLambda = (kaabaLongitude - longitude) * math.pi / 180;

  final y = math.sin(deltaLambda) * math.cos(phi2);
  final x =
      math.cos(phi1) * math.sin(phi2) -
      math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

  return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
}

/// Signed shortest turn from [from] to [to], in degrees (-180..180).
/// Positive means turn clockwise.
double angleDelta(double from, double to) => ((to - from + 540) % 360) - 180;
