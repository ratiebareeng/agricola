import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/utils/error_utils.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:agricola/core/widgets/app_dialogs.dart';
import 'package:agricola/features/orders/models/order_model.dart';
import 'package:agricola/features/orders/providers/orders_provider.dart';
import 'package:agricola/features/orders/widgets/order_card_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tabbed orders screen showing Sales (as seller) + My Requests (as buyer).
/// [showSalesTab] controls whether the Sales tab is visible (for AgriShop / merchants).
class OrdersScreen extends ConsumerStatefulWidget {
  final bool showSalesTab;

  const OrdersScreen({super.key, this.showSalesTab = true});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.showSalesTab ? 2 : 1,
      vsync: this,
    );
    // Refresh on every visit so newly placed orders appear immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(buyerOrdersProvider.notifier).loadOrders();
      if (widget.showSalesTab) {
        ref.read(sellerOrdersProvider.notifier).loadOrders();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          t('my_orders', lang),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.green,
        elevation: 0,
        bottom: widget.showSalesTab
            ? TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: t('sales', lang)),
                  Tab(text: t('my_requests', lang)),
                ],
              )
            : null,
      ),
      body: widget.showSalesTab
          ? TabBarView(
              controller: _tabController,
              children: [
                _OrdersList(
                  provider: sellerOrdersProvider,
                  emptyTitle: t('no_orders_yet', lang),
                  emptySubtitle: t('orders_will_appear_here', lang),
                  emptyIcon: Icons.receipt_long_outlined,
                  isSeller: true,
                ),
                _OrdersList(
                  provider: buyerOrdersProvider,
                  emptyTitle: t('no_purchase_requests', lang),
                  emptySubtitle: t('purchase_requests_appear_here', lang),
                  emptyIcon: Icons.shopping_cart_outlined,
                  isSeller: false,
                ),
              ],
            )
          : _OrdersList(
              provider: buyerOrdersProvider,
              emptyTitle: t('no_purchase_requests', lang),
              emptySubtitle: t('purchase_requests_appear_here', lang),
              emptyIcon: Icons.shopping_cart_outlined,
              isSeller: false,
            ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  final StateNotifierProvider<OrdersNotifier, AsyncValue<List<OrderModel>>>
      provider;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;
  final bool isSeller;

  const _OrdersList({
    required this.provider,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.emptyIcon,
    required this.isSeller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final ordersAsync = ref.watch(provider);

    return ordersAsync.when(
      data: (orders) => orders.isEmpty
          ? _buildEmpty(context)
          : _buildList(context, ref, orders, lang),
      loading: () => ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(4, (_) => const OrderCardSkeleton()),
      ),
      error: (error, _) => _buildError(context, ref, error, lang),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<OrderModel> orders,
    AppLanguage lang,
  ) {
    return RefreshIndicator(
      color: AppColors.green,
      onRefresh: () => ref.read(provider.notifier).loadOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) =>
            _OrderCard(order: orders[index], isSeller: isSeller, lang: lang),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 72, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              emptyTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    WidgetRef ref,
    Object error,
    AppLanguage lang,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'Failed to load orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              t(errorKeyFromException(error), lang),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            AgriStadiumButton(
              onPressed: () => ref.read(provider.notifier).loadOrders(),
              icon: Icons.refresh,
              label: t('retry', lang),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderModel order;
  final bool isSeller;
  final AppLanguage lang;

  const _OrderCard({
    required this.order,
    required this.isSeller,
    required this.lang,
  });

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OrderDetailsSheet(order: order, lang: lang),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetails(context),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 10),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 6, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'x${item.quantity}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _formatDate(order.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const Spacer(),
                Text(
                  'P ${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
            if (isSeller &&
                (order.status == 'pending' || order.status == 'confirmed')) ...[
              const Divider(height: 24),
              _SellerActions(order: order, lang: lang, onShowDetails: () => _showDetails(context)),
            ],
            if (!isSeller && order.status == 'pending') ...[
              const Divider(height: 24),
              _BuyerActions(order: order, lang: lang),
            ],
          ],
        ),
      ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SellerActions extends ConsumerWidget {
  final OrderModel order;
  final AppLanguage lang;
  final VoidCallback onShowDetails;

  const _SellerActions({
    required this.order,
    required this.lang,
    required this.onShowDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextStatus = _nextStatus(order.status);
    if (nextStatus == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: AgriStadiumButton(
            onPressed: onShowDetails,
            label: t('view_details', lang),
            isPrimary: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AgriStadiumButton(
            onPressed: () => _updateStatus(context, ref, nextStatus),
            label: _actionLabel(order.status),
          ),
        ),
      ],
    );
  }

  String? _nextStatus(String s) {
    switch (s) {
      case 'pending':
        return 'confirmed';
      case 'confirmed':
        return 'shipped';
      case 'shipped':
        return 'delivered';
      default:
        return null;
    }
  }

  String _actionLabel(String s) {
    switch (s) {
      case 'pending':
        return 'Confirm';
      case 'confirmed':
        return 'Ship';
      case 'shipped':
        return 'Delivered';
      default:
        return 'Update';
    }
  }

  Future<void> _updateStatus(
      BuildContext context, WidgetRef ref, String next) async {
    final error = await ref
        .read(sellerOrdersProvider.notifier)
        .updateOrderStatus(order.id!, next);
    if (context.mounted && error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(error, lang)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _BuyerActions extends ConsumerWidget {
  final OrderModel order;
  final AppLanguage lang;

  const _BuyerActions({required this.order, required this.lang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: AgriStadiumButton(
            onPressed: () => _confirmCancel(context, ref),
            label: t('cancel_order', lang),
            isPrimary: false,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: t('cancel_order', lang),
      content: t('cancel_order_confirm', lang),
      cancelText: t('cancel', lang),
      actionText: t('cancel_order', lang),
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final error =
        await ref.read(buyerOrdersProvider.notifier).cancelOrder(order.id!);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              error != null ? t(error, lang) : t('order_cancelled', lang)),
          backgroundColor: error != null ? Colors.red : AppColors.green,
        ),
      );
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = _config(status);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  (Color, IconData, String) _config(String s) {
    switch (s) {
      case 'pending':
        return (AppColors.warmYellow, Icons.schedule, 'Pending');
      case 'confirmed':
        return (AppColors.green, Icons.check_circle, 'Confirmed');
      case 'shipped':
        return (AppColors.mediumGray, Icons.local_shipping, 'Shipped');
      case 'delivered':
        return (AppColors.green, Icons.done_all, 'Delivered');
      case 'cancelled':
        return (AppColors.alertRed, Icons.cancel, 'Cancelled');
      default:
        return (AppColors.mediumGray, Icons.help_outline, s);
    }
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  final OrderModel order;
  final AppLanguage lang;

  const _OrderDetailsSheet({required this.order, required this.lang});

  @override
  Widget build(BuildContext context) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final d = order.createdAt;
    final dateStr =
        '${d.day} ${months[d.month - 1]} ${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scroll) => SingleChildScrollView(
        controller: scroll,
        padding: const EdgeInsets.all(24),
        child: Column(
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Items',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            Text(
                              'Qty: ${item.quantity} × P ${item.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'P ${(item.price * item.quantity).toStringAsFixed(2)}',
                        style:
                            const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  'P ${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Order placed: $dateStr',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
