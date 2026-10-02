import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/core/utils/time_format.dart';
import 'package:waqt/features/health_check/providers/health_check_provider.dart';

void main() {
  final now = DateTime(2026, 10, 3, 10, 0);

  group('formatLastFired', () {
    test('never fired', () {
      expect(formatLastFired(null, now), 'No Azan fired yet');
    });

    test('same day', () {
      final fired = DateTime(2026, 10, 3, 4, 45);
      expect(
        formatLastFired(fired, now),
        'Last Azan fired: today, ${formatTime(fired)}',
      );
    });

    test('previous day', () {
      final fired = DateTime(2026, 10, 2, 19, 5);
      expect(
        formatLastFired(fired, now),
        'Last Azan fired: yesterday, ${formatTime(fired)}',
      );
    });

    test('older', () {
      final fired = DateTime(2026, 9, 30, 12, 6);
      expect(
        formatLastFired(fired, now),
        startsWith('Last Azan fired: 30 Sep'),
      );
    });
  });
}
