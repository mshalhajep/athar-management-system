import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/purchase.dart';
import 'database_helper.dart';
import 'firestore_sync_service.dart';

enum FilterPeriod {
  all('كل المدة'),
  month('هذا الشهر'),
  sixMonths('آخر 6 أشهر'),
  year('آخر سنة');

  final String label;
  const FilterPeriod(this.label);
}

class PurchasesService extends ChangeNotifier {
  // [محاضرة 9 - التعامل مع قواعد البيانات SQFlite]: كائن إدارة الاتصال بقاعدة البيانات المحلية SQLite
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirestoreSyncService _firestoreSync = FirestoreSyncService.instance;
  StreamSubscription<List<Purchase>>? _cloudStreamSub;

  String? _currentUserEmail;
  List<Purchase> _purchases = [];
  bool _isLoading = true;
  String _searchQuery = '';
  FilterPeriod _selectedPeriod = FilterPeriod.all;

  List<Purchase> get purchases => _purchases;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  FilterPeriod get selectedPeriod => _selectedPeriod;
  String? get currentUserEmail => _currentUserEmail;

  PurchasesService({String? initialEmail}) {
    _currentUserEmail = initialEmail?.trim().toLowerCase();
    loadPurchases();
  }

  @override
  void dispose() {
    _cloudStreamSub?.cancel();
    super.dispose();
  }

  /// تحديث حساب المستخدم الحالي وإعادة تحميل بياناته المعزولة فورياً
  void setUserEmail(String? email) {
    final normalized = email?.trim().toLowerCase();
    if (_currentUserEmail != normalized) {
      _currentUserEmail = normalized;
      loadPurchases();
    }
  }

  /// مسح الذاكرة المؤقتة عند تسجيل الخروج لمنع ظهور بيانات المستخدم السابق
  void clearInAppMemory() {
    _purchases = [];
    _searchQuery = '';
    _selectedPeriod = FilterPeriod.all;
    notifyListeners();
  }

  Future<void> loadPurchases() {
    return _loadPurchasesInternal();
  }

  String _getUserPrefKey() {
    if (_currentUserEmail != null && _currentUserEmail!.isNotEmpty && _currentUserEmail != 'local@device' && _currentUserEmail != 'guest') {
      return 'athar_purchases_${_currentUserEmail!}';
    }
    return 'athar_purchases_guest';
  }

  // [محاضرة 9]: تحميل البيانات بشكل غير متزامن Asynchronous (Future) من قاعدة بيانات SQLite معزولة لكل حساب
  Future<void> _loadPurchasesInternal() async {
    _isLoading = true;
    notifyListeners();

    try {
      // [محاضرة 9]: استدعاء استعلام SELECT من SQLite عبر DatabaseHelper للحساب الحالي فقط
      _purchases = await _dbHelper.getAllPurchases(userEmail: _currentUserEmail);

      // استيراد أي نسخة احتياطية محلية سابقة خاصة بهذا الحساب إن وجدت وكانت قاعدة البيانات فارغة له
      if (_purchases.isEmpty && _currentUserEmail != null && _currentUserEmail!.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString(_getUserPrefKey());
        if (raw != null && raw.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
          final list = decoded
              .map((item) => Purchase.fromJson(item as Map<String, dynamic>))
              .toList();
          if (list.isNotEmpty) {
            await _dbHelper.batchInsert(list, userEmail: _currentUserEmail);
            _purchases = list;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading purchases from SQLite: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      _startCloudSync();
    }
  }

  /// الاستماع والمزامنة السحابية اللحظية لدمج أي فواتير جديدة من الأجهزة الأخرى
  void _startCloudSync() {
    _cloudStreamSub?.cancel();
    final email = _currentUserEmail;
    if (email == null || email.isEmpty || email == 'guest' || email == 'local@device') {
      return;
    }

    try {
      _cloudStreamSub = _firestoreSync.streamPurchases(userEmail: email).listen((cloudPurchases) async {
        if (cloudPurchases.isNotEmpty) {
          bool changed = false;
          for (final cp in cloudPurchases) {
            final idx = _purchases.indexWhere((p) => p.id == cp.id);
            if (idx == -1) {
              _purchases.add(cp);
              await _dbHelper.insertPurchase(cp, userEmail: email);
              changed = true;
            } else if (cp.updatedAt.compareTo(_purchases[idx].updatedAt) > 0) {
              _purchases[idx] = cp;
              await _dbHelper.updatePurchase(cp, userEmail: email);
              changed = true;
            }
          }
          if (changed) {
            _purchases.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
            notifyListeners();
            await _persist();
          }
        }
      }, onError: (e) {
        debugPrint('Cloud sync stream error: $e');
      });
    } catch (e) {
      debugPrint('Error initializing cloud sync stream: $e');
    }
  }

  // حفظ نسخة احتياطية إضافية في SharedPreferences معزولة لكل حساب
  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserPrefKey();
      final encoded = jsonEncode(_purchases.map((p) => p.toJson()).toList());
      await prefs.setString(key, encoded);
    } catch (e) {
      debugPrint('Error saving purchases backup: $e');
    }
  }

  // [محاضرة 9]: إضافة عملية شراء جديدة وحفظها في قاعدة بيانات SQLite عبر insert مع وسم البريد ودعم الأصناف المتعددة
  Future<void> addPurchase({
    String? itemName,
    int? quantity,
    double? unitPrice,
    List<InvoiceItem>? items,
    required String purchaseDate,
    String? invoiceUri,
    String? notes,
  }) async {
    final now = DateTime.now().toIso8601String();

    List<InvoiceItem> finalItems = [];
    if (items != null && items.isNotEmpty) {
      finalItems = List.from(items);
    } else if (itemName != null && itemName.isNotEmpty) {
      finalItems = [
        InvoiceItem(
          name: itemName,
          quantity: quantity ?? 1,
          unitPrice: unitPrice ?? 0.0,
        )
      ];
    }

    final derivedName = finalItems.length == 1
        ? finalItems.first.name
        : (itemName != null && itemName.trim().isNotEmpty
            ? itemName.trim()
            : finalItems.map((e) => e.name).join('، '));
    final derivedQty = finalItems.isNotEmpty
        ? finalItems.fold(0, (sum, i) => sum + i.quantity)
        : (quantity ?? 1);
    final derivedPrice = finalItems.length == 1
        ? finalItems.first.unitPrice
        : (unitPrice ?? 0.0);

    final newPurchase = Purchase(
      id: '${DateTime.now().millisecondsSinceEpoch}-${derivedName.hashCode}',
      itemName: derivedName,
      quantity: derivedQty,
      unitPrice: derivedPrice,
      purchaseDate: purchaseDate,
      invoiceUri: invoiceUri,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      userEmail: _currentUserEmail,
      items: finalItems,
    );

    // [محاضرة 9]: إدراج فوري في جدول SQLite مع البريد المعزول
    await _dbHelper.insertPurchase(newPurchase, userEmail: _currentUserEmail);

    _purchases.insert(0, newPurchase);
    notifyListeners();
    await _persist();

    // المزامنة اللحظية مع السحابة
    _firestoreSync.syncPurchaseToCloud(newPurchase);
  }

  // [محاضرة 9]: تعديل بيانات السجل في قاعدة بيانات SQLite عبر update
  Future<void> updatePurchase(Purchase updated) async {
    final index = _purchases.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      final updatedItem = updated.copyWith(
        updatedAt: DateTime.now().toIso8601String(),
        userEmail: _currentUserEmail ?? updated.userEmail,
      );
      // [محاضرة 9]: تنفيذ أمر UPDATE على SQLite
      await _dbHelper.updatePurchase(updatedItem, userEmail: _currentUserEmail);

      _purchases[index] = updatedItem;
      notifyListeners();
      await _persist();

      // المزامنة اللحظية مع السحابة
      _firestoreSync.syncPurchaseToCloud(updatedItem);
    }
  }

  // [محاضرة 9]: حذف السجل من قاعدة بيانات SQLite عبر delete
  Future<void> deletePurchase(String id) async {
    // [محاضرة 9]: تنفيذ أمر DELETE على SQLite
    await _dbHelper.deletePurchase(id);

    _purchases.removeWhere((p) => p.id == id);
    notifyListeners();
    await _persist();

    // حذف الفاتورة من السحابة
    _firestoreSync.deletePurchaseFromCloud(id);
  }

  // [محاضرة 9]: استبدال وتحديث السجلات دفعة واحدة لحساب المستخدم الحالي فقط
  Future<void> replacePurchases(List<Purchase> newPurchases) async {
    await _dbHelper.clearAllPurchases(userEmail: _currentUserEmail);
    await _dbHelper.batchInsert(newPurchases, userEmail: _currentUserEmail);

    _purchases = List.from(newPurchases);
    notifyListeners();
    await _persist();
  }

  // [محاضرة 9]: تصفير كامل بيانات جدول المشتريات للحساب الحالي فقط دون المساس ببيانات الحسابات الأخرى
  Future<void> clearAllPurchases() async {
    await _dbHelper.clearAllPurchases(userEmail: _currentUserEmail);
    _purchases.clear();
    notifyListeners();
    await _persist();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterPeriod(FilterPeriod period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  List<Purchase> get filteredPurchases {
    final now = DateTime.now();
    DateTime? cutoff;

    switch (_selectedPeriod) {
      case FilterPeriod.month:
        cutoff = DateTime(now.year, now.month, 1);
        break;
      case FilterPeriod.sixMonths:
        cutoff = DateTime(now.year, now.month - 6, now.day);
        break;
      case FilterPeriod.year:
        cutoff = DateTime(now.year - 1, now.month, now.day);
        break;
      case FilterPeriod.all:
        cutoff = null;
        break;
    }

    final query = _searchQuery.trim().toLowerCase();

    return _purchases.filter((item) {
      bool matchesDate = true;
      if (cutoff != null) {
        try {
          final pDate = DateTime.parse('${item.purchaseDate}T00:00:00');
          matchesDate = pDate.isAfter(cutoff) || pDate.isAtSameMomentAs(cutoff);
        } catch (_) {
          matchesDate = true;
        }
      }

      final matchesQuery = query.isEmpty ||
          item.itemName.toLowerCase().contains(query) ||
          (item.notes ?? '').toLowerCase().contains(query);

      return matchesDate && matchesQuery;
    }).toList();
  }

  double get filteredTotalAmount {
    return filteredPurchases.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get filteredTotalQuantity {
    return filteredPurchases.fold(0, (sum, item) => sum + item.quantity);
  }

  double get allTimeTotalAmount {
    return _purchases.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
}

extension _ListFilter<T> on List<T> {
  Iterable<T> filter(bool Function(T) test) sync* {
    for (final element in this) {
      if (test(element)) yield element;
    }
  }
}
