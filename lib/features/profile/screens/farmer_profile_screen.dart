import 'dart:io';

import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/routing/route_guard_helpers.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/language_select_content.dart';
import 'package:agricola/features/profile/providers/profile_provider.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class FarmerProfileScreen extends ConsumerWidget {
  const FarmerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final profileState = ref.watch(profileSetupProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.green,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.green, AppColors.green.withAlpha(80)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    GestureDetector(
                      onTap: () => _pickProfilePhoto(ref),
                      child: Stack(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              image: profileState.photoPath != null
                                  ? DecorationImage(
                                      image: FileImage(
                                        File(profileState.photoPath!),
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              color: Colors.white.withAlpha(30),
                            ),
                            child: profileState.photoPath == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.green,
                                  width: 2,
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: AppColors.green,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Molemi Kgosi',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t('farmer', currentLang),
                      style: TextStyle(
                        color: Colors.white.withAlpha(90),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _showLanguageDialog(context, ref),
                icon: const Icon(Icons.language, color: Colors.white),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileInfoCard(context, ref),
                  const SizedBox(height: 16),
                  _buildFarmDetailsCard(context, ref),
                  const SizedBox(height: 16),
                  _buildQuickActionsCard(context, ref),
                  const SizedBox(height: 16),
                  _buildSettingsSection(context, ref),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.green.withAlpha(10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.green, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildCropsSection(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final profileState = ref.watch(profileSetupProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.agriculture, size: 20, color: AppColors.green),
            const SizedBox(width: 12),
            Text(
              t('primary_crops', currentLang),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (profileState.selectedCrops.isEmpty)
          Text(
            'Not set',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profileState.selectedCrops.map((crop) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.green.withAlpha(10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.green.withAlpha(30)),
                ),
                child: Text(
                  crop,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildFarmDetailsCard(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final profileState = ref.watch(profileSetupProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                t('farm_details', currentLang),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 16),
                label: Text(t('edit', currentLang)),
                style: TextButton.styleFrom(foregroundColor: AppColors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.landscape,
            t('farm_size', currentLang),
            profileState.farmSize.isNotEmpty
                ? profileState.farmSize
                : 'Not set',
          ),
          const Divider(height: 24),
          _buildCropsSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfoCard(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final profileState = ref.watch(profileSetupProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                t('profile_information', currentLang),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 16),
                label: Text(t('edit', currentLang)),
                style: TextButton.styleFrom(foregroundColor: AppColors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.email_outlined,
            t('email', currentLang),
            'molemi@example.com',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.phone_outlined,
            t('phone', currentLang),
            '+267 7123 4567',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.location_on_outlined,
            t('location', currentLang),
            profileState.village.isNotEmpty
                ? (profileState.village == 'Other'
                      ? profileState.customVillage
                      : profileState.village)
                : 'Not set',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('quick_actions', currentLang),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (RouteGuardHelpers.isDebugBuild) ...[
            const SizedBox(height: 16),
            _buildActionButton(
              context,
              Icons.analytics_outlined,
              'Development',
              'Track and manage farm development activities',
              () => context.go('/debug/health-check'),
            ),
          ],
          const SizedBox(height: 12),
          _buildActionButton(
            context,
            Icons.analytics_outlined,
            t('view_reports', currentLang),
            t('view_reports_desc', currentLang),
            () {},
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context,
            Icons.history,
            t('activity_history', currentLang),
            t('activity_history_desc', currentLang),
            () {},
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context,
            Icons.download_outlined,
            t('export_data', currentLang),
            t('export_data_desc', currentLang),
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            t('settings', currentLang),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingsTile(
                context,
                Icons.lock_outline,
                t('change_password', currentLang),
                () {},
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                context,
                Icons.pin_outlined,
                t('change_pin', currentLang),
                () {},
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                context,
                Icons.notifications_outlined,
                t('notifications', currentLang),
                () {},
                showBadge: true,
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                context,
                Icons.help_outline,
                t('help_support', currentLang),
                () {},
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                context,
                Icons.info_outline,
                t('about', currentLang),
                () {},
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                context,
                Icons.logout,
                t('logout', currentLang),
                () => _showLogoutDialog(context, ref),
                isDestructive: true,
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                context,
                Icons.delete_forever,
                'Delete Account',
                () => _showDeleteAccountDialog(context, ref),
                isDestructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool showBadge = false,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : AppColors.green),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '3',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (showBadge) const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
      onTap: onTap,
    );
  }

  Future<void> _pickProfilePhoto(WidgetRef ref) async {
    final picker = ImagePicker();
    final notifier = ref.read(profileSetupProvider.notifier);

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      notifier.setPhoto(image.path);
    }
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final profileState = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);

    showDialog(
      context: context,
      barrierDismissible: !profileState.isLoading,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Delete Account'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone. Deleting your account will:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('• Remove all your personal information'),
            Text('• Delete all your crop and farm data'),
            Text('• Cancel any active subscriptions'),
            Text('• Remove access to all features'),
            SizedBox(height: 16),
            Text(
              'Are you absolutely sure you want to delete your account?',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: profileState.isLoading
                ? null
                : () => Navigator.pop(context),
            child: Text(t('cancel', currentLang)),
          ),
          TextButton(
            onPressed: profileState.isLoading
                ? null
                : () => _showFinalDeleteConfirmation(context, ref),
            style: TextButton.styleFrom(
              foregroundColor: profileState.isLoading
                  ? Colors.grey
                  : Colors.red,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation(BuildContext context, WidgetRef ref) {
    Navigator.pop(context); // Close first dialog

    final currentLang = ref.watch(languageProvider);
    final profileState = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);

    showDialog(
      context: context,
      barrierDismissible: !profileState.isLoading,
      builder: (context) => AlertDialog(
        title: const Text(
          'Final Confirmation',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: profileState.isLoading
                ? null
                : () => Navigator.pop(context),
            child: Text(t('cancel', currentLang)),
          ),
          TextButton(
            onPressed: profileState.isLoading
                ? null
                : () async {
                    final success = await profileNotifier.deleteAccount(
                      context,
                    );
                    if (success && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
            style: TextButton.styleFrom(
              foregroundColor: profileState.isLoading
                  ? Colors.grey
                  : Colors.red,
            ),
            child: profileState.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('DELETE ACCOUNT'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final notifier = ref.read(languageProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('select_language', currentLang)),
        content: LanguageSelectContent(
          currentLang: currentLang,
          notifier: notifier,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final profileState = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);

    showDialog(
      context: context,
      barrierDismissible: !profileState.isLoading,
      builder: (context) => AlertDialog(
        title: Text(t('logout', currentLang)),
        content: Text(t('logout_confirmation', currentLang)),
        actions: [
          TextButton(
            onPressed: profileState.isLoading
                ? null
                : () => Navigator.pop(context),
            child: Text(t('cancel', currentLang)),
          ),
          TextButton(
            onPressed: profileState.isLoading
                ? null
                : () async {
                    final success = await profileNotifier.signOut(context);
                    if (success && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
            style: TextButton.styleFrom(
              foregroundColor: profileState.isLoading
                  ? Colors.grey
                  : Colors.red,
            ),
            child: profileState.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(t('logout', currentLang)),
          ),
        ],
      ),
    );
  }
}
