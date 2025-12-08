import 'package:agricola/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t('home_title', currentLang))),
      body: Center(child: Text(t('welcome_message', currentLang))),
    );
  }
}
