import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/features/home/widgets/stat_card.dart';
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
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  if (isAgriShop) ...[
                    StatCard(
                      title: t('total_products', currentLang),
                      value: '47',
                      icon: Icons.inventory_2,
                      color: const Color(0xFF2D6A4F),
                      trend: '+5%',
                    ),
                    StatCard(
                      title: t('monthly_revenue', currentLang),
                      value: 'P24.8k',
                      icon: Icons.trending_up,
                      color: const Color(0xFFFF6B35),
                      trend: '+12%',
                    ),
                    StatCard(
                      title: t('active_orders', currentLang),
                      value: '18',
                      icon: Icons.shopping_cart,
                      color: const Color(0xFF4ECDC4),
                      trend: '+3',
                    ),
                    StatCard(
                      title: t('low_stock_items', currentLang),
                      value: '6',
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFFFBE0B),
                      trend: '',
                    ),
                  ] else ...[
                    StatCard(
                      title: t('total_suppliers', currentLang),
                      value: '23',
                      icon: Icons.people,
                      color: const Color(0xFF2D6A4F),
                      trend: '+3',
                    ),
                    StatCard(
                      title: t('monthly_purchases', currentLang),
                      value: 'P18.5k',
                      icon: Icons.shopping_bag,
                      color: const Color(0xFFFF6B35),
                      trend: '+8%',
                    ),
                    StatCard(
                      title: t('pending_orders', currentLang),
                      value: '12',
                      icon: Icons.pending_actions,
                      color: const Color(0xFF4ECDC4),
                      trend: '+2',
                    ),
                    StatCard(
                      title: t('available_produce', currentLang),
                      value: '2.8k kg',
                      icon: Icons.eco,
                      color: const Color(0xFFFFBE0B),
                      trend: '+15%',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAgriShop ? 'Recent Orders' : 'Recent Purchases',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      t('view_all', currentLang),
                      style: const TextStyle(color: Color(0xFF2D6A4F)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildRecentOrderCard(
                isAgriShop ? 'Fertiliser - NPK 2:3:2' : 'Fresh Maize - 200kg',
                isAgriShop ? 'Thabo Modise' : 'John Mokwena Farm',
                isAgriShop ? 'P560.00' : 'P1,200.00',
                isAgriShop ? '2 hours ago' : '5 hours ago',
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(height: 12),
              _buildRecentOrderCard(
                isAgriShop ? 'Irrigation Kit' : 'Sorghum - 150kg',
                isAgriShop ? 'Mpho Setlhabi' : 'Kgosi Agriculture',
                isAgriShop ? 'P1,200.00' : 'P900.00',
                isAgriShop ? 'Yesterday' : '1 day ago',
                Icons.local_shipping,
                Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildRecentOrderCard(
                isAgriShop ? 'Pesticide - 5L' : 'Beans - 80kg',
                isAgriShop ? 'Neo Kgabo' : 'Letlhogonolo Farm',
                isAgriShop ? 'P350.00' : 'P640.00',
                isAgriShop ? '2 days ago' : '3 days ago',
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(height: 24),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      isAgriShop ? 'Add Product' : 'Find Suppliers',
                      isAgriShop ? Icons.add_box : Icons.search,
                      const Color(0xFF2D6A4F),
                      () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      isAgriShop ? 'Manage Stock' : 'Create Order',
                      isAgriShop ? Icons.inventory : Icons.add_shopping_cart,
                      const Color(0xFFFF6B35),
                      () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrderCard(
    String title,
    String customer,
    String amount,
    String time,
    IconData statusIcon,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2D6A4F).withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag,
              color: Color(0xFF2D6A4F),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customer,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Icon(statusIcon, color: statusColor, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
