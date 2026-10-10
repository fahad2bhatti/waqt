import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/features/azan/providers/prayed_native_sync_provider.dart';

void main() {
  test('recentPrayedKeys keeps only the last few days', () {
    final log = {'2026-10-03|Fajr', '2026-10-01|Isha', '2026-09-20|Asr'};
    final keys = recentPrayedKeys(log, DateTime(2026, 10, 3));

    expect(keys, containsAll(['2026-10-03|Fajr', '2026-10-01|Isha']));
    expect(keys, isNot(contains('2026-09-20|Asr')));
  });
}
