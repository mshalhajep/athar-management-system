# 📋 توزيع مهام الفريق ودليل مناقشة المشروع (5 طلاب)
## مشروع نظام أثر لإدارة المشتريات والمخزون | Athar Management System

تم توزيع المشروع هندسياً على **5 طلاب** وفق المعمارية النظيفة (Layered Architecture)، ليكون لكل طالب دور ومسؤولية واضحة أمام الدكتور ولجنة التحكيم.

---

## 👥 جدول المهام السريع والمسؤوليات البرمجية

| # | الدور الهندسي (Role) | النطاق الفني (Technical Scope) | المجلدات والملفات المسندة |
|---|---|---|---|
| **1** | **مهندس الواجهات وتجربة المستخدم (UI/UX Lead)** | تصميم لوحة التحكم، الجداول الإحصائية، الفلاتر، والوضع المظلم | `lib/screens/home_screen.dart`<br>`lib/screens/inventory_table_screen.dart`<br>`lib/widgets/stat_card.dart`<br>`lib/widgets/purchase_card.dart`<br>`lib/theme/app_theme.dart` |
| **2** | **مهندس قواعد البيانات المحلية والعمليات الحسابية (Database & CRUD Architect)** | قاعدة بيانات SQLite المحلية، نمط Singleton، العمليات الحسابية والتحقق | `lib/services/database_helper.dart`<br>`lib/services/purchases_service.dart`<br>`lib/models/purchase.dart`<br>`lib/utils/validators.dart`<br>`lib/widgets/purchase_form_dialog.dart` |
| **3** | **مهندس الذكاء الاصطناعي ومعالجة الفواتير (AI & Smart OCR Engineer)** | استخراج نصوص الفواتير عبر Google Gemini Vision والتعبئة التلقائية | `lib/services/invoice_scanner_service.dart`<br>`lib/models/invoice_scan_result.dart`<br>`lib/widgets/autofill_invoice_dialog.dart`<br>`lib/widgets/invoice_viewer_dialog.dart`<br>`lib/widgets/invoice_details_dialog.dart` |
| **4** | **مهندس السحابة والمزامنة والنسخ الاحتياطي (Cloud Sync & Backup Engineer)** | الربط مع Google Firebase Firestore والمزامنة الفورية بنمط Offline-First | `lib/services/firestore_sync_service.dart`<br>`lib/services/backup_sync_service.dart`<br>`lib/widgets/app_image_view.dart` |
| **5** | **مهندس الأمان وضمان الجودة واختبارات الوحدة (Auth, Security & QA Engineer)** | تسجيل الدخول، إدارة الجلسات، التحديثات، واختبارات الوحدة (Unit Tests) | `lib/services/auth_service.dart`<br>`lib/screens/login_screen.dart`<br>`lib/screens/splash_screen.dart`<br>`lib/services/app_update_service.dart`<br>`test/multi_item_purchase_test.dart` |

---

## 🔍 المهام التفصيلية لكل طالب وأسئلة المناقشة المتوقعة

### 1️⃣ الطالب الأول: مهندس الواجهات وتجربة المستخدم (UI/UX Lead)
* **المسؤوليات:**
  * تصميم وبرمجة الشاشة الرئيسية [home_screen.dart](lib/screens/home_screen.dart) وبطاقات الإحصائيات [stat_card.dart](lib/widgets/stat_card.dart).
  * برمجة جدول الجرد المتقدم [inventory_table_screen.dart](lib/screens/inventory_table_screen.dart) مع محرك البحث الفوري وتصفية البيانات والفرز.
  * تصميم بطاقة عرض الفاتورة [purchase_card.dart](lib/widgets/purchase_card.dart).
  * ضبط الهوية البصرية ودعم الوضع المظلم والفاتح في [app_theme.dart](lib/theme/app_theme.dart).
* **سؤال الدكتور المتوقع:**
  * *س: كيف ضمنت سلاسة واجهة المستخدم (UI Performance) عند وجود مئات الفواتير؟*
  * **الإجابة:** اعتمدنا على `ListView.builder` للتحميل الكسول (Lazy Loading) لعرض العناصر الظاهرة فقط في الذاكرة، وعزلنا دوال التصفية والفلاتر بحيث لا تسبب إعادة بناء غير لازمة لعناصر الواجهة (Rebuilding Widgets).

---

### 2️⃣ الطالب الثاني: مهندس قواعد البيانات المحلية والعمليات الحسابية (Database & CRUD Architect)
* **المسؤوليات:**
  * تصميم وإنشاء قاعدة البيانات المحلية SQLite وإدارتها عبر [database_helper.dart](lib/services/database_helper.dart).
  * تطبيق نمط التصميم **Singleton Pattern** لضمان فتح اتصال وحيد بقاعدة البيانات ومنع تعارض العمليات (`Database Lock`).
  * برمجة دوال الـ CRUD الكاملة (إضافة، تعديل، حذف، جلب) في [purchases_service.dart](lib/services/purchases_service.dart).
  * ابتكار طريقة مرنة لتخزين الفواتير متعددة الأصناف داخل SQLite عبر حقل `items_json` في نموذج [purchase.dart](lib/models/purchase.dart).
  * بناء دوال التحقق من صحة المدخلات في [validators.dart](lib/utils/validators.dart).
* **سؤال الدكتور المتوقع:**
  * *س: كيف استطعت تخزين أكثر من صنف في الفاتورة الواحدة داخل جدول مشتريات محلي؟*
  * **الإجابة:** قمنا بتجميع الأصناف داخل كائن `PurchaseItem` ثم تحويلها إلى تسلسل نصي `JSON String` وتخزينها في عمود مخصص `items_json`. وعند استرجاع البيانات نقوم بفك التشفير وإعادة تحويلها لقوائم برمجية.

---

### 3️⃣ الطالب الثالث: مهندس الذكاء الاصطناعي ومعالجة الفواتير (AI & Smart OCR Engineer)
* **المسؤوليات:**
  * دمج واجهة برمجة تطبيقات نماذج الرؤية الذكية **Google Gemini Vision API** داخل [invoice_scanner_service.dart](lib/services/invoice_scanner_service.dart).
  * استخراج بيانات الفواتير المصورة (المورد، الأصناف، الكميات، والأسعار) بدقة وتحويلها لنموذج منظم [invoice_scan_result.dart](lib/models/invoice_scan_result.dart).
  * بناء نافذة المراجعة التفاعلية [autofill_invoice_dialog.dart](lib/widgets/autofill_invoice_dialog.dart) لتمكين المستخدم من التأكد وتصحيح أي صنف قبل اعتماده.
  * عرض ومطابقة الفاتورة الأصلية عبر [invoice_viewer_dialog.dart](lib/widgets/invoice_viewer_dialog.dart).
* **سؤال الدكتور المتوقع:**
  * *س: ماذا يحدث إذا كانت صورة الفاتورة غير واضحة أو تعطلت خدمة الذكاء الاصطناعي؟*
  * **الإجابة:** طبقنا استراتيجية `Graceful Degradation`؛ حيث يعالج التطبيق الخطأ ويبلغ المستخدم بلطف مع فتح خيار الإدخال اليدوي فوراً دون توقف أو إغلاق إجباري للتطبيق.

---

### 4️⃣ الطالب الرابع: مهندس السحابة والمزامنة والنسخ الاحتياطي (Cloud Sync & Backup Engineer)
* **المسؤوليات:**
  * ربط التطبيق بسحابة **Google Cloud Firestore** عبر [firestore_sync_service.dart](lib/services/firestore_sync_service.dart).
  * تطبيق استراتيجية **Offline-First**؛ حيث يعمل التطبيق بكفاءة وبدون إنترنت على SQLite، وتتم المزامنة تلقائياً عند استعادة الاتصال.
  * ربط البيانات والمزامنة بين أجهزة متعددة باستخدام بريد المستخدم المشترك (`user_email`).
  * برمجة خدمة تصدير واسترجاع النسخ الاحتياطية في [backup_sync_service.dart](lib/services/backup_sync_service.dart).
* **سؤال الدكتور المتوقع:**
  * *س: كيف يتم التعامل مع تعارض البيانات إذا عَدّل مستخدمان نفس الفاتورة في أجهزة مختلفة؟*
  * **الإجابة:** نعتمد على استراتيجية الختم الزمني `Last-Write-Wins` اعتماداً على حقل `updated_at`، بالإضافة لخاصية `merge: true` في Firestore مع استخدام معرفات عالمية موحدة `UUID` لكل فاتورة تمنع ازدواجية السجلات.

---

### 5️⃣ الطالب الخامس: مهندس الأمان والتحقق وضمان الجودة (Auth, Security & QA Engineer)
* **المسؤوليات:**
  * بناء نظام المصادقة وإدارة المستخدمين في [auth_service.dart](lib/services/auth_service.dart).
  * تصميم واجهة تسجيل الدخول في [login_screen.dart](lib/screens/login_screen.dart).
  * إدارة دورة حياة التطبيق وشاشة البداية الذكية [splash_screen.dart](lib/screens/splash_screen.dart) والتحقق من بقاء الجلسة نشطة محلياً عبر `SharedPreferences`.
  * متابعة التحديثات البرمجية عبر [app_update_service.dart](lib/services/app_update_service.dart).
  * كتابة الاختبارات الآلية (Unit Tests) في [multi_item_purchase_test.dart](test/multi_item_purchase_test.dart) لضمان دقة العمليات الحسابية.
* **سؤال الدكتور المتوقع:**
  * *س: ما الفائدة العملية للاختبارات الآلية (Unit Tests) التي قمت بكتابتها؟*
  * **الإجابة:** بما أن النظام يدير مشتريات ومخزوناً مالياً، فمن الضروري التأكد من خلو دوال حساب الإجماليات وتعدد الأصناف والتحويل من وإلى JSON من أي خطأ منطقي قبل إتاحة التطبيق للمستخدمين.

---

## 🎬 سيناريو العرض التقديمي الموحد أمام الدكتور (5 دقائق متكاملة)

1. **الطالب الخامس يبدأ (دقيقة 1):** يفتح التطبيق، يعرض شاشة البداية `SplashScreen`، ويوضح التحقق من جلسة المستخدم ونظام الأمان واختبارات الجودة.
2. **الطالب الأول يستلم (دقيقة 2):** يستعرض الواجهة الرئيسية، بطاقات الإحصائيات الذكية، والجدول المتجاوب والفرز السريع.
3. **الطالب الثاني يتدخل (دقيقة 3):** يضغط "إضافة فاتورة يدوياً"، ويشرح بنية قاعدة البيانات SQLite والتحقق من صحة المدخلات.
4. **الطالب الثالث يقدم الميزة الأقوى (دقيقة 4):** يلتقط صورة لفاتورة ورقية ويوضح كيف يقرأ الذكاء الاصطناعي (Gemini) البيانات ويعبئها تلقائياً.
5. **الطالب الرابع يختم (دقيقة 5):** يوضح مزامنة هذه الفاتورة سحابياً على Firebase وظهورها فوراً على هاتف آخر وخيارات النسخ الاحتياطي.
