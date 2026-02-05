import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/providers/nav_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/home/providers/dashboard_stats_provider.dart';
import 'package:agricola/features/home/widgets/stat_card.dart';
import 'package:agricola/features/marketplace/screens/add_product_screen.dart';
import 'package:agricola/features/orders/models/order_model.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MerchantDashboardScreen extends ConsumerWidget {
  const MerchantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final profile = ref.watch(profileSetupProvider);
    final isAgriShop =
        (profile.merchantType ?? MerchantType.agriShop) ==
        MerchantType.agriShop;
    final stats = ref.watch(merchantDashboardStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAgriShop
                            ? t('welcome_back_merchant', currentLang)
                            : t('welcome_back_vendor', currentLang),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAgriShop
                            ? 'Check your store performance'
                            : 'Track your business metrics',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF1A1A1A),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildStatsGrid(context, ref, currentLang, isAgriShop, stats),
              const SizedBox(height: 24),
              _buildRecentActivitySection(context, ref, currentLang, stats),
              const SizedBox(height: 24),
              _buildQuickActionsSection(context, ref, currentLang, isAgriShop),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    WidgetRef ref,
    AppLanguage lang,
    bool isAgriShop,
    MerchantDashboardStats stats,
  ) {
    if (stats.isLoading) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.25,
        children: List.generate(
          4,
          (_) => Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.green,
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        if (isAgriShop) ...[
          StatCard(
            title: t('total_products', lang),
            value: '${stats.totalProducts}',
            icon: Icons.inventory_2,
            color: const Color(0xFF2D6A4F),
            subtitle: stats.totalProducts == 1 ? 'product' : 'products',
          ),
          StatCard(
            title: t('monthly_revenue', lang),
            value: 'P ${stats.monthlyRevenue.toStringAsFixed(2)}',
            icon: Icons.attach_money,
            color: const Color(0xFFFF6B35),
            subtitle: 'this month',
          ),
          StatCard(
            title: t('active_orders', lang),
            value: '${stats.activeOrders}',
            icon: Icons.shopping_cart,
            color: const Color(0xFF4ECDC4),
            subtitle: stats.activeOrders == 1 ? 'order' : 'orders',
          ),
          StatCard(
            title: t('low_stock_items', lang),
            value: '${stats.lowStockItems}',
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFFFBE0B),
            subtitle: stats.lowStockItems == 0 ? 'all good' : 'need attention',
          ),
        ] else ...[
          StatCard(
            title: t('total_suppliers', lang),
            value: '0',
            icon: Icons.people,
            color: const Color(0xFF2D6A4F),
            subtitle: t('coming_soon', lang),
          ),
          StatCard(
            title: t('monthly_purchases', lang),
            value: 'P 0.00',
            icon: Icons.shopping_bag,
            color: const Color(0xFFFF6B35),
            subtitle: t('coming_soon', lang),
          ),
          StatCard(
            title: t('pending_orders', lang),
            value: '0',
            icon: Icons.pending_actions,
            color: const Color(0xFF4ECDC4),
            subtitle: t('coming_soon', lang),
          ),
          StatCard(
            title: t('available_produce', lang),
            value: '0 kg',
            icon: Icons.eco,
            color: const Color(0xFFFFBE0B),
            subtitle: t('coming_soon', lang),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickActionsSection(
    BuildContext context,
    WidgetRef ref,
    AppLanguage lang,
    bool isAgriShop,
  ) {
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddProductScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 24),
              _buildQuickActionTile(
                context,
                icon: Icons.receipt_long_outlined,
                iconColor: Colors.orange,
                title: t('view_orders', lang),
                subtitle: t('manage_customer_orders', lang),
                onTap: () {
                  // AgriShop: Orders is index 2
                  // Non-AgriShop: No orders tab, show coming soon
                  if (isAgriShop) {
                    ref.read(selectedTabProvider.notifier).state = 2;
                  } else {
                    _showComingSoonDialog(context, lang);
                  }
                },
              ),
              const Divider(height: 24),
              _buildQuickActionTile(
                context,
                icon: Icons.inventory_outlined,
                iconColor: Colors.blue,
                title: t('check_inventory', lang),
                subtitle: t('manage_stock_levels', lang),
                onTap: () {
                  // AgriShop: Inventory is index 1
                  // Non-AgriShop: Inventory is index 2
                  ref.read(selectedTabProvider.notifier).state = isAgriShop ? 1 : 2;
                },
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

  Widget _buildRecentActivitySection(
    BuildContext context,
    WidgetRef ref,
    AppLanguage lang,
    MerchantDashboardStats stats,
  ) {
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
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.green),
                  ),
                )
              : stats.recentOrders.isEmpty
                  ? _buildEmptyRecentActivity(lang)
                  : _buildOrdersList(context, ref, stats.recentOrders, lang),
        ),
      ],
    );
  }

  Widget _buildEmptyRecentActivity(AppLanguage lang) {
    return Padding(
      padding: const EdgeInsets.all(32),
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
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    WidgetRef ref,
    List<OrderModel> orders,
    AppLanguage lang,
  ) {
    return Column(
      children: [
        ...orders.asMap().entries.map((entry) {
          final index = entry.key;
          final order = entry.value;
          return Column(
            children: [
              _buildOrderTile(context, order),
              if (index < orders.length - 1)
                Divider(height: 1, color: Colors.grey[200]),
            ],
          );
        }),
        Divider(height: 1, color: Colors.grey[200]),
        InkWell(
          onTap: () {
            // Navigate to orders tab (index 2 for AgriShop)
            ref.read(selectedTabProvider.notifier).state = 2;
          },
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
                const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppColors.green,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTile(BuildContext context, OrderModel order) {
    final statusConfig = _getStatusConfig(order.status);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusConfig.color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(statusConfig.icon, color: statusConfig.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'} • ${_formatDate(order.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'P ${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusConfig.color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusConfig.label,
                  style: TextStyle(
                    fontSize: 10,
                    color: statusConfig.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status) {
      case 'pending':
        return _StatusConfig('Pending', Colors.orange, Icons.schedule);
      case 'confirmed':
        return _StatusConfig('Confirmed', Colors.blue, Icons.check_circle);
      case 'shipped':
        return _StatusConfig('Shipped', Colors.purple, Icons.local_shipping);
      case 'delivered':
        return _StatusConfig('Delivered', Colors.green, Icons.done_all);
      case 'cancelled':
        return _StatusConfig('Cancelled', Colors.grey, Icons.cancel);
      default:
        return _StatusConfig(status, Colors.grey, Icons.help_outline);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  _StatusConfig(this.label, this.color, this.icon);
}
