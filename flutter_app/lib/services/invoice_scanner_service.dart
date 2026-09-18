import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/invoice_scan_result.dart';

/// [خدمة الفحص والتحليل الذكي للفواتير - InvoiceScannerService]:
/// تتولى إرسال صورة الفاتورة إلى نموذج Google Gemini 1.5 Flash Vision
/// واستخراج الأصناف والكميات والأسعار والتاريخ واسم المورد بدقة فائقة.
class InvoiceScannerService {
  InvoiceScannerService._privateConstructor();
  static final InvoiceScannerService instance = InvoiceScannerService._privateConstructor();

  static const String _prefApiKey = 'athar_gemini_api_key';

  // مفتاح Gemini API الافتراضي (يُترك فارغاً لحماية الأمان ويُدخل من إعدادات التطبيق)
  static const String defaultApiKey = '';

  /// استرجاع مفتاح API الحالي
  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final customKey = prefs.getString(_prefApiKey);
    if (customKey != null && customKey.trim().isNotEmpty) {
      return customKey.trim();
    }
    if (defaultApiKey.isNotEmpty) {
      return defaultApiKey;
    }
    return null;
  }

  /// حفظ مفتاح API جديد
  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefApiKey, key.trim());
  }

  /// إزالة المفتاح المخصص
  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefApiKey);
  }

  /// تحليل صورة الفاتورة واستخراج البيانات المنظمة
  Future<InvoiceScanResult> scanInvoiceImage(File imageFile, {String? customApiKey}) async {
    final apiKey = customApiKey ?? await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('KEY_MISSING');
    }

    final bytes = await imageFile.readAsBytes();
    return scanInvoiceBytes(bytes, apiKey: apiKey, imageUri: imageFile.path);
  }

  static const String _prefWorkingModel = 'athar_gemini_working_model';

  static const List<String> _candidateModels = [
    'gemini-3.1-flash-lite',
    'gemini-3.5-flash-lite',
    'gemini-3.6-flash',
    'gemini-3.5-flash',
  ];

  /// تحليل مصفوفة بايتات الصورة مع دعم التبديل التلقائي الذكي بين نماذج Gemini
  Future<InvoiceScanResult> scanInvoiceBytes(
    Uint8List bytes, {
    required String apiKey,
    String? imageUri,
  }) async {
    final base64Image = base64Encode(bytes);
    final mimeType = _detectMimeType(bytes);

    final prefs = await SharedPreferences.getInstance();
    final cachedModel = prefs.getString(_prefWorkingModel);

    final modelsToTry = <String>[];
    if (cachedModel != null && _candidateModels.contains(cachedModel)) {
      modelsToTry.add(cachedModel);
    }
    for (final m in _candidateModels) {
      if (!modelsToTry.contains(m)) modelsToTry.add(m);
    }

    const promptText = '''
أنت خبير قراءة واستخراج بيانات الفواتير وعروض الأسعار بدقة تامة.
استخرج فقط وحصرياً ما هو مطبوع وموجود في أعمدة الفاتورة أمامك، دون أي افتراض أو إضافة أو حسابات خارجية.

القواعد الصارمة:
1. انظر إلى ترويسة الجدول (أسماء الأعمدة المطبوعة):
   - إذا كان الجدول يحتوي على عمود صريح خاص بالقيمة بعد الضريبة (مثل: AMOUNT أو بعد الضريبة أو الصافي مع الضريبة):
     اجعل hasTaxColumn = true وضع القيمة المطبوعة في هذا العمود في حقل amountAfterTax لكل صنف.
   - إذا لم يكن هناك عمود صريح بعد الضريبة (أي أن الجدول يحتوي فقط على السعر والإجمالي قبل أي ضريبة أو بدون ضريبة نهائياً):
     اجعل hasTaxColumn = false واجعل amountAfterTax = null لكل الأصناف.
     ممنوع منعاً باتاً اختلاق أو حساب أي ضريبة من عندك!

2. لكل صنف في الجدول:
   - name: اسم الصنف فقط (بدون ترقيم 1، 2، إلخ وبدون شرطات).
   - quantity: الكمية كرقم صحيح.
   - price: سعر الوحدة المكتوب في عمود (السعر / PRICE / Unit Price) كما هو في الفاتورة.
   - printedTotal: الرقم المكتوب في خانة الإجمالي/المجموع لهذا الصنف (كما هو مطبوع تماماً لتدقيق الضرب).
   - amountAfterTax: الرقم المطبوع في عمود AMOUNT / بعد الضريبة (فقط إذا وجد هذا العمود في الجدول، وإلا null).

3. الإجماليات:
   - printedGrandTotal: المجموع الكلي النهائي المكتوب أسفل الفاتورة.
   - printedTax: مبلغ الضريبة إذا كان مكتوباً في الفاتورة، وإلا 0.0.

أرجع فقط كائن JSON التالي بدون أي مقدمات أو علامات:
{
  "merchantName": "اسم المورد/الشركة إذا وجد وإلا null",
  "purchaseDate": "YYYY-MM-DD إذا وجد وإلا null",
  "hasTaxColumn": false,
  "items": [
    {
      "name": "اسم الصنف",
      "quantity": 1,
      "price": 10.0,
      "printedTotal": 10.0,
      "amountAfterTax": null
    }
  ],
  "printedGrandTotal": 10.0,
  "printedTax": 0.0,
  "notes": null
}
''';

    final requestBody = {
      "contents": [
        {
          "parts": [
            {
              "inlineData": {
                "mimeType": mimeType,
                "data": base64Image,
              }
            },
            {"text": promptText}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.0,
        "responseMimeType": "application/json",
      }
    };

    String? lastErrorMsg;

    for (final model in modelsToTry) {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
      );

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 35);

      try {
        final request = await client.postUrl(url);
        request.headers.contentType = ContentType.json;
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        request.headers.set('x-goog-api-key', apiKey);
        request.write(jsonEncode(requestBody));

        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();

        if (response.statusCode == 404) {
          debugPrint('Model $model returned 404, attempting fallback to next model...');
          lastErrorMsg = responseBody;
          continue;
        }

        if (response.statusCode != 200) {
          debugPrint('Gemini API Error ($model): Status ${response.statusCode}, Body: $responseBody');
          String detailedMsg = '';
          try {
            final errJson = jsonDecode(responseBody);
            detailedMsg = errJson['error']?['message'] ?? responseBody;
          } catch (_) {
            detailedMsg = responseBody;
          }

          // إذا كان المفتاح المستخدم على الجهاز خاطئاً أو معطلاً (401 أو 403)،
          // نقوم بمسحه تلقائياً والتحويل فوراً إلى المفتاح المعتمد الشغال
          if ((response.statusCode == 401 || response.statusCode == 403) &&
              apiKey != defaultApiKey &&
              defaultApiKey.isNotEmpty) {
            debugPrint('Custom API key failed with auth error (${response.statusCode}). Auto-clearing stale key and retrying with defaultApiKey...');
            await clearApiKey();
            return scanInvoiceBytes(bytes, apiKey: defaultApiKey, imageUri: imageUri);
          }

          if (response.statusCode == 400 || response.statusCode == 401 || response.statusCode == 403) {
            final lower = detailedMsg.toLowerCase();
            if (lower.contains('key') || lower.contains('credential') || response.statusCode == 403 || response.statusCode == 401) {
              throw Exception('INVALID_KEY: $detailedMsg');
            }
          } else if (response.statusCode == 429) {
            throw Exception('QUOTA_EXCEEDED: $detailedMsg');
          }
          throw Exception('API_ERROR (${response.statusCode}): $detailedMsg');
        }

        // حفظ النموذج العامل بنجاح للاستخدام السريع المستقبلي
        await prefs.setString(_prefWorkingModel, model);
        debugPrint('Successfully used Gemini model: $model');

        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        final candidates = jsonResponse['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          throw Exception('NO_RESPONSE: لم يقدم نموذج الذكاء الاصطناعي أي استجابة');
        }

        final content = candidates[0]['content'];
        final parts = content?['parts'] as List?;
        if (parts == null || parts.isEmpty) {
          throw Exception('EMPTY_PARTS: تم إرجاع استجابة فارغة');
        }

        String rawText = parts[0]['text'] as String? ?? '';
        rawText = _cleanJsonString(rawText);

        final Map<String, dynamic> extractedData = jsonDecode(rawText);
        return InvoiceScanResult.fromJson(extractedData, imageUri: imageUri);
      } on SocketException {
        throw Exception('NETWORK_ERROR: تعذر الاتصال بالإنترنت');
      } finally {
        client.close();
      }
    }

    throw Exception('API_ERROR (404): $lastErrorMsg');
  }

  /// تنظيف النص الناتج لضمان صحة الـ JSON واستخراج الكائن بين الأقواس
  String _cleanJsonString(String text) {
    String cleaned = text.trim();
    final firstBrace = cleaned.indexOf('{');
    final lastBrace = cleaned.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace != -1 && lastBrace >= firstBrace) {
      cleaned = cleaned.substring(firstBrace, lastBrace + 1);
    }
    return cleaned.trim();
  }

  /// تخمين نوع الصورة من ترويسة البايتات (Magic bytes)
  String _detectMimeType(Uint8List bytes) {
    if (bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }
}
