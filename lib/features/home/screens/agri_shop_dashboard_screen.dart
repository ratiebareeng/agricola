import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/providers/nav_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/home/providers/dashboard_stats_provider.dart';
import 'package:agricola/core/widgets/skeleton_primitives.dart';
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

    String businessName = 'AgriShop';
    if (displayableProfile != null &&
        displayableProfile is CompleteMerchantProfile) {
      businessName = displayableProfile.merchantData.businessName;
    }

    return Scaffold(
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                const SizedBox(height: 32),
                _StatsHero(stats: stats, lang: currentLang),
                const SizedBox(height: 40),
                Text(
                  t('quick_actions', currentLang).toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: AppColors.deepEmerald.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 20),
                _QuickActionsGrid(lang: currentLang),
                const SizedBox(height: 40),
                Text(
                  t('recent_activity', currentLang).toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: AppColors.deepEmerald.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 20),
                _RecentActivitySection(stats: stats, lang: currentLang),
                const SizedBox(height: 100),
              ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          businessName,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'MANAGE YOUR STOREFRONT',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: AppColors.forestGreen.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _StatsHero extends StatelessWidget {
  final MerchantDashboardStats stats;
  final AppLanguage lang;

  const _StatsHero({required this.stats, required this.lang});

  @override
  Widget build(BuildContext context) {
    if (stats.isLoading) {
      return const AgriFocusCard(
        color: AppColors.deepEmerald,
        child: SizedBox(height: 150, child: Center(child: CircularProgressIndicator(color: AppColors.bone))),
      );
    }

    return AgriFocusCard(
      color: AppColors.deepEmerald,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AgriMetricDisplay(
                value: '${stats.activeOrders}',
                label: t('active_orders', lang),
                valueColor: AppColors.bone,
                labelColor: AppColors.bone.withValues(alpha: 0.5),
              ),
              AgriMetricDisplay(
                value: 'P${stats.monthlyRevenue.toStringAsFixed(0)}',
                label: 'REVENUE',
                valueColor: AppColors.earthYellow,
                labelColor: AppColors.earthYellow.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Divider(color: AppColors.bone.withValues(alpha: 0.1)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${stats.totalProducts} Total Products',
                style: const TextStyle(color: AppColors.bone, fontWeight: FontWeight.w600, fontSize: 13),
              ),
              if (stats.lowStockItems > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.alertRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.alertRed.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${stats.lowStockItems} LOW STOCK',
                    style: const TextStyle(
                      color: AppColors.alertRed,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends ConsumerWidget {
  final AppLanguage lang;
  const _QuickActionsGrid({required this.lang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        AgriStadiumButton(
          label: t('add_new_product', lang),
          icon: Icons.add_circle_outline,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AgriStadiumButton(
                label: 'INVENTORY',
                isPrimary: false,
                icon: Icons.inventory_2_outlined,
                onPressed: () => ref.read(selectedTabProvider.notifier).state = 1,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AgriStadiumButton(
                label: 'REPORTS',
                isPrimary: false,
                icon: Icons.analytics_outlined,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MerchantReportsScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecentActivitySection extends ConsumerWidget {
  final MerchantDashboardStats stats;
  final AppLanguage lang;

  const _RecentActivitySection({required this.stats, required this.lang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (stats.isLoading) {
      return Column(
        children: List.generate(3, (_) => const SkeletonBox(width: double.infinity, height: 80, borderRadius: 24)),
      );
    }

    if (stats.recentOrders.isEmpty) {
      return AgriFocusCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.deepEmerald.withValues(alpha: 0.1)),
              const SizedBox(height: 16),
              Text(
                'No orders yet.',
                style: TextStyle(color: AppColors.deepEmerald.withValues(alpha: 0.3), fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ...stats.recentOrders.map((order) => _OrderTile(order: order)),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => ref.read(selectedTabProvider.notifier).state = 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t('view_all_orders', lang).toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12),
              ),
              const Icon(Icons.arrow_forward, size: 16),
            ],
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
    final statusColor = _getStatusColor(order.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AgriFocusCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.receipt_long_outlined, color: statusColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${(order.id ?? '').length > 8 ? order.id!.substring(0, 8).toUpperCase() : (order.id ?? '').toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.deepEmerald),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.items.length} items • ${_formatDate(order.createdAt)}',
                    style: TextStyle(fontSize: 12, color: AppColors.deepEmerald.withValues(alpha: 0.4), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'P${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.deepEmerald),
                ),
                const SizedBox(height: 4),
                Text(
                  order.status.toUpperCase(),
                  style: TextStyle(fontSize: 9, color: statusColor, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    return switch (status) {
      'pending' => AppColors.earthYellow,
      'confirmed' => AppColors.forestGreen,
      'shipped' => AppColors.mediumGray,
      'delivered' => AppColors.forestGreen,
      'cancelled' => AppColors.alertRed,
      _ => AppColors.mediumGray,
    };
  }

  static String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}';
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
            color: AppColors.deepEmerald,
            size: 28,
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.earthYellow,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: AppColors.deepEmerald,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
