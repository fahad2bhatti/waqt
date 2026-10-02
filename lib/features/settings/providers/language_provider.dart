import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/core/storage/prefs.dart';

class LanguageNotifier extends Notifier<String> {
  @override
  String build() =>
      ref.read(prefsProvider).getString(PrefKeys.language) ?? 'English';

  void select(String language) {
    state = language;
    ref.read(prefsProvider).setString(PrefKeys.language, language);
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, String>(
  LanguageNotifier.new,
);
