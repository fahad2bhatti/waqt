import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageNotifier extends Notifier<String> {
  @override
  String build() => 'English';

  void select(String language) => state = language;
}

final languageProvider = NotifierProvider<LanguageNotifier, String>(
  LanguageNotifier.new,
);
