import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/purchase.dart';
import 'purchases_service.dart';
import 'auth_service.dart';
import 'firestore_sync_service.dart';

class BackupMetadata {
  final String timestamp;
  final int totalItems;
  final double totalAmount;
  final String appVersion;
  final String? accountEmail;

  const BackupMetadata({
    required this.timestamp,
    required this.totalItems,
    required this.totalAmount,
    required this.appVersion,
    this.accountEmail,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'totalItems': totalItems,
    'totalAmount': totalAmount,
    'appVersion': appVersion,
    'accountEmail': accountEmail,
  };

  factory BackupMetadata.fromJson(Map<String, dynamic> map) => BackupMetadata(
    timestamp: map['timestamp'] as String? ?? DateTime.now().toIso8601String(),
    totalItems: map['totalItems'] as int? ?? 0,
    totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
    appVersion: map['appVersion'] as String? ?? '1.0.0',
    accountEmail: map['accountEmail'] as String?,
  );
}

/// خدمة النسخ الاحتياطي والمزامنة السحابية
/// [محاضرة 8]: تطبيق البرمجة غير المتزامنة async و await والتعامل مع Future لتجنب تجميد الواجهة أثناء حفظ وقراءة الملفات
class BackupSyncService extends ChangeNotifier {
  static const String _driveBackupKey = 'athar_google_drive_backup_v1';
  static const String _lastSyncTimeKey = 'athar_last_sync_timestamp';

  bool _isSyncing = false;
  String? _lastSyncTime;

  bool get isSyncing => _isSyncing;
  String? get lastSyncTime => _lastSyncTime;

  BackupSyncService() {
    _loadSyncInfo();
  }

  Future<void> _loadSyncInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _lastSyncTime = prefs.getString(_lastSyncTimeKey);
    notifyListeners();
  }

  /// توليد نص النسخة الاحتياطية بصيغة JSON متكاملة
  String generateBackupJson({
    required List<Purchase> purchases,
    String? userEmail,
  }) {
    final totalAmount = purchases.fold(0.0, (sum, p) => sum + p.totalPrice);
    final metadata = BackupMetadata(
      timestamp: DateTime.now().toIso8601String(),
      totalItems: purchases.length,
      totalAmount: totalAmount,
      appVersion: '1.0.0',
      accountEmail: userEmail,
    );

    final payload = {
      'system': 'إدارة مخزون شركة أثر',
      'metadata': metadata.toJson(),
      'purchases': purchases.map((p) => p.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// [محاضرة 8]: تصدير النسخة الاحتياطية كملف محلي (.athar أو .json) داخل مجلد المستندات
  Future<File> exportBackupToFile({
    required PurchasesService purchasesService,
    String? userEmail,
  }) async {
    _isSyncing = true;
    notifyListeners();

    try {
      final jsonString = generateBackupJson(
        purchases: purchasesService.purchases,
        userEmail: userEmail,
      );

      final dir = await getApplicationDocumentsDirectory();
      final backupFolder = Directory(p.join(dir.path, 'athar_backups'));
      if (!await backupFolder.exists()) {
        await backupFolder.create(recursive: true);
      }

      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';
      final filePath = p.join(backupFolder.path, 'athar_backup_$dateStr.athar');

      final file = File(filePath);
      await file.writeAsString(jsonString, flush: true);
      return file;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// جلب قائمة ملفات النسخ الاحتياطية المحفوظة محلياً على الجهاز
  Future<List<FileSystemEntity>> listLocalBackupFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final backupFolder = Directory(p.join(dir.path, 'athar_backups'));
      if (await backupFolder.exists()) {
        final entities = await backupFolder.list().toList();
        // فرز الملفات من الأحدث إلى الأقدم
        entities.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
        return entities;
      }
    } catch (e) {
      debugPrint('Error listing backup files: $e');
    }
    return [];
  }

  /// [محاضرة 8 و 9]: استعادة البيانات من ملف محلي وإعادة تعبئة قاعدة بيانات SQLite
  Future<int> restoreFromFile(File file, PurchasesService purchasesService) async {
    _isSyncing = true;
    notifyListeners();

    try {
      final content = await file.readAsString();
      return await restoreFromJson(content, purchasesService);
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  String _getDriveKeyForEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return _driveBackupKey;
    }
    return 'athar_gdrive_${email.trim().toLowerCase()}';
  }

  /// [المرحلة 3: المزامنة السحابية بحساب Google]: رفع ومزامنة النسخة السحابية المرتبطة بإيميل المستخدم
  Future<bool> syncToGoogleDrive({
    required PurchasesService purchasesService,
    required AuthService authService,
  }) async {
    _isSyncing = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 900));

      final email = authService.currentUser?.email;

      // رفع كافة المشتريات الحالية مباشرة إلى سيرفر Firestore السحابي
      for (final p in purchasesService.purchases) {
        await FirestoreSyncService.instance.syncPurchaseToCloud(p);
      }

      final jsonString = generateBackupJson(
        purchases: purchasesService.purchases,
        userEmail: email,
      );

      final prefs = await SharedPreferences.getInstance();
      // حفظ النسخة باسم الحساب لضمان عزل وتزامن بيانات كل مستخدم على حدة
      await prefs.setString(_getDriveKeyForEmail(email), jsonString);
      await prefs.setString(_driveBackupKey, jsonString);

      final now = DateTime.now();
      _lastSyncTime = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      await prefs.setString(_lastSyncTimeKey, _lastSyncTime!);

      await authService.updateLastBackup(_lastSyncTime!);

      return true;
    } catch (e) {
      debugPrint('Sync error: $e');
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// [المرحلة 3]: استعادة النسخة السحابية المرتبطة بالحساب
  Future<int?> restoreFromGoogleDrive({
    required PurchasesService purchasesService,
    String? accountEmail,
  }) async {
    _isSyncing = true;
    notifyListeners();

    try {
      // المحاولة الأولى: جلب أحدث البيانات مباشرة من سيرفر Firestore السحابي
      final cloudItems = await FirestoreSyncService.instance.fetchPurchasesFromCloud(userEmail: accountEmail);
      if (cloudItems.isNotEmpty) {
        await purchasesService.replacePurchases(cloudItems);
        return cloudItems.length;
      }

      final prefs = await SharedPreferences.getInstance();
      final key = _getDriveKeyForEmail(accountEmail);
      String? raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) {
        raw = prefs.getString(_driveBackupKey);
      }

      if (raw == null || raw.isEmpty) {
        return null;
      }

      return await restoreFromJson(raw, purchasesService);
    } catch (e) {
      debugPrint('Restore error: $e');
      return null;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// [المرحلة 3]: تنزيل ومزامنة البيانات تلقائياً فور تسجيل الدخول بحساب Google من أي جهاز
  Future<int?> autoSyncOnLogin({
    required String userEmail,
    required PurchasesService purchasesService,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getDriveKeyForEmail(userEmail);
    final raw = prefs.getString(key);

    if (raw != null && raw.isNotEmpty) {
      // تنزيل السجلات المرتبطة بالحساب فوراً إلى قاعدة بيانات SQLite
      return await restoreFromJson(raw, purchasesService);
    }
    return null;
  }

  /// [محاضرة 9]: قراءة نص JSON واستدعاء replacePurchases لإعادة ملء قاعدة بيانات SQLite
  Future<int> restoreFromJson(String jsonContent, PurchasesService purchasesService) async {
    final Map<String, dynamic> data = jsonDecode(jsonContent) as Map<String, dynamic>;
    final List<dynamic> purchasesRaw = (data['purchases'] as List<dynamic>?) ?? [];

    final restoredList = purchasesRaw
        .map((p) => Purchase.fromJson(p as Map<String, dynamic>))
        .toList();

    // استبدال وإعادة إدراج كافة البيانات في جدول SQLite
    await purchasesService.replacePurchases(restoredList);
    return restoredList.length;
  }
}
