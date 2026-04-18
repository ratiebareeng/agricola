import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:agricola/features/marketplace/models/crop_availability_model.dart';
import 'package:agricola/features/marketplace/models/saturation_thresholds.dart';
import 'package:agricola/features/marketplace/providers/crop_availability_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CropAvailabilityScreen extends ConsumerStatefulWidget {
  const CropAvailabilityScreen({super.key});

  @override
  ConsumerState<CropAvailabilityScreen> createState() =>
      _CropAvailabilityScreenState();
}

class _CropAvailabilityScreenState
    extends ConsumerState<CropAvailabilityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final availabilityAsync = ref.watch(cropAvailabilityProvider);

    return Scaffold(
      backgroundColor: AppColors.bone,
      appBar: AppBar(
        title: Text(
          t('crop_availability', lang),
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.forestGreen,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: t('available_now', lang)),
            Tab(text: t('in_2_weeks', lang)),
            Tab(text: t('in_4_weeks', lang)),
            Tab(text: t('in_6_weeks', lang)),
            Tab(text: t('in_8_weeks', lang)),
          ],
        ),
      ),
      body: availabilityAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildError(lang),
        data: (data) => TabBarView(
          controller: _tabController,
          children: [
            _buildAvailableNow(data.availableNow, lang),
            _buildUpcomingTab(data, 'in_2_weeks', data.in2Weeks, lang),
            _buildUpcomingTab(data, 'in_4_weeks', data.in4Weeks, lang),
            _buildUpcomingTab(data, 'in_6_weeks', data.in6Weeks, lang),
            _buildUpcomingTab(data, 'in_8_weeks', data.in8Weeks, lang),
          ],
        ),
      ),
    );
  }

  Widget _buildError(AppLanguage lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            t('error_loading_data', lang),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          AgriStadiumButton(
            onPressed: () => ref.read(cropAvailabilityProvider.notifier).refresh(),
            label: t('retry', lang),
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableNow(List<AvailableNowItem> items, AppLanguage lang) {
    if (items.isEmpty) return _buildEmpty(lang);
    return RefreshIndicator(
      color: AppColors.forestGreen,
      onRefresh: () => ref.read(cropAvailabilityProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) => _AvailableNowCard(item: items[i], lang: lang),
      ),
    );
  }

  Widget _buildUpcomingTab(
    CropAvailabilityData data,
    String window,
    List<UpcomingHarvestItem> items,
    AppLanguage lang,
  ) {
    final aggregates = data.summaryForWindow(window);

    if (items.isEmpty && aggregates.isEmpty) return _buildEmpty(lang);

    return RefreshIndicator(
      color: AppColors.forestGreen,
      onRefresh: () => ref.read(cropAvailabilityProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        itemCount: items.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            return MarketSaturationBanner(
              aggregates: aggregates,
              lang: lang,
            );
          }
          return _UpcomingHarvestCard(item: items[i - 1], lang: lang);
        },
      ),
    );
  }

  Widget _buildEmpty(AppLanguage lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grass_outlined, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            t('no_crops_in_window', lang),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t('check_other_windows', lang),
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class MarketSaturationBanner extends StatelessWidget {
  final List<SupplyAggregate> aggregates;
  final AppLanguage lang;

  const MarketSaturationBanner({
    super.key,
    required this.aggregates,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    if (aggregates.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('market_saturation', lang),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.deepEmerald,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: aggregates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _SaturationCard(
                aggregate: aggregates[i],
                lang: lang,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaturationCard extends StatelessWidget {
  final SupplyAggregate aggregate;
  final AppLanguage lang;

  const _SaturationCard({required this.aggregate, required this.lang});

  @override
  Widget build(BuildContext context) {
    final level = aggregate.saturation;
    final color = _colorFor(level);
    final label = _labelFor(level, lang);

    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  t(aggregate.cropType, lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepEmerald,
                  ),
                ),
              ),
            ],
          ),
          Text(
            '${aggregate.totalKg}kg',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Row(
            children: [
              Text(
                '${aggregate.sellerCount} ${t('farmers_count', lang)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _colorFor(SaturationLevel level) {
    switch (level) {
      case SaturationLevel.saturated:
        return AppColors.alertRed;
      case SaturationLevel.moderate:
        return AppColors.earthBrown;
      case SaturationLevel.low:
        return AppColors.forestGreen;
    }
  }

  String _labelFor(SaturationLevel level, AppLanguage lang) {
    switch (level) {
      case SaturationLevel.saturated:
        return t('saturated_supply', lang);
      case SaturationLevel.moderate:
        return t('moderate_supply', lang);
      case SaturationLevel.low:
        return t('low_supply', lang);
    }
  }
}

class _AvailableNowCard extends StatelessWidget {
  final AvailableNowItem item;
  final AppLanguage lang;

  const _AvailableNowCard({required this.item, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    t('available_now', lang),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (item.price != null)
              Text(
                'P${item.price!.toStringAsFixed(2)} / ${item.unit ?? 'unit'}',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestGreen),
              ),
            if (item.quantity != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${t('quantity', lang)}: ${item.quantity}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(item.sellerName,
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey[600])),
                const SizedBox(width: 12),
                Icon(Icons.location_on_outlined,
                    size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(item.location,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingHarvestCard extends StatelessWidget {
  final UpcomingHarvestItem item;
  final AppLanguage lang;

  const _UpcomingHarvestCard({required this.item, required this.lang});

  @override
  Widget build(BuildContext context) {
    final daysText = item.daysUntilHarvest <= 1
        ? t('tomorrow', lang)
        : '${item.daysUntilHarvest} ${t('days', lang)}';
    final harvestDateStr = item.expectedHarvestDate != null
        ? DateFormat('d MMM yyyy').format(item.expectedHarvestDate!)
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t(item.cropType, lang),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  daysText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: item.daysUntilHarvest <= 14
                        ? AppColors.earthBrown
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (item.estimatedYield != null)
              Text(
                '~${item.estimatedYield!.toStringAsFixed(0)} ${item.yieldUnit ?? 'kg'} ${t('estimated', lang).toLowerCase()}',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.forestGreen),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (harvestDateStr.isNotEmpty) ...[
                  Icon(Icons.calendar_today_outlined,
                      size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(harvestDateStr,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(width: 12),
                ],
                if (item.location != null) ...[
                  Icon(Icons.location_on_outlined,
                      size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(item.location!,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
