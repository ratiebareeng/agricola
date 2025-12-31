import 'package:agricola/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BusinessStatisticsScreen extends ConsumerWidget {
  const BusinessStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t('business_stats', currentLang))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatItem(
              t('total_purchases', currentLang),
              '127',
              Icons.shopping_bag_outlined,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              t('suppliers', currentLang),
              '23',
              Icons.people_outline,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              t('inventory_value', currentLang),
              'P 45,230',
              Icons.inventory_2_outlined,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              t('this_month', currentLang),
              'P 12,100',
              Icons.calendar_month_outlined,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
