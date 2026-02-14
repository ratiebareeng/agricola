import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/app_buttons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnonymousHomeScreenContent extends StatelessWidget {
  final AppLanguage lang;
  const AnonymousHomeScreenContent({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_open_outlined,
                  size: 80,
                  color: AppColors.green.withAlpha(178),
                ),
                const SizedBox(height: 24),
                Text(
                  t('welcome_to_agricola', lang),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  t('sign_in_to_access_features', lang),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.mediumGray,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                AppPrimaryButton(
                  label: t('sign_in', lang),
                  onTap: () => context.go('/sign-in'),
                ),
                const SizedBox(height: 16),
                AppSecondaryButton(
                  label: t('sign_up', lang),
                  onTap: () => context.go('/register'),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.go('/marketplace'),
                  child: Text(
                    t('browse_marketplace', lang),
                    style: const TextStyle(
                      color: AppColors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
