import 'package:agricola/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text(t('welcome', currentLang))),
      body: const Center(
        child: Text('Onboarding Carousel Placeholder'),
      ),
    );
  }
}
