import 'package:agricola/core/providers/analytics_provider.dart';
import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/profile/providers/profile_controller_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileSetupCompleteScreen extends ConsumerWidget {
  final Map<String, dynamic> profileData;

  const ProfileSetupCompleteScreen({super.key, required this.profileData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final profileState = ref.watch(profileControllerProvider);
    final isCreatingProfile = profileState.isLoading;
    final errorMessage = profileState.errorMessage;

    return Scaffold(
      backgroundColor: AppColors.bone,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: AppColors.forestGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 80,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      t('profile_complete', currentLang),
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t('ready_to_start', currentLang),
                      style: TextStyle(fontSize: 16, color: AppColors.deepEmerald.withValues(alpha: 0.5), fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _buildSummaryCard(context, currentLang),
                    const SizedBox(height: 32),
                    _buildFeaturesList(context, currentLang),
                  ],
                ),
              ),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.alertRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.alertRed.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.alertRed, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: AppColors.alertRed, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: AgriStadiumButton(
                onPressed: isCreatingProfile ? null : () => _handleGetStarted(context, ref),
                isLoading: isCreatingProfile,
                label: t('go_to_dashboard', currentLang).toUpperCase(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context, AppLanguage lang) {
    final features = [
      {
        'icon': Icons.crop,
        'title': t('track_crops', lang),
        'desc': t('track_crops_desc', lang),
      },
      {
        'icon': Icons.inventory,
        'title': t('manage_inventory', lang),
        'desc': t('manage_inventory_desc', lang),
      },
      {
        'icon': Icons.analytics,
        'title': t('view_analytics', lang),
        'desc': t('view_analytics_desc', lang),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('whats_next', lang).toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.deepEmerald.withValues(alpha: 0.4),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        ...features.map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: AppColors.forestGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.deepEmerald,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature['desc'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.deepEmerald.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.forestGreen.withValues(alpha: 0.5)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepEmerald.withValues(alpha: 0.4),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepEmerald,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, AppLanguage lang) {
    final userType = profileData['userType'] ?? 'farmer';
    final isFarmer = userType == 'farmer';

    return AgriFocusCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('your_profile', lang).toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.deepEmerald.withValues(alpha: 0.4),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),
          if (isFarmer) ...[
            _buildInfoRow(
              Icons.location_on,
              t('location', lang),
              profileData['location'] ?? 'Not set',
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
            _buildInfoRow(
              Icons.agriculture,
              t('crops', lang),
              (profileData['crops'] as List?)?.join(', ') ?? 'Not set',
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
            _buildInfoRow(
              Icons.landscape,
              t('farm_size', lang),
              profileData['farmSize'] ?? 'Not set',
            ),
          ] else ...[
            _buildInfoRow(
              Icons.business,
              t('business_name', lang),
              profileData['businessName'] ?? 'Not set',
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
            _buildInfoRow(
              Icons.location_on,
              t('location', lang),
              profileData['location'] ?? 'Not set',
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
            _buildInfoRow(
              Icons.inventory,
              t('products', lang),
              (profileData['products'] as List?)?.join(', ') ?? 'Not set',
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleGetStarted(BuildContext context, WidgetRef ref) async {
    final skipped = profileData['skipped'] as bool? ?? false;
    final userType = profileData['userType'] as String? ?? 'unknown';
    if (skipped) {
      ref.read(analyticsServiceProvider).logProfileSetupSkipped();
    } else {
      ref.read(analyticsServiceProvider).logProfileSetupComplete(userType: userType);
    }

    if (skipped) {
      // User skipped profile setup - invalidate auth state to refresh
      ref.invalidate(authStateProvider);

      // Wait for state to refresh
      await Future.delayed(const Duration(milliseconds: 800));
    }

    // Profile is already created (or marked as complete), navigate to home
    if (context.mounted) {
      context.go('/home');
    }
  }
}
