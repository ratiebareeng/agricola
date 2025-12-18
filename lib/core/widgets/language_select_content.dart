import 'package:agricola/core/providers/language_provider.dart';
import 'package:flutter/material.dart';

class LanguageSelectContent extends StatelessWidget {
  final AppLanguage currentLang;

  final LanguageNotifier notifier;
  const LanguageSelectContent({
    super.key,
    required this.currentLang,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return RadioGroup(
      groupValue: currentLang,
      onChanged: (value) {
        if (value == null) {
          return;
        }
        notifier.setLanguage(value);
        Navigator.pop(context);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<AppLanguage>(
            title: const Text('English'),
            value: AppLanguage.english,
          ),
          RadioListTile<AppLanguage>(
            title: const Text('Setswana'),
            value: AppLanguage.setswana,
          ),
        ],
      ),
    );
  }
}
