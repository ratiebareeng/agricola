import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:agricola/core/widgets/app_dialogs.dart';
import 'package:agricola/core/widgets/app_network_image.dart';
import 'package:agricola/core/widgets/app_text_field.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/marketplace/models/marketplace_listing.dart';
import 'package:agricola/features/marketplace/providers/marketplace_provider.dart';
import 'package:agricola/features/marketplace/screens/add_product_screen.dart';
import 'package:agricola/features/orders/models/order_model.dart';
import 'package:agricola/features/orders/providers/orders_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketplaceDetailScreen extends ConsumerWidget {
  final MarketplaceListing listing;

  const MarketplaceDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isOwner = currentUser != null && listing.sellerId == currentUser.uid;

    return Scaffold(
      backgroundColor: AppColors.bone,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: AppColors.deepEmerald,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.bone.withValues(alpha: 0.9), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: AppColors.deepEmerald, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: isOwner
                ? [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.bone.withValues(alpha: 0.9), shape: BoxShape.circle),
                        child: const Icon(Icons.edit, color: AppColors.forestGreen, size: 20),
                      ),
                      onPressed: () => _editListing(context, ref),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.bone.withValues(alpha: 0.9), shape: BoxShape.circle),
                        child: const Icon(Icons.delete, color: AppColors.alertRed, size: 20),
                      ),
                      onPressed: () => _confirmDelete(context, ref, currentLang),
                    ),
                  ]
                : null,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final top = constraints.biggest.height;
                final isCollapsed = top <= MediaQuery.of(context).padding.top + kToolbarHeight;
                return FlexibleSpaceBar(
                  centerTitle: true,
                  title: isCollapsed
                      ? Text(
                          listing.title.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.bone,
                            letterSpacing: 1.5,
                          ),
                        )
                      : null,
                  background: _buildImageGallery(listing),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.title,
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 28),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 14, color: AppColors.deepEmerald.withValues(alpha: 0.3)),
                                const SizedBox(width: 4),
                                Text(
                                  listing.location.toUpperCase(),
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.deepEmerald.withValues(alpha: 0.4), letterSpacing: 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (listing.status != null) _buildStatusBadge(listing.status!, currentLang),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (listing.price != null)
                    AgriFocusCard(
                      color: AppColors.deepEmerald,
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Expanded(
                            child: AgriMetricDisplay(
                              value: 'P${listing.price!.toStringAsFixed(0)}',
                              label: t('price', currentLang),
                              valueColor: AppColors.bone,
                              labelColor: AppColors.bone.withValues(alpha: 0.5),
                            ),
                          ),
                          if (listing.quantity != null) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: AgriMetricDisplay(
                                value: AgriKit.formatQuantity(double.tryParse(listing.quantity!) ?? 0),
                                label: t('available', currentLang),
                                valueColor: AppColors.earthYellow,
                                labelColor: AppColors.earthYellow.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 40),
                  Text(
                    t('description', currentLang).toUpperCase(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.deepEmerald.withValues(alpha: 0.4)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    listing.description,
                    style: TextStyle(fontSize: 16, height: 1.6, color: AppColors.deepEmerald.withValues(alpha: 0.7), fontWeight: FontWeight.w500),
                  ),
                  if (listing.harvestDate != null) ...[
                    const SizedBox(height: 32),
                    AgriFocusCard(
                      padding: const EdgeInsets.all(20),
                      color: AppColors.forestGreen.withValues(alpha: 0.05),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: AppColors.forestGreen, size: 20),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t('expected_harvest_date', currentLang).toUpperCase(),
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.forestGreen.withValues(alpha: 0.5), letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                listing.harvestDate!,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.forestGreen),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 48),
                  Text(
                    t('seller_information', currentLang).toUpperCase(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.deepEmerald.withValues(alpha: 0.4)),
                  ),
                  const SizedBox(height: 20),
                  AgriFocusCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.bone, borderRadius: BorderRadius.circular(16)),
                              child: Icon(
                                listing.type == ListingType.produce ? Icons.agriculture : Icons.store,
                                color: AppColors.forestGreen,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    listing.sellerName,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.deepEmerald),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    (listing.type == ListingType.produce ? t('farmer', currentLang) : t('supplier', currentLang)).toUpperCase(),
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.deepEmerald.withValues(alpha: 0.3), letterSpacing: 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        if (listing.sellerPhone != null)
                          AgriStadiumButton(
                            onPressed: () => _makePhoneCall(listing.sellerPhone!),
                            label: t('call_seller', currentLang).toUpperCase(),
                            icon: Icons.phone_outlined,
                          ),
                        if (listing.sellerEmail != null) ...[
                          const SizedBox(height: 16),
                          AgriStadiumButton(
                            onPressed: () => _sendEmail(listing.sellerEmail!, listing.title),
                            label: t('email_seller', currentLang).toUpperCase(),
                            icon: Icons.email_outlined,
                            isPrimary: false,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(color: AppColors.deepEmerald.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: isOwner
              ? AgriStadiumButton(
                  onPressed: () => _editListing(context, ref),
                  icon: Icons.edit_outlined,
                  label: t('edit_listing', currentLang),
                )
              : Row(
                  children: [
                    if (listing.sellerPhone != null)
                      SizedBox(
                        width: 64,
                        child: AgriStadiumButton(
                          onPressed: () => _makePhoneCall(listing.sellerPhone!),
                          label: '',
                          icon: Icons.phone_outlined,
                          isPrimary: false,
                        ),
                      ),
                    if (listing.sellerPhone != null) const SizedBox(width: 16),
                    Expanded(
                      child: AgriStadiumButton(
                        onPressed: listing.price != null ? () => _showRequestToBuySheet(context, ref, currentLang) : null,
                        icon: Icons.shopping_cart_outlined,
                        label: t('request_to_buy', currentLang),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(MarketplaceListing listing) {
    final allImages = [
      if (listing.imagePath != null && listing.imagePath!.isNotEmpty) listing.imagePath!,
      ...?listing.additionalImages,
    ].where((url) => url.isNotEmpty).toList();

    if (allImages.isEmpty) return _buildPlaceholderImage();

    return Stack(
      children: [
        PageView.builder(
          itemCount: allImages.length,
          itemBuilder: (context, index) => AppNetworkImage(
            url: allImages[index],
            width: double.infinity,
            errorWidget: _buildPlaceholderImage(),
          ),
        ),
        if (allImages.length > 1)
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                allImages.length,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.white.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.deepEmerald.withValues(alpha: 0.05),
      child: Center(
        child: Icon(
          listing.type == ListingType.produce ? Icons.agriculture : Icons.store,
          size: 80,
          color: AppColors.deepEmerald.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(CropStatus status, AppLanguage lang) {
    Color color;
    String label;
    switch (status) {
      case CropStatus.harvested:
        color = AppColors.forestGreen;
        label = t('harvested', lang);
        break;
      case CropStatus.readyToHarvest:
        color = AppColors.earthYellow;
        label = t('ready_soon', lang);
        break;
      case CropStatus.growing:
        color = AppColors.forestGreen;
        label = t('growing', lang);
        break;
      case CropStatus.planted:
        color = AppColors.mediumGray;
        label = t('planted', lang);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5),
      ),
    );
  }

  void _showRequestToBuySheet(BuildContext context, WidgetRef ref, AppLanguage lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bone,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => _RequestToBuySheet(listing: listing, lang: lang),
    );
  }

  void _editListing(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => AddProductScreen(existingProduct: listing)),
    );
    if (result == true && context.mounted) {
      ref.read(marketplaceNotifierProvider.notifier).refresh();
      Navigator.pop(context, true);
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, AppLanguage currentLang) async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: t('delete', currentLang),
      content: t('delete_listing_confirm', currentLang),
      cancelText: t('cancel', currentLang),
      actionText: t('delete', currentLang),
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      final error = await ref.read(marketplaceNotifierProvider.notifier).deleteListing(listing.id);
      if (context.mounted) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t(error, currentLang)), backgroundColor: AppColors.alertRed),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t('listing_deleted', currentLang)), backgroundColor: AppColors.forestGreen),
          );
          Navigator.pop(context, true);
        }
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendEmail(String email, String subject) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: encodeQueryParameters(<String, String>{
        'subject': 'Agricola Marketplace: $subject',
      }),
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries.map((MapEntry<String, String> e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
  }
}

class _RequestToBuySheet extends ConsumerStatefulWidget {
  final MarketplaceListing listing;
  final AppLanguage lang;

  const _RequestToBuySheet({required this.listing, required this.lang});

  @override
  ConsumerState<_RequestToBuySheet> createState() => _RequestToBuySheetState();
}

class _RequestToBuySheetState extends ConsumerState<_RequestToBuySheet> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController(text: '1');
  final _noteController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _qtyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int get _qty => int.tryParse(_qtyController.text) ?? 1;
  double get _unitPrice => widget.listing.price ?? 0;
  double get _total => _qty * _unitPrice;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final item = OrderItem(
      listingId: widget.listing.id,
      title: widget.listing.title,
      price: _unitPrice,
      quantity: _qty,
    );

    final error = await ref.read(buyerOrdersProvider.notifier).createOrder(
          sellerId: widget.listing.sellerId,
          totalAmount: _total,
          items: [item],
        );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(error, widget.lang)), backgroundColor: AppColors.alertRed),
      );
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('request_sent', widget.lang), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(t('seller_will_contact_you', widget.lang)),
          ],
        ),
        backgroundColor: AppColors.forestGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 32, right: 32, top: 32, bottom: MediaQuery.of(context).viewInsets.bottom + 32),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 48, height: 6, decoration: BoxDecoration(color: AppColors.deepEmerald.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(3))),
            ),
            const SizedBox(height: 32),
            Text(t('request_to_buy', widget.lang), style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(widget.listing.title, style: TextStyle(fontSize: 16, color: AppColors.deepEmerald.withValues(alpha: 0.5), fontWeight: FontWeight.w600)),
            const SizedBox(height: 40),
            AppTextField(
              label: t('quantity', widget.lang),
              controller: _qtyController,
              keyboardType: TextInputType.number,
              hint: t('enter_quantity', widget.lang),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 1) return t('quantity_must_be_positive', widget.lang);
                return null;
              },
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: t('optional_note', widget.lang),
              controller: _noteController,
              maxLines: 2,
              hint: t('note_hint', widget.lang),
            ),
            const SizedBox(height: 40),
            AgriFocusCard(
              color: AppColors.deepEmerald,
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AgriMetricDisplay(
                    value: 'P${_total.toStringAsFixed(0)}',
                    label: t('total', widget.lang),
                    valueColor: AppColors.bone,
                    labelColor: AppColors.bone.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AgriStadiumButton(onPressed: _loading ? null : _submit, isLoading: _loading, label: t('send_request', widget.lang)),
          ],
        ),
      ),
    );
  }
}
