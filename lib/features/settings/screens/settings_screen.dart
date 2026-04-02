import 'package:agricola/core/providers/database_provider.dart';
import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/providers/offline_settings_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/app_dialogs.dart';
import 'package:agricola/core/widgets/language_select_content.dart';
import 'package:agricola/features/auth/providers/auth_controller.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/feedback/feedback_helper.dart';
import 'package:agricola/features/profile/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(t('settings', currentLang)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language section
            _SectionHeader(title: t('language', currentLang)),
            _SettingsCard(
              children: [
                _LanguageTile(lang: currentLang),
              ],
            ),

            const SizedBox(height: 24),

            // Offline mode section
            _SectionHeader(title: t('offlineModeTitle', currentLang)),
            _SettingsCard(
              children: [
                _OfflineModeTile(lang: currentLang),
              ],
            ),

            const SizedBox(height: 24),

            // Account section
            _SectionHeader(title: t('account', currentLang)),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: t('change_password', currentLang),
                  onTap: () => _showChangePasswordDialog(context, ref),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.delete_forever,
                  title: t('delete_account', currentLang),
                  isDestructive: true,
                  onTap: () => _showDeleteAccountDialog(context, ref),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Support section
            _SectionHeader(title: t('support', currentLang)),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.bug_report_outlined,
                  title: t('report_bug', currentLang),
                  onTap: () => showFeedbackOverlay(context, ref),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.help_outline,
                  title: t('help_support', currentLang),
                  onTap: () => _showHelpDialog(context, currentLang),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // About section
            _SectionHeader(title: t('about', currentLang)),
            _SettingsCard(
              children: [
                _AboutTile(lang: currentLang),
              ],
            ),

            const SizedBox(height: 32),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context, ref),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(
                  t('logout', currentLang),
                  style: const TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Dialogs (moved from profile screens, shared for all user types)
  // -------------------------------------------------------------------------

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) async {
    final currentLang = ref.read(languageProvider);
    final user = ref.read(currentUserProvider);
    final email = user?.email;

    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('no_email_error', currentLang)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmed = await AppDialogs.confirm(
      context,
      title: t('change_password', currentLang),
      content: '${t('password_reset_message', currentLang)}\n\n$email',
      cancelText: t('cancel', currentLang),
      actionText: t('send_reset_link', currentLang),
    );

    if (confirmed && context.mounted) {
      final authController = ref.read(authControllerProvider.notifier);
      final result = await authController.sendPasswordResetEmail(email);
      if (context.mounted) {
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${t('reset_failed', currentLang)}: ${failure.message}',
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          ),
          (_) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t('reset_email_sent', currentLang)),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          ),
        );
      }
    }
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) async {
    final currentLang = ref.read(languageProvider);

    final confirmed = await AppDialogs.confirm(
      context,
      title: t('delete_account', currentLang),
      content: t('delete_account_warning', currentLang),
      cancelText: t('cancel', currentLang),
      actionText: t('continue_text', currentLang),
      isDestructive: true,
      icon: Icons.warning,
    );

    if (confirmed && context.mounted) {
      _showFinalDeleteConfirmation(context, ref);
    }
  }

  void _showFinalDeleteConfirmation(BuildContext context, WidgetRef ref) async {
    final currentLang = ref.read(languageProvider);

    final confirmed = await AppDialogs.confirm(
      context,
      title: t('final_confirmation', currentLang),
      content: t('delete_permanent_warning', currentLang),
      cancelText: t('cancel', currentLang),
      actionText: t('delete_account_confirm', currentLang),
      isDestructive: true,
    );

    if (confirmed) {
      await ref.read(profileProvider.notifier).deleteAccount();
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final currentLang = ref.read(languageProvider);
    final profileNotifier = ref.read(profileProvider.notifier);

    final confirmed = await AppDialogs.confirm(
      context,
      title: t('logout', currentLang),
      content: t('logout_confirmation', currentLang),
      cancelText: t('cancel', currentLang),
      actionText: t('logout', currentLang),
      isDestructive: true,
    );

    if (confirmed) {
      profileNotifier.signOut();
    }
  }

  void _showHelpDialog(BuildContext context, AppLanguage lang) {
    final isEn = lang == AppLanguage.english;
    AppDialogs.info(
      context,
      title: t('help_support', lang),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn
                ? 'Need help with Agricola? Contact us:'
                : 'A o tlhoka thuso ka Agricola? Ikgolaganye le rona:',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 18, color: AppColors.green),
              const SizedBox(width: 8),
              const Text('developer@agricola-app.com'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isEn
                ? 'You can also use the Report Bug feature to send feedback with a screenshot.'
                : 'O ka dirisa Report Bug go romela maikutlo ka setshwantsho.',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
      okayText: t('okay', lang),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable settings widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppColors.green,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }
}

class _LanguageTile extends ConsumerWidget {
  final AppLanguage lang;
  const _LanguageTile({required this.lang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLabel = lang == AppLanguage.english ? 'English' : 'Setswana';

    return ListTile(
      leading: const Icon(Icons.language, color: AppColors.green),
      title: Text(
        t('language', lang),
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentLabel,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
      onTap: () {
        final notifier = ref.read(languageProvider.notifier);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(t('select_language', lang)),
            content: LanguageSelectContent(
              currentLang: lang,
              notifier: notifier,
            ),
          ),
        );
      },
    );
  }
}

class _AboutTile extends StatelessWidget {
  final AppLanguage lang;
  const _AboutTile({required this.lang});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline, color: AppColors.green),
      title: Text(
        t('about', lang),
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: () async {
        final info = await PackageInfo.fromPlatform();
        if (!context.mounted) return;
        final isEn = lang == AppLanguage.english;
        AppDialogs.info(
          context,
          title: 'Agricola',
          icon: Icons.agriculture,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEn
                    ? 'Empowering smallholder farmers in Botswana with modern tools for crop management, marketplace access, and business growth.'
                    : 'Re thusa balemi ba bannye mo Botswana ka didirisiwa tsa segompieno tsa go laola dijalo, phitlhelelo ya mmaraka, le kgolo ya kgwebo.',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              _aboutRow(
                isEn ? 'Version' : 'Phetolelo',
                '${info.version} (${info.buildNumber})',
              ),
            ],
          ),
          okayText: t('okay', lang),
        );
      },
    );
  }

  static Widget _aboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _OfflineModeTile extends ConsumerWidget {
  final AppLanguage lang;
  const _OfflineModeTile({required this.lang});

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(offlineModeEnabledProvider);
    final cacheSize = ref.watch(cacheSizeProvider);

    return Column(
      children: [
        SwitchListTile(
          secondary: Icon(
            Icons.cloud_off_outlined,
            color: isEnabled ? AppColors.green : Colors.grey,
          ),
          title: Text(
            t('offlineModeToggle', lang),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            t('offlineModeDesc', lang),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          value: isEnabled,
          activeColor: AppColors.green,
          onChanged: (_) =>
              ref.read(offlineModeEnabledProvider.notifier).toggle(),
        ),
        if (isEnabled) ...[
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.storage_outlined, color: AppColors.green),
            title: Text(
              t('cacheSize', lang),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Text(
              cacheSize.whenOrNull(data: _formatBytes) ?? '...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined,
                color: AppColors.green),
            title: Text(
              t('clearCache', lang),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
            onTap: () => _showClearCacheDialog(context, ref),
          ),
        ],
      ],
    );
  }

  void _showClearCacheDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: t('clearCache', lang),
      content: t('clearCacheWarning', lang),
      cancelText: t('cancel', lang),
      actionText: t('clearCache', lang),
    );

    if (confirmed && context.mounted) {
      final db = ref.read(databaseProvider);
      await db.clearAllCache();
      ref.invalidate(cacheSizeProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('cacheCleared', lang)),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
