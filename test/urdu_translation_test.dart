import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/core/utils/time_format.dart';
import 'package:waqt/core/utils/translations.dart';

String _en(String key) => TranslationService.translate(key, 'English');
String _ur(String key) => TranslationService.translate(key, 'Urdu');

void main() {
  group('prayer names', () {
    test('every prayer name has an Urdu translation', () {
      for (final name in [
        'Fajr',
        'Dhuhr',
        'Asr',
        'Maghrib',
        'Isha',
        'jummah',
      ]) {
        expect(_ur(name), isNot(name));
        expect(_en(name).toLowerCase(), name.toLowerCase());
      }
    });
  });

  group('formatCountdown', () {
    test('English keeps the old wording', () {
      expect(
        formatCountdown(const Duration(minutes: 5), _en),
        'Starts in 5 min',
      );
      expect(
        formatCountdown(const Duration(minutes: 125), _en),
        'Starts in 2 h 5 min',
      );
    });

    test('Urdu has no English words left', () {
      final text = formatCountdown(const Duration(minutes: 125), _ur);
      expect(text, isNot(contains('Starts')));
      expect(text, contains('2'));
      expect(text, contains('5'));
    });
  });
}
