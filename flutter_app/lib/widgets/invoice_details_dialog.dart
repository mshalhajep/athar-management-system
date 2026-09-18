import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/purchase.dart';
import '../theme/app_theme.dart';
import 'app_image_view.dart';
import 'invoice_viewer_dialog.dart';

/// [شاشة/نافذة تفاصيل الفاتورة الشاملة]:
/// تعرض كافة بيانات الفاتورة المكتملة بما فيها جميع الأصناف، الكميات، أسعار الوحدة،
/// إجمالي كل صنف، الإجمالي النهائي، الصورة، الملاحظات، وتاريخ الشراء.
class InvoiceDetailsDialog extends StatelessWidget {
  final Purchase purchase;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const InvoiceDetailsDialog({
    super.key,
    required this.purchase,
    this.onEdit,
    this.onDelete,
  });

  static Future<void> show({
    required BuildContext context,
    required Purchase purchase,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InvoiceDetailsDialog(
        purchase: purchase,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  String _formatMoney(double value) {
    final formatter = NumberFormat('#,##0.##', 'ar');
    return '${formatter.format(value)} ر.س';
  }

  @override
  Widget build(BuildContext context) {
    final items = purchase.items;
    final totalUnits = purchase.totalQuantity;
    final grandTotal = purchase.totalPrice;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // رأس النافذة
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'تفاصيل الفاتورة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textMain,
                          ),
                        ),
                        Text(
                          'تاريخ الشراء: ${purchase.purchaseDate}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // المحتوى القابل للتمرير
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // بطاقات ملخص الفاتورة السريعة (KPIs)
                  Row(
                    children: [
                      // عدد الأصناف
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('الأصناف', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                '${items.length} صنف',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // إجمالي القطع
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('إجمالي القطع', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                '$totalUnits قطعة',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textMain),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // إجمالي الفاتورة
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('إجمالي الفاتورة', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                _formatMoney(grandTotal),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.success),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // عنوان قائمة الأصناف
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الأصناف المشتراة (${items.length})',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMain,
                        ),
                      ),
                      const Text(
                        'الكمية × سعر الحبة = الإجمالي',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // قائمة الأصناف المنظمة
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (ctx, index) {
                        final item = items[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: AppColors.primaryLight,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textMain,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'الكمية: ${item.quantity} حبة  |  سعر الحبة: ${_formatMoney(item.unitPrice)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _formatMoney(item.total),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // صورة الفاتورة إن وجدت
                  if (purchase.invoiceUri != null && purchase.invoiceUri!.isNotEmpty) ...[
                    const Text(
                      'صورة فاتورة الشراء',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textMain),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => InvoiceViewerDialog.show(context, purchase.invoiceUri!),
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AppImageView(
                                imageUri: purchase.invoiceUri!,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                color: Colors.black.withValues(alpha: 0.2),
                                alignment: Alignment.bottomRight,
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.zoom_in, color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'انقر للتكبير',
                                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // الملاحظات إن وجدت
                  if (purchase.notes != null && purchase.notes!.trim().isNotEmpty) ...[
                    const Text(
                      'ملاحظات وتفاصيل إضافية',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textMain),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        purchase.notes!,
                        style: const TextStyle(fontSize: 13, color: AppColors.textMain, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // بطاقة الإجمالي النهائي الفاخرة
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إجمالي الفاتورة النهائي',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                            ),
                            Text(
                              'شامل لجميع الأصناف المذكورة',
                              style: TextStyle(fontSize: 11, color: AppColors.textLight),
                            ),
                          ],
                        ),
                        Text(
                          _formatMoney(grandTotal),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // أزرار الإجراءات (تعديل / حذف)
                  Row(
                    children: [
                      if (onEdit != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                            label: const Text('تعديل الفاتورة', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            onPressed: () {
                              Navigator.of(context).pop();
                              onEdit!();
                            },
                          ),
                        ),
                      if (onEdit != null && onDelete != null)
                        const SizedBox(width: 12),
                      if (onDelete != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('حذف الفاتورة', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              Navigator.of(context).pop();
                              onDelete!();
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
