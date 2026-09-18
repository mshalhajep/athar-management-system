import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:athar_purchases/models/purchase.dart';
import 'package:athar_purchases/services/backup_sync_service.dart';
import 'package:athar_purchases/services/database_helper.dart';
import 'package:athar_purchases/services/purchases_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  });

  group('اختبارات صمام الأمان والنسخ الاحتياطي (المرحلة 2)', () {
    test('توليد واسترجاع نص النسخة الاحتياطية JSON وتطابق البيانات', () async {
      final backupService = BackupSyncService();
      final purchasesService = PurchasesService();

      final samplePurchases = [
        Purchase(
          id: 'b-1',
          itemName: 'طابعة فواتير أثر',
          quantity: 2,
          unitPrice: 350.0,
          purchaseDate: '2026-09-16',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ];

      // توليد JSON
      final jsonStr = backupService.generateBackupJson(
        purchases: samplePurchases,
        userEmail: 'admin@athar.com',
      );

      expect(jsonStr.contains('إدارة مخزون شركة أثر'), isTrue);
      expect(jsonStr.contains('طابعة فواتير أثر'), isTrue);

      // استرجاع السجلات في قاعدة البيانات
      final count = await backupService.restoreFromJson(jsonStr, purchasesService);
      expect(count, 1);

      final loaded = await DatabaseHelper.instance.getAllPurchases();
      expect(loaded.any((p) => p.itemName == 'طابعة فواتير أثر'), isTrue);
    });
  });
}
