# -*- coding: utf-8 -*-
import base64
import os
import subprocess
import re

print("Building Complete Academic Report with Screenshots and Lecture Mappings...")

script_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.abspath(os.path.join(script_dir, ".."))
upload_dir = r"C:\Users\Smart\.gemini\antigravity-ide\brain\e8241902-4e45-4e72-8f80-99cf5ff99e64\.user_uploaded"

def get_b64(filepath):
    if os.path.exists(filepath):
        with open(filepath, "rb") as f:
            ext = os.path.splitext(filepath)[1].lower()
            mime = "image/png" if ext == ".png" else "image/jpeg"
            return f"data:{mime};base64,{base64.b64encode(f.read()).decode('utf-8')}"
    return ""

img_autofill = get_b64(os.path.join(upload_dir, "media_1789659593545.png"))
img_invoice_tax = get_b64(os.path.join(upload_dir, "media_1789666613255.jpg"))
img_invoice_notax = get_b64(os.path.join(upload_dir, "media_1789667533633.jpg"))
img_fraud_sample = get_b64(os.path.join(upload_dir, "media_1789672224513.jpg"))

base_report_path = os.path.join(parent_dir, "report.html")
with open(base_report_path, "r", encoding="utf-8") as f:
    html = f.read()

existing_images = re.findall(r'src="(data:image/[^"]+)"', html)
img_splash = existing_images[0] if len(existing_images) > 0 else ""
img_login = existing_images[1] if len(existing_images) > 1 else ""
img_account_dialog = existing_images[2] if len(existing_images) > 2 else ""
img_home = existing_images[3] if len(existing_images) > 3 else ""
img_form = existing_images[4] if len(existing_images) > 4 else ""
img_table = existing_images[5] if len(existing_images) > 5 else ""

# Build additional HTML for screens 4.7, 4.8, 4.9 and Lectures Mapping Section
new_screens_html = f"""
<!-- 4.7 نافذة الملء التلقائي ومسح الفاتورة بالذكاء الاصطناعي -->
<div class="page-break"></div>
<h2 class="sub-title" id="sec-screen-autofill">4.7 نافذة الملء التلقائي ومسح الفاتورة بالذكاء الاصطناعي (AutoFill Invoice Dialog)</h2>
<p class="file-path"><strong>المسار البرمجي للملف:</strong> <code>lib/widgets/autofill_invoice_dialog.dart</code> & <code>lib/services/invoice_scanner_service.dart</code></p>

<div class="screen-layout">
  <div class="screen-image-col">
    <div class="screen-frame">
      <img src="{img_autofill}" alt="نافذة الملء التلقائي">
    </div>
    <p class="screen-caption">الشكل (7): نافذة اختيار صورة الفاتورة ومعاينتها وتحليلها بالذكاء الاصطناعي</p>
  </div>
  <div class="screen-details-col">
    <div class="widget-card">
      <h4><span class="annotation-badge">1</span> وظيفة الشاشة والهدف منها:</h4>
      <p>تمكين المستخدم من التقاط صورة الفاتورة الورقية عبر الكاميرا أو المعرض، معاينتها بدقة، ثم إرسالها إلى محرك الذكاء الاصطناعي Gemini 3.1 Flash Vision لاستخراج أسماء الأصناف والكميات والأسعار والتاريخ واسم المورد آلياً بضغطة زر واحدة.</p>
    </div>

    <div class="widget-card">
      <h4><span class="annotation-badge">2</span> الأدوات والـ Widgets المستخدمة وسبب اختيارها:</h4>
      <ul>
        <li><strong><code>ModalBottomSheet</code>:</strong> لعرض النافذة منبثقة من أسفل الشاشة بارتفاع متجاوب مع تجربة مستخدم سلسة وعصرية.</li>
        <li><strong><code>ImagePicker</code>:</strong> للتفاعل المباشر مع عتاد الهاتف (الكاميرا أو المعرض) مع ضغط الصورة وحفظ جودتها بنسبة 90% لتسريع التحليل.</li>
        <li><strong><code>ClipRRect</code> & <code>Image.file</code>:</strong> لعرض معاينة فورية للصورة المختارة بحواف دائرية أنيقة قبل بدء التحليل.</li>
        <li><strong><code>CircularProgressIndicator</code>:</strong> مؤشر دوران متحرك أثناء انتظار استجابة السحابة لمنع نقر المستخدم المتكرر.</li>
        <li><strong><code>IconButton</code>:</strong> أزرار علوية مخصصة تتيح للمستخدم فحص أو تعديل مفتاح API الخاص به في أي وقت.</li>
      </ul>
    </div>

    <div class="widget-card">
      <h4><span class="annotation-badge">3</span> الربط بالمحاضرات الجامعية المعتمدة:</h4>
      <p><strong>[المحاضرة 8 - البرمجة غير المتزامنة Asynchronous Programming]:</strong> استخدام دوال <code>async</code> و <code>await</code> مع كائن <code>Future&lt;InvoiceScanResult&gt;</code> لإجراء استدعاء شبكي خارجي REST API دون تجميد واجهة التطبيق (UI Thread).</p>
      <p><strong>[المحاضرة 7 - معالجة الأخطاء وحوارات التفاعل Dialogs]:</strong> استخدام كتل <code>try ... catch</code> لمعالجة انقطاع الإنترنت أو الصور غير الصالحة وتنبيه المستخدم برسائل SnackBar واضحة.</p>
    </div>

    <div class="doctor-tip">
      <strong>ماذا تقول للدكتور لمناقشة هذه الشاشة:</strong><br>
      <em>"استخدمنا نموذج Gemini 3.1 Flash مع درجة حرارة <code>temperature: 0.0</code> عبر بروتوكول HTTP REST المباشر بدون مكتبات خارجية ثقيلة، مما يضمن استخراج البيانات بصيغة JSON نقية ومطابقة لما هو مطبوع في الفاتورة فقط دون أي تخمين، مع دعم التبديل التلقائي الذكي (Fallback) بين الموديلات."</em>
    </div>
  </div>
</div>

<!-- 4.8 نافذة التدقيق الرياضي وكشف التلاعب والغش في الفاتورة -->
<div class="page-break"></div>
<h2 class="sub-title" id="sec-screen-fraud">4.8 نافذة التدقيق وكشف التلاعب والغش المحاسبي (Fraud & Math Discrepancy Dialog)</h2>
<p class="file-path"><strong>المسار البرمجي للملف:</strong> <code>lib/models/invoice_scan_result.dart</code> & <code>lib/widgets/autofill_invoice_dialog.dart</code></p>

<div class="screen-layout">
  <div class="screen-image-col">
    <div class="screen-frame">
      <img src="{img_fraud_sample}" alt="فاتورة تحتوي على تلاعب حسابي">
    </div>
    <p class="screen-caption">الشكل (8): نموذج فاتورة تحتوي على أخطاء ضرب متعمدة يتم اكتشافها آلياً</p>
  </div>
  <div class="screen-details-col">
    <div class="widget-card" style="border-right: 4px solid #ef4444;">
      <h4 style="color:#b91c1c;"><span class="annotation-badge" style="background:#ef4444;">!</span> وظيفة نظام كشف التلاعب والغش:</h4>
      <p>حماية التاجر من عمليات التلاعب المحاسبي الشائعة، حيث يقوم بعض المحاسبين غير الأمناء بتسجيل حاصل ضرب الكمية في السعر بشكل خاطئ في عمود الإجمالي، أو تزوير المجموع الكلي النهائي لاختلاس جزء من المبلغ. يقوم نظامنا بإعادة ضرب البنود رياضياً ومقارنتها بما هو مطبوع فوراً.</p>
    </div>

    <div class="widget-card">
      <h4><span class="annotation-badge">2</span> الخوارزمية الرياضية المطبقة في الكود:</h4>
      <ul>
        <li><strong>فحص كل صنف:</strong> <code>expectedSubtotal = qty * basePrice</code>. إذا كان الفارق بين الناتج الحقيقي والمبلغ المطبوع <code>(printedTotal - expectedSubtotal).abs() &gt; 1.0</code> يتم إنشاء تناقض <code>InvoiceDiscrepancy</code>.</li>
        <li><strong>فحص الإجمالي النهائي:</strong> مقارنة مجموع الأصناف الفعلي <code>itemsCalculatedSum</code> بالإجمالي المطبوع أسفل الفاتورة <code>printedGrandTotal</code> ورصد أي فارق يزيد عن ريال واحد.</li>
        <li><strong>الحماية التلقائية:</strong> يعتمد النظام رياضياً الناتج الصحيح (الكمية × السعر) ويتجاهل الأرقام المزورة تلقائياً.</li>
      </ul>
    </div>

    <div class="widget-card">
      <h4><span class="annotation-badge">3</span> الأدوات والـ Widgets المستخدمة:</h4>
      <ul>
        <li><strong><code>AlertDialog</code> مخصص:</strong> محاط بإطار أحمر وتنبيه بصري صارخ مع منع الإغلاق العشوائي <code>barrierDismissible: false</code>.</li>
        <li><strong><code>Icon(Icons.warning_amber_rounded)</code>:</strong> أيقونة تحذيرية باللون الأحمر لجذب انتباه التاجر فوراً.</li>
        <li><strong><code>SingleChildScrollView</code>:</strong> لاحتواء تقرير التناقضات حتى لو تضمنت الفاتورة عدة بنود مشبوهة.</li>
      </ul>
    </div>

    <div class="widget-card">
      <h4><span class="annotation-badge">4</span> الربط بالمحاضرات الجامعية المعتمدة:</h4>
      <p><strong>[المحاضرة 4 - البرمجة كائنية التوجه OOP ومصانع الكائنات]:</strong> بناء كلاس <code>InvoiceDiscrepancy</code> كنموذج كبسولي يحتوي قيم <code>expectedValue</code> و <code>printedValue</code> و <code>difference</code> ورسالة التنبيه التفصيلية.</p>
      <p><strong>[المحاضرة 3 - الجمل الشرطية والعمليات الحسابية]:</strong> تطبيق الشروط المنطقية <code>if-statements</code> والمقارنات الحسابية الدقيقة وتنسيق الأرقام عبر <code>toStringAsFixed(2)</code>.</p>
    </div>

    <div class="doctor-tip">
      <strong>ماذا تقول للدكتور لمناقشة هذه الميزة الاستثنائية:</strong><br>
      <em>"هذه الميزة تمثل قيمة مضافة فريدة تفوقت بها منظومتنا على البرامج التقليدية؛ حيث لا يكتفي التطبيق بمجرد قراءة الفاتورة، بل يلعب دور 'المدقق المالي الذكي' الذي يكتشف التزوير أو الخطأ البشري في عمليات الضرب والجمع ويحمي أموال التاجر قبل حفظ القيد."</em>
    </div>
  </div>
</div>

<!-- 4.9 مقارنة استخراج الفواتير المطبوعة بضريبة وبدون ضريبة -->
<div class="page-break"></div>
<h2 class="sub-title" id="sec-tax-logic">4.9 المقارنة العملية لاستخراج الفواتير (فواتير خالية من الضريبة مقابل فواتير ضريبية)</h2>
<p class="file-path"><strong>التطبيق الفعلي:</strong> اختبار النظام على نماذج فواتير حقيقية للتأكد من عدم اختلاق أي ضريبة وهمية</p>

<div style="display:flex; gap:16px; margin: 16px 0;">
  <div style="flex:1; background:#f8fafc; border:1px solid #cbd5e1; border-radius:12px; padding:12px;">
    <h4 style="color:#0f172a; margin-top:0;">الحالة الأولى: فاتورة خالية من الضريبة (No Tax Column)</h4>
    <div style="text-align:center; margin:10px 0;">
      <img src="{img_invoice_notax}" style="max-height:180px; border-radius:8px; border:1px solid #94a3b8;" alt="فاتورة بدون ضريبة">
    </div>
    <ul style="font-size:9pt; line-height:1.6; color:#334155;">
      <li><strong>التحقق البرمجي:</strong> <code>hasTaxColumn = false</code>.</li>
      <li><strong>السلوك الذكي:</strong> لا يتم اختلاق أي ضريبة من الذكاء الاصطناعي نهائياً.</li>
      <li><strong>السعر المعتمد:</strong> السعر المطبوع في خانة (PRICE) مباشرة.</li>
      <li><strong>الإجمالي:</strong> (الكمية × السعر المطبوع) فقط.</li>
    </ul>
  </div>

  <div style="flex:1; background:#f8fafc; border:1px solid #cbd5e1; border-radius:12px; padding:12px;">
    <h4 style="color:#0f172a; margin-top:0;">الحالة الثانية: فاتورة تحتوي على عمود ضريبة (AMOUNT / بعد الضريبة)</h4>
    <div style="text-align:center; margin:10px 0;">
      <img src="{img_invoice_tax}" style="max-height:180px; border-radius:8px; border:1px solid #94a3b8;" alt="فاتورة بضريبة">
    </div>
    <ul style="font-size:9pt; line-height:1.6; color:#334155;">
      <li><strong>التحقق البرمجي:</strong> <code>hasTaxColumn = true</code> ورصد عمود AMOUNT الصريح.</li>
      <li><strong>السلوك الذكي:</strong> اعتماد السعر النهائي بعد الضريبة <code>amountAfterTax / qty</code>.</li>
      <li><strong>السعر المعتمد:</strong> التكلفة الحقيقية الصافية المدفوعة للمورد شاملاً الضريبة.</li>
      <li><strong>الإجمالي:</strong> مطابقة الإجمالي الكلي النهائي المسجل أسفل الفاتورة.</li>
    </ul>
  </div>
</div>
"""

# Now build the full Lecture Binding Master Table
lecture_bindings_table_html = """
<div class="page-break"></div>
<h1 class="section-title" id="sec-lectures-master">الربط الأكاديمي الشامل بمحاضرات المنهج الجامعي (Lectures 3 to 9)</h1>
<p>تم استخراج ومطابقة كل جزء من كود التطبيق مع المحاضرات السبع المقررة في المنهج الجامعي لمادة تطوير تطبيقات الجوال (Flutter & Dart):</p>

<table style="font-size:9pt;">
  <thead>
    <tr>
      <th style="width:18%;">المحاضرة الجامعية</th>
      <th style="width:22%;">المفهوم المطبق في الكود</th>
      <th style="width:25%;">الملف البرمجي والمسار الفعلي</th>
      <th style="width:35%;">الشرح الأكاديمي النموذجي للدكتور</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>المحاضرة الثالثة</strong><br>(الكلاسات والوراثة Dart)</td>
      <td>
        • تعريف الكلاسات <code>class</code><br>
        • الخصائص والمشيدات <code>Constructor</code><br>
        • مبدأ الكبسولة <code>Encapsulation</code>
      </td>
      <td>
        <code>lib/models/purchase.dart</code><br>
        <code>lib/models/user_profile.dart</code>
      </td>
      <td>تم بناء كلاسات البيانات وفق مبادئ OOP بحيث تكون المتغيرات النهائية <code>final</code> محمية، ويتم الوصول لإجمالي الفاتورة عبر Getter محسوب <code>get totalPrice</code> دون السماح بتعديله من الخارج بالخطأ.</td>
    </tr>
    <tr>
      <td><strong>المحاضرة الرابعة</strong><br>(تابع الكلاسات في Dart)</td>
      <td>
        • المشيدات المسماة <code>Named Constructors</code><br>
        • مشيدات المصنع <code>Factory Constructors</code><br>
        • تحويل البيانات <code>Map / JSON Serialization</code>
      </td>
      <td>
        <code>lib/models/purchase.dart</code><br>
        <code>lib/models/invoice_scan_result.dart</code>
      </td>
      <td>استخدام <code>factory Purchase.fromJson</code> لتحويل مصفوفات البيانات القادمة من قاعدة البيانات SQLite أو السحابة إلى كائنات Dart برمجية قوية النوع (Strongly-Typed) تدعم الـ Null Safety.</td>
    </tr>
    <tr>
      <td><strong>المحاضرة الخامسة</strong><br>(المكونات الأساسية للواجهات و StatefulWidget)</td>
      <td>
        • دورة حياة <code>StatefulWidget</code><br>
        • دالة <code>initState()</code><br>
        • دالة <code>setState()</code><br>
        • دالة <code>dispose()</code>
      </td>
      <td>
        <code>lib/screens/home_screen.dart</code><br>
        <code>lib/screens/splash_screen.dart</code><br>
        <code>lib/widgets/purchase_form_dialog.dart</code>
      </td>
      <td>التحكم في دورة حياة الشاشة؛ حيث نستخدم <code>initState</code> لبدء الاتصال بقاعدة البيانات والاشتراك في المستمعين، ونستخدم <code>setState</code> لتحديث شجرة العناصر عند إضافة أو حذف فاتورة، ونفرغ الموارد في <code>dispose</code> لمنع تسريب الذاكرة.</td>
    </tr>
    <tr>
      <td><strong>المحاضرة السادسة</strong><br>(تخطيط العناصر وتنسيق الواجهات Layouts)</td>
      <td>
        • المحاذاة الأفقية <code>Row</code><br>
        • الترتيب الرأسي <code>Column</code><br>
        • حشوات الفراغ <code>Padding</code><br>
        • التوسع المتجاوب <code>Expanded</code><br>
        • البطاقات <code>Card & Container</code>
      </td>
      <td>
        <code>lib/widgets/stat_card.dart</code><br>
        <code>lib/widgets/purchase_card.dart</code><br>
        <code>lib/screens/home_screen.dart</code>
      </td>
      <td>بناء لوحة المؤشرات (KPI Cards) وبطاقات الفواتير باستخدام <code>Row</code> و <code>Column</code> مدمجة مع <code>Expanded</code> لمنع حدوث أخطاء تجاوز الشاشة (RenderFlex Overflow) على الشاشات الصغيرة.</td>
    </tr>
    <tr>
      <td><strong>المحاضرة السابعة</strong><br>(الهياكل الأساسية Scaffold والنماذج Forms)</td>
      <td>
        • الهيكل العام <code>Scaffold</code><br>
        • الشريط العلوي <code>AppBar</code><br>
        • الزر العائم <code>FloatingActionButton</code><br>
        • النماذج <code>Form</code> ومتحكمات <code>TextEditingController</code><br>
        • التحقق عبر <code>GlobalKey&lt;FormState&gt;</code>
      </td>
      <td>
        <code>lib/screens/home_screen.dart</code><br>
        <code>lib/widgets/purchase_form_dialog.dart</code><br>
        <code>lib/utils/validators.dart</code>
      </td>
      <td>استخدام <code>Scaffold</code> كوعاء رئيسي للشاشات، مع استخدام <code>Form</code> و <code>TextFormField</code> مربوطة بـ <code>GlobalKey</code> لضمان فحص جميع حقول إدخال الصنف والسعر والتاريخ دفعة واحدة ومنع الحفظ إذا كانت الحقول فارغة أو خاطئة.</td>
    </tr>
    <tr>
      <td><strong>المحاضرة الثامنة</strong><br>(البرمجة غير المتزامنة والتنقل Asynchronous & Navigation)</td>
      <td>
        • دوال <code>async</code> و <code>await</code><br>
        • كائنات <code>Future</code> والعمليات المؤجلة<br>
        • الانتقال <code>Navigator.push / pop</code><br>
        • الحركات المخصصة <code>PageRouteBuilder</code>
      </td>
      <td>
        <code>lib/services/backup_sync_service.dart</code><br>
        <code>lib/services/invoice_scanner_service.dart</code><br>
        <code>lib/screens/login_screen.dart</code>
      </td>
      <td>تنفيذ عمليات استيراد وتصدير النسخ الاحتياطية واستدعاء الذكاء الاصطناعي في الخلفية (Background) دون تجميد واجهة المستخدم، مع تطبيق انتقال انسيابي ناعم (FadeTransition) بين الشاشات.</td>
    </tr>
    <tr>
      <td><strong>المحاضرة التاسعة</strong><br>(قواعد البيانات المحلية SQFlite)</td>
      <td>
        • إنشاء وتسمية قاعدة البيانات <code>openDatabase</code><br>
        • أوامر تعريف الجداول <code>CREATE TABLE</code><br>
        • العمليات الأربع <code>CRUD (Insert, Query, Update, Delete)</code><br>
        • القوائم المبنية عند الطلب <code>ListView.builder</code><br>
        • مربعات الحوار <code>AlertDialog & showDialog</code>
      </td>
      <td>
        <code>lib/services/database_helper.dart</code><br>
        <code>lib/services/purchases_service.dart</code><br>
        <code>lib/screens/home_screen.dart</code>
      </td>
      <td>بناء محرك SQLite محلي متكامل يوفر التخزين الدائم للفواتير والأصناف داخل الهاتف مع نمط Singleton، واستعراض مئات السجلات عبر <code>ListView.builder</code> مع خاصية التدمير وإعادة البناء الذاتي لتوفير الذاكرة العشوائية.</td>
    </tr>
  </tbody>
</table>
"""

# Insert the new screens and lecture table into HTML before section 5
insert_pos_screens = html.find('<h1 id="sec-navigation"')
if insert_pos_screens != -1:
    html = html[:insert_pos_screens] + new_screens_html + "\n\n" + lecture_bindings_table_html + "\n\n" + html[insert_pos_screens:]
    print("Inserted new screens and lecture master table successfully.")
else:
    print("Warning: Navigation marker not found, appending to end.")
    html += new_screens_html + "\n\n" + lecture_bindings_table_html

# Update title and cover meta
html = html.replace("1.0.0", "1.1.0")
html = html.replace("2024 - 2025", "2025 - 2026")

# Save updated HTML in parent directory and app directory
final_html_parent = os.path.join(parent_dir, "report.html")
final_html_local = os.path.join(script_dir, "تقرير_مشروع_إدارة_أثر.html")

with open(final_html_parent, "w", encoding="utf-8") as f:
    f.write(html)

with open(final_html_local, "w", encoding="utf-8") as f:
    f.write(html)

print(f"Saved enhanced HTML report to:\n - {final_html_parent}\n - {final_html_local}")

# Compile to PDF using Headless Chrome
chrome_path = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
if not os.path.exists(chrome_path):
    chrome_path = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

pdf_parent = os.path.join(parent_dir, "تقرير_مشروع_إدارة_أثر.pdf")
pdf_english = os.path.join(parent_dir, "Athar_Project_Academic_Report.pdf")
pdf_local = os.path.join(script_dir, "تقرير_مشروع_إدارة_أثر.pdf")

url = "file:///" + final_html_parent.replace("\\", "/")

cmd = [
    chrome_path,
    "--headless",
    "--disable-gpu",
    "--run-all-compositor-stages-before-draw",
    f"--print-to-pdf={pdf_parent}",
    url
]

print("Compiling PDF with Headless Chrome/Edge...")
res = subprocess.run(cmd, capture_output=True)

# Copy to other target names
if os.path.exists(pdf_parent):
    import shutil
    shutil.copyfile(pdf_parent, pdf_english)
    shutil.copyfile(pdf_parent, pdf_local)
    size_mb = os.path.getsize(pdf_parent) / (1024 * 1024)
    print(f"SUCCESS! Created PDF reports ({size_mb:.2f} MB):")
    print(f" 1. {pdf_parent}")
    print(f" 2. {pdf_english}")
    print(f" 3. {pdf_local}")
else:
    print("PDF compilation failed or output not found.")
    print("Stderr:", res.stderr.decode('utf-8', errors='ignore'))
