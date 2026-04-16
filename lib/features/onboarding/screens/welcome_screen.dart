import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
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
                color: AppColors.green.withValues(alpha: 0.1),
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
                color: AppColors.earthBrown.withValues(alpha: 0.1),
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
                    width: 120,
                    height: 120,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icons/icon.jpg',
                        fit: BoxFit.cover,
                      ),
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
                  AgriFocusCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          t('select_language', currentLang).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.deepEmerald,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        AgriStadiumButton(
                          label: 'English',
                          icon: Icons.language,
                          isPrimary: false,
                          onPressed: () async {
                            await ref
                                .read(languageProvider.notifier)
                                .setLanguage(AppLanguage.english);
                            if (!context.mounted) return;
                            context.go('/onboarding');
                          },
                        ),
                        const SizedBox(height: 16),
                        AgriStadiumButton(
                          label: 'Setswana',
                          icon: Icons.translate,
                          isPrimary: false,
                          onPressed: () async {
                            await ref
                                .read(languageProvider.notifier)
                                .setLanguage(AppLanguage.setswana);
                            if (!context.mounted) return;
                            context.go('/onboarding');
                          },
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1),

                  // Debug / Testing Button
                  AgriTextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('App data cleared')),
                        );
                      }
                    },
                    label: 'RESET APP DATA (TESTING)',
                    color: Colors.grey,
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

