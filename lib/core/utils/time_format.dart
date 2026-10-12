import 'package:intl/intl.dart';

final _clock = DateFormat.jm();

String formatTime(DateTime time) => _clock.format(time);

String formatCountdown(Duration remaining, String Function(String) t) {
  final minutes = (remaining.inSeconds / 60).ceil();
  if (minutes < 60) {
    return t('starts_in_min').replaceAll('{m}', '$minutes');
  }
  return t(
    'starts_in_hm',
  ).replaceAll('{h}', '${minutes ~/ 60}').replaceAll('{m}', '${minutes % 60}');
}
