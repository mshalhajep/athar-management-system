import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/purchase.dart';
import '../theme/app_theme.dart';
import 'invoice_details_dialog.dart';
import 'invoice_viewer_dialog.dart';

/// [محاضرة 6 و 9]:
/// - [محاضرة 6]: استخدام الـ Widgets الأساسية (Card, Container, Padding, Row, Column, SizedBox, Text, Icons).
/// - [محاضرة 9]: كلاس منعزل لعرض بطاقة العنصر، وأزرار التعديل والحذف، وتأكيد الحذف عبر showDialog و AlertDialog، والتفاعل عبر InkWell.
/// تم تطويرها لتدعم النقر لفتح تفاصيل الفاتورة كاملة مع كافة الأصناف.
class PurchaseCard extends StatelessWidget {
  final Purchase item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PurchaseCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatMoney(double value) {
    final formatter = NumberFormat('#,##0.##', 'ar');
    return '${formatter.format(value)} ر.س';
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف فاتورة "${item.itemName}" من السجل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              onDelete();
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context) {
    InvoiceDetailsDialog.show(
      context: context,
      purchase: item,
      onEdit: onEdit,
      onDelete: () => _confirmDelete(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMultipleItems = item.items.length > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Icon, Item Name & Date, Total
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        hasMultipleItems ? Icons.receipt_long_rounded : Icons.category_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.itemName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textMain,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (hasMultipleItems) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${item.items.length} أصناف',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.purchaseDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatMoney(item.totalPrice),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),

                // Details Row: Quantity, Unit Price / Items Count, and Actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Quantity
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'إجمالي القطع',
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${NumberFormat('#,###', 'ar').format(item.totalQuantity)} حبة',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),

                    // Unit price (if single item) or number of items (if multiple items)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasMultipleItems ? 'عدد الأصناف' : 'سعر الحبة',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasMultipleItems
                              ? '${item.items.length} صنف'
                              : _formatMoney(item.unitPrice),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Action buttons: Details, Invoice, Edit, Delete
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // زر عرض تفاصيل الفاتورة
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _openDetails(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.remove_red_eye_outlined, size: 14, color: AppColors.textMain),
                                SizedBox(width: 4),
                                Text(
                                  'التفاصيل',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        if (item.invoiceUri != null && item.invoiceUri!.isNotEmpty)
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => InvoiceViewerDialog.show(context, item.invoiceUri!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.image_outlined, size: 14, color: AppColors.primary),
                                  SizedBox(width: 4),
                                  Text(
                                    'الصورة',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 19, color: AppColors.textMuted),
                          tooltip: 'تعديل',
                          onPressed: onEdit,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(5),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 19, color: AppColors.danger),
                          tooltip: 'حذف',
                          onPressed: () => _confirmDelete(context),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(5),
                        ),
                      ],
                    ),
                  ],
                ),

                // Optional notes
                if (item.notes != null && item.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.notes!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
