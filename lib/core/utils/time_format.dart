import 'package:intl/intl.dart';

final _clock = DateFormat.jm();

String formatTime(DateTime time) => _clock.format(time);

String formatCountdown(Duration remaining) {
  final minutes = (remaining.inSeconds / 60).ceil();
  if (minutes < 60) return 'Starts in $minutes min';
  return 'Starts in ${minutes ~/ 60} h ${minutes % 60} min';
}
