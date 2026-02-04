import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:agricola/features/inventory/providers/inventory_providers.dart';
import 'package:agricola/features/inventory/screens/add_edit_inventory_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class InventoryDetailScreen extends ConsumerStatefulWidget {
  final InventoryModel item;

  const InventoryDetailScreen({super.key, required this.item});

  @override
  ConsumerState<InventoryDetailScreen> createState() =>
      _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends ConsumerState<InventoryDetailScreen> {
  late InventoryModel _item;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final dateFormat = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: Text(t('inventory_details', language)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editItem(context, language),
          ),
          IconButton(
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete),
            onPressed: _isDeleting ? null : () => _confirmDelete(context, language),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(context),
            const SizedBox(height: 24),
            _buildHeader(context, language),
            const SizedBox(height: 24),
            _buildDetailSection(
              context,
              title: t('storage_info', language),
              children: [
                _buildDetailRow(
                  context,
                  icon: Icons.calendar_today,
                  label: t('storage_date', language),
                  value: dateFormat.format(_item.storageDate),
                ),
                _buildDetailRow(
                  context,
                  icon: Icons.location_on,
                  label: t('location', language),
                  value: _item.storageLocation,
                ),
                _buildDetailRow(
                  context,
                  icon: Icons.info_outline,
                  label: t('condition', language),
                  value: t(_item.condition, language),
                ),
              ],
            ),
            if (_item.notes != null && _item.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildDetailSection(
                context,
                title: t('notes', language),
                children: [
                  Text(_item.notes!, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _editItem(BuildContext context, AppLanguage language) async {
    final result = await Navigator.push<InventoryModel>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditInventoryScreen(existingItem: _item),
      ),
    );

    if (result != null && context.mounted) {
      final error = await ref
          .read(inventoryNotifierProvider.notifier)
          .updateInventory(result);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t('error', language)}: $error'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (context.mounted) {
        setState(() {
          _item = result;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('inventory_updated', language)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, AppLanguage language) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('delete_inventory', language)),
        content: Text(t('delete_inventory_confirm', language)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('cancel', language)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t('delete', language)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _deleteItem(context, language);
    }
  }

  Future<void> _deleteItem(BuildContext context, AppLanguage language) async {
    if (_item.id == null) return;

    setState(() => _isDeleting = true);

    final error = await ref
        .read(inventoryNotifierProvider.notifier)
        .deleteInventory(_item.id!);

    if (!context.mounted) return;

    setState(() => _isDeleting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${t('error', language)}: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('inventory_deleted', language)),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppLanguage language) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.inventory_2,
              color: Colors.green.shade800,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(_item.cropType, language),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_item.quantity} ${t(_item.unit, language)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(
                  'https://picsum.photos/seed/${_item.id ?? 'default'}$index/600/400',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                if (index == 0)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(60),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Primary',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
