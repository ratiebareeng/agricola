import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/providers/nav_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/home/providers/dashboard_stats_provider.dart';
import 'package:agricola/core/widgets/skeleton_primitives.dart';
import 'package:agricola/features/home/widgets/stat_card.dart';
import 'package:agricola/features/home/widgets/stat_card_skeleton.dart';
import 'package:agricola/features/marketplace/screens/add_product_screen.dart';
import 'package:agricola/features/notifications/providers/notifications_provider.dart';
import 'package:agricola/features/notifications/screens/notifications_screen.dart';
import 'package:agricola/features/orders/models/order_model.dart';
import 'package:agricola/features/profile/domain/models/displayable_profile.dart';
import 'package:agricola/features/profile/providers/profile_controller_provider.dart';
import 'package:agricola/features/reports/screens/reports_screen.dart';
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
    final stats = ref.watch(merchantDashboardStatsProvider);

    String businessName = 'Business';
    if (displayableProfile != null &&
        displayableProfile is CompleteMerchantProfile) {
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
            ref.invalidate(myListingsNotifierProvider);
            ref.invalidate(merchantDashboardStatsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _WelcomeHeader(businessName: businessName, lang: currentLang),
                      ),
                      _AgriShopNotificationBell(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _StatsGrid(stats: stats, lang: currentLang),
                  const SizedBox(height: 24),
                  _QuickActionsSection(lang: currentLang),
                  const SizedBox(height: 24),
                  _RecentActivitySection(stats: stats, lang: currentLang),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final String businessName;
  final AppLanguage lang;

  const _WelcomeHeader({required this.businessName, required this.lang});

  @override
  Widget build(BuildContext context) {
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
}

class _StatsGrid extends StatelessWidget {
  final MerchantDashboardStats stats;
  final AppLanguage lang;

  const _StatsGrid({required this.stats, required this.lang});

  @override
  Widget build(BuildContext context) {
    if (stats.isLoading) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.5,
        children: List.generate(4, (_) => const StatCardSkeleton()),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: t('total_products', lang),
          value: '${stats.totalProducts}',
          icon: Icons.inventory_2,
          color: AppColors.green,
        ),
        StatCard(
          title: t('active_orders', lang),
          value: '${stats.activeOrders}',
          icon: Icons.shopping_cart,
          color: AppColors.green,
        ),
        StatCard(
          title: t('monthly_revenue', lang),
          value: 'P ${stats.monthlyRevenue.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: AppColors.green,
        ),
        StatCard(
          title: t('low_stock_items', lang),
          value: '${stats.lowStockItems}',
          icon: Icons.warning_amber_rounded,
          color: stats.lowStockItems == 0
              ? AppColors.warmYellow
              : AppColors.alertRed,
        ),
      ],
    );
  }
}

class _QuickActionsSection extends ConsumerWidget {
  final AppLanguage lang;

  const _QuickActionsSection({required this.lang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              _QuickActionTile(
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
              _QuickActionTile(
                icon: Icons.receipt_long_outlined,
                iconColor: AppColors.green,
                title: t('view_orders', lang),
                subtitle: t('manage_customer_orders', lang),
                onTap: () =>
                    ref.read(selectedTabProvider.notifier).state = 2,
              ),
              const Divider(height: 24),
              _QuickActionTile(
                icon: Icons.inventory_outlined,
                iconColor: AppColors.green,
                title: t('check_inventory', lang),
                subtitle: t('manage_stock_levels', lang),
                onTap: () =>
                    ref.read(selectedTabProvider.notifier).state = 1,
              ),
              const Divider(height: 24),
              _QuickActionTile(
                icon: Icons.analytics_outlined,
                iconColor: AppColors.green,
                title: t('view_analytics', lang),
                subtitle: t('business_insights', lang),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MerchantReportsScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
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
}

class _RecentActivitySection extends ConsumerWidget {
  final MerchantDashboardStats stats;
  final AppLanguage lang;

  const _RecentActivitySection({required this.stats, required this.lang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          child: stats.isLoading
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: ShimmerWrapper(
                    child: Column(
                      children: List.generate(
                        3,
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              const SkeletonBox(width: 40, height: 40, borderRadius: 10),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SkeletonLine(width: 100, height: 14),
                                    const SizedBox(height: 4),
                                    const SkeletonLine(width: 140, height: 12),
                                  ],
                                ),
                              ),
                              const SkeletonLine(width: 60, height: 14),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : stats.recentOrders.isEmpty
                  ? _buildEmptyState()
                  : _buildOrdersList(context, ref),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
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
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
    );
  }

  Widget _buildOrdersList(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ...stats.recentOrders.asMap().entries.map((entry) {
          final index = entry.key;
          final order = entry.value;
          return Column(
            children: [
              _OrderTile(order: order),
              if (index < stats.recentOrders.length - 1)
                Divider(height: 1, color: Colors.grey[200]),
            ],
          );
        }),
        Divider(height: 1, color: Colors.grey[200]),
        InkWell(
          onTap: () => ref.read(selectedTabProvider.notifier).state = 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  t('view_all_orders', lang),
                  style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 16, color: AppColors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderTile extends StatelessWidget {
  final OrderModel order;

  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(order.status);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(config.icon, color: config.color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'} • ${_formatDate(order.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'P ${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                config.label,
                style: TextStyle(
                  fontSize: 10,
                  color: config.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static ({String label, Color color, IconData icon}) _statusConfig(String status) {
    return switch (status) {
      'pending' => (label: 'Pending', color: AppColors.warmYellow, icon: Icons.schedule),
      'confirmed' => (label: 'Confirmed', color: AppColors.green, icon: Icons.check_circle),
      'shipped' => (label: 'Shipped', color: AppColors.mediumGray, icon: Icons.local_shipping),
      'delivered' => (label: 'Delivered', color: AppColors.green, icon: Icons.done_all),
      'cancelled' => (label: 'Cancelled', color: AppColors.alertRed, icon: Icons.cancel),
      _ => (label: status, color: AppColors.mediumGray, icon: Icons.help_outline),
    };
  }

  static String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _AgriShopNotificationBell extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(unreadNotificationCountProvider);

    return Stack(
      children: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: Color(0xFF1A1A1A),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.alertRed,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
