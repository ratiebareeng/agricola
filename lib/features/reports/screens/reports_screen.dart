import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/widgets/skeleton_primitives.dart';
import 'package:agricola/features/home/widgets/stat_card_skeleton.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/features/crops/providers/crop_providers.dart';
import 'package:agricola/features/inventory/providers/inventory_providers.dart';
import 'package:agricola/features/orders/providers/orders_provider.dart';
import 'package:agricola/features/purchases/providers/purchases_provider.dart';
import 'package:agricola/features/reports/models/analytics_model.dart';
import 'package:agricola/features/reports/providers/reports_provider.dart';
import 'package:agricola/features/reports/services/export_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(t('view_reports', currentLang)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExportSheet(context, ref, currentLang, isFarmer: true),
        backgroundColor: AppColors.green,
        icon: const Icon(Icons.file_download, color: Colors.white),
        label: Text(t('export_data', currentLang),
            style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FarmerStatsSection(lang: currentLang),
            const SizedBox(height: 24),
            _ActivityTimeline(lang: currentLang),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class MerchantReportsScreen extends ConsumerWidget {
  const MerchantReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(t('business_stats', currentLang)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExportSheet(context, ref, currentLang, isFarmer: false),
        backgroundColor: AppColors.green,
        icon: const Icon(Icons.file_download, color: Colors.white),
        label: Text(t('export_data', currentLang),
            style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MerchantStatsSection(lang: currentLang),
            const SizedBox(height: 24),
            _ActivityTimeline(lang: currentLang),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Farmer stats
// ---------------------------------------------------------------------------

class _FarmerStatsSection extends ConsumerWidget {
  final AppLanguage lang;
  const _FarmerStatsSection({required this.lang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider('month'));

    return analyticsAsync.when(
      loading: () => _ReportsStatsSkeleton(),
      error: (_, __) => _FarmerStatsFallback(lang: lang),
      data: (analytics) => _buildFarmerStats(analytics),
    );
  }

  Widget _buildFarmerStats(AnalyticsModel analytics) {
    final crops = analytics.crops;
    final inv = analytics.inventory;
    final mkt = analytics.marketplace;
    final harvests = analytics.harvests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('farm_overview', lang),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildStatsGrid([
          _StatData(t('total_fields', lang), '${crops.total}', Icons.landscape, AppColors.green),
          _StatData(t('active_crops', lang), '${crops.active}', Icons.grass, AppColors.green),
          _StatData(t('harvested', lang), '${crops.harvested}', Icons.agriculture, AppColors.green),
          _StatData(t('upcoming_harvests', lang), '${crops.upcomingHarvests}', Icons.schedule, AppColors.green),
        ]),
        const SizedBox(height: 16),
        _ReportCard(
          title: t('field_summary', lang),
          items: [
            _ReportRow(t('total_field_size', lang), '${crops.totalFieldSize.toStringAsFixed(1)} ha'),
            _ReportRow(t('estimated_yield', lang), '${crops.totalEstimatedYield.toStringAsFixed(1)} kg'),
            _ReportRow(t('total_harvests', lang), '${harvests.total}'),
            _ReportRow(t('total_yield', lang), '${harvests.totalYield.toStringAsFixed(1)} kg'),
            _ReportRow(t('inventory_items', lang), '${inv.total}'),
            _ReportRow(t('items_need_attention', lang), '${inv.criticalItems}', isWarning: inv.criticalItems > 0),
            _ReportRow(t('marketplace_listings', lang), '${mkt.activeListings}'),
          ],
        ),
      ],
    );
  }
}

/// Fallback: uses client-side providers when analytics API is unavailable
class _FarmerStatsFallback extends ConsumerWidget {
  final AppLanguage lang;
  const _FarmerStatsFallback({required this.lang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(farmerReportStatsProvider);

    if (stats.isLoading) {
      return _ReportsStatsSkeleton();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('farm_overview', lang),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildStatsGrid([
          _StatData(t('total_fields', lang), '${stats.totalCrops}', Icons.landscape, AppColors.green),
          _StatData(t('active_crops', lang), '${stats.activeCrops}', Icons.grass, AppColors.green),
          _StatData(t('harvested', lang), '${stats.harvestedCrops}', Icons.agriculture, AppColors.green),
          _StatData(t('upcoming_harvests', lang), '${stats.upcomingHarvests}', Icons.schedule, AppColors.green),
        ]),
        const SizedBox(height: 16),
        _ReportCard(
          title: t('field_summary', lang),
          items: [
            _ReportRow(t('total_field_size', lang), '${stats.totalFieldSize.toStringAsFixed(1)} ha'),
            _ReportRow(t('estimated_yield', lang), '${stats.totalEstimatedYield.toStringAsFixed(1)} kg'),
            _ReportRow(t('inventory_items', lang), '${stats.inventoryItems}'),
            _ReportRow(t('items_need_attention', lang), '${stats.criticalItems}', isWarning: stats.criticalItems > 0),
            _ReportRow(t('marketplace_listings', lang), '${stats.marketplaceListings}'),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Merchant stats
// ---------------------------------------------------------------------------

class _MerchantStatsSection extends ConsumerWidget {
  final AppLanguage lang;
  const _MerchantStatsSection({required this.lang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider('month'));

    return analyticsAsync.when(
      loading: () => _ReportsStatsSkeleton(),
      error: (_, __) => _MerchantStatsFallback(lang: lang),
      data: (analytics) => _buildMerchantStats(analytics),
    );
  }

  Widget _buildMerchantStats(AnalyticsModel analytics) {
    final orders = analytics.orders;
    final purchases = analytics.purchases;
    final inv = analytics.inventory;
    final mkt = analytics.marketplace;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('business_overview', lang),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildStatsGrid([
          _StatData(t('total_products', lang), '${mkt.activeListings}', Icons.inventory_2, AppColors.green),
          _StatData(t('active_orders', lang), '${orders.active}', Icons.shopping_cart, AppColors.green),
          _StatData(t('total_purchases', lang), '${purchases.total}', Icons.shopping_bag, AppColors.green),
          _StatData(t('suppliers', lang), '${purchases.uniqueSuppliers}', Icons.people, AppColors.green),
        ]),
        const SizedBox(height: 16),
        _ReportCard(
          title: t('financial_summary', lang),
          items: [
            _ReportRow(t('monthly_revenue', lang), 'P ${orders.periodRevenue.toStringAsFixed(2)}'),
            _ReportRow(t('total_revenue', lang), 'P ${orders.totalRevenue.toStringAsFixed(2)}'),
            _ReportRow(t('monthly_purchases', lang), 'P ${purchases.periodValue.toStringAsFixed(2)}'),
            _ReportRow(t('total_purchase_value', lang), 'P ${purchases.totalValue.toStringAsFixed(2)}'),
          ],
        ),
        const SizedBox(height: 16),
        _ReportCard(
          title: t('inventory_summary', lang),
          items: [
            _ReportRow(t('inventory_items', lang), '${inv.total}'),
            _ReportRow(t('low_stock_items', lang), '${inv.criticalItems}', isWarning: inv.criticalItems > 0),
            _ReportRow(t('marketplace_listings', lang), '${mkt.activeListings}'),
          ],
        ),
      ],
    );
  }
}

/// Fallback: uses client-side providers when analytics API is unavailable
class _MerchantStatsFallback extends ConsumerWidget {
  final AppLanguage lang;
  const _MerchantStatsFallback({required this.lang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(merchantReportStatsProvider);

    if (stats.isLoading) {
      return _ReportsStatsSkeleton();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('business_overview', lang),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildStatsGrid([
          _StatData(t('total_products', lang), '${stats.totalProducts}', Icons.inventory_2, AppColors.green),
          _StatData(t('active_orders', lang), '${stats.activeOrders}', Icons.shopping_cart, AppColors.green),
          _StatData(t('total_purchases', lang), '${stats.totalPurchases}', Icons.shopping_bag, AppColors.green),
          _StatData(t('suppliers', lang), '${stats.totalSuppliers}', Icons.people, AppColors.green),
        ]),
        const SizedBox(height: 16),
        _ReportCard(
          title: t('financial_summary', lang),
          items: [
            _ReportRow(t('monthly_revenue', lang), 'P ${stats.monthlyRevenue.toStringAsFixed(2)}'),
            _ReportRow(t('total_revenue', lang), 'P ${stats.totalRevenue.toStringAsFixed(2)}'),
            _ReportRow(t('monthly_purchases', lang), 'P ${stats.monthlyPurchaseValue.toStringAsFixed(2)}'),
            _ReportRow(t('total_purchase_value', lang), 'P ${stats.totalPurchaseValue.toStringAsFixed(2)}'),
          ],
        ),
        const SizedBox(height: 16),
        _ReportCard(
          title: t('inventory_summary', lang),
          items: [
            _ReportRow(t('inventory_items', lang), '${stats.inventoryItems}'),
            _ReportRow(t('low_stock_items', lang), '${stats.lowStockItems}', isWarning: stats.lowStockItems > 0),
            _ReportRow(t('marketplace_listings', lang), '${stats.marketplaceListings}'),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Activity timeline
// ---------------------------------------------------------------------------

class _ActivityTimeline extends ConsumerWidget {
  final AppLanguage lang;
  const _ActivityTimeline({required this.lang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(recentActivityProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('activity_history', lang),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        if (activities.isEmpty)
          _buildEmptyActivity()
        else
          Container(
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
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey[100]),
              itemBuilder: (_, index) =>
                  _ActivityTile(activity: activities[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyActivity() {
    final isEn = lang == AppLanguage.english;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.history, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            isEn ? 'No activity yet' : 'Ga go na ditiro',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isEn
                ? 'Your farming activities will appear here'
                : 'Ditiro tsa gago tsa temo di tla bonala fano',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityItem activity;
  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final config = _activityConfig(activity.type);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(config.icon, color: config.color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(activity.date),
            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  static ({IconData icon, Color color}) _activityConfig(ActivityType type) {
    return switch (type) {
      ActivityType.crop => (icon: Icons.grass, color: AppColors.green),
      ActivityType.inventory => (icon: Icons.inventory_2, color: AppColors.green),
      ActivityType.purchase => (icon: Icons.shopping_bag, color: AppColors.green),
      ActivityType.listing => (icon: Icons.store, color: AppColors.green),
    };
  }

  static String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ---------------------------------------------------------------------------
// Export bottom sheet
// ---------------------------------------------------------------------------

void _showExportSheet(
    BuildContext context, WidgetRef ref, AppLanguage lang,
    {required bool isFarmer}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ExportSheet(ref: ref, lang: lang, isFarmer: isFarmer),
  );
}

class _ExportSheet extends StatelessWidget {
  final WidgetRef ref;
  final AppLanguage lang;
  final bool isFarmer;

  const _ExportSheet({
    required this.ref,
    required this.lang,
    required this.isFarmer,
  });

  @override
  Widget build(BuildContext context) {
    final options = isFarmer
        ? [
            _ExportOption(
              icon: Icons.grass,
              label: t('crops_report', lang),
              onTap: () => _exportCsv(context, 'crops'),
            ),
            _ExportOption(
              icon: Icons.inventory_2,
              label: t('inventory_report', lang),
              onTap: () => _exportCsv(context, 'inventory'),
            ),
            _ExportOption(
              icon: Icons.picture_as_pdf,
              label: '${t('farm_summary', lang)} (PDF)',
              onTap: () => _exportPdf(context, 'farmer_summary'),
            ),
          ]
        : [
            _ExportOption(
              icon: Icons.inventory_2,
              label: t('inventory_report', lang),
              onTap: () => _exportCsv(context, 'inventory'),
            ),
            _ExportOption(
              icon: Icons.shopping_bag,
              label: t('purchases_report', lang),
              onTap: () => _exportCsv(context, 'purchases'),
            ),
            _ExportOption(
              icon: Icons.shopping_cart,
              label: t('orders_report', lang),
              onTap: () => _exportCsv(context, 'orders'),
            ),
            _ExportOption(
              icon: Icons.picture_as_pdf,
              label: '${t('business_summary', lang)} (PDF)',
              onTap: () => _exportPdf(context, 'merchant_summary'),
            ),
          ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t('select_data', lang),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...options.map((opt) => ListTile(
                leading: Icon(opt.icon, color: AppColors.green),
                title: Text(opt.label),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onTap: opt.onTap,
              )),
        ],
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context, String type) async {
    Navigator.pop(context);

    String csv;
    String filename;
    final date = DateTime.now().toIso8601String().split('T').first;

    switch (type) {
      case 'crops':
        final crops = ref.read(cropNotifierProvider).valueOrNull ?? [];
        if (crops.isEmpty) {
          _showMessage(context, t('no_data_to_export', lang));
          return;
        }
        csv = cropsToCsv(crops, lang);
        filename = 'agricola_crops_$date.csv';
      case 'inventory':
        final items = ref.read(inventoryNotifierProvider).valueOrNull ?? [];
        if (items.isEmpty) {
          _showMessage(context, t('no_data_to_export', lang));
          return;
        }
        csv = inventoryToCsv(items, lang);
        filename = 'agricola_inventory_$date.csv';
      case 'purchases':
        final purchases =
            ref.read(purchasesNotifierProvider).valueOrNull ?? [];
        if (purchases.isEmpty) {
          _showMessage(context, t('no_data_to_export', lang));
          return;
        }
        csv = purchasesToCsv(purchases, lang);
        filename = 'agricola_purchases_$date.csv';
      case 'orders':
        final orders = ref.read(ordersNotifierProvider).valueOrNull ?? [];
        if (orders.isEmpty) {
          _showMessage(context, t('no_data_to_export', lang));
          return;
        }
        csv = ordersToCsv(orders, lang);
        filename = 'agricola_orders_$date.csv';
      default:
        return;
    }

    try {
      await shareExportFile(csv, filename, 'text/csv');
    } catch (_) {
      if (context.mounted) _showMessage(context, t('export_error', lang));
    }
  }

  Future<void> _exportPdf(BuildContext context, String type) async {
    Navigator.pop(context);

    try {
      List<int> bytes;
      String filename;
      final date = DateTime.now().toIso8601String().split('T').first;

      if (type == 'farmer_summary') {
        final stats = ref.read(farmerReportStatsProvider);
        bytes = await farmerSummaryPdf(stats, lang);
        filename = 'agricola_farm_summary_$date.pdf';
      } else {
        final stats = ref.read(merchantReportStatsProvider);
        bytes = await merchantSummaryPdf(stats, lang);
        filename = 'agricola_business_summary_$date.pdf';
      }

      await sharePdfFile(bytes, filename);
    } catch (_) {
      if (context.mounted) _showMessage(context, t('export_error', lang));
    }
  }

  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _ExportOption {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ExportOption(
      {required this.icon, required this.label, required this.onTap});
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatData(this.label, this.value, this.icon, this.color);
}

Widget _buildStatsGrid(List<_StatData> stats) {
  return GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: 1.6,
    children: stats.map((s) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(s.icon, color: s.color, size: 22),
            const Spacer(),
            Text(
              s.value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              s.label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }).toList(),
  );
}

class _ReportCard extends StatelessWidget {
  final String title;
  final List<_ReportRow> items;
  const _ReportCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...items.asMap().entries.map((entry) {
            final row = entry.value;
            final isLast = entry.key == items.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        row.label,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      Text(
                        row.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: row.isWarning ? AppColors.alertRed : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast) Divider(height: 1, color: Colors.grey[100]),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ReportRow {
  final String label;
  final String value;
  final bool isWarning;
  const _ReportRow(this.label, this.value, {this.isWarning = false});
}

class _ReportsStatsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: List.generate(4, (_) => const StatCardSkeleton()),
          ),
          const SizedBox(height: 24),
          ShimmerWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLine(width: 140, height: 18),
                const SizedBox(height: 16),
                ...List.generate(
                  3,
                  (_) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SkeletonLine(width: 120, height: 14),
                        const SkeletonLine(width: 60, height: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
