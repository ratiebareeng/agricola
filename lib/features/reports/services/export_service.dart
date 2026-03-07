import 'dart:io';

import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/features/crops/models/crop_model.dart';
import 'package:agricola/features/inventory/models/inventory_model.dart';
import 'package:agricola/features/orders/models/order_model.dart';
import 'package:agricola/features/purchases/models/purchase_model.dart';
import 'package:agricola/features/reports/providers/reports_provider.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

// ---------------------------------------------------------------------------
// CSV generation
// ---------------------------------------------------------------------------

String cropsToCsv(List<CropModel> crops, AppLanguage lang) {
  final headers = [
    t('crop_type', lang),
    t('field_name', lang),
    t('field_size', lang),
    t('unit', lang),
    t('planting_date', lang),
    t('expected_harvest', lang),
    t('estimated_yield', lang),
    t('yield_unit', lang),
    t('storage_method', lang),
    t('notes', lang),
  ];
  final rows = crops.map((c) => [
        c.cropType,
        c.fieldName,
        c.fieldSize,
        c.fieldSizeUnit,
        _fmtDate(c.plantingDate),
        _fmtDate(c.expectedHarvestDate),
        c.estimatedYield,
        c.yieldUnit,
        c.storageMethod,
        c.notes ?? '',
      ]);
  return const ListToCsvConverter().convert([headers, ...rows]);
}

String inventoryToCsv(List<InventoryModel> items, AppLanguage lang) {
  final headers = [
    t('crop_type', lang),
    t('quantity', lang),
    t('unit', lang),
    t('storage_date', lang),
    t('storage_location', lang),
    t('condition', lang),
    t('notes', lang),
  ];
  final rows = items.map((i) => [
        i.cropType,
        i.quantity,
        i.unit,
        _fmtDate(i.storageDate),
        i.storageLocation,
        i.condition,
        i.notes ?? '',
      ]);
  return const ListToCsvConverter().convert([headers, ...rows]);
}

String purchasesToCsv(List<PurchaseModel> purchases, AppLanguage lang) {
  final headers = [
    t('crop_type', lang),
    t('seller', lang),
    t('quantity', lang),
    t('unit', lang),
    t('price_per_unit', lang),
    t('total_amount', lang),
    t('purchase_date', lang),
    t('notes', lang),
  ];
  final rows = purchases.map((p) => [
        p.cropType,
        p.sellerName,
        p.quantity,
        p.unit,
        p.pricePerUnit,
        p.totalAmount,
        _fmtDate(p.purchaseDate),
        p.notes ?? '',
      ]);
  return const ListToCsvConverter().convert([headers, ...rows]);
}

String ordersToCsv(List<OrderModel> orders, AppLanguage lang) {
  final headers = [
    t('order_id', lang),
    t('status', lang),
    t('items', lang),
    t('total_amount', lang),
    t('date', lang),
  ];
  final rows = orders.map((o) => [
        o.id ?? '',
        o.status,
        o.items.map((i) => '${i.title} x${i.quantity}').join('; '),
        o.totalAmount,
        _fmtDate(o.createdAt),
      ]);
  return const ListToCsvConverter().convert([headers, ...rows]);
}

// ---------------------------------------------------------------------------
// PDF generation
// ---------------------------------------------------------------------------

Future<List<int>> farmerSummaryPdf(
    FarmerReportStats stats, AppLanguage lang) async {
  final pdf = pw.Document();
  final date = _fmtDate(DateTime.now());

  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    build: (context) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Agricola — ${t('farm_summary', lang)}',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text('${t('generated_on', lang)}: $date',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Divider(),
        pw.SizedBox(height: 12),
        _pdfSection(t('farm_overview', lang), [
          _pdfRow(t('total_fields', lang), '${stats.totalCrops}'),
          _pdfRow(t('active_crops', lang), '${stats.activeCrops}'),
          _pdfRow(t('harvested', lang), '${stats.harvestedCrops}'),
          _pdfRow(t('upcoming_harvests', lang), '${stats.upcomingHarvests}'),
        ]),
        pw.SizedBox(height: 16),
        _pdfSection(t('field_summary', lang), [
          _pdfRow(t('total_field_size', lang),
              '${stats.totalFieldSize.toStringAsFixed(1)} ha'),
          _pdfRow(t('estimated_yield', lang),
              '${stats.totalEstimatedYield.toStringAsFixed(1)} kg'),
          _pdfRow(t('inventory_items', lang), '${stats.inventoryItems}'),
          _pdfRow(t('items_need_attention', lang), '${stats.criticalItems}'),
          _pdfRow(
              t('marketplace_listings', lang), '${stats.marketplaceListings}'),
        ]),
      ],
    ),
  ));
  return pdf.save();
}

Future<List<int>> merchantSummaryPdf(
    MerchantReportStats stats, AppLanguage lang) async {
  final pdf = pw.Document();
  final date = _fmtDate(DateTime.now());

  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    build: (context) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Agricola — ${t('business_summary', lang)}',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text('${t('generated_on', lang)}: $date',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Divider(),
        pw.SizedBox(height: 12),
        _pdfSection(t('business_overview', lang), [
          _pdfRow(t('total_products', lang), '${stats.totalProducts}'),
          _pdfRow(t('active_orders', lang), '${stats.activeOrders}'),
          _pdfRow(t('total_purchases', lang), '${stats.totalPurchases}'),
          _pdfRow(t('suppliers', lang), '${stats.totalSuppliers}'),
        ]),
        pw.SizedBox(height: 16),
        _pdfSection(t('financial_summary', lang), [
          _pdfRow(t('monthly_revenue', lang),
              'P ${stats.monthlyRevenue.toStringAsFixed(2)}'),
          _pdfRow(t('total_revenue', lang),
              'P ${stats.totalRevenue.toStringAsFixed(2)}'),
          _pdfRow(t('monthly_purchases', lang),
              'P ${stats.monthlyPurchaseValue.toStringAsFixed(2)}'),
          _pdfRow(t('total_purchase_value', lang),
              'P ${stats.totalPurchaseValue.toStringAsFixed(2)}'),
        ]),
        pw.SizedBox(height: 16),
        _pdfSection(t('inventory_summary', lang), [
          _pdfRow(t('inventory_items', lang), '${stats.inventoryItems}'),
          _pdfRow(t('low_stock_items', lang), '${stats.lowStockItems}'),
          _pdfRow(
              t('marketplace_listings', lang), '${stats.marketplaceListings}'),
        ]),
      ],
    ),
  ));
  return pdf.save();
}

// ---------------------------------------------------------------------------
// Share / save
// ---------------------------------------------------------------------------

Future<void> shareExportFile(
    String content, String filename, String mimeType) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsString(content);
  await Share.shareXFiles([XFile(file.path, mimeType: mimeType)]);
}

Future<void> sharePdfFile(List<int> bytes, String filename) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes);
  await Share.shareXFiles([XFile(file.path, mimeType: 'application/pdf')]);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _fmtDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

pw.Widget _pdfSection(String title, List<pw.Widget> rows) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
      ...rows,
    ],
  );
}

pw.Widget _pdfRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
        pw.Text(value,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      ],
    ),
  );
}
