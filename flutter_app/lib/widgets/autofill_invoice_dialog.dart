import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/invoice_scan_result.dart';
import '../services/invoice_scanner_service.dart';
import '../theme/app_theme.dart';

/// [نافذة الملء التلقائي واستخراج بيانات الفاتورة بالذكاء الاصطناعي - AutoFillInvoiceDialog]:
/// تتيح للمستخدم التقاط أو اختيار صورة الفاتورة، معاينتها، ثم تحليلها سحابياً
/// لاستخراج كافة الأصناف والأسعار والكميات وتعبئتها آلياً.
class AutoFillInvoiceDialog extends StatefulWidget {
  const AutoFillInvoiceDialog({super.key});

  static Future<InvoiceScanResult?> show(BuildContext context) {
    return showModalBottomSheet<InvoiceScanResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AutoFillInvoiceDialog(),
    );
  }

  @override
  State<AutoFillInvoiceDialog> createState() => _AutoFillInvoiceDialogState();
}

class _AutoFillInvoiceDialogState extends State<AutoFillInvoiceDialog> {
  final ImagePicker _picker = ImagePicker();
  final InvoiceScannerService _scanner = InvoiceScannerService.instance;

  File? _selectedImage;
  bool _isAnalyzing = false;
  String? _errorMessage;
  String? _currentApiKey;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final key = await _scanner.getApiKey();
    if (mounted) {
      setState(() => _currentApiKey = key);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (picked != null) {
        final file = File(picked.path);
        if (await file.exists()) {
          final bytes = await file.length();
          if (bytes == 0) {
            _showError('الصورة المختارة فارغة أو تالفة، يرجى اختيار صورة صالحة.');
            return;
          }
          setState(() {
            _selectedImage = file;
            _errorMessage = null;
          });
        }
      }
    } catch (e) {
      _showError('حدث خطأ أثناء فتح المعرض/الكاميرا: $e');
    }
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
  }

  Future<void> _analyzeInvoice() async {
    if (_selectedImage == null) {
      _showError('يرجى اختيار صورة الفاتورة أولاً.');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final result = await _scanner.scanInvoiceImage(_selectedImage!);
      if (!mounted) return;

      if (result.items.isEmpty) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = 'لم نتمكن من العثور على أصناف واضحة في الصورة. يرجى رفع صورة أقرب وأفضل إضاءة.';
        });
        return;
      }

      if (result.hasDiscrepancies) {
        setState(() => _isAnalyzing = false);
        final proceed = await _showFraudDiscrepancyDialog(result);
        if (proceed == true && mounted) {
          Navigator.pop(context, result);
        }
        return;
      }

      // إرجاع النتيجة بنجاح إلى نموذج الفاتورة
      Navigator.pop(context, result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      final errorStr = e.toString();
      if (errorStr.contains('KEY_MISSING')) {
        _showApiKeyDialog(isFirstTime: true);
      } else if (errorStr.contains('not supported for generateContent') ||
          errorStr.contains('is not found for API version') ||
          errorStr.contains('NOT_FOUND')) {
        _showError(
          'المفتاح الحالي غير مفعّل لخدمة الذكاء الاصطناعي (Gemini API).\n\n'
          '• السبب: يبدو أن المفتاح منقول من Firebase أو مشروع لم تُفعّل به خدمة Generative Language API.\n\n'
          '• الحل البسيط: ادخل على: aistudio.google.com/app/apikey ثم اضغط (Create API key in new project) والصق المفتاح في الإعدادات ⚙️ وسيعمل فوراً مجاناً.',
        );
      } else if (errorStr.contains('INVALID_KEY') || errorStr.contains('401')) {
        _showError(
          'تم معالجة خطأ المصادقة وحذف المفتاح القديم المخزن على جهازك.\n\n'
          'يرجى الضغط على زر (تحليل واستخراج البيانات) للبدء بالمفتاح الشغال المعتمد فوراً.'
        );
      } else if (errorStr.contains('QUOTA_EXCEEDED')) {
        _showError('تم تجاوز الحد المسموح به لطلبات الذكاء الاصطناعي مؤقتاً. يرجى الانتظار دقيقة ثم المحاولة مجدداً.');
      } else if (errorStr.contains('NETWORK_ERROR')) {
        _showError('تعذر الاتصال بالسيرفر السحابي. يرجى التحقق من اتصال الإنترنت والمحاولة مجدداً.');
      } else {
        final cleanMsg = errorStr.replaceAll('Exception:', '').trim();
        _showError('تنبيه أثناء معالجة الفاتورة: $cleanMsg\n(يمكنك فحص مفتاح Gemini بالضغط على أيقونة الإعدادات ⚙️ بالأعلى)');
      }
    }
  }

  Future<bool?> _showFraudDiscrepancyDialog(InvoiceScanResult result) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'تنبيه: اشتباه تلاعب أو خطأ حسابي!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'أظهر التدقيق الرياضي للفاتورة وجود اختلاف بين الأرقام المسجلة والناتج الحقيقي لعمليات الضرب أو الجمع:',
                  style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                ...result.discrepancies.map(
                  (d) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            d.message,
                            style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.black87, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'لحمايتك، سيقوم النظام تلقائياً بتطبيق الحساب الصحيح رياضياً (الكمية × السعر) وتجاوز الأرقام الخاطئة.',
                          style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء ومراجعة الصورة', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('اعتماد الحساب الصحيح رياضياً'),
            ),
          ],
        ),
      ),
    );
  }

  void _showApiKeyDialog({bool isFirstTime = false}) {
    final controller = TextEditingController(text: _currentApiKey ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.vpn_key_rounded, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'مفتاح الذكاء الاصطناعي المجاني',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFirstTime
                    ? 'لاستخدام ميزة الملء التلقائي، يُرجى إدخال مفتاح Google Gemini API المجاني من Google AI Studio (مجاناً 100% وبدون بطاقة بنكية):'
                    : 'يمكنك تعديل مفتاح Gemini أو استعادة المفتاح المعتمد الشغال تلقائياً:',
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Gemini API Key',
                  hintText: 'AQ.... أو AIzaSy...',
                  prefixIcon: const Icon(Icons.key, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  controller.text = InvoiceScannerService.defaultApiKey;
                  await _scanner.clearApiKey();
                  if (mounted) {
                    setState(() => _currentApiKey = InvoiceScannerService.defaultApiKey);
                  }
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('تم استعادة وتعيين المفتاح المعتمد الشغال بنجاح ✅'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.restore, size: 18),
                label: const Text('استعادة المفتاح المعتمد الشغال', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(height: 8),
              const Text(
                '• يمكنك أيضاً توليد مفتاح خاص بك مجاناً من: aistudio.google.com',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final key = controller.text.trim();
                if (key.isNotEmpty) {
                  final nav = Navigator.of(ctx);
                  await _scanner.saveApiKey(key);
                  if (mounted) {
                    setState(() => _currentApiKey = key);
                  }
                  nav.pop();
                  // إعادة الفحص فوراً إذا كانت هناك صورة محددة
                  if (_selectedImage != null) {
                    _analyzeInvoice();
                  }
                }
              },
              child: const Text('حفظ وتفعيل'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          top: 16,
          left: 20,
          right: 20,
          bottom: bottomInset + 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // مؤشر السحب
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // العنوان والإعدادات
              Row(
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
                        child: const Icon(
                          Icons.document_scanner_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'الملء التلقائي',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'استخراج الأصناف والأسعار من صورة الفاتورة',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: AppColors.textMuted),
                    tooltip: 'إعدادات المفتاح',
                    onPressed: () => _showApiKeyDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // صندوق اختيار / معاينة الصورة
              if (_selectedImage == null) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.document_scanner_outlined,
                        size: 54,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'ارفع صورة واضحة للفاتورة أو عرض الأسعار',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'سيقوم النظام بقراءة أسماء الأصناف، الكميات، أسعار الوحدات، والإجمالي تلقائياً.',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_rounded, size: 18),
                            label: const Text('تصوير بالكاميرا'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_outlined, size: 18),
                            label: const Text('اختيار من المعرض'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // عرض الصورة المختارة مع زر تغيير الصورة
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.7),
                        radius: 18,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                          tooltip: 'تغيير الصورة',
                          onPressed: _isAnalyzing ? null : () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // عرض رسالة الخطأ إن وجدت
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.danger, fontSize: 12, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // زر بدء التحليل أو مؤشر التحميل
              if (_isAnalyzing) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: const [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'جارٍ قراءة بيانات الفاتورة واستخراج الأصناف...',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_selectedImage != null) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 1,
                  ),
                  onPressed: _analyzeInvoice,
                  icon: const Icon(Icons.document_scanner_rounded, size: 20),
                  label: const Text(
                    'تحليل واستخراج البيانات',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
