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

  group('اختبارات عزل بيانات الحسابات والمستخدمين (Multi-User Data Isolation)', () {
    final dbHelper = DatabaseHelper.instance;

    test('عزل تام لبيانات كل حساب: الحساب الجديد يبدأ من الصفر', () async {
      const userA = 'user.a@gmail.com';
      const userB = 'user.b@gmail.com';

      // 1. تصفير أي بيانات سابقة لحساب A و B
      await dbHelper.clearAllPurchases(userEmail: userA);
      await dbHelper.clearAllPurchases(userEmail: userB);

      // 2. التحقق من أن حساب A وحساب B يبدآن من الصفر تماماً
      final listA0 = await dbHelper.getAllPurchases(userEmail: userA);
      final listB0 = await dbHelper.getAllPurchases(userEmail: userB);
      expect(listA0.isEmpty, isTrue);
      expect(listB0.isEmpty, isTrue);

      // 3. إضافة مشتريات لحساب A
      await dbHelper.insertPurchase(
        Purchase(
          id: 'item-a-1',
          itemName: 'بضاعة حساب أ',
          quantity: 10,
          unitPrice: 50.0,
          purchaseDate: '2026-09-17',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          userEmail: userA,
        ),
        userEmail: userA,
      );

      // 4. استعلام حساب A: يجب أن يرى صنفاً واحداً
      final listA1 = await dbHelper.getAllPurchases(userEmail: userA);
      expect(listA1.length, 1);
      expect(listA1.first.itemName, 'بضاعة حساب أ');

      // 5. استعلام حساب B (المستخدم الجديد): يجب أن يظل فارغاً تماماً يبدأ من 0!
      final listB1 = await dbHelper.getAllPurchases(userEmail: userB);
      expect(listB1.isEmpty, isTrue, reason: 'الحساب الجديد يجب أن يعرض بياناته من الصفر دون رؤية بيانات الحساب الآخر');

      // 6. إضافة مشتريات خاصة بحساب B
      await dbHelper.insertPurchase(
        Purchase(
          id: 'item-b-1',
          itemName: 'بضاعة حساب ب الخاصة',
          quantity: 2,
          unitPrice: 200.0,
          purchaseDate: '2026-09-17',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          userEmail: userB,
        ),
        userEmail: userB,
      );

      // 7. التحقق من عزل كل حساب عن الآخر بشكل مستقل 100%
      final listA2 = await dbHelper.getAllPurchases(userEmail: userA);
      final listB2 = await dbHelper.getAllPurchases(userEmail: userB);

      expect(listA2.length, 1);
      expect(listA2.first.itemName, 'بضاعة حساب أ');

      expect(listB2.length, 1);
      expect(listB2.first.itemName, 'بضاعة حساب ب الخاصة');
    });
  });
}
