import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../models/purchase.dart';
import '../services/app_update_service.dart';
import '../services/auth_service.dart';
import '../services/backup_sync_service.dart';
import '../services/purchases_service.dart';
import '../theme/app_theme.dart';
import '../widgets/purchase_card.dart';
import '../widgets/purchase_form_dialog.dart';
import '../widgets/stat_card.dart';
import '../widgets/autofill_invoice_dialog.dart';
import 'inventory_table_screen.dart';
import 'login_screen.dart';

/// [الربط الأكاديمي مع محاضرات المنهج]:
/// - [محاضرة 5]: دورة حياة StatefulWidget و State و initState و setState.
/// - [محاضرة 6]: تقسيم واجهات التطبيق، بطاقات الإحصاء، Row و Column و Padding.
/// - [محاضرة 7]: الهيكل الأساسي Scaffold، شريط التطبيق العلوي AppBar، شريط التنقل السفلي NavigationBar، والزر العائم FloatingActionButton.
/// - [محاضرة 8]: البرمجة غير المتزامنة async / await، والتنقل بين الصفحات Navigator.push و Navigator.pop.
/// - [محاضرة 9]: التعامل المباشر مع قاعدة بيانات SQLite، وعرض القوائم عبر ListView.builder مع shrinkWrap، ومربعات الحوار AlertDialog و showDialog ومؤشرات التحميل CircularProgressIndicator.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PurchasesService _purchasesService;
  late final AuthService _authService;
  late final BackupSyncService _backupSyncService;
  late final AppUpdateService _appUpdateService;
  final TextEditingController _searchController = TextEditingController();
  int _currentNavIndex = 0; // 0: سجل المشتريات, 1: قائمة المخزون

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _purchasesService = PurchasesService(initialEmail: _authService.currentUser?.email);
    _backupSyncService = BackupSyncService();
    _appUpdateService = AppUpdateService();

    _purchasesService.addListener(_onUpdate);
    _authService.addListener(_onUpdate);
    _backupSyncService.addListener(_onUpdate);
    _appUpdateService.addListener(_onUpdate);
  }

  void _onUpdate() {
    if (mounted) {
      final email = _authService.currentUser?.email;
      if (_purchasesService.currentUserEmail != email?.trim().toLowerCase()) {
        _purchasesService.setUserEmail(email);
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _purchasesService.removeListener(_onUpdate);
    _authService.removeListener(_onUpdate);
    _backupSyncService.removeListener(_onUpdate);

    _purchasesService.dispose();
    _authService.dispose();
    _backupSyncService.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatMoney(double value) {
    final formatter = NumberFormat('#,##0.##', 'ar');
    return '${formatter.format(value)} ر.س';
  }

  void _openAddModal() async {
    await PurchaseFormDialog.show(
      context: context,
      onSave: ({
        String? itemName,
        int? quantity,
        double? unitPrice,
        List<InvoiceItem>? items,
        required String purchaseDate,
        String? invoiceUri,
        String? notes,
      }) async {
        // Reset filter to show the new item immediately
        _searchController.clear();
        _purchasesService.setSearchQuery('');
        _purchasesService.setFilterPeriod(FilterPeriod.all);

        await _purchasesService.addPurchase(
          itemName: itemName,
          quantity: quantity,
          unitPrice: unitPrice,
          items: items,
          purchaseDate: purchaseDate,
          invoiceUri: invoiceUri,
          notes: notes,
        );
      },
    );

    if (mounted) {
      setState(() {});
      final latestTotal = _purchasesService.allTimeTotalAmount;
      final totalCount = _purchasesService.purchases.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تسجيل الفاتورة بنجاح ✅ - إجمالي المشتريات: ${_formatMoney(latestTotal)} (عدد العمليات: $totalCount)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _openAiScanModal() async {
    final result = await AutoFillInvoiceDialog.show(context);
    if (result != null && mounted) {
      await PurchaseFormDialog.show(
        context: context,
        initialScanResult: result,
        onSave: ({
          String? itemName,
          int? quantity,
          double? unitPrice,
          List<InvoiceItem>? items,
          required String purchaseDate,
          String? invoiceUri,
          String? notes,
        }) async {
          _searchController.clear();
          _purchasesService.setSearchQuery('');
          _purchasesService.setFilterPeriod(FilterPeriod.all);

          await _purchasesService.addPurchase(
            itemName: itemName,
            quantity: quantity,
            unitPrice: unitPrice,
            items: items,
            purchaseDate: purchaseDate,
            invoiceUri: invoiceUri,
            notes: notes,
          );
        },
      );

      if (mounted) {
        setState(() {});
        final latestTotal = _purchasesService.allTimeTotalAmount;
        final totalCount = _purchasesService.purchases.length;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تسجيل الفاتورة بنجاح ✅ - إجمالي المشتريات: ${_formatMoney(latestTotal)} (عدد العمليات: $totalCount)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
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
        await _purchasesService.updatePurchase(
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

  void _openCloudSyncModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.cloud_sync_rounded, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'المزامنة مع Google Drive',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textMain),
                        ),
                        Text(
                          _authService.currentUser?.email ?? 'حساب غير مربوط بعد',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Backup info tile
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history_toggle_off_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _backupSyncService.lastSyncTime != null
                            ? 'آخر مزامنة ناجحة: ${_backupSyncService.lastSyncTime}'
                            : 'لم تتم مزامنة البيانات سحابياً بعد',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMain),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sync Now Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _backupSyncService.isSyncing
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          final ok = await _backupSyncService.syncToGoogleDrive(
                            purchasesService: _purchasesService,
                            authService: _authService,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? 'تم أخذ نسخة احتياطية ومزامنتها على Google Drive بنجاح ☁️'
                                      : 'حدث خطأ أثناء المزامنة السحابية',
                                ),
                                backgroundColor: ok ? AppColors.success : AppColors.danger,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text('أخذ نسخة احتياطية الآن إلى Google Drive', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 10),

              // Restore from Cloud Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _backupSyncService.isSyncing
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          final count = await _backupSyncService.restoreFromGoogleDrive(
                            purchasesService: _purchasesService,
                            accountEmail: _authService.currentUser?.email,
                          );
                          if (mounted) {
                            if (count != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تم استرجاع $count عنصراً من Google Drive بنجاح ✅'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('لم يتم العثور على نسخة احتياطية سابقة في درايف'),
                                  backgroundColor: AppColors.warning,
                                ),
                              );
                            }
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.cloud_download_outlined),
                  label: const Text('استعادة البيانات من Google Drive', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 10),

              // [المرحلة 2: صمام الأمان والنسخ الاحتياطي المحلي]: تصدير واسترجاع ملفات .athar
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          final file = await _backupSyncService.exportBackupToFile(
                            purchasesService: _purchasesService,
                            userEmail: _authService.currentUser?.email,
                          );
                          if (mounted) {
                            final fileName = file.path.replaceAll(r'\', '/').split('/').last;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم حفظ ملف النسخة الاحتياطية بنجاح:\n$fileName 💾'),
                                backgroundColor: AppColors.success,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('فشل تصدير الملف: $e'), backgroundColor: AppColors.danger),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.textMain,
                        elevation: 0,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.save_alt_rounded, size: 16, color: AppColors.primary),
                      label: const Text('تصدير ملف .athar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showLocalBackupsDialog(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        foregroundColor: AppColors.textMain,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.folder_open_rounded, size: 16, color: AppColors.primary),
                      label: const Text('النسخ المحفوظة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Export/Copy Raw JSON Backup
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final jsonStr = _backupSyncService.generateBackupJson(
                          purchases: _purchasesService.purchases,
                          userEmail: _authService.currentUser?.email,
                        );
                        Clipboard.setData(ClipboardData(text: jsonStr));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم نسخ شفرة النسخة الاحتياطية JSON للحافظة 📋'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        foregroundColor: AppColors.textMuted,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 15),
                      label: const Text('نسخ كـ JSON', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showImportJsonDialog(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        foregroundColor: AppColors.textMuted,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.file_download_outlined, size: 15),
                      label: const Text('استيراد JSON', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
              // [المرحلة 4: التحديث الذكي بضغطة زر]: زر فحص وجود تحديثات
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showAppUpdateModal();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.system_update_alt_rounded, size: 16),
                  label: const Text(
                    'التحقق من التحديثات الذكية (v1.0.0)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Reset / Clear all data button
              Center(
                child: TextButton.icon(
                  onPressed: () => _confirmResetAllData(ctx),
                  icon: const Icon(Icons.restart_alt_rounded, size: 18, color: AppColors.warning),
                  label: const Text(
                    'تصفير السجل وحذف البيانات التجريبية (البدء من 0)',
                    style: TextStyle(color: AppColors.warning, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Sign Out / Switch Account
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    _purchasesService.clearInAppMemory();
                    await _authService.signOut();
                    if (mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(authService: _authService),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, size: 16, color: AppColors.danger),
                  label: const Text(
                    'تسجيل الخروج / تبديل الحساب',
                    style: TextStyle(color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // [المرحلة 4: التحديث الذكي بضغطة زر]: فحص وتنزيل التحديثات مع الحفاظ الكامل على قاعدة بيانات SQLite
  void _showAppUpdateModal() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    final info = await _appUpdateService.checkForUpdates();
    if (!mounted) return;
    Navigator.pop(context); // إغلاق مؤشر التحميل

    double downloadProgress = 0.0;
    bool isDownloading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.rocket_launch_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.hasUpdate
                              ? 'يتوفر تحديث جديد (${info.latestVersion})'
                              : 'تطبيقك محدث بالكامل ✅',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'الإصدار الحالي: ${info.currentVersion}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (info.hasUpdate) ...[
                    const Text(
                      'ما الجديد في هذا التحديث:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        info.releaseNotes,
                        style: const TextStyle(fontSize: 12, height: 1.5, color: AppColors.textMain),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // تنويه صمام الأمان
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_outlined, color: AppColors.success, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'تحديث آمن: ستبقى قاعدة بيانات SQLite وسجل الفواتير بالكامل كما هي دون أي حذف.',
                              style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isDownloading) ...[
                      const SizedBox(height: 16),
                      Text(
                        'جاري تنزيل التحديث: ${(downloadProgress * 100).toInt()}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: downloadProgress,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'أنت تستخدم أحدث إصدار متوفر للتطبيق حالياً، وقاعدة بيانات SQLite تعمل بأقصى سرعة.',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                if (!isDownloading)
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(info.hasUpdate ? 'لاحقاً' : 'إغلاق'),
                  ),
                if (info.hasUpdate && !isDownloading)
                  ElevatedButton.icon(
                    onPressed: () async {
                      setDialogState(() {
                        isDownloading = true;
                      });
                      final nav = Navigator.of(ctx);
                      final messenger = ScaffoldMessenger.of(this.context);
                      final ok = await _appUpdateService.downloadAndInstallUpdate(
                        onProgress: (p) {
                          setDialogState(() {
                            downloadProgress = p;
                          });
                        },
                      );
                      if (mounted) {
                        nav.pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? 'تم تنزيل وتثبيت التحديث بنجاح! تم الحفاظ على قاعدة البيانات 100% 🚀'
                                  : 'فشل إكمال التحديث',
                            ),
                            backgroundColor: ok ? AppColors.success : AppColors.danger,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('تحديث وتثبيت الآن', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // [محاضرة 9]: استخدام showDialog و AlertDialog و ListView.builder لعرض النسخ الاحتياطية المحفوظة محلياً
  void _showLocalBackupsDialog(BuildContext parentCtx) async {
    Navigator.pop(parentCtx);
    final files = await _backupSyncService.listLocalBackupFiles();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.folder_special_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('النسخ الاحتياطية المحلية', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: files.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'لا توجد نسخ احتياطية محفوظة محلياً بعد.\nيمكنك إنشاء نسخة عبر زر (تصدير ملف .athar).',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: files.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final file = File(files[i].path);
                      final fileName = file.path.replaceAll(r'\', '/').split('/').last;
                      final stat = file.statSync();
                      final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(stat.modified);

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
                        ),
                        title: Text(
                          fileName,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(dateStr, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        trailing: TextButton.icon(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(this.context);
                            Navigator.pop(ctx);
                            final count = await _backupSyncService.restoreFromFile(file, _purchasesService);
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('تم استعادة $count عنصراً بنجاح إلى قاعدة البيانات SQLite ✅'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.restore_rounded, size: 16, color: AppColors.primary),
                          label: const Text('استعادة', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImportJsonDialog(BuildContext parentCtx) {
    Navigator.pop(parentCtx);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('استيراد نسخة احتياطية JSON', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'الصق نص النسخة الاحتياطية بصيغة JSON لاستعادتها فوراً:',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 6,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                decoration: const InputDecoration(
                  hintText: '{"system": "إدارة مخزون شركة أثر", ...}',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                final content = controller.text.trim();
                Navigator.pop(ctx);
                if (content.isNotEmpty) {
                  try {
                    final count = await _backupSyncService.restoreFromJson(content, _purchasesService);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم استيراد $count عنصراً بنجاح ✅'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('صيغة الـ JSON غير صالحة أو تالفة'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('استيراد واستبدال'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmResetAllData(BuildContext parentCtx) {
    Navigator.pop(parentCtx);
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
              Text('تصفير السجل والبدء من الصفر', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          content: const Text(
            'سيتم حذف كافة العمليات والفواتير التجريبية المحفوظة حالياً، وسيعود العداد وإجمالي المشتريات إلى (0 ر.س) للبدء من جديد.\n\nهل أنت متأكد؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _purchasesService.clearAllPurchases();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تصفير السجل بنجاح! العداد الآن: 0 ر.س (0 عملية) ✅'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              child: const Text('تأكيد التصفير'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _purchasesService,
      builder: (context, _) {
        final allItems = _purchasesService.purchases;
        final filtered = _purchasesService.filteredPurchases;
        final isAllPeriod = _purchasesService.selectedPeriod == FilterPeriod.all;
        final isSearchEmpty = _purchasesService.searchQuery.isEmpty;

        // Total purchases amount: uses allTimeTotal when viewing all, or period total when filtered
        final total = (isAllPeriod && isSearchEmpty)
            ? _purchasesService.allTimeTotalAmount
            : _purchasesService.filteredTotalAmount;

        final allTotal = _purchasesService.allTimeTotalAmount;
        final count = (isAllPeriod && isSearchEmpty)
            ? allItems.length
            : filtered.length;
        final allCount = allItems.length;
        final totalQty = _purchasesService.filteredTotalQuantity;

        final totalLabel = isAllPeriod && isSearchEmpty
            ? 'إجمالي المشتريات'
            : 'إجمالي المشتريات (${_purchasesService.selectedPeriod.label})';

        final countLabel = isAllPeriod && isSearchEmpty
            ? 'عدد العمليات'
            : 'العمليات المحددة';

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.pureWhite,
              elevation: 0.5,
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.2)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    padding: const EdgeInsets.all(0),
                    child: Image.asset(
                      'assets/images/athar-black-logo.jpg',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.inventory_2,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إدارة مخزون شركة أثر',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        _currentNavIndex == 0 ? 'سجل المشتريات اليومي' : 'قائمة المخزون (جدول تفاعلي)',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                // AI Auto-Fill Scanner Button
                IconButton(
                  icon: const Icon(Icons.document_scanner_outlined, color: AppColors.primary, size: 24),
                  tooltip: 'استخراج فاتورة (الملء التلقائي)',
                  onPressed: _openAiScanModal,
                ),
                // Cloud Sync / Google Drive Button
                IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.cloud_sync_outlined, color: AppColors.primary, size: 26),
                      if (_backupSyncService.isSyncing)
                        const Positioned(
                          right: 0,
                          top: 0,
                          child: SizedBox(
                            width: 8,
                            height: 8,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary),
                          ),
                        ),
                    ],
                  ),
                  tooltip: 'النسخ السحابي ومزامنة Google Drive',
                  onPressed: _openCloudSyncModal,
                ),
                const SizedBox(width: 6),
              ],
            ),
            body: Stack(
              children: [
                // Athar brand background watermark
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.05,
                    child: Image.asset(
                      'assets/images/athar-black-logo.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                _currentNavIndex == 1
                    ? InventoryTableScreen(purchasesService: _purchasesService)
                    : SafeArea(
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => _purchasesService.loadPurchases(),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Stats Cards Row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: StatCard(
                                          label: totalLabel,
                                          value: _formatMoney(total),
                                          icon: Icons.payments_outlined,
                                          highlighted: true,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: StatCard(
                                          label: countLabel,
                                          value: isAllPeriod && isSearchEmpty
                                              ? '$count عملية'
                                              : '$count من $allCount',
                                          icon: Icons.receipt_long_outlined,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                              // Mini Summary Bar
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          const Text(
                                            'إجمالي كل المدة',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            _formatMoney(allTotal),
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textMain),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(width: 1, height: 28, color: AppColors.border),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          const Text(
                                            'عدد الحبات المعروضة',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${NumberFormat('#,###', 'ar').format(totalQty)} حبة',
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textMain),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Section Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'الاستعلام عن المشتريات',
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textMain),
                                  ),
                                  Text(
                                    '$count نتيجة',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Search Input Box
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) => _purchasesService.setSearchQuery(val),
                                  decoration: InputDecoration(
                                    hintText: 'ابحث باسم الصنف أو الملاحظات...',
                                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 22),
                                    suffixIcon: _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                                            onPressed: () {
                                              _searchController.clear();
                                              _purchasesService.setSearchQuery('');
                                            },
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Filter Chips Row
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: FilterPeriod.values.map((period) {
                                    final isSelected = _purchasesService.selectedPeriod == period;
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: ChoiceChip(
                                        label: Text(period.label),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          if (selected) {
                                            _purchasesService.setFilterPeriod(period);
                                          }
                                        },
                                        selectedColor: AppColors.primaryLight,
                                        backgroundColor: AppColors.surface,
                                        side: BorderSide(
                                          color: isSelected ? AppColors.primary : AppColors.border,
                                        ),
                                        labelStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: isSelected ? AppColors.primary : AppColors.textMuted,
                                        ),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),

                      // Purchases List
                      if (_purchasesService.isLoading)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        )
                      else if (filtered.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: const Icon(
                                      Icons.receipt_outlined,
                                      size: 36,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  const Text(
                                    'لا توجد عمليات شراء',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textMain,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'اضغط على زر الإضافة بالأسفل لتسجيل أول عملية شراء للمخزون.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = filtered[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: PurchaseCard(
                                    item: item,
                                    onEdit: () => _openEditModal(item),
                                    onDelete: () => _purchasesService.deletePurchase(item.id),
                                  ),
                                );
                              },
                              childCount: filtered.length,
                            ),
                          ),
                        ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: 80),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentNavIndex,
          onDestinationSelected: (idx) => setState(() => _currentNavIndex = idx),
          backgroundColor: AppColors.pureWhite,
          indicatorColor: AppColors.primaryLight,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded, color: AppColors.primary),
              label: 'سجل المشتريات',
            ),
            NavigationDestination(
              icon: Icon(Icons.table_chart_outlined),
              selectedIcon: Icon(Icons.table_chart_rounded, color: AppColors.primary),
              label: 'قائمة المخزون',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddModal,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add, size: 24),
          label: const Text(
            'إضافة شراء',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  },
);
}
}
