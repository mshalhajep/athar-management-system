import 'dart:convert';

/// [نموذج بيانات الصنف داخل الفاتورة - InvoiceItem]:
/// يمثل عنصراً واحداً داخل الفاتورة ويحتوي على اسم الصنف، الكمية، وسعر الوحدة، مع الإجمالي المحسوب.
class InvoiceItem {
  final String id;
  final String name;
  final int quantity;
  final double unitPrice;

  InvoiceItem({
    String? id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  double get total => quantity * unitPrice;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'itemName': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'unit_price': unitPrice,
      'total': total,
    };
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] as String?,
      name: json['name'] as String? ?? json['itemName'] as String? ?? json['item_name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ??
          (json['unit_price'] as num?)?.toDouble() ??
          0.0,
    );
  }

  InvoiceItem copyWith({
    String? id,
    String? name,
    int? quantity,
    double? unitPrice,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}

/// [محاضرة 3 و 4 - كلاسات Dart والبرمجة كائنية التوجه OOP]:
/// تم بناء نموذج البيانات Purchase وفق مبادئ الكبسولة وتحديد الخصائص والمشيد (Constructor)
/// وطرق تحويل البيانات من وإلى Map للتعامل مع قاعدة بيانات SQLite و JSON.
/// يدعم نموذج الفاتورة قائمة متعددة من الأصناف (items) مع الحفاظ الكامل على التوافق الرجعي للفواتير الفردية السابقة.
class Purchase {
  final String id;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final String purchaseDate;
  final String? invoiceUri;
  final String? notes;
  final String createdAt;
  final String updatedAt;
  final String? userEmail;
  final List<InvoiceItem> items;

  Purchase({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.purchaseDate,
    this.invoiceUri,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.userEmail,
    List<InvoiceItem>? items,
  }) : items = (items != null && items.isNotEmpty)
            ? List.unmodifiable(items)
            : List.unmodifiable([
                InvoiceItem(
                  name: itemName,
                  quantity: quantity,
                  unitPrice: unitPrice,
                )
              ]);

  /// إجمالي الفاتورة: مجموع إجماليات كافة الأصناف داخل الفاتورة
  double get totalPrice {
    if (items.isNotEmpty) {
      return items.fold(0.0, (sum, item) => sum + item.total);
    }
    return quantity * unitPrice;
  }

  /// إجمالي عدد القطع في الفاتورة
  int get totalQuantity {
    if (items.isNotEmpty) {
      return items.fold(0, (sum, item) => sum + item.quantity);
    }
    return quantity;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'purchaseDate': purchaseDate,
      'invoiceUri': invoiceUri,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userEmail': userEmail,
      'user_email': userEmail,
      'items': items.map((e) => e.toJson()).toList(),
      'items_json': jsonEncode(items.map((e) => e.toJson()).toList()),
    };
  }

  factory Purchase.fromJson(Map<String, dynamic> json) {
    List<InvoiceItem> parsedItems = [];

    // استخراج الأصناف من قائمة كائنات JSON إن وجدت
    if (json['items'] != null && json['items'] is List) {
      parsedItems = (json['items'] as List)
          .map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    // استخراج الأصناف من عمود SQLite المخزن بنص JSON إن وجد
    else if (json['items_json'] != null &&
        json['items_json'] is String &&
        (json['items_json'] as String).trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(json['items_json'] as String);
        if (decoded is List) {
          parsedItems = decoded
              .map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {}
    }

    final rawName = json['itemName'] as String? ?? json['item_name'] as String? ?? '';
    final rawQuantity = (json['quantity'] as num?)?.toInt() ?? 1;
    final rawUnitPrice = (json['unitPrice'] as num?)?.toDouble() ??
        (json['unit_price'] as num?)?.toDouble() ??
        0.0;

    // توافق رجعي: إذا لم توجد قائمة أصناف وكان هناك اسم صنف قديم، نحوله لصنف داخل القائمة
    if (parsedItems.isEmpty && rawName.isNotEmpty) {
      parsedItems = [
        InvoiceItem(
          name: rawName,
          quantity: rawQuantity,
          unitPrice: rawUnitPrice,
        )
      ];
    }

    // حساب إجمالي الكمية والاسم التلخيصي
    final finalName = parsedItems.isNotEmpty
        ? (rawName.isNotEmpty ? rawName : parsedItems.map((e) => e.name).join('، '))
        : rawName;
    final finalQuantity = parsedItems.isNotEmpty
        ? parsedItems.fold(0, (sum, item) => sum + item.quantity)
        : rawQuantity;

    return Purchase(
      id: json['id'] as String,
      itemName: finalName,
      quantity: finalQuantity,
      unitPrice: rawUnitPrice,
      purchaseDate: json['purchaseDate'] as String? ?? json['purchase_date'] as String? ?? '',
      invoiceUri: json['invoiceUri'] as String? ?? json['invoice_uri'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] as String? ?? json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      userEmail: json['userEmail'] as String? ?? json['user_email'] as String?,
      items: parsedItems,
    );
  }

  Purchase copyWith({
    String? id,
    String? itemName,
    int? quantity,
    double? unitPrice,
    String? purchaseDate,
    String? invoiceUri,
    String? notes,
    String? createdAt,
    String? updatedAt,
    String? userEmail,
    List<InvoiceItem>? items,
  }) {
    final newItems = items ?? this.items;
    final derivedName = itemName ??
        (newItems.length == 1
            ? newItems.first.name
            : newItems.map((e) => e.name).join('، '));
    final int derivedQty = quantity ??
        (newItems.isNotEmpty
            ? newItems.fold<int>(0, (sum, i) => sum + i.quantity)
            : this.quantity);

    return Purchase(
      id: id ?? this.id,
      itemName: derivedName,
      quantity: derivedQty,
      unitPrice: unitPrice ?? (newItems.length == 1 ? newItems.first.unitPrice : this.unitPrice),
      purchaseDate: purchaseDate ?? this.purchaseDate,
      invoiceUri: invoiceUri ?? this.invoiceUri,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userEmail: userEmail ?? this.userEmail,
      items: newItems,
    );
  }
}
