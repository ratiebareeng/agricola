import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnonymousHomeScreenContent extends StatelessWidget {
  final AppLanguage lang;
  const AnonymousHomeScreenContent({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bone,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_open_outlined,
                    size: 64,
                    color: AppColors.forestGreen,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  t('welcome_to_agricola', lang),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  t('sign_in_to_access_features', lang),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.deepEmerald.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 56),
                AgriStadiumButton(
                  label: t('sign_in', lang),
                  onPressed: () => context.go('/sign-in'),
                ),
                const SizedBox(height: 16),
                AgriStadiumButton(
                  label: t('sign_up', lang),
                  onPressed: () => context.go('/register'),
                  isPrimary: false,
                ),
                const SizedBox(height: 32),
                AgriTextButton(
                  label: t('browse_marketplace', lang),
                  onPressed: () => context.go('/marketplace'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
