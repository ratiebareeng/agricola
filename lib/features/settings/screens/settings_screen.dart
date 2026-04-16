import 'package:agricola/core/providers/database_provider.dart';
import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/providers/offline_settings_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
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
      appBar: AppBar(
        title: Text(
          t('settings', currentLang).toUpperCase(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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

            const SizedBox(height: 32),

            // Offline mode section
            _SectionHeader(title: t('offlineModeTitle', currentLang)),
            _SettingsCard(
              children: [
                _OfflineModeTile(lang: currentLang),
              ],
            ),

            const SizedBox(height: 32),

            // Account section
            _SectionHeader(title: t('account', currentLang)),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: t('change_password', currentLang),
                  onTap: () => _showChangePasswordDialog(context, ref),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                _SettingsTile(
                  icon: Icons.delete_forever,
                  title: t('delete_account', currentLang),
                  isDestructive: true,
                  onTap: () => _showDeleteAccountDialog(context, ref),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Support section
            _SectionHeader(title: t('support', currentLang)),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.bug_report_outlined,
                  title: t('report_bug', currentLang),
                  onTap: () => showFeedbackOverlay(context, ref),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                _SettingsTile(
                  icon: Icons.help_outline,
                  title: t('help_support', currentLang),
                  onTap: () => _showHelpDialog(context, currentLang),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // About section
            _SectionHeader(title: t('about', currentLang)),
            _SettingsCard(
              children: [
                _AboutTile(lang: currentLang),
              ],
            ),

            const SizedBox(height: 48),

            // Logout
            AgriStadiumButton(
              onPressed: () => _showLogoutDialog(context, ref),
              icon: Icons.logout,
              label: t('logout', currentLang).toUpperCase(),
              isPrimary: false,
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Dialogs
  // -------------------------------------------------------------------------

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) async {
    final currentLang = ref.read(languageProvider);
    final user = ref.read(currentUserProvider);
    final email = user?.email;

    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('no_email_error', currentLang)),
          backgroundColor: AppColors.alertRed,
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
              content: Text('${t('reset_failed', currentLang)}: ${failure.message}'),
              backgroundColor: AppColors.alertRed,
              behavior: SnackBarBehavior.floating,
            ),
          ),
          (_) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t('reset_email_sent', currentLang)),
              backgroundColor: AppColors.forestGreen,
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
            isEn ? 'Need help with Agricola? Contact us:' : 'A o tlhoka thuso ka Agricola? Ikgolaganye le rona:',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.deepEmerald),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.forestGreen.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.email_outlined, size: 18, color: AppColors.forestGreen),
              ),
              const SizedBox(width: 12),
              const Text(
                'developer@agricola-app.com',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.deepEmerald),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isEn ? 'You can also use the Report Bug feature to send feedback with a screenshot.' : 'O ka dirisa Report Bug go romela maikutlo ka setshwantsho.',
            style: TextStyle(fontSize: 13, color: AppColors.deepEmerald.withValues(alpha: 0.5), fontWeight: FontWeight.w500),
          ),
        ],
      ),
      okayText: t('okay', lang),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: AppColors.deepEmerald.withValues(alpha: 0.4),
          letterSpacing: 1.5,
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
    return AgriFocusCard(
      padding: EdgeInsets.zero,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDestructive ? AppColors.alertRed : AppColors.forestGreen).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppColors.alertRed : AppColors.forestGreen,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.alertRed : AppColors.deepEmerald,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.deepEmerald.withValues(alpha: 0.2)),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.forestGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.language, color: AppColors.forestGreen, size: 20),
      ),
      title: Text(
        t('language', lang),
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.deepEmerald),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentLabel,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.deepEmerald.withValues(alpha: 0.4),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: AppColors.deepEmerald.withValues(alpha: 0.2)),
        ],
      ),
      onTap: () {
        final notifier = ref.read(languageProvider.notifier);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            title: Text(
              t('select_language', lang),
              style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.deepEmerald),
            ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.forestGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.info_outline, color: AppColors.forestGreen, size: 20),
      ),
      title: Text(
        t('about', lang),
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.deepEmerald),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.deepEmerald.withValues(alpha: 0.2)),
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
                style: TextStyle(fontSize: 15, color: AppColors.deepEmerald.withValues(alpha: 0.7), fontWeight: FontWeight.w500, height: 1.5),
              ),
              const SizedBox(height: 24),
              _aboutRow(isEn ? 'Version' : 'Phetolelo', '${info.version} (${info.buildNumber})'),
            ],
          ),
          okayText: t('okay', lang),
        );
      },
    );
  }

  static Widget _aboutRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 10, color: AppColors.deepEmerald.withValues(alpha: 0.4), fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.deepEmerald),
        ),
      ],
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isEnabled ? AppColors.forestGreen : AppColors.deepEmerald).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.cloud_off_outlined,
              color: isEnabled ? AppColors.forestGreen : AppColors.deepEmerald.withValues(alpha: 0.4),
              size: 20,
            ),
          ),
          title: Text(
            t('offlineModeToggle', lang),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.deepEmerald),
          ),
          subtitle: Text(
            t('offlineModeDesc', lang),
            style: TextStyle(fontSize: 12, color: AppColors.deepEmerald.withValues(alpha: 0.5), fontWeight: FontWeight.w500),
          ),
          value: isEnabled,
          activeThumbColor: AppColors.forestGreen,
          onChanged: (_) => ref.read(offlineModeEnabledProvider.notifier).toggle(),
        ),
        if (isEnabled) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.forestGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.storage_outlined, color: AppColors.forestGreen, size: 20),
            ),
            title: Text(
              t('cacheSize', lang),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.deepEmerald),
            ),
            trailing: Text(
              cacheSize.whenOrNull(data: _formatBytes) ?? '...',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.deepEmerald.withValues(alpha: 0.4),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.forestGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_sweep_outlined, color: AppColors.forestGreen, size: 20),
            ),
            title: Text(
              t('clearCache', lang),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.deepEmerald),
            ),
            trailing: Icon(Icons.chevron_right, color: AppColors.deepEmerald.withValues(alpha: 0.2)),
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
            backgroundColor: AppColors.forestGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
