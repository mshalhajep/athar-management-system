import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:athar_purchases/models/purchase.dart';
import 'package:athar_purchases/services/database_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  });

  group('اختبارات قاعدة البيانات SQLite (المحاضرة التاسعة)', () {
    final dbHelper = DatabaseHelper.instance;

    test('إدراج واسترجاع عملية شراء من جدول SQLite', () async {
      final item = Purchase(
        id: 'test-1',
        itemName: 'صندوق هدايا فاخر',
        quantity: 5,
        unitPrice: 120.0,
        purchaseDate: '2026-09-16',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      // اختبار الإدراج (Insert)
      await dbHelper.insertPurchase(item);

      // اختبار الاسترجاع (Query)
      final all = await dbHelper.getAllPurchases();
      expect(all.any((p) => p.id == 'test-1' && p.itemName == 'صندوق هدايا فاخر'), isTrue);
    });

    test('تعديل عملية شراء في SQLite', () async {
      final updated = Purchase(
        id: 'test-1',
        itemName: 'صندوق هدايا معدل',
        quantity: 10,
        unitPrice: 150.0,
        purchaseDate: '2026-09-16',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      // اختبار التعديل (Update)
      await dbHelper.updatePurchase(updated);

      final all = await dbHelper.getAllPurchases();
      final found = all.firstWhere((p) => p.id == 'test-1');
      expect(found.itemName, 'صندوق هدايا معدل');
      expect(found.quantity, 10);
      expect(found.unitPrice, 150.0);
    });

    test('حذف عملية شراء من SQLite', () async {
      // اختبار الحذف (Delete)
      await dbHelper.deletePurchase('test-1');

      final all = await dbHelper.getAllPurchases();
      expect(all.any((p) => p.id == 'test-1'), isFalse);
    });
  });
}
