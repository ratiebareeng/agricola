import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Logo Placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.agriculture,
                  size: 64,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 24),
              // App Name
              Text(
                t('app_title', currentLang),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Tagline
              Text(
                t('tagline', currentLang),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.earthBrown),
              ),
              const Spacer(flex: 3),
              // Language Selection Header
              Text(
                t('select_language', currentLang),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              // English Button
              _LanguageButton(
                label: 'English',
                isSelected: currentLang == AppLanguage.english,
                onTap: () {
                  ref
                      .read(languageProvider.notifier)
                      .setLanguage(AppLanguage.english);
                  // Add a small delay or just navigate directly if preferred,
                  // but usually user selects then clicks continue or it auto-navigates.
                  // Design brief says "Selecting language saves preference and proceeds to onboarding"
                  // We can add a small delay to show selection state or just go.
                  Future.delayed(const Duration(milliseconds: 300), () {
                    context.go('/onboarding');
                  });
                },
              ),
              const SizedBox(height: 16),
              // Setswana Button
              _LanguageButton(
                label: 'Setswana',
                isSelected: currentLang == AppLanguage.setswana,
                onTap: () {
                  ref
                      .read(languageProvider.notifier)
                      .setLanguage(AppLanguage.setswana);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    context.go('/onboarding');
                  });
                },
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.green : AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.green : AppColors.mediumGray,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: isSelected ? AppColors.white : AppColors.darkGray,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
