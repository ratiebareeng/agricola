import 'dart:developer' as developer;

import 'package:agricola_core/agricola_core.dart';
import 'package:agricola/core/providers/analytics_provider.dart';
import 'package:agricola/core/providers/app_initialization_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Re-export AppLanguage and t from agricola_core for convenience
export 'package:agricola_core/agricola_core.dart' show AppLanguage, t;

class LanguageNotifier extends StateNotifier<AppLanguage> {
  final Ref _ref;

  LanguageNotifier(this._ref) : super(AppLanguage.english) {
    _loadLanguage();
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'language_code',
      language == AppLanguage.setswana ? 'tn' : 'en',
    );
    await prefs.setBool('has_seen_welcome', true);
    developer.log(
      '✅ LANGUAGE SET: ${language.name}, has_seen_welcome = true',
      name: 'LanguageProvider',
    );

    // Update the initialization provider synchronously
    _ref
        .read(appInitializationProvider.notifier)
        .updateFlag(hasSeenWelcome: true);
    developer.log(
      '🔄 UPDATED: appInitializationProvider (hasSeenWelcome: true)',
      name: 'LanguageProvider',
    );

    _ref.read(analyticsServiceProvider).setLanguage(language.name);
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code');
    if (langCode == 'tn') {
      state = AppLanguage.setswana;
      _ref
          .read(analyticsServiceProvider)
          .setLanguage(AppLanguage.setswana.name);
    } else {
      state = AppLanguage.english;
      _ref.read(analyticsServiceProvider).setLanguage(AppLanguage.english.name);
    }
  }
}

final hasSeenWelcomeProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('has_seen_welcome') ?? false;
});

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((
  ref,
) {
  return LanguageNotifier(ref);
});
