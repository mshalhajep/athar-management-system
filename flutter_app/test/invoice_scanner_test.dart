import 'package:flutter_test/flutter_test.dart';
import 'package:athar_purchases/models/invoice_scan_result.dart';
import 'package:athar_purchases/utils/validators.dart';

void main() {
  group('InvoiceScanResult & Extraction Tests', () {
    test('Correctly parses quotation JSON matching user sample invoice', () {
      final sampleJson = {
        "merchantName": "AL-MASADER EL-KUBRA FOR TRADING",
        "purchaseDate": "2026-09-03",
        "hasTaxColumn": true,
        "items": [
          {
            "name": "1- ستي كلار 1200 واط",
            "quantity": 10,
            "unitPrice": 1700.0,
            "total": 17000.0
          },
          {
            "name": "2. بيم 580 واط",
            "quantity": 10,
            "unitPrice": 3000.0,
            "total": 30000.0
          },
          {
            "name": "3- بارلد 24 لمبه وتربروف",
            "quantity": 20,
            "unitPrice": 370.0,
            "total": 7400.0
          },
          {
            "name": "4 دمكس 512",
            "quantity": 1,
            "unitPrice": 1000.0,
            "total": 1000.0
          },
          {
            "name": "5: كيبل دمكس 5 متر",
            "quantity": 10,
            "unitPrice": 30.0,
            "total": 300.0
          },
          {
            "name": "6 / كيبل باور 5 متر",
            "quantity": 20,
            "unitPrice": 40.0,
            "total": 800.0
          }
        ],
        "grandTotal": 56500.0,
        "taxAmount": 8475.0,
        "notes": "ONLY QUOTATION - ضريبة 15%"
      };

      final result = InvoiceScanResult.fromJson(sampleJson, imageUri: 'test/path/inv.jpg');

      expect(result.merchantName, 'AL-MASADER EL-KUBRA FOR TRADING');
      expect(result.purchaseDate, '2026-09-03');
      expect(result.items.length, 6);
      expect(result.grandTotal, 56500.0);
      expect(result.taxAmount, 8475.0);
      expect(result.imageUri, 'test/path/inv.jpg');

      // Test automatic cleaning of sequence numbers to ensure AppValidators passes
      expect(result.items[0].name, 'ستي كلار 1200 واط');
      expect(result.items[0].quantity, 10);
      expect(result.items[0].unitPrice, 1700.0);
      expect(result.items[0].total, 17000.0);

      expect(result.items[1].name, 'بيم 580 واط');
      expect(result.items[1].quantity, 10);
      expect(result.items[1].unitPrice, 3000.0);

      expect(result.items[2].name, 'بارلد 24 لمبه وتربروف');
      expect(result.items[3].name, 'دمكس 512');
      expect(result.items[4].name, 'كيبل دمكس 5 متر');
      expect(result.items[5].name, 'كيبل باور 5 متر');

      // Ensure every extracted item name passes AppValidators.validateItemName without any errors
      for (final item in result.items) {
        final error = AppValidators.validateItemName(item.name);
        expect(error, isNull, reason: 'Item name "${item.name}" should be valid');
      }

      // Total quantity check
      final totalQty = result.items.fold(0, (sum, i) => sum + i.quantity);
      expect(totalQty, 71);

      // Total amount check
      final calculatedTotal = result.items.fold(0.0, (sum, i) => sum + i.total);
      expect(calculatedTotal, 56500.0);
    });

    test('Handles fallback formats and alternative column names', () {
      final json = {
        "companyName": "شركة التوريدات",
        "date": "2026-01-15",
        "items": [
          {
            "description": "شاحن أصلي",
            "qty": 3,
            "price": 45.0,
          }
        ],
        "total": 135.0
      };

      final result = InvoiceScanResult.fromJson(json);
      expect(result.merchantName, 'شركة التوريدات');
      expect(result.purchaseDate, '2026-01-15');
      expect(result.items.length, 1);
      expect(result.items.first.name, 'شاحن أصلي');
      expect(result.items.first.quantity, 3);
      expect(result.items.first.unitPrice, 45.0);
      expect(result.items.first.total, 135.0);
      expect(result.grandTotal, 135.0);
    });

    test('Correctly calculates prices and grand total after tax (VAT included)', () {
      final taxJson = {
        "merchantName": "AL-MASADER EL-KUBRA FOR TRADING",
        "purchaseDate": "2026-09-03",
        "hasTaxColumn": true,
        "items": [
          {
            "name": "ستي كلار 1200 واط",
            "quantity": 10,
            "unitPrice": 1955.0,
            "total": 19550.0
          },
          {
            "name": "بيم 580 واط",
            "quantity": 10,
            "unitPrice": 3450.0,
            "total": 34500.0
          },
          {
            "name": "بارلد 24 لمبه وتربروف",
            "quantity": 20,
            "unitPrice": 425.5,
            "total": 8510.0
          },
          {
            "name": "دمكس 512",
            "quantity": 1,
            "unitPrice": 1150.0,
            "total": 1150.0
          },
          {
            "name": "كيبل دمكس 5 متر",
            "quantity": 10,
            "unitPrice": 34.5,
            "total": 345.0
          },
          {
            "name": "كيبل باور 5 متر",
            "quantity": 20,
            "unitPrice": 46.0,
            "total": 920.0
          }
        ],
        "grandTotal": 64975.0,
        "taxAmount": 8475.0,
        "notes": "شامل ضريبة 15% بمبلغ 8475"
      };

      final result = InvoiceScanResult.fromJson(taxJson);
      expect(result.items.length, 6);
      expect(result.items[0].unitPrice, 1955.0);
      expect(result.items[0].total, 19550.0);
      expect(result.items[1].unitPrice, 3450.0);
      expect(result.items[1].total, 34500.0);
      expect(result.grandTotal, 64975.0);
      expect(result.taxAmount, 8475.0);

      final sumAfterTax = result.items.fold(0.0, (acc, i) => acc + i.total);
      expect(sumAfterTax, 64975.0);
    });

    test('Strictly extracts no-tax invoice: price x quantity without any tax', () {
      final noTaxJson = {
        "merchantName": "شركة النور للتجارة",
        "purchaseDate": "2026-02-01",
        "hasTaxColumn": false,
        "items": [
          {
            "name": "ماوس لاسلكي",
            "quantity": 4,
            "price": 25.0,
            "amountAfterTax": null
          },
          {
            "name": "كيبورد مضيء",
            "quantity": 2,
            "price": 75.0,
            "amountAfterTax": null
          }
        ],
        "printedGrandTotal": 250.0,
        "printedTax": 0.0,
        "notes": null
      };

      final result = InvoiceScanResult.fromJson(noTaxJson);
      expect(result.items.length, 2);
      expect(result.items[0].unitPrice, 25.0);
      expect(result.items[0].total, 100.0);
      expect(result.items[1].unitPrice, 75.0);
      expect(result.items[1].total, 150.0);
      expect(result.taxAmount, 0.0);
      expect(result.grandTotal, 250.0);
      expect(result.hasDiscrepancies, false);
    });

    test('Detects mathematical fraud/discrepancies in item multiplication and total', () {
      final fraudJson = {
        "merchantName": "شركة الإضاءة الحديثة",
        "purchaseDate": "2026-03-01",
        "hasTaxColumn": false,
        "items": [
          {
            "name": "كشافات ليد",
            "quantity": 5,
            "price": 100.0,
            "printedTotal": 600.0, // Fraud! 5 * 100 = 500
            "amountAfterTax": null
          }
        ],
        "printedGrandTotal": 600.0, // Discrepancy! Actual item sum is 500
        "printedTax": 0.0,
        "notes": null
      };

      final result = InvoiceScanResult.fromJson(fraudJson);
      expect(result.items.length, 1);
      // Ensures the app used mathematically correct unit price & total to protect merchant
      expect(result.items.first.unitPrice, 100.0);
      expect(result.items.first.total, 500.0);
      expect(result.hasDiscrepancies, true);
      expect(result.discrepancies.length, 2);
      expect(result.discrepancies.first.itemName, 'كشافات ليد');
      expect(result.discrepancies.first.expectedValue, 500.0);
      expect(result.discrepancies.first.printedValue, 600.0);
      expect(result.discrepancies.first.difference, 100.0);
    });
  });
}
