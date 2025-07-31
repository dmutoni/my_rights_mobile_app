import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedBottomNavIndexProvider = StateProvider<int>((ref) => 0);

enum Language {
  english,
  french,
  kinyarwanda,
}

class LanguageNotifier extends StateNotifier<Language> {
  LanguageNotifier() : super(Language.english);

  void setLanguage(Language language) {
    state = language;
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, Language>(
  (ref) => LanguageNotifier(),
);
