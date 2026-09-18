import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' show sqfliteFfiInit, databaseFactoryFfi;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' show databaseFactoryFfiWeb;
import '../models/purchase.dart';

/// كلاس إدارة قاعدة البيانات المحلية SQLite
/// تم بناؤه وفق المعايير الأكاديمية المشروحة في [المحاضرة التاسعة - قواعد البيانات SQFlite]
class DatabaseHelper {
  static const String _databaseName = 'athar_inventory.db';
  static const int _databaseVersion = 1;
  static const String tablePurchases = 'purchases';

  // أسماء الأعمدة في الجدول
  static const String colId = 'id';
  static const String colItemName = 'item_name';
  static const String colQuantity = 'quantity';
  static const String colUnitPrice = 'unit_price';
  static const String colPurchaseDate = 'purchase_date';
  static const String colInvoiceUri = 'invoice_uri';
  static const String colNotes = 'notes';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colUserEmail = 'user_email';
  static const String colItemsJson = 'items_json';

  // تطبيق نمط Singleton لضمان وجود نسخة اتصال واحدة بقاعدة البيانات
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  // [محاضرة 9]: التعامل غير المتزامن Future لإرجاع كائن قاعدة البيانات دون تجميد واجهة المستخدم UI
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // [محاضرة 9]: تهيئة قاعدة البيانات واستخدام getDatabasesPath و join لدمج المسار
  Future<Database> _initDatabase() async {
    // تهيئة المحرك للعمل بسلاسة على بيئات الويب وسطح المكتب والأجهزة المحمولة
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // [محاضرة 9]: دالة getDatabasesPath لتحديد مجلد تخزين قواعد البيانات المخصص للنظام
    final databasesPath = await getDatabasesPath();
    // [محاضرة 9]: دالة join من مكتبة path لدمج المسارات بشكل آمن ومتوافق مع نظام التشغيل
    final path = join(databasesPath, _databaseName);

    // [محاضرة 9]: دالة openDatabase لفتح أو إنشاء قاعدة البيانات وتنفيذ onCreate
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onOpen: (db) async {
        try {
          await db.execute('ALTER TABLE $tablePurchases ADD COLUMN $colUserEmail TEXT;');
        } catch (_) {
          // Column already exists
        }
        try {
          await db.execute('ALTER TABLE $tablePurchases ADD COLUMN $colItemsJson TEXT;');
        } catch (_) {
          // Column already exists
        }
      },
    );
  }

  // [محاضرة 9]: دالة execute لتنفيذ أوامر تعريف البيانات (DDL) مثل CREATE TABLE
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tablePurchases (
        $colId TEXT PRIMARY KEY,
        $colItemName TEXT NOT NULL,
        $colQuantity INTEGER NOT NULL,
        $colUnitPrice REAL NOT NULL,
        $colPurchaseDate TEXT NOT NULL,
        $colInvoiceUri TEXT,
        $colNotes TEXT,
        $colCreatedAt TEXT NOT NULL,
        $colUpdatedAt TEXT NOT NULL,
        $colUserEmail TEXT,
        $colItemsJson TEXT
      )
    ''');
  }

  // [محاضرة 9]: عمليات إدراج البيانات (DML) - حفظ عنصر شراء جديد في SQLite مع عزل الحساب ودعم الأصناف المتعددة
  Future<int> insertPurchase(Purchase purchase, {String? userEmail}) async {
    final db = await database;
    final email = (purchase.userEmail ?? userEmail)?.trim().toLowerCase();
    final itemsJson = jsonEncode(purchase.items.map((i) => i.toJson()).toList());

    return await db.insert(
      tablePurchases,
      {
        colId: purchase.id,
        colItemName: purchase.itemName,
        colQuantity: purchase.quantity,
        colUnitPrice: purchase.unitPrice,
        colPurchaseDate: purchase.purchaseDate,
        colInvoiceUri: purchase.invoiceUri,
        colNotes: purchase.notes,
        colCreatedAt: purchase.createdAt,
        colUpdatedAt: purchase.updatedAt,
        colUserEmail: email,
        colItemsJson: itemsJson,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // [محاضرة 9]: استعالمات جلب البيانات (DQL) - SELECT واسترجاع قائمة المشتريات المعزولة للمستخدم مع تفاصيل الأصناف
  Future<List<Purchase>> getAllPurchases({String? userEmail}) async {
    final db = await database;
    final normalized = userEmail?.trim().toLowerCase();

    List<Map<String, dynamic>> maps;

    if (normalized != null && normalized.isNotEmpty && normalized != 'local@device' && normalized != 'guest') {
      // إسناد السجلات السابقة التلقائية التي بدون بريد للحساب الإداري الأساسي إن وجدت
      if (normalized == 'athar.admin@gmail.com') {
        try {
          await db.update(
            tablePurchases,
            {colUserEmail: normalized},
            where: '$colUserEmail IS NULL OR $colUserEmail = ?',
            whereArgs: [''],
          );
        } catch (_) {}
      }

      // جلب السجلات التابعة فقط لهذا الحساب المعين
      maps = await db.query(
        tablePurchases,
        where: 'LOWER($colUserEmail) = ?',
        whereArgs: [normalized],
        orderBy: '$colPurchaseDate DESC, $colCreatedAt DESC',
      );
    } else {
      // جلب بيانات الضيف المحلي فقط
      maps = await db.query(
        tablePurchases,
        where: '$colUserEmail IS NULL OR $colUserEmail = ? OR $colUserEmail = ? OR $colUserEmail = ?',
        whereArgs: ['', 'guest', 'local@device'],
        orderBy: '$colPurchaseDate DESC, $colCreatedAt DESC',
      );
    }

    return List.generate(maps.length, (i) {
      final row = maps[i];
      final rawItemsJson = row[colItemsJson] as String?;
      List<InvoiceItem> items = [];

      if (rawItemsJson != null && rawItemsJson.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(rawItemsJson);
          if (decoded is List) {
            items = decoded
                .map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        } catch (_) {}
      }

      final rawName = row[colItemName] as String;
      final rawQty = (row[colQuantity] as num).toInt();
      final rawPrice = (row[colUnitPrice] as num).toDouble();

      if (items.isEmpty && rawName.isNotEmpty) {
        items = [
          InvoiceItem(
            name: rawName,
            quantity: rawQty,
            unitPrice: rawPrice,
          )
        ];
      }

      return Purchase(
        id: row[colId] as String,
        itemName: rawName,
        quantity: items.isNotEmpty ? items.fold(0, (s, it) => s + it.quantity) : rawQty,
        unitPrice: rawPrice,
        purchaseDate: row[colPurchaseDate] as String,
        invoiceUri: row[colInvoiceUri] as String?,
        notes: row[colNotes] as String?,
        createdAt: row[colCreatedAt] as String? ?? DateTime.now().toIso8601String(),
        updatedAt: row[colUpdatedAt] as String? ?? DateTime.now().toIso8601String(),
        userEmail: row[colUserEmail] as String?,
        items: items,
      );
    });
  }

  // [محاضرة 9]: استعالمات تحديث البيانات (DML) - تعديل سجل مشتريات موجود عبر UPDATE
  Future<int> updatePurchase(Purchase purchase, {String? userEmail}) async {
    final db = await database;
    final email = (purchase.userEmail ?? userEmail)?.trim().toLowerCase();
    final itemsJson = jsonEncode(purchase.items.map((i) => i.toJson()).toList());

    return await db.update(
      tablePurchases,
      {
        colItemName: purchase.itemName,
        colQuantity: purchase.quantity,
        colUnitPrice: purchase.unitPrice,
        colPurchaseDate: purchase.purchaseDate,
        colInvoiceUri: purchase.invoiceUri,
        colNotes: purchase.notes,
        colCreatedAt: purchase.createdAt,
        colUpdatedAt: purchase.updatedAt,
        colUserEmail: email,
        colItemsJson: itemsJson,
      },
      where: '$colId = ?',
      whereArgs: [purchase.id],
    );
  }

  // [محاضرة 9]: استعلامات حذف البيانات (DML) - حذف سجل بناءً على المعرف id
  Future<int> deletePurchase(String id) async {
    final db = await database;
    return await db.delete(
      tablePurchases,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  // حذف كافة السجلات الخاصة بالحساب الحالي فقط للبدء من الصفر دون مساس بحسابات المستخدمين الآخرين
  Future<int> clearAllPurchases({String? userEmail}) async {
    final db = await database;
    final normalized = userEmail?.trim().toLowerCase();
    if (normalized != null && normalized.isNotEmpty && normalized != 'local@device' && normalized != 'guest') {
      return await db.delete(
        tablePurchases,
        where: 'LOWER($colUserEmail) = ?',
        whereArgs: [normalized],
      );
    } else {
      return await db.delete(
        tablePurchases,
        where: '$colUserEmail IS NULL OR $colUserEmail = ? OR $colUserEmail = ? OR $colUserEmail = ?',
        whereArgs: ['', 'guest', 'local@device'],
      );
    }
  }

  // إدراج دفعة مشتريات مع ربطها بحساب المستخدم (مفيدة للاستيراد السريع واستعادة النسخ الاحتياطية)
  Future<void> batchInsert(List<Purchase> purchases, {String? userEmail}) async {
    final db = await database;
    final batch = db.batch();
    final defaultEmail = userEmail?.trim().toLowerCase();

    for (final p in purchases) {
      final email = (p.userEmail ?? defaultEmail)?.trim().toLowerCase();
      final itemsJson = jsonEncode(p.items.map((i) => i.toJson()).toList());

      batch.insert(
        tablePurchases,
        {
          colId: p.id,
          colItemName: p.itemName,
          colQuantity: p.quantity,
          colUnitPrice: p.unitPrice,
          colPurchaseDate: p.purchaseDate,
          colInvoiceUri: p.invoiceUri,
          colNotes: p.notes,
          colCreatedAt: p.createdAt,
          colUpdatedAt: p.updatedAt,
          colUserEmail: email,
          colItemsJson: itemsJson,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // إغلاق اتصال قاعدة البيانات عند الحاجة
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
