import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/providers/nav_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/marketplace/screens/add_product_screen.dart';
import 'package:agricola/features/profile/domain/models/displayable_profile.dart';
import 'package:agricola/features/profile/providers/profile_controller_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AgriShopDashboardScreen extends ConsumerWidget {
  const AgriShopDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final profileState = ref.watch(profileControllerProvider);
    final user = ref.watch(currentUserProvider);
    final displayableProfile = profileState.displayableProfile;

    // Get business name from profile or use default
    String businessName = 'Business';
    if (displayableProfile != null && displayableProfile is CompleteMerchantProfile) {
      businessName = displayableProfile.merchantData.businessName;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (user != null) {
              await ref
                  .read(profileControllerProvider.notifier)
                  .loadProfile(userId: user.uid, forceRefresh: true);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header
                  _buildWelcomeHeader(businessName, currentLang),
                  const SizedBox(height: 24),

                  // Quick Stats Cards
                  _buildQuickStatsGrid(currentLang),
                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActionsSection(context, ref, currentLang),
                  const SizedBox(height: 24),

                  // Recent Activity
                  _buildRecentActivitySection(context, currentLang),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String businessName, AppLanguage lang) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = t('good_morning', lang);
    } else if (hour < 17) {
      greeting = t('good_afternoon', lang);
    } else {
      greeting = t('good_evening', lang);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          businessName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsGrid(AppLanguage lang) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          icon: Icons.inventory_2,
          iconColor: AppColors.green,
          label: t('total_products', lang),
          value: '0',
        ),
        _buildStatCard(
          icon: Icons.shopping_cart,
          iconColor: Colors.orange,
          label: t('orders_today', lang),
          value: '0',
        ),
        _buildStatCard(
          icon: Icons.attach_money,
          iconColor: Colors.blue,
          label: t('revenue_month', lang),
          value: 'P 0.00',
        ),
        _buildStatCard(
          icon: Icons.warning,
          iconColor: Colors.red,
          label: t('low_stock', lang),
          value: '0',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, WidgetRef ref, AppLanguage lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('quick_actions', lang),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
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
              _buildQuickActionTile(
                context,
                icon: Icons.add_circle_outline,
                iconColor: AppColors.green,
                title: t('add_new_product', lang),
                subtitle: t('add_to_catalog', lang),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProductScreen()),
                ),
              ),
              const Divider(height: 24),
              _buildQuickActionTile(
                context,
                icon: Icons.receipt_long_outlined,
                iconColor: Colors.orange,
                title: t('view_orders', lang),
                subtitle: t('manage_customer_orders', lang),
                onTap: () => ref.read(selectedTabProvider.notifier).state = 2,
              ),
              const Divider(height: 24),
              _buildQuickActionTile(
                context,
                icon: Icons.inventory_outlined,
                iconColor: Colors.blue,
                title: t('check_inventory', lang),
                subtitle: t('manage_stock_levels', lang),
                onTap: () => ref.read(selectedTabProvider.notifier).state = 1,
              ),
              const Divider(height: 24),
              _buildQuickActionTile(
                context,
                icon: Icons.analytics_outlined,
                iconColor: Colors.purple,
                title: t('view_analytics', lang),
                subtitle: t('business_insights', lang),
                onTap: () => _showComingSoonDialog(context, lang),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
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
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
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

  Widget _buildRecentActivitySection(BuildContext context, AppLanguage lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('recent_activity', lang),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(32),
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
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  t('no_recent_orders', lang),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t('orders_will_appear_here', lang),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  t('add_products_to_start', lang),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showComingSoonDialog(BuildContext context, AppLanguage lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.construction, color: AppColors.green),
            const SizedBox(width: 12),
            Text(t('coming_soon', lang)),
          ],
        ),
        content: Text(
          t('feature_under_development', lang),
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('okay', lang)),
          ),
        ],
      ),
    );
  }
}
