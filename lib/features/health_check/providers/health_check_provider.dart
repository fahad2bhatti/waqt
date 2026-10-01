import 'package:flutter_riverpod/flutter_riverpod.dart';

final healthChecksProvider = Provider<List<(String, bool)>>((ref) {
  return const [
    ('Notifications', true),
    ('Exact alarms', true),
    ('Battery: no restrictions', false),
    ('Usage access', true),
    ('Display over other apps', false),
  ];
});
