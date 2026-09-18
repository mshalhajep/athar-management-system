import 'purchase.dart';

/// [بيانات التناقض أو الخطأ الحسابي في الفاتورة - InvoiceDiscrepancy]:
/// يمثل فحصاً تدقيقياً لكشف أي تلاعب أو خطأ في عمليات الضرب أو الإجماليات
class InvoiceDiscrepancy {
  final String itemName;
  final double expectedValue;
  final double printedValue;
  final double difference;
  final String message;

  const InvoiceDiscrepancy({
    required this.itemName,
    required this.expectedValue,
    required this.printedValue,
    required this.difference,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
    'itemName': itemName,
    'expectedValue': expectedValue,
    'printedValue': printedValue,
    'difference': difference,
    'message': message,
  };
}

/// [نموذج نتيجة مسح الفاتورة بالذكاء الاصطناعي - InvoiceScanResult]:
/// يحتوي على البيانات المستخرجة من صورة الفاتورة بعد تحليلها بواسطة نموذج الرؤية
class InvoiceScanResult {
  final String? merchantName;
  final String? purchaseDate;
  final List<InvoiceItem> items;
  final double? grandTotal;
  final double? taxAmount;
  final String? notes;
  final String? rawText;
  final double confidence;
  final String? imageUri;
  final List<InvoiceDiscrepancy> discrepancies;

  bool get hasDiscrepancies => discrepancies.isNotEmpty;

  const InvoiceScanResult({
    this.merchantName,
    this.purchaseDate,
    required this.items,
    this.grandTotal,
    this.taxAmount,
    this.notes,
    this.rawText,
    this.confidence = 1.0,
    this.imageUri,
    this.discrepancies = const [],
  });

  Map<String, dynamic> toJson() => {
    'merchantName': merchantName,
    'purchaseDate': purchaseDate,
    'items': items.map((e) => e.toJson()).toList(),
    'grandTotal': grandTotal,
    'taxAmount': taxAmount,
    'notes': notes,
    'rawText': rawText,
    'confidence': confidence,
    'imageUri': imageUri,
    'discrepancies': discrepancies.map((e) => e.toJson()).toList(),
  };

  factory InvoiceScanResult.fromJson(Map<String, dynamic> json, {String? imageUri}) {
    final rawItems = json['items'];
    final bool hasTaxColumn = json['hasTaxColumn'] == true ||
        (json['hasTaxColumn'] != false &&
            rawItems is List &&
            rawItems.any((i) => i is Map && i['amountAfterTax'] != null));
    List<InvoiceItem> parsedItems = [];
    final discrepancies = <InvoiceDiscrepancy>[];

    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map<String, dynamic>) {
          String name = (item['name'] ?? item['itemName'] ?? item['description'] ?? '').toString().trim();
          
          // تنظيف اسم الصنف إن كان يبدأ بترقيم مثل "1- " أو "1. " ليتوافق مع شروط النظام
          name = name.replaceFirst(RegExp(r'^[0-9٠-٩]+[\s\.\-_/:]+'), '').trim();
          if (name.isEmpty) {
            name = (item['name'] ?? item['itemName'] ?? 'صنف غير محدد').toString();
          }

          int qty = 1;
          if (item['quantity'] != null) {
            qty = (item['quantity'] as num).toInt();
          } else if (item['qty'] != null) {
            qty = (item['qty'] as num).toInt();
          }
          if (qty <= 0) qty = 1;

          // السعر المطبوع في عمود السعر
          double basePrice = (item['price'] as num?)?.toDouble() ??
              (item['unitPrice'] as num?)?.toDouble() ??
              0.0;

          // القيمة بعد الضريبة (فقط إذا وجد عمود صريح بعد الضريبة AMOUNT)
          final double? amountAfterTax = (item['amountAfterTax'] as num?)?.toDouble() ??
              (item['amount'] as num?)?.toDouble();

          final double? printedTotal = (item['printedTotal'] as num?)?.toDouble() ??
              (hasTaxColumn ? null : (item['total'] as num?)?.toDouble());

          // التدقيق الرياضي لعملية الضرب (الكمية × السعر المطبوع)
          final expectedSubtotal = qty * basePrice;
          if (printedTotal != null && printedTotal > 0 && basePrice > 0) {
            final diff = (printedTotal - expectedSubtotal).abs();
            if (diff > 1.0) {
              discrepancies.add(
                InvoiceDiscrepancy(
                  itemName: name,
                  expectedValue: expectedSubtotal,
                  printedValue: printedTotal,
                  difference: printedTotal - expectedSubtotal,
                  message: 'الصنف "$name": حاصل ضرب الكمية ($qty) × السعر (${basePrice.toStringAsFixed(basePrice.truncateToDouble() == basePrice ? 0 : 2)}) = ${expectedSubtotal.toStringAsFixed(2)}، بينما المسجل بالفاتورة هو ${printedTotal.toStringAsFixed(2)} (فارق خطأ/تلاعب: ${(printedTotal - expectedSubtotal).toStringAsFixed(2)})!',
                ),
              );
            }
          }

          double finalUnitPrice = basePrice;
          if (hasTaxColumn && amountAfterTax != null && amountAfterTax > 0 && qty > 0) {
            // عمود صريح بعد الضريبة: نعتمد السعر بعد الضريبة
            finalUnitPrice = amountAfterTax / qty;
          } else {
            // فاتورة عادية أو لا يوجد عمود بعد الضريبة: السعر المطبوع كما هو تماماً
            finalUnitPrice = basePrice;
          }

          parsedItems.add(
            InvoiceItem(
              name: name,
              quantity: qty,
              unitPrice: finalUnitPrice,
            ),
          );
        }
      }
    }

    double? parsedGrandTotal = (json['printedGrandTotal'] as num?)?.toDouble() ??
        (json['grandTotal'] as num?)?.toDouble() ??
        (json['total'] as num?)?.toDouble();

    double parsedTax = 0.0;
    if (hasTaxColumn) {
      parsedTax = (json['printedTax'] as num?)?.toDouble() ??
          (json['taxAmount'] as num?)?.toDouble() ??
          0.0;
    }

    // التدقيق الحسابي لإجمالي الفاتورة النهائي مقارنة بمجموع البنود
    if (parsedGrandTotal != null && parsedGrandTotal > 0 && parsedItems.isNotEmpty) {
      final itemsCalculatedSum = parsedItems.fold<double>(0.0, (acc, item) => acc + item.total);
      final double expectedGrand = (hasTaxColumn && parsedTax > 0 && ((itemsCalculatedSum - parsedGrandTotal).abs() > 1.5))
          ? itemsCalculatedSum + parsedTax
          : itemsCalculatedSum;

      final grandDiff = (parsedGrandTotal - expectedGrand).abs();
      if (grandDiff > 1.5) {
        discrepancies.add(
          InvoiceDiscrepancy(
            itemName: 'المجموع الكلي النهائي',
            expectedValue: expectedGrand,
            printedValue: parsedGrandTotal,
            difference: parsedGrandTotal - expectedGrand,
            message: 'المجموع الكلي للفاتورة: المجموع الفعلي الصحيح للأصناف هو ${expectedGrand.toStringAsFixed(2)}، بينما الإجمالي المسجل أسفل الفاتورة هو ${parsedGrandTotal.toStringAsFixed(2)} (فارق: ${(parsedGrandTotal - expectedGrand).toStringAsFixed(2)})!',
          ),
        );
      }
    }

    if (parsedGrandTotal == null || parsedGrandTotal <= 0) {
      final itemsSum = parsedItems.fold<double>(0.0, (acc, item) => acc + item.total);
      parsedGrandTotal = itemsSum;
    }

    return InvoiceScanResult(
      merchantName: json['merchantName'] as String? ?? json['companyName'] as String?,
      purchaseDate: json['purchaseDate'] as String? ?? json['date'] as String?,
      items: parsedItems,
      grandTotal: parsedGrandTotal,
      taxAmount: parsedTax,
      notes: json['notes'] as String?,
      rawText: json['rawText'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.95,
      imageUri: imageUri ?? json['imageUri'] as String?,
      discrepancies: discrepancies,
    );
  }
}
