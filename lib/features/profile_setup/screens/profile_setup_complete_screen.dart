import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: AppColors.green.withAlpha(10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 80,
                        color: AppColors.green,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      t('profile_complete', currentLang),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t('ready_to_start', currentLang),
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _buildSummaryCard(currentLang),
                    const SizedBox(height: 24),
                    _buildFeaturesList(currentLang),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isCreatingProfile
                      ? null
                      : () => _handleGetStarted(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isCreatingProfile
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          t('go_to_dashboard', currentLang),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList(AppLanguage lang) {
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
          t('whats_next', lang),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...features.map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppColors.green.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: AppColors.green,
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        feature['desc'] as String,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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

  Widget _buildSummaryCard(AppLanguage lang) {
    final userType = profileData['userType'] ?? 'farmer';
    final isFarmer = userType == 'farmer';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('your_profile', lang),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (isFarmer) ...[
            _buildInfoRow(
              Icons.location_on,
              t('location', lang),
              profileData['location'] ?? 'Not set',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.agriculture,
              t('crops', lang),
              (profileData['crops'] as List?)?.join(', ') ?? 'Not set',
            ),
            const Divider(height: 24),
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
            const Divider(height: 24),
            _buildInfoRow(
              Icons.location_on,
              t('location', lang),
              profileData['location'] ?? 'Not set',
            ),
            const Divider(height: 24),
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
