import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:athar_purchases/models/purchase.dart';
import 'package:athar_purchases/services/database_helper.dart';

void main() {
  setUpAll(() {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  });

  group('اختبارات نموذج الأصناف المتعددة والفاتورة (InvoiceItem & Purchase)', () {
    test('حساب إجمالي كل صنف بدقة (الكمية × سعر الوحدة)', () {
      final item1 = InvoiceItem(name: 'أرز بشاور', quantity: 3, unitPrice: 45.0);
      final item2 = InvoiceItem(name: 'سكر ناعم', quantity: 2, unitPrice: 15.5);

      expect(item1.total, 135.0);
      expect(item2.total, 31.0);
    });

    test('حساب إجمالي الفاتورة ومجموع القطع لعدة أصناف', () {
      final items = [
        InvoiceItem(name: 'أرز', quantity: 2, unitPrice: 5.0),
        InvoiceItem(name: 'سكر', quantity: 3, unitPrice: 4.0),
        InvoiceItem(name: 'زيت', quantity: 1, unitPrice: 8.0),
      ];

      final purchase = Purchase(
        id: 'inv-test-1',
        itemName: 'فاتورة تموينات',
        quantity: 6,
        unitPrice: 0.0,
        purchaseDate: '2026-09-17',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        items: items,
      );

      // 2*5 + 3*4 + 1*8 = 10 + 12 + 8 = 30
      expect(purchase.totalPrice, 30.0);
      expect(purchase.totalQuantity, 6);
      expect(purchase.items.length, 3);
      expect(purchase.items[0].name, 'أرز');
      expect(purchase.items[1].name, 'سكر');
      expect(purchase.items[2].name, 'زيت');
    });

    test('التوافق الرجعي مع الفواتير القديمة ذات الصنف الواحد', () {
      final legacyJson = {
        'id': 'legacy-001',
        'itemName': 'طابعة ليزر',
        'quantity': 2,
        'unitPrice': 650.0,
        'purchaseDate': '2026-09-01',
        'createdAt': '2026-09-01T10:00:00',
        'updatedAt': '2026-09-01T10:00:00',
      };

      final p = Purchase.fromJson(legacyJson);

      expect(p.id, 'legacy-001');
      expect(p.itemName, 'طابعة ليزر');
      expect(p.items.length, 1);
      expect(p.items.first.name, 'طابعة ليزر');
      expect(p.items.first.quantity, 2);
      expect(p.items.first.unitPrice, 650.0);
      expect(p.totalPrice, 1300.0);
    });

    test('تحويل الفاتورة إلى JSON واسترجاعها بدقة تامة لكافة الأصناف', () {
      final items = [
        InvoiceItem(name: 'لوحة مفاتيح', quantity: 4, unitPrice: 120.0),
        InvoiceItem(name: 'فأرة لاسلكية', quantity: 5, unitPrice: 60.0),
      ];

      final original = Purchase(
        id: 'json-test-1',
        itemName: 'أجهزة مكتبية',
        quantity: 9,
        unitPrice: 0.0,
        purchaseDate: '2026-09-17',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        items: items,
      );

      final json = original.toJson();
      final restored = Purchase.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.items.length, 2);
      expect(restored.items[0].name, 'لوحة مفاتيح');
      expect(restored.items[0].total, 480.0);
      expect(restored.items[1].name, 'فأرة لاسلكية');
      expect(restored.items[1].total, 300.0);
      expect(restored.totalPrice, 780.0);
    });
  });

  group('اختبارات قاعدة بيانات SQLite للأصناف المتعددة (DatabaseHelper)', () {
    final dbHelper = DatabaseHelper.instance;
    const testUser = 'test_multi_items@athar.sa';

    tearDown(() async {
      await dbHelper.clearAllPurchases(userEmail: testUser);
    });

    test('إدراج فاتورة متعددة الأصناف واسترجاعها بكافة تفاصيلها من SQLite', () async {
      final items = [
        InvoiceItem(name: 'أرز', quantity: 2, unitPrice: 5.0),
        InvoiceItem(name: 'سكر', quantity: 3, unitPrice: 4.0),
        InvoiceItem(name: 'زيت', quantity: 1, unitPrice: 8.0),
      ];

      final newInvoice = Purchase(
        id: 'sqlite-multi-1',
        itemName: 'أرز، سكر، زيت',
        quantity: 6,
        unitPrice: 5.0,
        purchaseDate: '2026-09-17',
        notes: 'مشتريات غذائية شهرية',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        userEmail: testUser,
        items: items,
      );

      await dbHelper.insertPurchase(newInvoice, userEmail: testUser);

      final purchases = await dbHelper.getAllPurchases(userEmail: testUser);
      expect(purchases.isNotEmpty, true);

      final saved = purchases.firstWhere((p) => p.id == 'sqlite-multi-1');
      expect(saved.totalPrice, 30.0);
      expect(saved.totalQuantity, 6);
      expect(saved.notes, 'مشتريات غذائية شهرية');
      expect(saved.items.length, 3);
      expect(saved.items[0].name, 'أرز');
      expect(saved.items[0].quantity, 2);
      expect(saved.items[0].unitPrice, 5.0);
      expect(saved.items[1].name, 'سكر');
      expect(saved.items[1].quantity, 3);
      expect(saved.items[1].unitPrice, 4.0);
      expect(saved.items[2].name, 'زيت');
      expect(saved.items[2].quantity, 1);
      expect(saved.items[2].unitPrice, 8.0);
    });

    test('تعديل فاتورة متعددة الأصناف وإضافة صنف جديد لها في SQLite', () async {
      final initialItems = [
        InvoiceItem(name: 'أقلام حبر', quantity: 10, unitPrice: 2.0),
      ];

      final invoice = Purchase(
        id: 'sqlite-multi-edit',
        itemName: 'أقلام حبر',
        quantity: 10,
        unitPrice: 2.0,
        purchaseDate: '2026-09-17',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        userEmail: testUser,
        items: initialItems,
      );

      await dbHelper.insertPurchase(invoice, userEmail: testUser);

      final updatedItems = [
        ...initialItems,
        InvoiceItem(name: 'دفاتر ملاحظات', quantity: 5, unitPrice: 10.0),
      ];

      final updatedInvoice = invoice.copyWith(
        items: updatedItems,
        notes: 'تمت إضافة الدفاتر',
      );

      await dbHelper.updatePurchase(updatedInvoice, userEmail: testUser);

      final purchases = await dbHelper.getAllPurchases(userEmail: testUser);
      final saved = purchases.firstWhere((p) => p.id == 'sqlite-multi-edit');

      expect(saved.items.length, 2);
      expect(saved.totalQuantity, 15);
      // 10*2 + 5*10 = 20 + 50 = 70
      expect(saved.totalPrice, 70.0);
      expect(saved.notes, 'تمت إضافة الدفاتر');
    });
  });
}
