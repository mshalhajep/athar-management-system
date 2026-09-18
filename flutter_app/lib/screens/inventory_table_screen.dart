import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../models/purchase.dart';
import '../services/purchases_service.dart';
import '../theme/app_theme.dart';
import '../widgets/invoice_details_dialog.dart';
import '../widgets/invoice_viewer_dialog.dart';
import '../widgets/purchase_form_dialog.dart';

enum InventorySortOption {
  dateDesc('الأحدث أولاً'),
  dateAsc('الأقدم أولاً'),
  quantityDesc('الكمية (الأعلى)'),
  quantityAsc('الكمية (الأقل)'),
  priceDesc('القيمة (الأعلى)'),
  nameAsc('الاسم (أ - ي)');

  final String label;
  const InventorySortOption(this.label);
}

class InventoryTableScreen extends StatefulWidget {
  final PurchasesService purchasesService;

  const InventoryTableScreen({
    super.key,
    required this.purchasesService,
  });

  @override
  State<InventoryTableScreen> createState() => _InventoryTableScreenState();
}

class _InventoryTableScreenState extends State<InventoryTableScreen> {
  String _tableSearch = '';
  InventorySortOption _sortOption = InventorySortOption.dateDesc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Purchase> _getSortedAndFilteredList(List<Purchase> all) {
    final query = _tableSearch.trim().toLowerCase();
    final filtered = all.where((p) {
      if (query.isEmpty) return true;
      return p.itemName.toLowerCase().contains(query) ||
          (p.notes ?? '').toLowerCase().contains(query) ||
          p.purchaseDate.contains(query);
    }).toList();

    switch (_sortOption) {
      case InventorySortOption.dateDesc:
        filtered.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
        break;
      case InventorySortOption.dateAsc:
        filtered.sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));
        break;
      case InventorySortOption.quantityDesc:
        filtered.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case InventorySortOption.quantityAsc:
        filtered.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case InventorySortOption.priceDesc:
        filtered.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
        break;
      case InventorySortOption.nameAsc:
        filtered.sort((a, b) => a.itemName.compareTo(b.itemName));
        break;
    }

    return filtered;
  }

  void _copyInventorySummary(List<Purchase> items) {
    final buffer = StringBuffer();
    buffer.writeln('📋 تقرير جدول مخزون شركة أثر:');
    buffer.writeln('----------------------------------------');
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      buffer.writeln(
        '${i + 1}. ${item.itemName} | الكمية: ${item.quantity} | السعر: ${item.unitPrice} ر.س | الإجمالي: ${item.totalPrice} ر.س | التاريخ: ${item.purchaseDate}',
      );
    }
    buffer.writeln('----------------------------------------');
    final totalQty = items.fold(0, (sum, p) => sum + p.quantity);
    final totalSum = items.fold(0.0, (sum, p) => sum + p.totalPrice);
    buffer.writeln('إجمالي القطع في المخزون: $totalQty');
    buffer.writeln('إجمالي القيمة التقديرية: ${totalSum.toStringAsFixed(2)} ر.س');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ بيانات تقرير المخزون للحافظة بنجاح ✅'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _confirmDelete(Purchase item) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.danger),
              SizedBox(width: 8),
              Text('حذف من المخزون', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          content: Text('هل أنت متأكد من حذف الصنف "${item.itemName}" من جدول المخزون نهائياً؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                widget.purchasesService.deletePurchase(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم حذف "${item.itemName}" بنجاح')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              child: const Text('تأكيد الحذف'),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditModal(Purchase item) {
    PurchaseFormDialog.show(
      context: context,
      editingPurchase: item,
      onSave: ({
        String? itemName,
        int? quantity,
        double? unitPrice,
        List<InvoiceItem>? items,
        required String purchaseDate,
        String? invoiceUri,
        String? notes,
      }) async {
        await widget.purchasesService.updatePurchase(
          item.copyWith(
            itemName: itemName,
            quantity: quantity,
            unitPrice: unitPrice,
            items: items,
            purchaseDate: purchaseDate,
            invoiceUri: invoiceUri,
            notes: notes,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.purchasesService,
      builder: (context, _) {
        final allItems = widget.purchasesService.purchases;
        final displayedItems = _getSortedAndFilteredList(allItems);

        final isSearching = _tableSearch.trim().isNotEmpty;
        final totalItemsCount = isSearching ? displayedItems.length : allItems.length;
        final totalUnitsCount = isSearching
            ? displayedItems.fold(0, (sum, p) => sum + p.quantity)
            : allItems.fold(0, (sum, p) => sum + p.quantity);
        final totalValuation = isSearching
            ? displayedItems.fold(0.0, (sum, p) => sum + p.totalPrice)
            : allItems.fold(0.0, (sum, p) => sum + p.totalPrice);
        final currencyFmt = NumberFormat('#,##0.00', 'ar_SA');

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // Top KPI Summary Header Bar
              Container(
                color: AppColors.pureWhite,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Stat 1: Items Count
                        Expanded(
                          child: _buildMiniStat(
                            title: 'الأصناف',
                            value: '$totalItemsCount',
                            icon: Icons.category_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Stat 2: Total Units
                        Expanded(
                          child: _buildMiniStat(
                            title: 'إجمالي القطع',
                            value: '$totalUnitsCount',
                            icon: Icons.inventory_rounded,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Stat 3: Valuation
                        Expanded(
                          child: _buildMiniStat(
                            title: 'قيمة المخزون',
                            value: '${currencyFmt.format(totalValuation)} ر.س',
                            icon: Icons.account_balance_wallet_rounded,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Search & Sort Controls
                    Row(
                      children: [
                        // Search bar
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => setState(() => _tableSearch = val),
                              decoration: InputDecoration(
                                hintText: 'بحث في جدول المخزون...',
                                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.primary),
                                suffixIcon: _tableSearch.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _tableSearch = '');
                                        },
                                      )
                                    : null,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Sort dropdown
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<InventorySortOption>(
                              value: _sortOption,
                              icon: const Icon(Icons.sort, color: AppColors.primary, size: 20),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                              items: InventorySortOption.values.map((opt) {
                                return DropdownMenuItem(
                                  value: opt,
                                  child: Text(opt.label),
                                );
                              }).toList(),
                              onChanged: (opt) {
                                if (opt != null) setState(() => _sortOption = opt);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Copy / Export report button
                        IconButton.filled(
                          onPressed: () => _copyInventorySummary(displayedItems),
                          icon: const Icon(Icons.copy_all_rounded, size: 20),
                          tooltip: 'نسخ تقرير المخزون',
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: AppColors.border),

              // Table Content
              Expanded(
                child: displayedItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.table_chart_outlined,
                              size: 64,
                              color: AppColors.textLight.withValues(alpha: 0.6),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'لا توجد أصناف تطابق البحث في المخزون',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.pureWhite,
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: DataTable(
                                    headingRowColor: const WidgetStatePropertyAll(AppColors.tableHeader),
                                    dataRowMinHeight: 48,
                                    dataRowMaxHeight: 56,
                                    horizontalMargin: 16,
                                    columnSpacing: 22,
                                    columns: const [
                                      DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.w800))),
                                      DataColumn(label: Text('اسم الصنف', style: TextStyle(fontWeight: FontWeight.w800))),
                                      DataColumn(label: Text('الكمية', style: TextStyle(fontWeight: FontWeight.w800))),
                                      DataColumn(label: Text('سعر الحبة', style: TextStyle(fontWeight: FontWeight.w800))),
                                      DataColumn(label: Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.w800))),
                                      DataColumn(label: Text('تاريخ الشراء', style: TextStyle(fontWeight: FontWeight.w800))),
                                      DataColumn(label: Text('ملاحظات', style: TextStyle(fontWeight: FontWeight.w800))),
                                      DataColumn(label: Text('الفاتورة', style: TextStyle(fontWeight: FontWeight.w800))),
                                      DataColumn(label: Text('الإجراءات', style: TextStyle(fontWeight: FontWeight.w800))),
                                    ],
                                    rows: List.generate(displayedItems.length, (index) {
                                      final item = displayedItems[index];
                                      final isEven = index % 2 == 0;
                                      return DataRow(
                                        color: WidgetStatePropertyAll(
                                          isEven ? AppColors.pureWhite : AppColors.tableRowAlternate,
                                        ),
                                        cells: [
                                          // Index
                                          DataCell(
                                            Text(
                                              '${index + 1}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted),
                                            ),
                                          ),
                                          // Item Name
                                          DataCell(
                                            Text(
                                              item.itemName,
                                              style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMain),
                                            ),
                                          ),
                                          // Quantity
                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryLight,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${item.quantity}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.primaryDark,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Unit Price
                                          DataCell(
                                            Text(
                                              '${item.unitPrice.toStringAsFixed(2)} ر.س',
                                              style: const TextStyle(color: AppColors.textMuted),
                                            ),
                                          ),
                                          // Total Price
                                          DataCell(
                                            Text(
                                              '${item.totalPrice.toStringAsFixed(2)} ر.س',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.success,
                                              ),
                                            ),
                                          ),
                                          // Purchase Date
                                          DataCell(
                                            Text(
                                              item.purchaseDate,
                                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                            ),
                                          ),
                                          // Notes
                                          DataCell(
                                            SizedBox(
                                              width: 140,
                                              child: Text(
                                                item.notes?.isNotEmpty == true ? item.notes! : '-',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                                              ),
                                            ),
                                          ),
                                          // Invoice preview icon
                                          DataCell(
                                            item.invoiceUri != null && item.invoiceUri!.isNotEmpty
                                                ? IconButton(
                                                    icon: const Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
                                                    tooltip: 'معاينة الفاتورة',
                                                    onPressed: () {
                                                      InvoiceViewerDialog.show(
                                                        context,
                                                        item.invoiceUri!,
                                                      );
                                                    },
                                                  )
                                                : const Text('-', style: TextStyle(color: AppColors.textLight)),
                                          ),
                                          // Actions
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.remove_red_eye_outlined, size: 18, color: AppColors.textMain),
                                                  tooltip: 'تفاصيل الفاتورة',
                                                  onPressed: () {
                                                    InvoiceDetailsDialog.show(
                                                      context: context,
                                                      purchase: item,
                                                      onEdit: () => _openEditModal(item),
                                                      onDelete: () => _confirmDelete(item),
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                                  tooltip: 'تعديل',
                                                  onPressed: () => _openEditModal(item),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                                  tooltip: 'حذف',
                                                  onPressed: () => _confirmDelete(item),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
