import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/app_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.green.withAlpha(25),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.earthBrown.withAlpha(25),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // Logo & Branding
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withAlpha(105),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.agriculture_rounded,
                      size: 80,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    t('app_title', currentLang),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.green,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t('tagline', currentLang),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.earthBrown,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Language Selection
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.lightGray),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          t('select_language', currentLang),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGray,
                              ),
                        ),
                        const SizedBox(height: 24),
                        AppSecondaryButton(
                          label: 'English',
                          icon: Icons.language,
                          onTap: () {
                            ref
                                .read(languageProvider.notifier)
                                .setLanguage(AppLanguage.english);
                            Future.delayed(
                              const Duration(milliseconds: 300),
                              () {
                                if (!context.mounted) {
                                  return;
                                }
                                context.go('/onboarding');
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        AppSecondaryButton(
                          label: 'Setswana',
                          icon: Icons.translate,
                          onTap: () {
                            ref
                                .read(languageProvider.notifier)
                                .setLanguage(AppLanguage.setswana);
                            Future.delayed(
                              const Duration(milliseconds: 300),
                              () {
                                if (!context.mounted) return;
                                context.go('/onboarding');
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1),

                  // Debug / Testing Button
                  TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('App data cleared')),
                        );
                      }
                    },
                    child: const Text(
                      'Reset App Data (Testing)',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
