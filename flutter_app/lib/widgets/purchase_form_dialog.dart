import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/invoice_scan_result.dart';
import '../models/purchase.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import 'app_image_view.dart';
import 'autofill_invoice_dialog.dart';

/// [محاضرة 7 و 9]:
/// - [محاضرة 9 - سلايدات 10 و 11]: كلاس منعزل لصندوق تعبئة البيانات وحقول الإدخال والتعديل لتقليل الأكواد في الصفحات.
/// - [محاضرة 7]: حقول الإدخال TextFormField والتحقق عبر FormState ومتحكمات النصوص TextEditingController.
/// - [محاضرة 8]: إرجاع البيانات بشكل غير متزامن بعد الحفظ.
/// تم تطويره ليدعم فواتير متعددة الأصناف، الملء التلقائي بالذكاء الاصطناعي، والتحقق الصارم من أسماء الأصناف.
class PurchaseFormDialog extends StatefulWidget {
  final Purchase? editingPurchase;
  final InvoiceScanResult? initialScanResult;
  final Function({
    String? itemName,
    int? quantity,
    double? unitPrice,
    List<InvoiceItem>? items,
    required String purchaseDate,
    String? invoiceUri,
    String? notes,
  }) onSave;

  const PurchaseFormDialog({
    super.key,
    this.editingPurchase,
    this.initialScanResult,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    Purchase? editingPurchase,
    InvoiceScanResult? initialScanResult,
    required Function({
      String? itemName,
      int? quantity,
      double? unitPrice,
      List<InvoiceItem>? items,
      required String purchaseDate,
      String? invoiceUri,
      String? notes,
    }) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PurchaseFormDialog(
        editingPurchase: editingPurchase,
        initialScanResult: initialScanResult,
        onSave: onSave,
      ),
    );
  }

  @override
  State<PurchaseFormDialog> createState() => _PurchaseFormDialogState();
}

class _PurchaseFormDialogState extends State<PurchaseFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // متحكمات حقول إدخال الصنف الحالي
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;

  // متحكمات بيانات الفاتورة العامة
  late TextEditingController _dateController;
  late TextEditingController _notesController;

  // قائمة الأصناف داخل الفاتورة
  final List<InvoiceItem> _items = [];
  String? _editingItemId;

  String? _invoiceUri;
  bool _isSaving = false;
  bool _hasAttemptedAddItem = false;
  bool _hasAttemptedSave = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = widget.editingPurchase;

    if (p != null) {
      if (p.items.isNotEmpty) {
        _items.addAll(p.items);
      } else if (p.itemName.isNotEmpty) {
        _items.add(
          InvoiceItem(
            name: p.itemName,
            quantity: p.quantity,
            unitPrice: p.unitPrice,
          ),
        );
      }
    }

    _nameController = TextEditingController();
    _quantityController = TextEditingController();
    _priceController = TextEditingController();

    _dateController = TextEditingController(
      text: p?.purchaseDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    _notesController = TextEditingController(text: p?.notes ?? '');
    _invoiceUri = p?.invoiceUri;

    _quantityController.addListener(_onCalculatedChanged);
    _priceController.addListener(_onCalculatedChanged);

    if (widget.initialScanResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyScanResult(widget.initialScanResult!, showToast: false);
      });
    }
  }

  /// تطبيق البيانات المستخرجة من صورة الفاتورة وتعبئتها في الحقول والقائمة آلياً
  Future<void> _applyScanResult(InvoiceScanResult result, {bool showToast = true}) async {
    setState(() {
      _items.clear();
      _items.addAll(result.items);

      if (result.purchaseDate != null && result.purchaseDate!.trim().isNotEmpty) {
        _dateController.text = result.purchaseDate!.trim();
      }

      final noteParts = <String>[];
      if (result.merchantName != null && result.merchantName!.trim().isNotEmpty) {
        noteParts.add('المورد: ${result.merchantName!.trim()}');
      }
      if (result.taxAmount != null && result.taxAmount! > 0) {
        noteParts.add('الضريبة: ${result.taxAmount}');
      }
      if (result.notes != null && result.notes!.trim().isNotEmpty) {
        noteParts.add(result.notes!.trim());
      }
      if (result.hasDiscrepancies) {
        noteParts.add('⚠️ تنبيه: تم رصد خطأ حسابي في الفاتورة الورقية وتصحيحه رياضياً');
      }
      if (noteParts.isNotEmpty) {
        _notesController.text = noteParts.join(' | ');
      }

      _nameController.clear();
      _quantityController.clear();
      _priceController.clear();
      _editingItemId = null;
    });

    if (result.imageUri != null && result.imageUri!.isNotEmpty) {
      try {
        final file = File(result.imageUri!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final base64String = base64Encode(bytes);
          final ext = file.path.split('.').last.toLowerCase();
          final mimeType = (ext == 'png')
              ? 'image/png'
              : (ext == 'webp' ? 'image/webp' : 'image/jpeg');
          if (mounted) {
            setState(() {
              _invoiceUri = 'data:$mimeType;base64,$base64String';
            });
          }
        }
      } catch (e) {
        debugPrint('Error attaching scanned image: $e');
      }
    }

    if (showToast && mounted) {
      if (result.hasDiscrepancies) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ تنبيه: تم رصد اختلاف أو خطأ حسابي بالفاتورة (${result.discrepancies.length} بند) وتم تصحيحه لحمايتك!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.orange[900],
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم استخراج ${result.items.length} أصناف بنجاح، يمكنك مراجعتها وحفظ الفاتورة',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _onCalculatedChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _quantityController.removeListener(_onCalculatedChanged);
    _priceController.removeListener(_onCalculatedChanged);
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // إجمالي الصنف الحالي الذي يتم كتابته في الحقول
  double get _currentDraftItemTotal {
    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
    final price = double.tryParse(_priceController.text.trim().replaceAll(',', '.')) ?? 0.0;
    return qty * price;
  }

  // إجمالي الفاتورة التراكمي المحسوب من كافة الأصناف المضافة
  double get _invoiceTotal {
    return _items.fold(0.0, (sum, it) => sum + it.total);
  }

  // إجمالي قطع الفاتورة
  int get _invoiceQuantity {
    return _items.fold(0, (sum, it) => sum + it.quantity);
  }

  void _addOrUpdateItem() {
    setState(() {
      _hasAttemptedAddItem = true;
    });

    final name = _nameController.text.trim();
    final nameError = AppValidators.validateItemName(_nameController.text);
    final qty = int.tryParse(_quantityController.text.trim());
    final price = double.tryParse(_priceController.text.trim().replaceAll(',', '.'));

    if (nameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nameError),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال كمية صحيحة (أكبر من 0)'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال سعر حبة صحيح (أكبر من 0)'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() {
      if (_editingItemId != null) {
        // تحديث صنف موجود
        final index = _items.indexWhere((it) => it.id == _editingItemId);
        if (index != -1) {
          _items[index] = InvoiceItem(
            id: _editingItemId,
            name: name,
            quantity: qty,
            unitPrice: price,
          );
        }
        _editingItemId = null;
      } else {
        // إضافة صنف جديد
        _items.add(
          InvoiceItem(
            name: name,
            quantity: qty,
            unitPrice: price,
          ),
        );
      }

      // تفريغ حقول الصنف فقط
      _nameController.clear();
      _quantityController.clear();
      _priceController.clear();
      _hasAttemptedAddItem = false;
    });
  }

  void _startEditItem(InvoiceItem item) {
    setState(() {
      _editingItemId = item.id;
      _nameController.text = item.name;
      _quantityController.text = item.quantity.toString();
      _priceController.text = item.unitPrice.toString();
      _hasAttemptedAddItem = false;
    });
  }

  void _cancelEditItem() {
    setState(() {
      _editingItemId = null;
      _nameController.clear();
      _quantityController.clear();
      _priceController.clear();
      _hasAttemptedAddItem = false;
    });
  }

  void _removeItem(int index) {
    final removed = _items[index];
    setState(() {
      _items.removeAt(index);
      if (_editingItemId == removed.id) {
        _cancelEditItem();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف "${removed.name}" من الفاتورة'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'تراجع',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _items.insert(index, removed);
            });
          },
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 75,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64String = base64Encode(bytes);
        final mimeType = picked.mimeType ?? 'image/jpeg';
        final dataUri = 'data:$mimeType;base64,$base64String';

        setState(() {
          _invoiceUri = dataUri;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر اختيار الصورة: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    DateTime initial = DateTime.now();
    try {
      initial = DateTime.parse(_dateController.text.trim());
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('ar'),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _hasAttemptedSave = true;
    });

    // إذا كان المستخدم قد كتب صنفاً ولم يضغط زر إضافة، نتحقق منه ونضيفه تلقائياً
    final draftName = _nameController.text.trim();
    if (draftName.isNotEmpty) {
      final nameErr = AppValidators.validateItemName(_nameController.text);
      if (nameErr != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nameErr),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      final draftQty = int.tryParse(_quantityController.text.trim());
      final draftPrice = double.tryParse(_priceController.text.trim().replaceAll(',', '.'));

      if (draftQty == null || draftQty <= 0 || draftPrice == null || draftPrice <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى استكمال كمية وسعر الصنف الحالي أو إفراغ الحقول'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      _items.add(
        InvoiceItem(
          name: draftName,
          quantity: draftQty,
          unitPrice: draftPrice,
        ),
      );
      _nameController.clear();
      _quantityController.clear();
      _priceController.clear();
    }

    // التحقق من وجود صنف واحد على الأقل
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب إضافة صنف واحد على الأقل للفاتورة قبل الحفظ'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // التحقق من أن جميع الأصناف صحيحة ولا تبدأ برقم
    for (final item in _items) {
      final err = AppValidators.validateItemName(item.name);
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الصنف "${item.name}": $err'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
      if (item.quantity <= 0 || item.unitPrice <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('الكمية أو السعر غير صحيح في الصنف "${item.name}"'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
    }

    final date = _dateController.text.trim();
    if (date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تحديد تاريخ الشراء'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final derivedName = _items.length == 1
          ? _items.first.name
          : _items.map((e) => e.name).join('، ');
      final totalQty = _items.fold(0, (sum, i) => sum + i.quantity);
      final totalPrice = _items.fold(0.0, (sum, i) => sum + i.total);
      final avgPrice = totalQty > 0 ? (totalPrice / totalQty) : 0.0;

      await widget.onSave(
        itemName: derivedName,
        quantity: totalQty,
        unitPrice: avgPrice,
        items: List.from(_items),
        purchaseDate: date,
        invoiceUri: _invoiceUri,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حفظ الفاتورة: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Widget _buildInvoicePreview() {
    if (_invoiceUri == null || _invoiceUri!.isEmpty) return const SizedBox.shrink();

    final imageWidget = AppImageView(
      imageUri: _invoiceUri!,
      fit: BoxFit.cover,
    );

    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(top: 8, bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: imageWidget,
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: InkWell(
            onTap: () => setState(() => _invoiceUri = null),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // بطاقات عرض الأصناف المضافة داخل الفاتورة
  Widget _buildItemsList() {
    if (_items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.textMuted, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'لم يتم إضافة أصناف إلى الفاتورة بعد. أدخل بيانات الصنف واضغط "إضافة صنف للفاتورة".',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      );
    }

    final moneyFmt = NumberFormat('#,##0.##', 'ar');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.format_list_bulleted_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'الأصناف المضافة (${_items.length})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                Text(
                  'المجموع: ${moneyFmt.format(_invoiceTotal)} ر.س',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
            itemBuilder: (ctx, index) {
              final item = _items[index];
              final isBeingEdited = _editingItemId == item.id;

              return Container(
                color: isBeingEdited ? AppColors.warning.withValues(alpha: 0.1) : Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // رقم الصنف
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: isBeingEdited ? AppColors.warning : AppColors.primaryLight,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isBeingEdited ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // تفاصيل الصنف
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'الكمية: ${item.quantity} × ${moneyFmt.format(item.unitPrice)} ر.س',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    // الإجمالي الفرعي للصنف
                    Text(
                      '${moneyFmt.format(item.total)} ر.س',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // زر التعديل
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textMuted),
                      tooltip: 'تعديل الصنف',
                      onPressed: () => _startEditItem(item),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),
                    // زر الحذف
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                      tooltip: 'حذف الصنف',
                      onPressed: () => _removeItem(index),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.editingPurchase != null;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // شريط العنوان وأزرار التحكم العليا
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء', style: TextStyle(color: AppColors.textMuted)),
              ),
              Text(
                isEditing ? 'تعديل الفاتورة' : 'إضافة فاتورة مشتريات',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textMain,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('حفظ الفاتورة', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.border),

          // منطقة الحقول القابلة للتمرير
          Flexible(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // زر استخدام الملء التلقائي بالذكاء الاصطناعي
                    if (!isEditing) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              final result = await AutoFillInvoiceDialog.show(context);
                              if (result != null) {
                                await _applyScanResult(result);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.document_scanner_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'استخدام الملء التلقائي',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'ارفع صورة الفاتورة لاستخراج الأصناف والأسعار تلقائياً',
                                          style: TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    // ============================================
                    // القسم الأول: بيانات الصنف (إدخال صنف أو تعديله)
                    // ============================================
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _editingItemId != null ? AppColors.warning : AppColors.border,
                          width: _editingItemId != null ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _editingItemId != null ? 'تعديل بيانات الصنف' : 'بيانات الصنف',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: _editingItemId != null ? AppColors.warning : AppColors.primary,
                                ),
                              ),
                              if (_editingItemId != null)
                                InkWell(
                                  onTap: _cancelEditItem,
                                  child: const Text(
                                    'إلغاء التعديل',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // اسم الصنف مع التحقق الصارم
                          const Text('اسم الصنف *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            autovalidateMode: _hasAttemptedAddItem || _hasAttemptedSave
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.disabled,
                            validator: AppValidators.validateItemName,
                            decoration: const InputDecoration(
                              hintText: 'مثال: تفاح، ورق A4، أحبار طابعة',
                              prefixIcon: Icon(Icons.category_outlined, size: 20, color: AppColors.textMuted),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // الكمية وسعر الحبة
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('عدد الحبات *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _quantityController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(hintText: '0'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('سعر الحبة (ريال) *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _priceController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(hintText: '0.00'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // عرض إجمالي الصنف الحالي أثناء الكتابة
                          if (_currentDraftItemTotal > 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'إجمالي هذا الصنف: ${NumberFormat('#,##0.##', 'ar').format(_currentDraftItemTotal)} ر.س',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),

                          // الزر المخصص باللونين الأسود والأبيض فوق حقل تاريخ الشراء لإضافة صنف آخر
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(color: Colors.black, width: 1.2),
                                    ),
                                  ),
                                  onPressed: _addOrUpdateItem,
                                  icon: Icon(
                                    _editingItemId != null ? Icons.check_circle_outline : Icons.add_circle_outline,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    _editingItemId != null ? 'تحديث هذا الصنف في الفاتورة' : 'إضافة صنف آخر للفاتورة +',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ============================================
                    // قائمة الأصناف المضافة للفاتورة
                    // ============================================
                    _buildItemsList(),

                    // ============================================
                    // القسم الثاني: بيانات الفاتورة العامة
                    // ============================================
                    const Text(
                      'بيانات الفاتورة العامة',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textMain),
                    ),
                    const SizedBox(height: 10),

                    // Purchase Date
                    const Text('تاريخ الشراء *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _selectDate,
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            hintText: 'YYYY-MM-DD',
                            suffixIcon: Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Invoice Photo
                    const Text('صورة فاتورة الشراء', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.camera_alt, color: AppColors.primary, size: 20),
                            label: const Text(
                              'تصوير الفاتورة',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            onPressed: () => _pickImage(ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.photo_library_outlined, color: AppColors.textMuted, size: 20),
                            label: const Text(
                              'من الصور',
                              style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            onPressed: () => _pickImage(ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),
                    _buildInvoicePreview(),
                    const SizedBox(height: 10),

                    // Notes
                    const Text('ملاحظات الفاتورة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(hintText: 'اختياري (اسم المورد أو المتجر، الغرض، تفاصيل الضمان)'),
                    ),
                    const SizedBox(height: 16),

                    // بطاقة الإجمالي التراكمي النهائي للفاتورة
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'عدد الأصناف في الفاتورة:',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                              ),
                              Text(
                                '${_items.length} صنف ($_invoiceQuantity قطعة)',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'إجمالي الفاتورة النهائي:',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                              ),
                              Text(
                                '${NumberFormat('#,##0.##', 'ar').format(_invoiceTotal)} ر.س',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
