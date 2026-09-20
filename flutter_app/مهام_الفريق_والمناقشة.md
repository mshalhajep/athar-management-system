# 📋 توزيع مهام الفريق ودليل مناقشة المشروع (5 طلاب)
## مشروع نظام أثر لإدارة المشتريات والمخزون | Athar Management System

تم توزيع المشروع هندسياً ومعمارياً على أعضاء الفريق الخمسة وفق المعمارية النظيفة (Layered Architecture):

---

## 👥 جدول المهام وأسماء الطلاب

| # | اسم الطالب | التخصص الهندسي والدور | النطاق الفني (Technical Scope) | المجلدات والملفات المسندة |
|---|---|---|---|---|
| **1** | **أواب النزيلي** | **مهندس الواجهات وتجربة المستخدم (UI/UX Lead)** | تصميم لوحة التحكم، الجداول الإحصائية، الفلاتر والوضع المظلم | `lib/screens/home_screen.dart`<br>`lib/screens/inventory_table_screen.dart`<br>`lib/widgets/stat_card.dart`<br>`lib/widgets/purchase_card.dart`<br>`lib/theme/app_theme.dart` |
| **2** | **مشعل حاجب** | **مهندس قواعد البيانات المحلية والعمليات الحسابية (Database & CRUD Architect)** | قاعدة بيانات SQLite المحلية، نمط Singleton، العمليات الحسابية والتحقق | `lib/services/database_helper.dart`<br>`lib/services/purchases_service.dart`<br>`lib/models/purchase.dart`<br>`lib/utils/validators.dart`<br>`lib/widgets/purchase_form_dialog.dart` |
| **3** | **محمد العيدروس** | **مهندس الذكاء الاصطناعي ومعالجة الفواتير (AI & Smart OCR Engineer)** | استخراج نصوص الفواتير عبر Google Gemini Vision، التعبئة الآلية | `lib/services/invoice_scanner_service.dart`<br>`lib/models/invoice_scan_result.dart`<br>`lib/widgets/autofill_invoice_dialog.dart`<br>`lib/widgets/invoice_viewer_dialog.dart`<br>`lib/widgets/invoice_details_dialog.dart` |
| **4** | **قحطان الشاجع** | **مهندس السحابة والمزامنة والنسخ الاحتياطي (Cloud Sync & Backup Engineer)** | الربط مع Google Firebase Firestore، المزامنة الفورية Offline-First | `lib/services/firestore_sync_service.dart`<br>`lib/services/backup_sync_service.dart`<br>`lib/widgets/app_image_view.dart` |
| **5** | **محمد العواضي** | **مهندس تسجيل الدخول، الأمان وضمان الجودة (Auth, Security & QA Engineer)** | تسجيل الدخول، إدارة الجلسات، التحديثات، واختبارات الوحدة (Unit Tests) | `lib/services/auth_service.dart`<br>`lib/screens/login_screen.dart`<br>`lib/screens/splash_screen.dart`<br>`lib/services/app_update_service.dart`<br>`test/multi_item_purchase_test.dart` |

---

## 🔍 التفصيل الهندسي لمهام كل طالب وأسئلة المناقشة

### 1️⃣ الطالب الأول: أواب النزيلي — مهندس الواجهات وتجربة المستخدم (UI/UX Lead)
* **الملفات:**
  * `lib/screens/home_screen.dart` (الشاشة الرئيسية ولوحة التحكم)
  * `lib/screens/inventory_table_screen.dart` (جدول المخزون الكامل والفلاتر والفرز)
  * `lib/widgets/stat_card.dart` و `lib/widgets/purchase_card.dart` (بطاقات العرض التفاعلية)
  * `lib/theme/app_theme.dart` (هوية التطبيق البصرية والوضع المظلم/الفاتح)
* **المسؤوليات:**
  * تصميم وبرمجة الشاشة الرئيسية وبطاقات الإحصائيات الفورية.
  * برمجة جدول الجرد المتقدم مع محرك البحث الفوري وتصفية البيانات والفرز.
  * ضبط الهوية البصرية ودعم الوضع المظلم والفاتح.
* **سؤال الدكتور المتوقع:**
  * *س: كيف ضمنت سلاسة واجهة المستخدم (UI Performance) عند وجود مئات الفواتير؟*
  * **الإجابة:** اعتمدنا على `ListView.builder` للتحميل الكسول (Lazy Loading) لعرض العناصر الظاهرة فقط في الذاكرة، وعزلنا دوال التصفية والفلاتر بحيث لا تسبب إعادة بناء غير لازمة لعناصر الواجهة (Rebuilding Widgets).

---

### 2️⃣ الطالب الثاني: مشعل حاجب — مهندس قواعد البيانات المحلية والعمليات الحسابية (Database & CRUD Architect)
* **الملفات:**
  * `lib/services/database_helper.dart` (إنشاء جداول SQLite، الربط مع sqflite، وترقيات قاعدة البيانات)
  * `lib/services/purchases_service.dart` (عمليات الإضافة، التعديل، الحذف، وحساب المجاميع)
  * `lib/models/purchase.dart` (نموذج المشتريات وتخزين الأصناف بصيغة `items_json`)
  * `lib/utils/validators.dart` و `lib/widgets/purchase_form_dialog.dart` (التحقق ونموذج الإدخال)
* **المسؤوليات:**
  * تصميم وإنشاء قاعدة البيانات المحلية SQLite وإدارتها عبر `database_helper.dart`.
  * تطبيق نمط التصميم **Singleton Pattern** لضمان فتح اتصال وحيد بقاعدة البيانات ومنع تعارض العمليات (`Database Lock`).
  * برمجة دوال الـ CRUD الكاملة (إضافة، تعديل، حذف، جلب).
  * ابتكار طريقة مرنة لتخزين الفواتير متعددة الأصناف داخل SQLite عبر حقل `items_json`.
* **سؤال الدكتور المتوقع:**
  * *س: كيف استطعت تخزين أكثر من صنف في الفاتورة الواحدة داخل جدول مشتريات محلي؟*
  * **الإجابة:** قمنا بتجميع الأصناف داخل كائن `PurchaseItem` ثم تحويلها إلى تسلسل نصي `JSON String` وتخزينها في عمود مخصص `items_json`. وعند استرجاع البيانات نقوم بفك التشفير وإعادة تحويلها لقوائم برمجية.

---

### 3️⃣ الطالب الثالث: محمد العيدروس — مهندس الذكاء الاصطناعي ومعالجة الفواتير (AI & Smart OCR Engineer)
* **الملفات:**
  * `lib/services/invoice_scanner_service.dart` (الاتصال بنماذج Google Gemini Vision Flash واستخراج البيانات)
  * `lib/models/invoice_scan_result.dart` (كائن الفاتورة المستخرجة وحفظ الثقة والبيانات المقروءة)
  * `lib/widgets/autofill_invoice_dialog.dart` (نافذة مراجعة وتعديل بيانات الذكاء الاصطناعي قبل الحفظ)
  * `lib/widgets/invoice_viewer_dialog.dart` و `lib/widgets/invoice_details_dialog.dart`
* **المسؤوليات:**
  * دمج واجهة برمجة تطبيقات نماذج الرؤية الذكية **Google Gemini Vision API**.
  * استخراج بيانات الفواتير المصورة (المورد، الأصناف، الكميات، والأسعار) بدقة وتحويلها لنموذج منظم.
  * بناء نافذة المراجعة التفاعلية `AutofillInvoiceDialog` لتمكين المستخدم من التأكد وتصحيح أي صنف قبل اعتماده.
* **سؤال الدكتور المتوقع:**
  * *س: ماذا يحدث إذا كانت صورة الفاتورة غير واضحة أو تعطلت خدمة الذكاء الاصطناعي؟*
  * **الإجابة:** طبقنا استراتيجية `Graceful Degradation`؛ حيث يعالج التطبيق الخطأ ويبلغ المستخدم بلطف مع فتح خيار الإدخال اليدوي فوراً دون توقف أو إغلاق إجباري للتطبيق.

---

### 4️⃣ الطالب الرابع: قحطان الشاجع — مهندس السحابة والمزامنة والنسخ الاحتياطي (Cloud Sync & Backup Engineer)
* **الملفات:**
  * `lib/services/firestore_sync_service.dart` (الربط المباشر مع Google Cloud Firestore والمزامنة الآنية)
  * `lib/services/backup_sync_service.dart` (توليد واستعادة النسخ الاحتياطية وتصدير البيانات)
  * `lib/widgets/app_image_view.dart` (معالجة عرض صور الفواتير السحابية والمحلية)
* **المسؤوليات:**
  * ربط التطبيق بسحابة **Google Cloud Firestore**.
  * تطبيق استراتيجية **Offline-First**؛ حيث يعمل التطبيق بكفاءة وبدون إنترنت على SQLite، وتتم المزامنة تلقائياً عند استعادة الاتصال.
  * ربط البيانات والمزامنة بين أجهزة متعددة باستخدام بريد المستخدم المشترك (`user_email`).
  * برمجة خدمة تصدير واسترجاع النسخ الاحتياطية.
* **سؤال الدكتور المتوقع:**
  * *س: كيف يتم التعامل مع تعارض البيانات إذا عَدّل مستخدمان نفس الفاتورة في أجهزة مختلفة؟*
  * **الإجابة:** نعتمد على استراتيجية الختم الزمني `Last-Write-Wins` اعتماداً على حقل `updated_at`، بالإضافة لخاصية `merge: true` في Firestore مع استخدام معرفات عالمية موحدة `UUID` لكل فاتورة تمنع ازدواجية السجلات.

---

### 5️⃣ الطالب الخامس: محمد العواضي — مهندس تسجيل الدخول، الأمان وضمان الجودة (Auth, Security & QA Engineer)
* **الملفات:**
  * `lib/services/auth_service.dart` (إدارة المستخدمين وجلسات الدخول `UserModel`)
  * `lib/screens/login_screen.dart` (واجهة الدخول والتحقق من صحة البريد وكلمة المرور)
  * `lib/screens/splash_screen.dart` (شاشة البداية، فحص الجلسة، والتحقق التلقائي)
  * `lib/services/app_update_service.dart` (فحص التحديثات البرمجية)
  * `test/multi_item_purchase_test.dart` (اختبارات الوحدة لضمان دقة العمليات الحسابية)
* **المسؤوليات:**
  * بناء نظام المصادقة وإدارة المستخدمين في `auth_service.dart`.
  * تصميم واجهة تسجيل الدخول في `login_screen.dart`.
  * إدارة دورة حياة التطبيق وشاشة البداية الذكية `splash_screen.dart` والتحقق من بقاء الجلسة نشطة محلياً عبر `SharedPreferences`.
  * كتابة الاختبارات الآلية (Unit Tests) في `multi_item_purchase_test.dart`.
* **سؤال الدكتور المتوقع:**
  * *س: ما الفائدة العملية للاختبارات الآلية (Unit Tests) التي قمت بكتابتها؟*
  * **الإجابة:** بما أن النظام يدير مشتريات ومخزوناً مالياً، فمن الضروري التأكد من خلو دوال حساب الإجماليات وتعدد الأصناف والتحويل من وإلى JSON من أي خطأ منطقي قبل إتاحة التطبيق للمستخدمين.

---

## 🎬 سيناريو العرض التقديمي الموحد أمام الدكتور (5 دقائق متكاملة)

1. **محمد العواضي يبدأ (دقيقة 1):** يفتح التطبيق، يستعرض شاشة البداية `SplashScreen`، فحص الجلسة، تسجيل الدخول والأمان، مع الإشارة لاختبارات الجودة.
2. **أواب النزيلي يستلم (دقيقة 2):** يستعرض لوحة التحكم الرئيسية (Dashboard)، كروت الإحصائيات، وجدول الجرد المتجاوب مع ميزات الفرز والبحث الحي.
3. **مشعل حاجب يتدخل (دقيقة 3):** يضغط على زر "إضافة فاتورة يدوياً"، ويشرح بنية قاعدة البيانات SQLite المحلية، ونمط Singleton، والتحقق الحسابي.
4. **محمد العيدروس يقدم الميزة الأقوى (دقيقة 4):** يلتقط صورة لفاتورة ورقية حقيقية، ويوضح بالبث الحي استخراج Gemini Vision للأصناف وتعبئتها آلياً.
5. **قحطان الشاجع يختم (دقيقة 5):** يوضح مزامنة هذه الفاتورة سحابياً مع Firebase وظهورها فوراً على هاتف آخر، ويستعرض نظام النسخ الاحتياطي.
