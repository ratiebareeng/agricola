import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/widgets/app_buttons.dart';
import 'package:agricola/features/auth/widgets/or_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SocialLoginButtons extends ConsumerWidget {
  final VoidCallback? onGoogleTap;
  final VoidCallback? onFacebookTap;
  final bool isLoading;

  const SocialLoginButtons({
    super.key,
    this.onGoogleTap,
    this.onFacebookTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    return Column(
      children: [
        OrDivider(text: t('or_continue_with', currentLang)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: AppSecondaryButton(
                label: t('google', currentLang),
                icon: Icons.g_mobiledata,
                onTap: isLoading ? null : onGoogleTap,
              ),
            ),
            if (onFacebookTap != null) ...[
              const SizedBox(width: 16),
              Expanded(
                child: AppSecondaryButton(
                  label: t('facebook', currentLang),
                  icon: Icons.facebook,
                  onTap: isLoading ? null : onFacebookTap,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
