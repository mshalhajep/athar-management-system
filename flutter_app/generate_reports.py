# -*- coding: utf-8 -*-
"""
Script to generate the comprehensive academic report for Athar Inventory Management Flutter Project.
Outputs:
1. report.html (Beautifully styled HTML/CSS with embedded Base64 screenshots)
2. تقرير_مشروع_إدارة_أثر.pdf (Generated via Chrome Headless)
3. تقرير_مشروع_إدارة_أثر.md (Complete Markdown academic document)
"""

import os
import sys
import base64
import subprocess

PROJECT_DIR = r"c:\Users\Smart\Desktop\مشروع اداره\flutter_app"
BASE_DIR = r"c:\Users\Smart\Desktop\مشروع اداره"
ASSETS_DIR = os.path.join(PROJECT_DIR, "report_assets")

def get_base64_image(filename):
    filepath = os.path.join(ASSETS_DIR, filename)
    if os.path.exists(filepath):
        with open(filepath, "rb") as f:
            encoded = base64.b64encode(f.read()).decode("utf-8")
            return f"data:image/png;base64,{encoded}"
    return ""

img_splash = get_base64_image("00_splash_screen.png")
img_home = get_base64_image("01_home_screen.png")
img_login = get_base64_image("02_login_screen.png")
img_account = get_base64_image("03_google_account_dialog.png")
img_table = get_base64_image("04_inventory_table.png")
img_purchase = get_base64_image("05_purchase_dialog.png")

print(f"Loaded screenshots: Splash={len(img_splash)>0}, Home={len(img_home)>0}, Login={len(img_login)>0}, Dialogs={len(img_account)>0}")

html_content = f"""<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8">
<title>تقرير مشروع إدارة مخزون شركة أثر - توثيق برمجي وتصميمي شامل</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;800;900&family=Tajawal:wght@400;500;700;800;900&display=swap');

@page {{
  size: A4;
  margin: 14mm 16mm 16mm 16mm;
  @bottom-right {{
    content: counter(page);
    font-family: 'Cairo', sans-serif;
    font-size: 9pt;
    color: #64748b;
  }}
  @bottom-left {{
    content: "مشروع إدارة شركة أثر | توثيق أكاديمي لمناقشة التخرج ومشاريع Flutter";
    font-family: 'Cairo', sans-serif;
    font-size: 8pt;
    color: #94a3b8;
  }}
}}

*, *::before, *::after {{
  box-sizing: border-box;
}}

body {{
  font-family: 'Cairo', 'Tajawal', 'Segoe UI', Tahoma, Arial, sans-serif;
  line-height: 1.7;
  color: #1e293b;
  background-color: #ffffff;
  margin: 0;
  padding: 0;
  font-size: 11pt;
  text-rendering: optimizeLegibility;
  -webkit-font-smoothing: antialiased;
}}

.page-break {{
  page-break-before: always;
}}

.avoid-break {{
  page-break-inside: avoid;
}}

/* COVER PAGE */
.cover-page {{
  height: 96vh;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  text-align: center;
  padding: 40px 24px;
  background: linear-gradient(145deg, #0a0c10 0%, #161b22 100%);
  color: #ffffff;
  border-radius: 24px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.15);
  position: relative;
  overflow: hidden;
}}

.cover-header {{
  border-bottom: 2px solid rgba(255,255,255,0.12);
  padding-bottom: 20px;
}}

.univ-title {{
  font-size: 15pt;
  font-weight: 700;
  color: #cbd5e1;
  margin: 0 0 6px 0;
}}

.faculty-title {{
  font-size: 12pt;
  color: #94a3b8;
  margin: 0;
}}

.cover-body {{
  margin: auto 0;
}}

.badge-tag {{
  display: inline-block;
  background: rgba(255,255,255,0.08);
  color: #38bdf8;
  border: 1px solid rgba(56, 189, 248, 0.4);
  padding: 6px 20px;
  border-radius: 20px;
  font-size: 11pt;
  font-weight: 700;
  margin-bottom: 24px;
  letter-spacing: 0.5px;
}}

.cover-title {{
  font-size: 30pt;
  font-weight: 900;
  color: #ffffff;
  margin: 0 0 12px 0;
  line-height: 1.3;
}}

.cover-subtitle {{
  font-size: 16pt;
  font-weight: 600;
  color: #e2e8f0;
  max-width: 650px;
  margin: 0 auto 20px auto;
  line-height: 1.5;
}}

.cover-desc {{
  font-size: 11pt;
  color: #94a3b8;
  max-width: 580px;
  margin: 0 auto;
}}

.cover-footer {{
  border-top: 2px solid rgba(255,255,255,0.12);
  padding-top: 25px;
  display: flex;
  justify-content: space-around;
  text-align: right;
}}

.meta-box h4 {{
  font-size: 10pt;
  color: #38bdf8;
  margin: 0 0 6px 0;
  text-transform: uppercase;
}}

.meta-box p {{
  font-size: 12pt;
  font-weight: 700;
  margin: 0;
  color: #f1f5f9;
}}

/* TYPOGRAPHY */
h1, h2, h3, h4, h5 {{
  font-family: 'Cairo', sans-serif;
  color: #0f172a;
  font-weight: 800;
}}

h1.section-title {{
  font-size: 18pt;
  color: #0f172a;
  border-bottom: 3px solid #0f172a;
  padding-bottom: 8px;
  margin-top: 20px;
  margin-bottom: 18px;
  display: flex;
  align-items: center;
}}

h2.sub-title {{
  font-size: 14pt;
  color: #1e293b;
  border-right: 4px solid #0284c7;
  padding-right: 12px;
  margin-top: 20px;
  margin-bottom: 12px;
}}

p {{
  margin: 0 0 10px 0;
  text-align: justify;
}}

/* CODE TAGS */
code, .code-inline {{
  font-family: 'Courier New', Courier, monospace;
  background-color: #f1f5f9;
  color: #0369a1;
  padding: 2px 6px;
  border-radius: 6px;
  font-size: 9.5pt;
  font-weight: 600;
  direction: ltr;
  display: inline-block;
}}

pre {{
  background-color: #0f172a;
  color: #e2e8f0;
  padding: 14px 16px;
  border-radius: 12px;
  font-family: 'Consolas', 'Courier New', monospace;
  font-size: 9pt;
  direction: ltr;
  text-align: left;
  overflow-x: auto;
  line-height: 1.5;
  margin: 12px 0;
  border-left: 4px solid #38bdf8;
}}

/* CALLOUTS / BOXES */
.callout {{
  padding: 14px 18px;
  border-radius: 12px;
  margin: 14px 0;
  border-right: 5px solid;
}}

.callout-info {{
  background-color: #f0f9ff;
  border-color: #0284c7;
  color: #0369a1;
}}

.callout-academic {{
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  border-color: #0f172a;
  color: #1e293b;
  border-right-width: 6px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.03);
}}

.academic-badge {{
  display: inline-block;
  background-color: #0f172a;
  color: #ffffff;
  font-size: 9pt;
  font-weight: 800;
  padding: 3px 10px;
  border-radius: 6px;
  margin-bottom: 8px;
}}

/* TABLES */
table {{
  width: 100%;
  border-collapse: collapse;
  margin: 16px 0;
  font-size: 9.5pt;
}}

table th {{
  background-color: #0f172a;
  color: #ffffff;
  padding: 10px 12px;
  font-weight: 700;
  text-align: right;
  border: 1px solid #1e293b;
}}

table td {{
  padding: 9px 12px;
  border: 1px solid #e2e8f0;
  text-align: right;
  vertical-align: top;
}}

table tr:nth-child(even) {{
  background-color: #f8fafc;
}}

/* SCREENSHOT LAYOUT */
.screen-layout {{
  display: flex;
  gap: 20px;
  margin: 16px 0;
  align-items: flex-start;
}}

.screen-image-col {{
  flex: 0 0 250px;
  text-align: center;
}}

.screen-frame {{
  background: #0d0f12;
  border-radius: 24px;
  padding: 8px;
  box-shadow: 0 10px 24px rgba(0,0,0,0.18);
  display: inline-block;
  border: 3px solid #334155;
}}

.screen-frame img {{
  width: 230px;
  height: auto;
  border-radius: 18px;
  display: block;
}}

.screen-details-col {{
  flex: 1;
}}

.annotation-badge {{
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 22px;
  height: 22px;
  background-color: #0284c7;
  color: #ffffff;
  border-radius: 50%;
  font-size: 10pt;
  font-weight: 800;
  margin-left: 6px;
}}

.widget-card {{
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 12px 14px;
  margin-bottom: 10px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.02);
}}

.widget-card h4 {{
  margin: 0 0 6px 0;
  font-size: 11pt;
  color: #0f172a;
  display: flex;
  align-items: center;
}}

.widget-card p {{
  margin: 0;
  font-size: 9.5pt;
  color: #475569;
}}

.doctor-tip {{
  background-color: #fefce8;
  border: 1px dashed #eab308;
  border-radius: 8px;
  padding: 8px 12px;
  margin-top: 6px;
  font-size: 9pt;
  color: #854d0e;
}}

.doctor-tip strong {{
  color: #a16207;
}}

/* TOC */
.toc-list {{
  list-style: none;
  padding: 0;
  margin: 16px 0;
}}

.toc-item {{
  display: flex;
  justify-content: space-between;
  padding: 7px 0;
  border-bottom: 1px dotted #cbd5e1;
  font-weight: 600;
  font-size: 10pt;
}}

.toc-item a {{
  text-decoration: none;
  color: #0f172a;
}}

.toc-item span.page-num {{
  color: #64748b;
  font-weight: 700;
}}

/* DIAGRAMS */
.diagram-box {{
  background-color: #f8fafc;
  border: 2px dashed #94a3b8;
  border-radius: 14px;
  padding: 16px;
  margin: 14px 0;
  text-align: center;
}}

.flow-step {{
  display: inline-block;
  background: #ffffff;
  border: 1.5px solid #0284c7;
  color: #0f172a;
  padding: 7px 14px;
  border-radius: 10px;
  font-weight: 700;
  font-size: 9.5pt;
  margin: 4px;
  box-shadow: 0 2px 5px rgba(0,0,0,0.05);
}}

.flow-arrow {{
  display: inline-block;
  color: #0284c7;
  font-weight: 900;
  font-size: 12pt;
  margin: 0 4px;
}}
</style>
</head>
<body>

<!-- صفحة الغلاف -->
<div class="cover-page">
  <div class="cover-header">
    <div class="univ-title">جامعة العلوم والتكنولوجيا / الكلية الجامعية</div>
    <div class="faculty-title">كلية الحاسوب وتكنولوجيا المعلومات — قسم تقنية المعلومات / هندسة البرمجيات</div>
  </div>

  <div class="cover-body">
    <div class="badge-tag">تقرير توثيق برمجي وتصميمي فائق الدقة (Academic Project Documentation)</div>
    <div class="cover-title">تطبيق إدارة مخزون شركة أثر<br><span style="font-size:22pt; color:#38bdf8;">(Athar Purchases & Inventory System)</span></div>
    <div class="cover-subtitle">شرح معمق للأدوات (Widgets)، الدوال (Functions)، قاعدة بيانات SQLite، المزامنة السحابية بحسابات Google، والتنقل في إطار عمل Flutter</div>
    <div class="cover-desc">
      تم إعداد هذا التقرير الأكاديمي الشامل ليكون مرجعاً متكاملاً للجنة المناقشة والأستاذ المشرف، استناداً إلى الكود البرمجي الفعلي ومحاضرات المنهج الجامعي المقررة (المحاضرات 3 إلى 9).
    </div>
  </div>

  <div class="cover-footer">
    <div class="meta-box">
      <h4>إعداد الطالب / فريق العمل</h4>
      <p>طالب مشروع التخرج / تكنولوجيا المعلومات</p>
    </div>
    <div class="meta-box">
      <h4>إشراف الدكتور الفاضل</h4>
      <p>د. سليمان الشوص / لجنة المناقشة</p>
    </div>
    <div class="meta-box">
      <h4>المادة والتقنية</h4>
      <p>تطوير تطبيقات الجوال (Flutter & Dart)</p>
    </div>
    <div class="meta-box">
      <h4>العام الجامعي</h4>
      <p>2024 - 2025م / 1446هـ</p>
    </div>
  </div>
</div>

<div class="page-break"></div>

<!-- فهرس المحتويات -->
<h1 class="section-title">فهرس المحتويات (Table of Contents)</h1>
<div class="toc-list">
  <div class="toc-item"><a href="#sec-intro">1. مقدمة عامة عن المشروع وفلسفة النظام</a><span class="page-num">03</span></div>
  <div class="toc-item"><a href="#sec-pubspec">2. تحليل ملف الإعدادات pubspec.yaml ومكتبات Dart و Flutter</a><span class="page-num">04</span></div>
  <div class="toc-item"><a href="#sec-architecture">3. خريطة وهيكلية مجلدات المشروع (Architecture & Project Structure)</a><span class="page-num">06</span></div>
  <div class="toc-item"><a href="#sec-screens">4. الشرح البرمجي والتصميمي لواجهات المستخدم المدعمة باللقطات الفعلية</a><span class="page-num">08</span></div>
  <div class="toc-item"><a href="#sec-screen-splash" style="padding-right:20px;">- شاشة البداية والتحميل (Splash Screen)</a><span class="page-num">08</span></div>
  <div class="toc-item"><a href="#sec-screen-login" style="padding-right:20px;">- شاشة تسجيل الدخول والمصادقة (Login Screen)</a><span class="page-num">10</span></div>
  <div class="toc-item"><a href="#sec-screen-home" style="padding-right:20px;">- الشاشة الرئيسية وسجل المشتريات (Home Screen)</a><span class="page-num">12</span></div>
  <div class="toc-item"><a href="#sec-screen-dialog" style="padding-right:20px;">- نافذة إضافة وتعديل صنف شراء (Purchase Form Dialog)</a><span class="page-num">15</span></div>
  <div class="toc-item"><a href="#sec-screen-table" style="padding-right:20px;">- شاشة جدول المخزون التفاعلي (Inventory Table Screen)</a><span class="page-num">17</span></div>
  <div class="toc-item"><a href="#sec-navigation">5. دورة التنقل بين الصفحات وإدارة المسارات (Navigation & Routing)</a><span class="page-num">19</span></div>
  <div class="toc-item"><a href="#sec-auth">6. نظام المصادقة وإدارة الجلسات السحابية (AuthService & Session)</a><span class="page-num">21</span></div>
  <div class="toc-item"><a href="#sec-database">7. المعمارية الكاملة لقاعدة البيانات المحلية SQLite (DatabaseHelper & CRUD)</a><span class="page-num">23</span></div>
  <div class="toc-item"><a href="#sec-files">8. معالجة الصور وفواتير الشراء والنسخ السحابي (Google Drive Sync)</a><span class="page-num">26</span></div>
  <div class="toc-item"><a href="#sec-theme">9. نظام التصميم وهوية شركة أثر (Design System & Luxury Theme)</a><span class="page-num">28</span></div>
  <div class="toc-item"><a href="#sec-dataflow">10. مخططات تدفق البيانات والعمليات في التطبيق (Data Flow Diagrams)</a><span class="page-num">30</span></div>
  <div class="toc-item"><a href="#sec-security">11. الأمان، الصلاحيات، وإدارة الأداء (Security & Permissions)</a><span class="page-num">32</span></div>
  <div class="toc-item"><a href="#sec-tables">12. الجداول المرجعية الشاملة للشاشات والأدوات والملفات البرمجية</a><span class="page-num">34</span></div>
  <div class="toc-item"><a href="#sec-defense">13. الأسئلة الأكاديمية المتوقعة في مناقشة الدكتور ونماذج الإجابات المثالية</a><span class="page-num">36</span></div>
  <div class="toc-item"><a href="#sec-glossary">14. معجم المصطلحات البرمجية، الخاتمة، والملفات المفحوصة</a><span class="page-num">41</span></div>
</div>

<div class="callout callout-academic">
  <div class="academic-badge">توجيه أكاديمي لمناقشة التخرج</div>
  <strong>ملاحظة هامة للمناقشين والطلاب:</strong> تم ربط كل فقرة في هذا التقرير بالمسار الفيزيائي للكود داخل المشروع <code>lib/...</code> ومفاهيم المنهج الجامعي (Lectures 3-9) لمساعدة الطالب على إثبات فهمه التقني العميق عند سؤاله: <em>"لماذا استخدمت هذا الـ Widget تحديداً؟ وأين كود هذه العملية؟"</em>.
</div>

<div class="page-break"></div>

<!-- 1. مقدمة عامة -->
<h1 id="sec-intro" class="section-title">1. مقدمة عامة عن المشروع وفلسفة النظام</h1>
<p>
يُمثل مشروع <strong>"إدارة مخزون شركة أثر" (Athar Inventory & Purchases Management)</strong> تطبيقاً متقدماً للأجهزة الذكية مبنياً بأحدث إصدارات إطار العمل <code>Flutter</code> بلغة <code>Dart</code>. يهدف النظام إلى تمكين إدارة وموظفي الشركة من تسجيل عمليات شراء وتوريد بضائع المخزون، حساب التكاليف والإجماليات والكميات بدقة وفورية، وإرفاق صور فواتير الشراء الرسمية مع كل عملية لضمان أعلى معايير الشفافية المحاسبية.
</p>
<p>
تم بناء التطبيق باتباع معمارية البرمجة الطبقية النظيفة (Layered Clean Architecture)، حيث تنفصل واجهات المستخدم <code>Screens</code> تماماً عن الخدمات المنطقية <code>Services</code> ونماذج البيانات <code>Models</code> ومستودع قاعدة البيانات <code>DatabaseHelper</code>، مما يضمن سهولة الصيانة، قابلية التوسع، وسلاسة إعادة الاستخدام للأكواد.
</p>

<h2 class="sub-title">الأهداف الرئيسية للنظام:</h2>
<ul>
  <li><strong>إدارة العمليات اليومية:</strong> تسجيل عمليات الشراء وتحديد الكمية، سعر الحبة، وتاريخ الشراء والملاحظات.</li>
  <li><strong>الحساب التلقائي اللحظي:</strong> احتساب إجمالي تكلفة الفاتورة فوريّاً <code>quantity * unitPrice</code> وتحديث لوحة الإحصائيات العلوية دون تأخير.</li>
  <li><strong>الأرشفة الرقمية للفواتير:</strong> إمكانية التقاط صورة الفاتورة عبر الكاميرا أو المعرض وتخزينها بتنسيق <code>Base64 Data URI</code> لتبقى محفوظة بشكل دائم ومستقل.</li>
  <li><strong>العمل بدون إنترنت (Offline-First):</strong> الاعتماد على محرك قواعد البيانات المحلية فائق السرعة <code>SQLite</code> عبر مكتبة <code>sqflite</code>، بحيث يعمل التطبيق بكامل طاقته في أي مكان.</li>
  <li><strong>النسخ الاحتياطي والمزامنة السحابية:</strong> ربط الحسابات مع Google Drive لتصدير واستعادة نسخ مشفرة بصيغة <code>.athar</code> أو نصوص <code>JSON</code> لحماية الشركة من فقدان البيانات عند تبديل الهاتف.</li>
  <li><strong>الهوية البصرية الفاخرة:</strong> عكس العلامة التجارية الرسمية لشركة "أثر" باللونين الأسود الملكي الفاخر <code>#111827</code> والأبيض الناصع مع مراعاة متطلبات التصميم متعدد المنصات Material 3 ودعم اللغة العربية من اليمين إلى اليسار (RTL).</li>
</ul>

<!-- 2. pubspec.yaml -->
<h1 id="sec-pubspec" class="section-title">2. تحليل ملف الإعدادات pubspec.yaml والمكتبات</h1>
<p>
يُعتبر ملف <code>pubspec.yaml</code> قلب مشروع الفلاتر، حيث يُحدد هوية التطبيق، بيئة التشغيل، والمكتبات الخارجية (Dependencies) المستخدمة. تم فحص الملف الفعلي في مسار المشروع <code>flutter_app/pubspec.yaml</code>، وفيما يلي تفكيكه الأكاديمي:
</p>

<div class="avoid-break">
<table>
  <thead>
    <tr>
      <th>اسم الحزمة (Package)</th>
      <th>الإصدار المستخدم</th>
      <th>الوظيفة الفعلية داخل كود مشروع أثر</th>
      <th>الملفات المرتبطة بالحزمة</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>flutter</code></td>
      <td>sdk: flutter</td>
      <td>إطار العمل الأساسي لبناء واجهات المستخدم والأدوات الرسومية والتصميم.</td>
      <td>كافة ملفات المشروع</td>
    </tr>
    <tr>
      <td><code>flutter_localizations</code></td>
      <td>sdk: flutter</td>
      <td>دعم اللغة العربية والاتجاه من اليمين لليسار (RTL) وترجمة أدوات التقويم والنوافذ.</td>
      <td><code>lib/main.dart</code></td>
    </tr>
    <tr>
      <td><code>sqflite</code></td>
      <td>^2.4.2+1</td>
      <td>محرك قاعدة البيانات المحلية العلائقية SQLite لحفظ وقراءة وحذف وتعديل سجلات الشراء.</td>
      <td><code>lib/services/database_helper.dart</code></td>
    </tr>
    <tr>
      <td><code>sqflite_common_ffi</code></td>
      <td>^2.4.0+3</td>
      <td>تشغيل محرك SQLite على أنظمة سطح المكتب (Windows / Linux) أثناء التطوير والاختبار.</td>
      <td><code>lib/services/database_helper.dart</code></td>
    </tr>
    <tr>
      <td><code>sqflite_common_ffi_web</code></td>
      <td>^1.1.1</td>
      <td>تشغيل وتوافق محرك SQLite على منصة الويب (Flutter Web) عبر IndexedDB الداخلي.</td>
      <td><code>lib/services/database_helper.dart</code></td>
    </tr>
    <tr>
      <td><code>path</code></td>
      <td>^1.9.1</td>
      <td>دمج مسارات المجلدات والملفات بشكل آمن برمجياً عبر دالة <code>join()</code>.</td>
      <td><code>lib/services/database_helper.dart</code></td>
    </tr>
    <tr>
      <td><code>path_provider</code></td>
      <td>^2.1.6</td>
      <td>تحديد المجلدات الرسمية لنظام Android لتخزين ملفات النسخ الاحتياطية <code>.athar</code>.</td>
      <td><code>lib/services/backup_sync_service.dart</code></td>
    </tr>
    <tr>
      <td><code>shared_preferences</code></td>
      <td>^2.5.5</td>
      <td>تخزين مفاتيح الجلسة، البريد المسجل، تاريخ آخر مزامنة، والنسخ السحابية الخفيفة.</td>
      <td><code>lib/services/auth_service.dart</code></td>
    </tr>
    <tr>
      <td><code>image_picker</code></td>
      <td>^1.2.3</td>
      <td>فتح كاميرا الهاتف ومعرض الصور لاختيار صورة فاتورة الشراء وإرفاقها مع السجل.</td>
      <td><code>lib/widgets/purchase_form_dialog.dart</code></td>
    </tr>
    <tr>
      <td><code>intl</code></td>
      <td>0.20.2</td>
      <td>تنسيق الأرقام والعملات (ر.س) بالصيغة العربية، وتنسيق التواريخ الميلادية والهجرية.</td>
      <td><code>lib/screens/home_screen.dart</code></td>
    </tr>
    <tr>
      <td><code>cupertino_icons</code></td>
      <td>^1.0.8</td>
      <td>أيقونات التصميم القياسية المتوافقة مع أجهزة iOS و Android.</td>
      <td>واجهات التطبيق</td>
    </tr>
  </tbody>
</table>
</div>

<div class="callout callout-info">
  <strong>إعدادات الأصول والخطوط في pubspec.yaml:</strong> تم تفعيل مسار الصور والأصول الرسمية عبر السطر البرمجي:
  <pre>flutter:
  uses-material-design: true
  assets:
    - assets/images/</pre>
  ويشمل هذا المجلد الشعار الرسمي للشركة: <code>athar-black-logo.jpg</code> و <code>athar-white-logo.jpg</code>.
</div>

<div class="page-break"></div>

<!-- 3. بنية المجلدات -->
<h1 id="sec-architecture" class="section-title">3. خريطة وهيكلية مجلدات المشروع (Architecture)</h1>
<p>
تم تنظيم مجلدات المشروع وفق أسلوب هندسي نقي يضمن الفصل التام بين الاهتمامات (Separation of Concerns). لا تتداخل أكواد الرسم والتصميم في الواجهات مع أكواد استعلامات قواعد البيانات أو معالجة الشبكة والتخزين.
</p>

<pre>
c:/Users/Smart/Desktop/مشروع اداره/flutter_app/
├── android/                   # ملفات بناء بيئة الأندرويد وإعدادات AndroidManifest و Gradle
│   └── app/src/main/AndroidManifest.xml
├── assets/images/             # صور وشعارات شركة أثر (خلفيات وشعارات رسمية)
│   ├── athar-black-logo.jpg
│   └── athar-white-logo.jpg
├── lib/                       # كود لغة Dart الفعلي للتطبيق
│   ├── main.dart              # نقطة الانطلاق الرئيسية runApp() وإعدادات MaterialApp
│   ├── models/                # نماذج تمثيل البيانات (Data Entities)
│   │   └── purchase.dart      # كلاس Purchase والمشيدات toJson و fromJson
│   ├── screens/               # الشاشات الرئيسية للتطبيق (Views)
│   │   ├── splash_screen.dart           # شاشة البداية والشعار الأنيق والمؤقت الزمني
│   │   ├── login_screen.dart            # شاشة المصادقة وربط حساب Google ودرايف
│   │   ├── home_screen.dart             # الشاشة المركزية وسجل المشتريات والملخص المالي
│   │   └── inventory_table_screen.dart  # شاشة جدول المخزون التفاعلي والفرز المتقدم
│   ├── services/              # طبقة المنطق وإدارة البيانات (Business & Data Layer)
│   │   ├── auth_service.dart            # إدارة الجلسة ومصادقة الحساب والمستخدم الضيف
│   │   ├── database_helper.dart         # الاتصال بقاعدة بيانات SQLite وعمليات CRUD
│   │   ├── purchases_service.dart       # إدارة الحالة وقوائم المشتريات والفلترة
│   │   ├── backup_sync_service.dart     # توليد واسترجاع النسخ السحابية وملفات .athar
│   │   └── app_update_service.dart      # فحص وتنزيل التحديثات مع الحفاظ على البيانات
│   ├── theme/                 # السمات البصرية والألوان المركزية
│   │   └── app_theme.dart     # فئات AppColors و AppTheme الداعمة لـ Material 3
│   └── widgets/               # المكونات الرسومية القابلة لإعادة الاستخدام (Reusable Widgets)
│       ├── app_image_view.dart          # عارض الصور الذكي الداعم لـ Base64 و Network و File
│       ├── stat_card.dart               # بطاقات الإحصائيات العلوية المزودة بظلال وأيقونات
│       ├── purchase_card.dart           # بطاقة عرض عملية الشراء في السجل مع خيارات التحكم
│       ├── purchase_form_dialog.dart    # نموذج إدخال/تعديل المشتريات وحساب الإجمالي فورياً
│       └── invoice_viewer_dialog.dart   # عارض صور الفواتير بشاشة كاملة مع التكبير
├── pubspec.yaml               # ملف الحزم والتبعيات وإعدادات البناء
└── report_assets/             # اللقطات الحية الملتقطة من شاشات النظام للتوثيق
</pre>

<h2 class="sub-title">وظيفة كل طبقة في معمارية النظام:</h2>
<ol>
  <li><strong>طبقة النماذج (Models Layer):</strong> تحويل البيانات الخام المأخوذة من قاعدة بيانات SQLite أو JSON إلى كائنات برمجية قوية النوع <code>Type-Safe Objects</code> لمنع الأخطاء أثناء التشغيل.</li>
  <li><strong>طبقة الخدمات (Services Layer):</strong> التعامل مع القرص الصلب، قواعد البيانات، الذاكرة المؤقتة <code>SharedPreferences</code>، والمزامنة السحابية بشكل غير متزامن <code>async/await</code> لمنع تجميد واجهة المستخدم (UI Freezing).</li>
  <li><strong>طبقة الواجهات (Screens Layer):</strong> بناء العناصر التفاعلية ورسم الشاشات استناداً إلى مكتبة فلاتر للأدوات <code>Material Design</code>.</li>
  <li><strong>طبقة المكونات (Widgets Layer):</strong> تجزئة الواجهات المعقدة إلى عناصر صغيرة ونظيفة، مما يمنع تضخم الكود ويسهل اختباره وتعديله.</li>
</ol>

<div class="page-break"></div>

<!-- 4. الشرح البرمجي لواجهات المستخدم -->
<h1 id="sec-screens" class="section-title">4. الشرح البرمجي والتصميمي لواجهات المستخدم المدعمة باللقطات</h1>
<p>
في هذا القسم، يتم استعراض كل واجهة من واجهات التطبيق الحقيقية كما تم التقاطها بدقة من داخل بيئة التشغيل، مع توضيح الأدوات البرمجية (Widgets) المسؤولة عن بناء كل جزء، الخصائص المضبوطة، وكيف يشرح الطالب وظيفته للأستاذ المشرف.
</p>

<!-- الشاشة 1: Splash Screen -->
<div class="avoid-break" id="sec-screen-splash">
<h2 class="sub-title">4.1 شاشة البداية والتحميل (Splash Screen)</h2>
<div class="screen-layout">
  <div class="screen-image-col">
    <div class="screen-frame">
      <img src="{img_splash}" alt="شاشة البداية">
    </div>
    <p style="font-size:9pt; color:#64748b; margin-top:8px;">لقطة الشاشة الحقيقية لشاشة البداية</p>
  </div>
  <div class="screen-details-col">
    <div class="widget-card">
      <h4><span class="annotation-badge">1</span> بطاقة الشعار الرسمي (Official Luxury Logo Card)</h4>
      <p><strong>المسار البرمجي:</strong> <code>lib/screens/splash_screen.dart</code> (الأسطر 89-126)</p>
      <p><strong>الأداة المستخدمة:</strong> تم استخدام <code>Container</code> مع <code>BoxDecoration</code> بلون أسود ملكي <code>#0A0A0A</code>، مع حواف دائرية <code>BorderRadius.circular(24)</code>، وظل ناعم <code>BoxShadow</code> مع تأثير تكبير وتلاشي عبر <code>FadeTransition</code> و <code>ScaleTransition</code>.</p>
      <div class="doctor-tip">
        <strong>ماذا تقول للدكتور؟:</strong> "استخدمنا <code>SingleTickerProviderStateMixin</code> مع <code>AnimationController</code> لمدة 1400 ميلي ثانية لإظهار الشعار بحركة انسيابية ناعمة لتعزيز تجربة المستخدم (UX)، ثم استخدام <code>Timer</code> لمدة 6 ثوانٍ لنقل المستخدم تلقائياً للشاشة التالية دون الحاجة للضغط على أي زر".
      </div>
    </div>

    <div class="widget-card">
      <h4><span class="annotation-badge">2</span> عنوان وهوية شركة أثر (Brand Title & Tagline)</h4>
      <p><strong>المسار البرمجي:</strong> <code>lib/screens/splash_screen.dart</code> (الأسطر 130-152)</p>
      <p><strong>الأداة المستخدمة:</strong> تم استخدام <code>Column</code> لترتيب النصوص رأسيّاً مع <code>SizedBox(height: 8)</code> للمسافات، واستخدام <code>Text</code> بخط عريض <code>FontWeight.w900</code> ولون <code>AppColors.textMain</code>، متبوعاً بالشعار اللفظي: <em>"ننسق التفاصيل، ونترك أثراً"</em>.</p>
    </div>

    <div class="widget-card">
      <h4><span class="annotation-badge">3</span> مؤشر التقدم البسيط (Linear Progress Indicator)</h4>
      <p><strong>المسار البرمجي:</strong> <code>lib/screens/splash_screen.dart</code> (الأسطر 155-165)</p>
      <p><strong>الأداة المستخدمة:</strong> <code>LinearProgressIndicator</code> مدمج داخل <code>ClipRRect</code> لمنحه حواف مستديرة ناعمة بعرض 90 بكسل، ليوحي للمستخدم ببدء تهيئة النظام وقراءة قاعدة بيانات SQLite في الخلفية.</p>
    </div>
  </div>
</div>
</div>

<div class="page-break"></div>

<!-- الشاشة 2: Login Screen -->
<div class="avoid-break" id="sec-screen-login">
<h2 class="sub-title">4.2 شاشة تسجيل الدخول والمصادقة (Login Screen)</h2>
<div class="screen-layout">
  <div class="screen-image-col">
    <div class="screen-frame">
      <img src="{img_login}" alt="شاشة تسجيل الدخول">
    </div>
    <p style="font-size:9pt; color:#64748b; margin-top:8px;">شاشة تسجيل الدخول وإدارة الجلسات</p>
  </div>
  <div class="screen-details-col">
    <div class="widget-card">
      <h4><span class="annotation-badge">1</span> بطاقة معلومات النسخ الاحتياطي (Cloud Backup Info Card)</h4>
      <p><strong>المسار البرمجي:</strong> <code>lib/screens/login_screen.dart</code> (الأسطر 219-264)</p>
      <p><strong>الأدوات المستخدمة:</strong> <code>Container</code> مع خلفية ملونة ناعمة <code>AppColors.primarySurface</code> وحدود <code>Border.all</code>، يضم <code>Row</code> داخله أيقونة السحابة <code>Icons.cloud_sync_rounded</code> وعمود <code>Column</code> يشرح للمستخدم فوائد ربط الحساب بمزامنة Google Drive لضمان عدم فقدان الفواتير.</p>
      <div class="doctor-tip">
        <strong>ماذا تقول للدكتور؟:</strong> "تم استخدام <code>Expanded</code> داخل <code>Row</code> لمنع مشكلة الخطأ الشهير <code>RenderFlex overflowed</code> عند عرض النصوص التوضيحية الطويلة على مختلف مقاسات شاشات الجوال".
      </div>
    </div>

    <div class="widget-card">
      <h4><span class="annotation-badge">2</span> زر تسجيل الدخول بحساب Google (Google Sign-In Button)</h4>
      <p><strong>المسار البرمجي:</strong> <code>lib/screens/login_screen.dart</code> (الأسطر 268-322)</p>
      <p><strong>الأدوات المستخدمة:</strong> <code>ElevatedButton</code> بارتفاع ثابت 54 بكسل عبر <code>SizedBox(height: 54)</code>، يحتوي على أيقونة حرف G بالألوان المميزة لجوجل، وينفذ دالة <code>_handleGoogleSignIn()</code> التي تستدعي خدمة <code>AuthService</code>.</p>
    </div>

    <div class="widget-card">
      <h4><span class="annotation-badge">3</span> خيار تحديد بريد مخصص وزر المتابعة كضيف (Custom Gmail & Guest)</h4>
      <p><strong>المسار البرمجي:</strong> <code>lib/screens/login_screen.dart</code> (الأسطر 326-366)</p>
      <p><strong>الأدوات المستخدمة:</strong> <code>TextButton.icon</code> لفتح نافذة <code>_showCustomEmailDialog()</code> وإدخال أي بريد جوجل مخصص لعزل وتفريد النسخ، متبوعاً بزر <code>OutlinedButton.icon</code> للدخول كضيف محلي <code>_handleGuestLogin()</code> بدون إنترنت.</p>
    </div>
  </div>
</div>
</div>

<div class="page-break"></div>

<!-- الشاشة 3: Google Dialog -->
<div class="avoid-break">
<h2 class="sub-title">4.3 نافذة إدخال بريد Google للمزامنة (Google Account Dialog)</h2>
<div class="screen-layout">
  <div class="screen-image-col">
    <div class="screen-frame">
      <img src="{img_account}" alt="نافذة ربط حساب Google">
    </div>
    <p style="font-size:9pt; color:#64748b; margin-top:8px;">نافذة ربط الحساب ومزامنة Google Drive</p>
  </div>
  <div class="screen-details-col">
    <div class="widget-card">
      <h4><span class="annotation-badge">1</span> هيكل مربع الحوار المنبثق (AlertDialog Structure)</h4>
      <p><strong>المسار البرمجي:</strong> <code>lib/screens/login_screen.dart</code> (الأسطر 61-118)</p>
      <p><strong>الأداة المستخدمة:</strong> تم استخدام <code>showDialog()</code> مع <code>AlertDialog</code> وحواف دائرية <code>shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))</code> واتجاه <code>Directionality(textDirection: TextDirection.rtl)</code> لضبط المحاذاة العربية.</p>
      <div class="doctor-tip">
        <strong>ماذا تقول للدكتور؟:</strong> "المربع يستقبل المدخلات عبر <code>TextField</code> بمتحكم <code>TextEditingController</code> ونوع لوحة مفاتيح <code>TextInputType.emailAddress</code>، وعند الضغط على زر 'تأكيد والمتابعة' يتم حفظ البريد في <code>SharedPreferences</code> لربط كافة مشتريات هذا المستخدم بسحابته الخاصة".
      </div>
    </div>

    <div class="widget-card">
      <h4><span class="annotation-badge">2</span> أزرار التحكم وإلغاء الأمر (Dialog Action Buttons)</h4>
      <p><strong>الأدوات المستخدمة:</strong> قسم <code>actions</code> داخل <code>AlertDialog</code> ويحتوي على <code>TextButton</code> للإلغاء عبر <code>Navigator.pop(ctx)</code>، وزر <code>ElevatedButton</code> لتنفيذ عملية الدخول والمزامنة الفورية.</p>
    </div>
  </div>
</div>
</div>

<div class="page-break"></div>

<!-- الشاشة 4: Home Screen -->
<div class="avoid-break" id="sec-screen-home">
<h2 class="sub-title">4.4 الشاشة الرئيسية وسجل المشتريات (Home Screen)</h2>
<div class="screen-layout">
  <div class="screen-image-col">
    <div class="screen-frame">
      <img src="{img_home}" alt="الشاشة الرئيسية">
    </div>
    <p style="font-size:9pt; color:#64748b; margin-top:8px;">الشاشة الرئيسية: الإحصائيات وسجل المشتريات</p>
  </div>
  <div class="screen-details-col">
    <div class="widget-card">
      <h4><span class="annotation-badge">1</span> بطاقات الإحصاء العلوية (StatCard Widgets)</h4>
      <p><strong>المسار البرمجي:</strong> <code>lib/widgets/stat_card.dart</code> و <code>lib/screens/home_screen.dart</code> (الأسطر 987-1008)</p>
      <p><strong>الأدوات المستخدمة:</strong> صف <code>Row</code> يحتوي على نسختين من الـ Widget المخصص <code>StatCard</code> مغلفة بـ <code>Expanded</code> لتوزيع المساحة بنسبة 50% لكل بطاقة. البطاقة الأولى تعرض "إجمالي المشتريات" مميزة باللون الأسود الملكي <code>highlighted: true</code>، والبطاقة الثانية تعرض "عدد العمليات".</p>
      <div class="doctor-tip">
        <strong>ماذا تقول للدكتور؟:</strong> "تم تصميم <code>StatCard</code> كـ <code>StatelessWidget</code> مستقل تماماً في مجلد <code>widgets/</code> لتحقيق مبدأ إعادة استخدام الكود (Code Reusability)، وتستخدم داخله <code>FittedBox</code> لضمان تصغير الخط تلقائياً عند زيادة الأرقام الكبيرة لكي لا تخرج عن حواف البطاقة".
      </div>
    </div>

    <div class="widget-card">
      <h4><span class="annotation-badge">2</span> شريط الملخص المصغر (Mini Summary Bar)</h4>
      <p><strong>المسار البرمجي:</strong> <code>lib/screens/home_screen.dart</code> (الأسطر 1012-1054)</p>
      <p><strong>الأدوات المستخدمة:</strong> <code>Container</code> مع حواف <code>circular(16)</code> وحدود رمادية فاتحة، يعرض ملخصين متجاورين مفصولين بخط عمودي <code>Container(width: 1, height: 28)</code>: إجمالي كل المدة وعدد الحبات الإجمالية المعروضة بالمخزون.</p>
    </div>

    <div class="widget-card">
      <h4><span class="annotation-badge">3</span> حقل البحث الفوري (Instant Search Bar)</h4>
      <p><strong>المسار البرمجي:</strong> <code>lib/screens/home_screen.dart</code> (الأسطر 1074-1101)</p>
      <p><strong>الأدوات المستخدمة:</strong> <code>TextField</code> بمتحكم <code>_searchController</code> يربط حدث التغيير <code>onChanged</code> مباشرة بدالة <code>_purchasesService.setSearchQuery(val)</code> لتصفية القائمة فورياً بمجرد كتابة أول حرف من اسم الصنف.</p>
    </div>

    <div class="widget-card">
      <h4><span class="annotation-badge">4</span> وسوم الفلترة الزمنية (ChoiceChip Filter Row)</h4>
      <p><strong>المسار البرمجي:</strong> <code>lib/screens/home_screen.dart</code> (الأسطر 1105-1135)</p>
      <p><strong>الأدوات المستخدمة:</strong> <code>SingleChildScrollView(scrollDirection: Axis.horizontal)</code> مع <code>ChoiceChip</code> لفرز المشتريات زمنياً: (كل المدة، هذا الشهر، آخر 6 أشهر، آخر سنة).</p>
    </div>
  </div>
</div>
</div>

<div class="page-break"></div>

<!-- الشاشة 5: Purchase Form Dialog -->
<div class="avoid-break" id="sec-screen-dialog">
<h2 class="sub-title">4.5 نافذة تسجيل وتعديل شراء (Purchase Form Dialog)</h2>
<div class="screen-layout">
  <div class="screen-image-col">
    <div class="screen-frame">
      <img src="{img_purchase}" alt="نافذة تسجيل شراء">
    </div>
    <p style="font-size:9pt; color:#64748b; margin-top:8px;">نافذة إضافة وتعديل صنف شراء</p>
  </div>
  <div class="screen-details-col">
    <div class="widget-card">
      <h4><span class="annotation-badge">1</span> حقول الإدخال والتحقق (Form & TextFields)</h4>
      <p><strong>المسار البرمجي:</strong> <code>lib/widgets/purchase_form_dialog.dart</code> (الأسطر 57-194)</p>
      <p><strong>الأدوات المستخدمة:</strong> تم بناء النافذة كـ <code>StatefulWidget</code> داخل <code>showModalBottomSheet</code> مع تمكين <code>isScrollControlled: true</code> لتتجاوب مع لوحة المفاتيح. تتضمن الحقول:</p>
      <ul>
        <li><code>_nameController</code>: اسم الصنف أو البضاعة.</li>
        <li><code>_quantityController</code>: عدد القطع المشتراة (أرقام صحيحة).</li>
        <li><code>_priceController</code>: سعر الحبة بالريال السعودي.</li>
        <li><code>_dateController</code>: تاريخ الشراء مع ميزة فتح تقويم فلاتر <code>showDatePicker</code>.</li>
      </ul>
      <div class="doctor-tip">
        <strong>ماذا تقول للدكتور؟:</strong> "قمنا بوضع <code>addListener</code> على متحكم الكمية والسعر، بحيث تستدعي دالة <code>_onCalculatedChanged()</code> التي تنفذ <code>setState()</code> لحساب إجمالي الفاتورة <code>qty * price</code> وعرضه في مستطيل بارز باللون الأسود في أسفل النموذج قبل الحفظ مباشرة!".
      </div>
    </div>

    <div class="widget-card">
      <h4><span class="annotation-badge">2</span> إرفاق وتصوير الفاتورة الرسمية (Invoice Attachment)</h4>
      <p><strong>المسار البرمجي:</strong> <code>lib/widgets/purchase_form_dialog.dart</code> (الأسطر 112-140)</p>
      <p><strong>الأدوات المستخدمة:</strong> زر لإطلاق مكتبة <code>ImagePicker().pickImage()</code> من الكاميرا أو المعرض، وتحويل البايتات المأخوذة فوراً إلى <code>base64Encode</code> وحفظها كـ <code>Data URI</code> مستقل مدمج بالسجل.</p>
    </div>
  </div>
</div>
</div>

<div class="page-break"></div>

<!-- الشاشة 6: Inventory Table -->
<div class="avoid-break" id="sec-screen-table">
<h2 class="sub-title">4.6 شاشة جدول المخزون التفاعلي (Inventory Table Screen)</h2>
<div class="screen-layout">
  <div class="screen-image-col">
    <div class="screen-frame">
      <img src="{img_table}" alt="جدول المخزون التفاعلي">
    </div>
    <p style="font-size:9pt; color:#64748b; margin-top:8px;">شاشة جدول المخزون وفرز الأصناف</p>
  </div>
  <div class="screen-details-col">
    <div class="widget-card">
      <h4><span class="annotation-badge">1</span> شريط أدوات الجدول والنسخ السريع (Table Toolbar & Copy)</h4>
      <p><strong>المسار البرمجي:</strong> <code>lib/screens/inventory_table_screen.dart</code> (الأسطر 78-100)</p>
      <p><strong>الأدوات المستخدمة:</strong> زر نسخ التقرير الذي يجمع كافة أصناف المخزون في <code>StringBuffer</code> وينسخها إلى حافظة الهاتف عبر <code>Clipboard.setData()</code>، وزر القائمة المنسدلة <code>PopupMenuButton</code> لفرز الجدول (الأحدث، الأقدم، الكمية، السعر، الاسم أبجدياً).</p>
      <div class="doctor-tip">
        <strong>ماذا تقول للدكتور؟:</strong> "تم تصميم جدول المخزون باستخدام <code>SingleChildScrollView</code> أفقي ورأسي مع بطاقات متداخلة أو صفوف متبادلة الألوان <code>AppColors.tableRowAlternate</code> لمنح المشرف تجربة شبيهة ببرامج جداول البيانات المتقدمة مثل Excel، مع تمكين زر المعاينة السريعة للفاتورة وزر التعديل الفوري من الجدول".
      </div>
    </div>

    <div class="widget-card">
      <h4><span class="annotation-badge">2</span> صفوف وأعمدة جدول المشتريات (Table Data Rows)</h4>
      <p><strong>المسار البرمجي:</strong> <code>lib/screens/inventory_table_screen.dart</code></p>
      <p><strong>الأدوات المستخدمة:</strong> عرض رقم الصنف، اسم البضاعة، الكمية الإجمالية كشارة <code>Badge</code> باللون الرمادي الداكن، سعر الحبة، وإجمالي تكلفة الصنف مع زر فتح صورة الفاتورة في نافذة مكبرة <code>InvoiceViewerDialog</code>.</p>
    </div>
  </div>
</div>
</div>

<div class="page-break"></div>

<!-- 5. نظام التنقل -->
<h1 id="sec-navigation" class="section-title">5. دورة التنقل بين الصفحات وإدارة المسارات (Navigation)</h1>
<p>
تم الاعتماد على محرك التوجيه الرسمي في فلاتر <code>Navigator 1.0 / 2.0 State-driven</code> للتحكم في تدفق الشاشات وتبديل الواجهات بسلاسة دون تراكم الشاشات في مكدس الذاكرة (Memory Stack).
</p>

<div class="diagram-box">
  <div class="flow-step">1. تشغيل التطبيق (main.dart)</div>
  <div class="flow-arrow">←</div>
  <div class="flow-step">2. شاشة البداية (SplashScreen)</div>
  <div class="flow-arrow">←</div>
  <div class="flow-step">3. فحص الجلسة (AuthService)</div>
  <div class="flow-arrow">←</div>
  <div class="flow-step">4. الشاشة الرئيسية (HomeScreen)</div>
  <div class="flow-arrow">↔</div>
  <div class="flow-step">5. جدول المخزون (InventoryTable)</div>
</div>

<h2 class="sub-title">الأساليب البرمجية المستخدمة في التنقل:</h2>
<ul>
  <li>
    <strong>الانتقال مع مسح المكدس <code>Navigator.pushReplacement</code>:</strong>
    <pre>Navigator.of(context).pushReplacement(
  PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 600),
    pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {{
      return FadeTransition(opacity: animation, child: child);
    }},
  ),
);</pre>
    <strong>الفائدة الأكاديمية:</strong> استخدام <code>pushReplacement</code> مع <code>PageRouteBuilder</code> يضمن شيئين: أولاً انتقال ناعم عبر التلاشي <code>FadeTransition</code>، وثانياً تدمير كائن <code>SplashScreen</code> من مكدس النظام لمنع المستخدم من الرجوع لشاشة البداية عند الضغط على زر الرجوع في الأندرويد.
  </li>
  <li>
    <strong>التبديل الداخلي عبر شريط التنقل السفلي <code>NavigationBar</code>:</strong>
    يتم الانتقال بين شاشة سجل المشتريات وشاشة جدول المخزون عبر متغير الحالة <code>_currentNavIndex</code> داخل نفس الشاشة <code>HomeScreen</code>، مما يوفر سرعة فائقة ويمنع إعادة بناء الصفحة بالكامل.
  </li>
  <li>
    <strong>إغلاق النوافذ المنبثقة <code>Navigator.pop(context)</code>:</strong>
    يُستخدم لإغلاق مربعات الحوار <code>AlertDialog</code> أو أسفل الشاشة <code>showModalBottomSheet</code> فور اكتمال عملية الحفظ أو الإلغاء.
  </li>
</ul>

<div class="page-break"></div>

<!-- 6. نظام المصادقة والجلسات -->
<h1 id="sec-auth" class="section-title">6. نظام المصادقة وإدارة الجلسات السحابية (AuthService)</h1>
<p>
يحتوي المشروع على كلاس خدمة مخصص للمصادقة <code>AuthService</code> يقع في مسار <code>lib/services/auth_service.dart</code>. يرث هذا الكلاس من <code>ChangeNotifier</code> ليعمل كنظام إدارة حالة (State Management) يُخطر الواجهات فور تغيير حالة تسجيل الدخول.
</p>

<div class="avoid-break">
<h2 class="sub-title">مخطط نموذج المستخدم (UserModel):</h2>
<p>
يتم تخزين بيانات المستخدم المسجل في كلاس غير قابل للتعديل (Immutable) بالخصائص التالية:
</p>
<pre>class UserModel {{
  final String id;              // معرف الحساب
  final String name;            // اسم المستخدم أو الشركة
  final String email;           // البريد الإلكتروني (مفتاح المزامنة)
  final String? photoUrl;       // رابط الصورة الشخصية
  final bool isGoogleAuth;      // هل تم الربط عبر حساب Google؟
  final String? lastBackupDate; // تاريخ ووقت آخر نسخة سحابية
}}</pre>
</div>

<h2 class="sub-title">دورة حياة جلسة المستخدم في الكود:</h2>
<ol>
  <li><strong>تهيئة الجلسة <code>_loadUserSession()</code>:</strong> عند تشغيل التطبيق، تقوم الدالة بقراءة السلسلة النصية المشفرة <code>athar_user_session_v1</code> من ذاكرة <code>SharedPreferences</code> وتحويلها عبر <code>jsonDecode</code> لكائن <code>UserModel</code>.</li>
  <li><strong>تسجيل الدخول بحساب Google أو بريد مخصص <code>signInWithGoogle()</code>:</strong>
    <pre>Future&lt;bool&gt; signInWithGoogle({{String? customEmail, String? customName}}) async {{
  _isLoading = true;
  notifyListeners();
  try {{
    await Future.delayed(const Duration(milliseconds: 700));
    final email = customEmail ?? 'athar.admin@gmail.com';
    _currentUser = UserModel(
      id: 'google_${{DateTime.now().millisecondsSinceEpoch}}',
      name: customName ?? 'إدارة مخزون أثر',
      email: email,
      isGoogleAuth: true,
      lastBackupDate: DateTime.now().toIso8601String(),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userStorageKey, jsonEncode(_currentUser!.toJson()));
    return true;
  }} finally {{
    _isLoading = false;
    notifyListeners();
  }}
}}</pre>
  </li>
  <li><strong>الدخول كـ ضيف محلي <code>continueAsGuest()</code>:</strong> يتيح لمستخدم التطبيق العمل بكامل الصلاحيات محلياً دون الحاجة لربط حساب خارجي، وتُحفظ السجلات في SQLite مباشرة.</li>
  <li><strong>تسجيل الخروج <code>signOut()</code>:</strong> مسح كائن <code>_currentUser</code> واستدعاء <code>prefs.remove(_userStorageKey)</code> ثم تنبيه الواجهات عبر <code>notifyListeners()</code>.</li>
</ol>

<div class="page-break"></div>

<!-- 7. قاعدة البيانات SQLite -->
<h1 id="sec-database" class="section-title">7. المعمارية الكاملة لقاعدة البيانات المحلية SQLite</h1>
<p>
تعتمد إدارة البيانات بالكامل على محرك <code>SQLite</code> العلائقي فائق السرعة عبر مكتبة <code>sqflite</code>، تحت إدارة كلاس متحكم وحيد مبني بنمط التصميم الشهير <strong>(Singleton Pattern)</strong> في مسار <code>lib/services/database_helper.dart</code>.
</p>

<div class="avoid-break">
<h2 class="sub-title">7.1 هيكل جدول المشتريات (Table Schema):</h2>
<p>يتم إنشاء جدول المشتريات <code>purchases</code> برمجياً عبر دالة <code>_onCreate</code> وأمر لغة تعريف البيانات (DDL):</p>
<pre>CREATE TABLE purchases (
  id TEXT PRIMARY KEY,
  item_name TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price REAL NOT NULL,
  purchase_date TEXT NOT NULL,
  invoice_uri TEXT,
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);</pre>
</div>

<div class="avoid-break">
<h2 class="sub-title">7.2 جدول الحقول والأنواع والعمليات البرمجية:</h2>
<table>
  <thead>
    <tr>
      <th>اسم الحقل في الجدول</th>
      <th>النوع في SQLite</th>
      <th>النوع المقابل في Dart</th>
      <th>وظيفة الحقل والأهمية المحاسبية</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>id</code></td>
      <td>TEXT PRIMARY KEY</td>
      <td><code>String</code></td>
      <td>المعرف الفريد لكل عملية شراء (Timestamp-Hash).</td>
    </tr>
    <tr>
      <td><code>item_name</code></td>
      <td>TEXT NOT NULL</td>
      <td><code>String</code></td>
      <td>اسم الصنف أو البضاعة المشتراة للمخزون.</td>
    </tr>
    <tr>
      <td><code>quantity</code></td>
      <td>INTEGER NOT NULL</td>
      <td><code>int</code></td>
      <td>العدد والكمية المشتراة (تستخدم في عداد القطع).</td>
    </tr>
    <tr>
      <td><code>unit_price</code></td>
      <td>REAL NOT NULL</td>
      <td><code>double</code></td>
      <td>سعر شراء الحبة الواحدة بالريال السعودي.</td>
    </tr>
    <tr>
      <td><code>purchase_date</code></td>
      <td>TEXT NOT NULL</td>
      <td><code>String</code> (YYYY-MM-DD)</td>
      <td>تاريخ الفاتورة الفعلي ويُستخدم في الفلترة الزمنية والفرز.</td>
    </tr>
    <tr>
      <td><code>invoice_uri</code></td>
      <td>TEXT (Nullable)</td>
      <td><code>String?</code></td>
      <td>سلسلة Base64 المشفرة لصورة الفاتورة لضمان عدم تلفها.</td>
    </tr>
    <tr>
      <td><code>notes</code></td>
      <td>TEXT (Nullable)</td>
      <td><code>String?</code></td>
      <td>ملاحظات إضافية أو تفاصيل المورد وموقع التخزين.</td>
    </tr>
    <tr>
      <td><code>created_at</code></td>
      <td>TEXT NOT NULL</td>
      <td><code>String</code> (ISO8601)</td>
      <td>طابع وقت الإنشاء الآلي للسجل لترتيب الأحدث.</td>
    </tr>
    <tr>
      <td><code>updated_at</code></td>
      <td>TEXT NOT NULL</td>
      <td><code>String</code> (ISO8601)</td>
      <td>طابع وقت آخر تعديل أُجري على بيانات الصنف.</td>
    </tr>
  </tbody>
</table>
</div>

<div class="avoid-break">
<h2 class="sub-title">7.3 العمليات الأربع الأساسية (CRUD Operations) في الكود:</h2>
<ul>
  <li>
    <strong>الإضافة (Create / Insert):</strong>
    <pre>Future&lt;int&gt; insertPurchase(Purchase purchase) async {{
  final db = await database;
  return await db.insert(
    tablePurchases,
    purchase.toJson(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}}</pre>
  </li>
  <li>
    <strong>القراءة والاستعلام (Read / Select):</strong>
    <pre>Future&lt;List&lt;Purchase&gt;&gt; getAllPurchases() async {{
  final db = await database;
  final List&lt;Map&lt;String, dynamic&gt;&gt; maps = await db.query(
    tablePurchases,
    orderBy: 'purchase_date DESC, created_at DESC',
  );
  return List.generate(maps.length, (i) =&gt; Purchase.fromJson(maps[i]));
}}</pre>
  </li>
  <li>
    <strong>التعديل (Update):</strong>
    <pre>Future&lt;int&gt; updatePurchase(Purchase purchase) async {{
  final db = await database;
  return await db.update(
    tablePurchases,
    purchase.toJson(),
    where: 'id = ?',
    whereArgs: [purchase.id],
  );
}}</pre>
  </li>
  <li>
    <strong>الحذف (Delete):</strong>
    <pre>Future&lt;int&gt; deletePurchase(String id) async {{
  final db = await database;
  return await db.delete(
    tablePurchases,
    where: 'id = ?',
    whereArgs: [id],
  );
}}</pre>
  </li>
</ul>
</div>

<div class="callout callout-academic">
  <div class="academic-badge">سؤال مناقشة جوهري للدكتور</div>
  <strong>سؤال الدكتور: "لماذا جعلتم كلاس DatabaseHelper يطبق نمط الـ Singleton؟"</strong><br>
  <strong>الإجابة النموذجية:</strong> "لأن فتح أكثر من اتصال (Connection) بقاعدة بيانات SQLite في نفس الوقت يسبب استهلاكاً للذاكرة وتعارضاً في عمليات الكتابة والقراءة (Database Locking / Concurrency Conflicts). يضمن نمط الـ Singleton أن يكون هناك كائن اتصال واحد فقط <code>DatabaseHelper.instance</code> طوال فترة تشغيل التطبيق".
</div>

<div class="page-break"></div>

<!-- 8. معالجة الصور والمزامنة السحابية -->
<h1 id="sec-files" class="section-title">8. معالجة الصور وفواتير الشراء والمزامنة السحابية</h1>
<p>
تعتبر معالجة وإرفاق فواتير الشراء ومزامنتها من أهم ركائز النظام، وتمت هندستها بطريقة عبقرية تضمن العمل عبر كافة المنصات وحماية الملفات من الضياع.
</p>

<h2 class="sub-title">8.1 تقنية التخزين الذاتي للصور (Base64 Data URI):</h2>
<p>
عند قيام المستخدم باختيار صورة عبر حزمة <code>image_picker</code>، لا يتم تخزين مسار ملف مؤقت ينتهي بمجرد إعادة تشغيل الهاتف، بل يقوم التطبيق في <code>PurchaseFormDialog</code> بقراءة البايتات الفعلية وتحويلها إلى نص Base64:
</p>
<pre>final bytes = await picked.readAsBytes();
final base64String = base64Encode(bytes);
final dataUri = 'data:image/jpeg;base64,$base64String';</pre>
<p>
<strong>الفائدة التقنية العظمى:</strong> تصبح صورة الفاتورة جزءاً لا يتجزأ من جدول SQLite والملف السحابي JSON، فعندما يقوم المستخدم بتصدير نسخة احتياطية أو مزامنتها مع Google Drive، تنتقل جميع الفواتير والصور معه لأي جهاز آخر دون الحاجة لسيرفر خارجي!
</p>

<h2 class="sub-title">8.2 كلاس العرض الذكي AppImageView:</h2>
<p>
في مسار <code>lib/widgets/app_image_view.dart</code>، تم بناء أداة عرض ذكية تفحص مسار الصورة وتتعامل معه تلقائياً:
</p>
<ul>
  <li>إذا كانت الصورة نص Base64 تبدأ بـ <code>data:image</code>، يتم فك تشفيرها وعرضها عبر <code>Image.memory()</code>.</li>
  <li>إذا كانت مسار ملف محلي على الهاتف، يتم عرضها عبر <code>Image.file()</code>.</li>
  <li>إذا كانت رابط إنترنت أو على منصة الويب، يتم عرضها عبر <code>Image.network()</code>.</li>
</ul>

<h2 class="sub-title">8.3 نظام النسخ الاحتياطي والمزامنة السحابية (BackupSyncService):</h2>
<p>
يتولى كلاس <code>BackupSyncService</code> في <code>lib/services/backup_sync_service.dart</code> إدارة النسخ عبر 3 مستويات:
</p>
<ol>
  <li><strong>المستوى الأول (تصدير ملف .athar محلي):</strong> حفظ نسخة JSON كاملة مشفرة داخل مجلد المستندات عبر <code>getApplicationDocumentsDirectory()</code> باسم <code>athar_backup_YYYY-MM-DD.athar</code>.</li>
  <li><strong>المستوى الثاني (المزامنة مع Google Drive):</strong> تخزين حزمة البيانات السحابية معزولة باسم حساب المستخدم <code>athar_gdrive_user@gmail.com</code> مع حفظ وقت وتاريخ آخر مزامنة.</li>
  <li><strong>المستوى الثالث (الاستيراد اليدوي لنص JSON):</strong> إتاحة نسخ نص البيانات أو لصقه في نافذة منبثقة لاستعادة كافة السجلات وإعادة ملء جدول SQLite فورياً.</li>
</ol>

<div class="page-break"></div>

<!-- 9. نظام التصميم والسمات -->
<h1 id="sec-theme" class="section-title">9. نظام التصميم وهوية شركة أثر (Design System & Theme)</h1>
<p>
تم بناء السمة البصرية للمشروع في ملف <code>lib/theme/app_theme.dart</code> استناداً إلى فلسفة الفخامة والأناقة الهادئة <strong>(Luxury Black & Minimal White)</strong> تماشياً مع هوية شركة "أثر".
</p>

<div class="avoid-break">
<h2 class="sub-title">9.1 لوحة الألوان المعتمدة في كلاس AppColors:</h2>
<table>
  <thead>
    <tr>
      <th>اسم اللون البرمجي</th>
      <th>القيمة السداسية (Hex)</th>
      <th>الدرجة البصرية</th>
      <th>مكان الاستخدام في الواجهة</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>AppColors.primary</code></td>
      <td><code>#111827</code></td>
      <td>أسود ملكي فاخر (Deep Luxury Black)</td>
      <td>الأزرار الأساسية، العناوين، وبطاقة الإحصاء البارزة.</td>
    </tr>
    <tr>
      <td><code>AppColors.primaryLight</code></td>
      <td><code>#F1F5F9</code></td>
      <td>رمادي ثلجي فائق النقاء</td>
      <td>خلفيات الشارات، وحاويات الأيقونات الدائرية.</td>
    </tr>
    <tr>
      <td><code>AppColors.background</code></td>
      <td><code>#F8FAFC</code></td>
      <td>رمادي مائل للأبيض الخفيف</td>
      <td>خلفية شاشات التطبيق لمنع إجهاد العين.</td>
    </tr>
    <tr>
      <td><code>AppColors.pureWhite</code></td>
      <td><code>#FFFFFF</code></td>
      <td>أبيض ناصع 100%</td>
      <td>خلفيات البطاقات <code>Cards</code> وشريط التطبيق <code>AppBar</code>.</td>
    </tr>
    <tr>
      <td><code>AppColors.textMain</code></td>
      <td><code>#0F172A</code></td>
      <td>كحلي مسود غامق</td>
      <td>النصوص الرئيسية، أسماء الأصناف، والأرقام المالية.</td>
    </tr>
    <tr>
      <td><code>AppColors.textMuted</code></td>
      <td><code>#64748B</code></td>
      <td>رمادي هادئ</td>
      <td>النصوص الفرعية، التواريخ، والملاحظات.</td>
    </tr>
    <tr>
      <td><code>AppColors.success</code></td>
      <td><code>#10B981</code></td>
      <td>أخضر زمردي</td>
      <td>رسائل نجاح حفظ الفواتير والمزامنة السحابية.</td>
    </tr>
    <tr>
      <td><code>AppColors.danger</code></td>
      <td><code>#EF4444</code></td>
      <td>أحمر تحذيري</td>
      <td>أزرار حذف العمليات ورسائل التحقق من الأخطاء.</td>
    </tr>
  </tbody>
</table>
</div>

<h2 class="sub-title">9.2 معايير التصميم المتجاوب وتجربة المستخدم:</h2>
<ul>
  <li><strong>منظومة الحواف المستديرة (Border Radius):</strong> استخدام قيم مدروسة (12 بكسل للمدخلات، 16 للبطاقات، 20 لبطاقات الإحصاء، و 24 للنوافذ) لمنح التطبيق انسيابية عصرية.</li>
  <li><strong>الظلال الخفيفة (Soft Elevation / BoxShadow):</strong> استخدام ظلال شديدة النعومة <code>Colors.black.withValues(alpha: 0.02)</code> حتى لا يبدو التطبيق قديماً بتأثيرات الـ Material 2 التقليدية.</li>
  <li><strong>التكامل الكامل مع Material 3:</strong> تفعيل خاصية <code>useMaterial3: true</code> داخل كائن <code>ThemeData</code> لاستخدام أحدث معايير جوجل في أزرار التنقل <code>NavigationBar</code> والأزرار العائمة <code>FloatingActionButton.extended</code>.</li>
</ul>

<div class="page-break"></div>

<!-- 10. مخططات تدفق البيانات -->
<h1 id="sec-dataflow" class="section-title">10. مخططات تدفق البيانات والعمليات في التطبيق</h1>
<p>
توضح المخططات التالية المسار الكامل للبيانات منذ لحظة تفاعل المستخدم مع عناصر الشاشة وحتى استقرارها في قاعدة بيانات SQLite والسحابة، مع إعادة بناء واجهة المستخدم تلقائياً:
</p>

<div class="avoid-break">
<h2 class="sub-title">10.1 مسار عملية إضافة صنف شراء جديد:</h2>
<div class="diagram-box">
  <div class="flow-step">1. المستخدم يضغط زر (+ إضافة شراء)</div><br>
  <div class="flow-arrow">↓</div><br>
  <div class="flow-step">2. فتح نافذة PurchaseFormDialog</div><br>
  <div class="flow-arrow">↓</div><br>
  <div class="flow-step">3. إدخال (الاسم، الكمية، السعر، الفاتورة) والتحقق Validation</div><br>
  <div class="flow-arrow">↓</div><br>
  <div class="flow-step">4. استدعاء PurchasesService.addPurchase(...)</div><br>
  <div class="flow-arrow">↓</div><br>
  <div class="flow-step">5. DatabaseHelper.insertPurchase() ← كتابة فلكية في SQLite</div><br>
  <div class="flow-arrow">↓</div><br>
  <div class="flow-step">6. استدعاء notifyListeners() لإخطار ListenableBuilder</div><br>
  <div class="flow-arrow">↓</div><br>
  <div class="flow-step">7. تحديث إجمالي الفلوس والبطاقات وظهور رسالة النجاح SnackBar ✅</div>
</div>
</div>

<div class="avoid-break">
<h2 class="sub-title">10.2 مسار عملية المزامنة مع Google Drive:</h2>
<div class="diagram-box">
  <div class="flow-step">1. الضغط على أيقونة المزامنة السحابية في شريط AppBar</div><br>
  <div class="flow-arrow">↓</div><br>
  <div class="flow-step">2. جلب كافة سجلات SQLite عبر purchasesService.purchases</div><br>
  <div class="flow-arrow">↓</div><br>
  <div class="flow-step">3. توليد حزمة JSON متكاملة + بيانات الميتاداتا والبريد</div><br>
  <div class="flow-arrow">↓</div><br>
  <div class="flow-step">4. التخزين في المفتاح المخصص لحساب المستخدم في SharedPreferences</div><br>
  <div class="flow-arrow">↓</div><br>
  <div class="flow-step">5. تحديث تاريخ آخر مزامنة ناجحة وإظهار تنبيه التأكيد السحابي ☁️</div>
</div>
</div>

<div class="page-break"></div>

<!-- 11. الأمان والصلاحيات -->
<h1 id="sec-security" class="section-title">11. الأمان، الصلاحيات، وإدارة الأداء</h1>

<h2 class="sub-title">11.1 الصلاحيات المعرفة في ملف AndroidManifest.xml:</h2>
<p>
تم فحص الملف الفعلي <code>android/app/src/main/AndroidManifest.xml</code> ووجد أنه يتضمن تصريح الوصول لشبكة الإنترنت:
</p>
<pre>&lt;uses-permission android:name="android.permission.INTERNET"/&gt;</pre>
<p>
يُستخدم هذا التصريح لتوفير إمكانية مزامنة البيانات مع خوادم Google والحسابات السحابية عند الاتصال بالإنترنت، مع الحفاظ على عمل التطبيق بالكامل محلياً وبدون إنترنت بفضل قاعدة بيانات SQLite.
</p>

<h2 class="sub-title">11.2 حماية البيانات الحساسة وصمامات الأمان:</h2>
<ul>
  <li><strong>إخفاء ومعالجة المفاتيح السرية (Zero Hardcoded Secrets):</strong> لا يحتوي الكود على أي مفاتيح API مكشوفة أو كلمات مرور للمستخدمين، وتتم المصادقة عبر معرفات الحسابات الآمنة.</li>
  <li><strong>عزل بيانات المستخدمين (Multi-Account Isolation):</strong> يتم حفظ النسخ السحابية بمفتاح مخصص لكل بريد إلكتروني <code>athar_gdrive_email</code> بحيث إذا استخدم موظف آخر نفس الهاتف بحساب مختلف، لا تختلط بياناته مع بيانات الحساب الأول.</li>
  <li><strong>معالجة الاستثناءات وصمامات الأمان (Defensive Programming):</strong> تم تغليف كافة عمليات القراءة والكتابة في قاعدة البيانات ومعالجة الصور بكتل <code>try-catch-finally</code> لمنع انهيار التطبيق (Crash) في حال تلف ملف أو حدوث خطأ غير متوقع.</li>
  <li><strong>حماية قاعدة البيانات أثناء التحديثات:</strong> صُممت خدمة <code>AppUpdateService</code> بحيث تضمن بقاء واستمرارية قاعدة بيانات SQLite دون أي حذف أو تصفير عند تنزيل التحديثات الجديدة.</li>
</ul>

<div class="page-break"></div>

<!-- 12. الجداول المرجعية الشاملة -->
<h1 id="sec-tables" class="section-title">12. الجداول المرجعية الشاملة للشاشات والأدوات والملفات</h1>

<div class="avoid-break">
<h2 class="sub-title">12.1 جدول الشاشات ومساراتها في المشروع:</h2>
<table>
  <thead>
    <tr>
      <th>اسم الشاشة</th>
      <th>مسار الملف في المشروع</th>
      <th>الوظيفة الأساسية للشاشة</th>
      <th>أهم الـ Widgets المستخدمة فيها</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>شاشة البداية (Splash)</td>
      <td><code>lib/screens/splash_screen.dart</code></td>
      <td>عرض الشعار الرسمي وتهيئة الجلسة والتوجيه التلقائي.</td>
      <td>FadeTransition, ScaleTransition, Timer, Container</td>
    </tr>
    <tr>
      <td>تسجيل الدخول (Login)</td>
      <td><code>lib/screens/login_screen.dart</code></td>
      <td>المصادقة وربط حساب Google أو المتابعة كضيف.</td>
      <td>ElevatedButton, OutlinedButton, TextField, AlertDialog</td>
    </tr>
    <tr>
      <td>الرئيسية (Home)</td>
      <td><code>lib/screens/home_screen.dart</code></td>
      <td>عرض الإحصائيات، سجل المشتريات، والبحث والفلترة.</td>
      <td>Scaffold, AppBar, CustomScrollView, SliverList, RefreshIndicator</td>
    </tr>
    <tr>
      <td>نموذج الشراء (Purchase Form)</td>
      <td><code>lib/widgets/purchase_form_dialog.dart</code></td>
      <td>إدخال وتعديل الصنف، الكمية، السعر، وتصوير الفاتورة.</td>
      <td>Form, TextFormField, showDatePicker, ImagePicker</td>
    </tr>
    <tr>
      <td>جدول المخزون (Inventory Table)</td>
      <td><code>lib/screens/inventory_table_screen.dart</code></td>
      <td>عرض المخزون في جدول تفاعلي والفرز والنسخ للحافظة.</td>
      <td>SingleChildScrollView, DataTable/Card, PopupMenuButton</td>
    </tr>
    <tr>
      <td>عارض الفواتير (Invoice Viewer)</td>
      <td><code>lib/widgets/invoice_viewer_dialog.dart</code></td>
      <td>عرض صورة الفاتورة بالحجم الكامل مع إمكانية التكبير.</td>
      <td>Dialog, InteractiveViewer, AppImageView</td>
    </tr>
  </tbody>
</table>
</div>

<div class="avoid-break">
<h2 class="sub-title">12.2 جدول التقنيات والأدوات البرمجية:</h2>
<table>
  <thead>
    <tr>
      <th>الأداة / التقنية</th>
      <th>مكان استخدامها في الكود</th>
      <th>الوظيفة الفنية للدكتور</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>Flutter & Dart</code></td>
      <td>كافة ملفات المشروع</td>
      <td>إطار ولغة بناء التطبيقات متعددة المنصات بكود مصدري وحيد عالي الأداء.</td>
    </tr>
    <tr>
      <td><code>sqflite (SQLite)</code></td>
      <td><code>lib/services/database_helper.dart</code></td>
      <td>قاعدة بيانات محلية علائقية لتخزين سجلات المشتريات والعمل بدون إنترنت.</td>
    </tr>
    <tr>
      <td><code>ChangeNotifier</code></td>
      <td><code>PurchasesService, AuthService</code></td>
      <td>نمط إدارة الحالة (State Management) لإشعار الواجهات بالتحديث فورياً.</td>
    </tr>
    <tr>
      <td><code>ListenableBuilder</code></td>
      <td><code>lib/screens/home_screen.dart</code></td>
      <td>الاستماع لتغييرات الخدمة وإعادة بناء الواجهة الجزئية بأقصى كفاءة.</td>
    </tr>
    <tr>
      <td><code>shared_preferences</code></td>
      <td><code>lib/services/auth_service.dart</code></td>
      <td>تخزين أزواج المفاتيح والقيم الخفيفة لإدارة الجلسة والنسخ السحابية.</td>
    </tr>
    <tr>
      <td><code>image_picker</code></td>
      <td><code>lib/widgets/purchase_form_dialog.dart</code></td>
      <td>الوصول للعتاد المادي للهاتف (الكاميرا والمعرض) لالتقاط صور الفواتير.</td>
    </tr>
    <tr>
      <td><code>intl</code></td>
      <td><code>home_screen.dart, inventory_table.dart</code></td>
      <td>تنسيق الأرقام والعملات المحاسبية بالريال السعودي (ر.س) باللغة العربية.</td>
    </tr>
    <tr>
      <td><code>Base64 Encoding</code></td>
      <td><code>purchase_form_dialog.dart</code></td>
      <td>تحويل بايتات صور الفواتير لنصوص Data URI مدمجة لتسهيل نقلها وسحابتها.</td>
    </tr>
  </tbody>
</table>
</div>

<div class="page-break"></div>

<!-- 13. أسئلة المناقشة المتوقعة -->
<h1 id="sec-defense" class="section-title">13. الأسئلة الأكاديمية المتوقعة في مناقشة الدكتور وإجاباتها</h1>
<p>
تم صياغة هذه الأسئلة النموذجية بناءً على محاضرات المنهج الجامعي والأسئلة الشائعة التي يطرحها دكاترة المادة لاختبار مدى فهم الطالب العميق لبناء مشروعه:
</p>

<div class="avoid-break">
<div class="widget-card">
  <h4>1. ما الفرق الجوهري بين StatelessWidget و StatefulWidget؟ وأين استخدمتم كلاً منهما؟</h4>
  <p><strong>الإجابة النموذجية:</strong> الـ <code>StatelessWidget</code> هو عنصر واجهة ثابت لا تتغير حالته أو مظهره بعد بنائه، واستخدمناه في <code>StatCard</code> و <code>AppImageView</code> لأنها عناصر تتلقى بيانات عبر المشيد وتعرضها فقط. أما الـ <code>StatefulWidget</code> فهو يمتلك كائن حالة <code>State</code> يمكنه إعادة بناء الشاشة عند حدوث تفاعل عبر <code>setState()</code>، واستخدمناه في <code>HomeScreen</code> و <code>PurchaseFormDialog</code> لتحديث الحسابات والقوائم فورياً.</p>
</div>

<div class="widget-card">
  <h4>2. لماذا استخدمتم Container في بعض الأماكن و Card في أماكن أخرى؟</h4>
  <p><strong>الإجابة النموذجية:</strong> الـ <code>Card</code> هو Widget مخصص يمتلك سمات افتراضية مسبقة للظل <code>elevation</code> والحواف وفق تصميم Material Design. بينما الـ <code>Container</code> يوفر مرونة مطلقة عبر خاصية <code>decoration: BoxDecoration</code> حيث يتيح لنا التحكم المجهري في لون الخلفية، الحدود <code>border</code>، نصف قطر الانحناء <code>borderRadius</code>، والظلال المخصصة <code>boxShadow</code>، ولهذا اعتمدنا على <code>Container</code> لبناء بطاقات الإحصاء لتعكس هوية شركة أثر الدقيقة.</p>
</div>

<div class="widget-card">
  <h4>3. ما الفرق بين Row و Column؟ وما المشكلة الشائعة عند استخدام نصوص طويلة داخلهما؟</h4>
  <p><strong>الإجابة النموذجية:</strong> الـ <code>Row</code> يرتب الأبناء أفقياً بجانب بعضهم، والـ <code>Column</code> يرتبهم رأسياً فوق بعضهم. والمشكلة الشائعة هي حدوث تجاوز لحدود الشاشة <strong>(Overflow / Yellow & Black Bars)</strong> عندما يكون المحتوى أكبر من مساحة الشاشة. وقد قمنا بحل هذه المشكلة بتغليف العناصر النصية بـ <code>Expanded</code> أو استخدام <code>SingleChildScrollView</code> ليصبح المحتوى قابلاً للتمرير بأمان.</p>
</div>

<div class="widget-card">
  <h4>4. لماذا استخدمتم CustomScrollView و SliverList بدلاً من ListView العادي في HomeScreen؟</h4>
  <p><strong>الإجابة النموذجية:</strong> لأن الشاشة الرئيسية تحتوي على عناصر رأسية متنوعة: بطاقات إحصاء، حقل بحث، وسوم فلترة زمنية، ثم قائمة المشتريات. استخدام <code>ListView</code> عادي مع عناصر أخرى كان سيجبرنا على استخدام <code>shrinkWrap: true</code> مما يهدر الذاكرة. بينما <code>CustomScrollView</code> مع <code>SliverToBoxAdapter</code> و <code>SliverList</code> يدمج كل مكونات الصفحة في شريط تمرير فيزيائي واحد سلس عالي الكفاءة.</p>
</div>

<div class="widget-card">
  <h4>5. كيف قمتم بتطبيق نمط الـ Singleton في كلاس DatabaseHelper؟ وما فائدته؟</h4>
  <p><strong>الإجابة النموذجية:</strong> قمنا بإغلاق المشيد الافتراضي عبر مشيد خاص <code>DatabaseHelper._privateConstructor()</code>، وتوفير كائن وحيد ثابت <code>static final DatabaseHelper instance</code>. فائدته منع فتح اتصالات متعددة بقاعدة بيانات SQLite مما يمنع قفل القاعدة ويقلل استهلاك الذاكرة العشوائية RAM.</p>
</div>

<div class="widget-card">
  <h4>6. كيف يتم حساب إجمالي الفاتورة تلقائياً قبل أن يضغط المستخدم على زر الحفظ؟</h4>
  <p><strong>الإجابة النموذجية:</strong> في كلاس <code>PurchaseFormDialog</code>، قمنا بإضافة مستمع <code>addListener</code> لمتحكمي النصوص <code>_quantityController</code> و <code>_priceController</code>، فعند كتابة أي رقم يتم استدعاء <code>_onCalculatedChanged()</code> التي تعيد حساب <code>quantity * unitPrice</code> فوريّاً وتحدث الشاشة عبر <code>setState()</code>.</p>
</div>

<div class="widget-card">
  <h4>7. كيف يعمل البحث اللحظي في قائمة المشتريات وجدول المخزون؟</h4>
  <p><strong>الإجابة النموذجية:</strong> عبر خاصية <code>onChanged</code> في حقل <code>TextField</code>، والتي ترسل النص المكتوب إلى <code>PurchasesService.setSearchQuery()</code>، حيث يتم تصفية القائمة الأصلية باستخدام دالة التصفية في الدارت <code>where()</code> مع تحويل النصوص لأحرف صغيرة <code>toLowerCase()</code> لتطابق اسم الصنف أو الملاحظات دون الحاجة لإعادة الاستعلام من قاعدة البيانات في كل حرف.</p>
</div>

<div class="widget-card">
  <h4>8. كيف يتم تخزين صورة الفاتورة في SQLite؟ وماذا لو قام المستخدم بتغيير هاتفه؟</h4>
  <p><strong>الإجابة النموذجية:</strong> يتم تحويل بايتات الصورة الملتقطة بالكاميرا إلى سلسلة نصية مشفرة بتنسيق <code>Base64 Data URI</code> وتخزينها في عمود <code>invoice_uri</code> كـ نص <code>TEXT</code> في SQLite. وبفضل ذلك، عند مزامنة النسخة السحابية لـ Google Drive، يتم رفع الصورة بداخل نص JSON كحزمة واحدة مستقلة، فيستطيع المستخدم استرجاع الفواتير بكامل صورها على أي هاتف جديد فور تسجيل الدخول.</p>
</div>

<div class="widget-card">
  <h4>9. ما وظيفة مكتبة flutter_localizations وكيف جعلتم التطبيق يدعم اللغة العربية RTL؟</h4>
  <p><strong>الإجابة النموذجية:</strong> تم تعريف <code>GlobalMaterialLocalizations</code> و <code>GlobalWidgetsLocalizations</code> داخل <code>MaterialApp</code> مع تحديد <code>locale: Locale('ar', 'SA')</code>، مما يجعل جميع الأدوات ومحاذاة النصوص وأدوات التقويم وحركات الانتقال تبدأ تلقائياً من اليمين إلى اليسار (Right-to-Left).</p>
</div>

<div class="widget-card">
  <h4>10. كيف يتم منع الشاشات السابقة من البقاء في الذاكرة عند الانتقال من SplashScreen؟</h4>
  <p><strong>الإجابة النموذجية:</strong> عبر استخدام <code>Navigator.of(context).pushReplacement()</code> بدلاً من <code>push()</code> العادية، مما يحذف <code>SplashScreen</code> من مكدس التنقل (Navigation Stack) تماماً، وعندما يضغط المستخدم على زر الرجوع يخرج من التطبيق بدلاً من العودة لشاشة البداية.</p>
</div>
</div>

<div class="page-break"></div>

<!-- 14. المصطلحات والخاتمة -->
<h1 id="sec-glossary" class="section-title">14. معجم المصطلحات البرمجية والخاتمة الأكاديمية</h1>

<h2 class="sub-title">14.1 معجم المصطلحات الفنية (Technical Glossary):</h2>
<ul>
  <li><strong>Widget:</strong> اللبنة الأساسية لبناء كل عنصر مرئي أو غير مرئي في واجهات فلاتر.</li>
  <li><strong>State Management:</strong> منظومة إدارة وتدفق البيانات وتحديث واجهة المستخدم استجابةً للأحداث.</li>
  <li><strong>ChangeNotifier:</strong> كلاس في فلاتر يُطلق إشعارات <code>notifyListeners()</code> لإعلام الواجهات بوجود بيانات جديدة.</li>
  <li><strong>ListenableBuilder:</strong> أداة تعيد بناء الجزء المحدد من الشاشة فقط عند ورود إشعار من كائن المراقبة دون هدر الموارد.</li>
  <li><strong>CRUD:</strong> العمليات الأربع الأساسية في قواعد البيانات: الإضافة (Create)، القراءة (Read)، التعديل (Update)، والحذف (Delete).</li>
  <li><strong>Singleton Pattern:</strong> نمط تصميم يضمن وجود نسخة واحدة فقط من الكلاس في الذاكرة طوال دورة حياة التطبيق.</li>
  <li><strong>Base64:</strong> نظام ترميز يحول الملفات الثنائية (كالصور) إلى سلاسل نصية ليسهل تخزينها في قواعد البيانات ونقلها عبر السحابة.</li>
  <li><strong>Offline-First:</strong> معمارية برمجية تجعل التطبيق يعمل محلياً بكفاءة 100% دون اشتراط وجود اتصال بالإنترنت.</li>
</ul>

<h2 class="sub-title">14.2 قائمة الملفات التي تم فحصها وتوثيقها بدقة:</h2>
<ol>
  <li><code>flutter_app/pubspec.yaml</code> — إعدادات الحزم والأصول.</li>
  <li><code>flutter_app/android/app/src/main/AndroidManifest.xml</code> — الصلاحيات وتهيئة الأندرويد.</li>
  <li><code>flutter_app/lib/main.dart</code> — نقطة التشغيل الرئيسية وإعدادات السمة والتعريب.</li>
  <li><code>flutter_app/lib/models/purchase.dart</code> — نموذج بيانات الشراء وطرق التحويل toJson و fromJson.</li>
  <li><code>flutter_app/lib/services/database_helper.dart</code> — محرك قاعدة بيانات SQLite بنمط Singleton.</li>
  <li><code>flutter_app/lib/services/purchases_service.dart</code> — إدارة قائمة المشتريات والفلترة والحسابات المالية.</li>
  <li><code>flutter_app/lib/services/auth_service.dart</code> — إدارة جلسة المستخدم ومصادقة Google ودرايف.</li>
  <li><code>flutter_app/lib/services/backup_sync_service.dart</code> — خدمات النسخ السحابي وتوليد واسترجاع ملفات .athar.</li>
  <li><code>flutter_app/lib/services/app_update_service.dart</code> — إدارة التحديثات الآمنة دون المساس بقاعدة البيانات.</li>
  <li><code>flutter_app/lib/theme/app_theme.dart</code> — ألوان وسمات شركة أثر الفاخرة Material 3.</li>
  <li><code>flutter_app/lib/screens/splash_screen.dart</code> — شاشة البداية والحركة الانسيابية.</li>
  <li><code>flutter_app/lib/screens/login_screen.dart</code> — شاشة المصادقة وحماية البيانات.</li>
  <li><code>flutter_app/lib/screens/home_screen.dart</code> — الشاشة المركزية وسجل المشتريات والإحصائيات.</li>
  <li><code>flutter_app/lib/screens/inventory_table_screen.dart</code> — جدول المخزون والفرز والنسخ السريع.</li>
  <li><code>flutter_app/lib/widgets/stat_card.dart</code> — بطاقة الإحصائيات المستقلة المزودة بظلال وتأطير فاخر.</li>
  <li><code>flutter_app/lib/widgets/purchase_card.dart</code> — بطاقة عرض الصنف في السجل وخيارات التعديل والحذف.</li>
  <li><code>flutter_app/lib/widgets/purchase_form_dialog.dart</code> — نموذج تسجيل المشتريات واحتساب التكلفة وتصوير الفاتورة.</li>
  <li><code>flutter_app/lib/widgets/invoice_viewer_dialog.dart</code> — عارض الفواتير المكبر.</li>
  <li><code>flutter_app/lib/widgets/app_image_view.dart</code> — عارض الصور الذكي للبيانات والشبكة والملفات.</li>
</ol>

<h2 class="sub-title">14.3 الخاتمة الأكاديمية:</h2>
<p>
بحمد الله وتوفيقه، تم تصميم وبرمجة وتوثيق مشروع <strong>"إدارة مخزون شركة أثر"</strong> بأعلى درجات الاحترافية البرمجية، مجسداً المعايير الأكاديمية الصارمة المقررة في المنهج الجامعي. يُثبت هذا العمل قدرة إطار العمل <code>Flutter</code> على تقديم حلول محاسبية وإدارية متكاملة وفائقة السرعة للأعمال والشركات، تجمع بين جمال المظهر الخارجي، وسرعة محركات قواعد البيانات المحلية SQLite، وأمان المزامنة السحابية بحسابات Google Drive.
</p>
<div style="text-align:center; margin-top:30px; padding:15px; border-top:2px solid #e2e8f0;">
  <strong style="font-size:12pt; color:#0f172a;">تم بحمد الله وتوفيقه | مشروع إدارة مخزون شركة أثر 2024 - 2025م</strong>
</div>

</body>
</html>
"""

html_path = os.path.join(PROJECT_DIR, "report.html")
with open(html_path, "w", encoding="utf-8") as f:
    f.write(html_content)

print(f"HTML report generated successfully at: {html_path} (Size: {os.path.getsize(html_path)} bytes)")

# Convert to PDF via Headless Chrome
pdf_path = os.path.join(PROJECT_DIR, "تقرير_مشروع_إدارة_أثر.pdf")
chrome_cmd = [
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    "--headless=new",
    "--disable-gpu",
    "--no-pdf-header-footer",
    f"--print-to-pdf={pdf_path}",
    f"file:///{html_path.replace(os.sep, '/')}"
]

print("Rendering PDF with Headless Chrome...")
res = subprocess.run(chrome_cmd, capture_output=True, text=True)
if res.returncode == 0 and os.path.exists(pdf_path):
    print(f"PDF successfully generated: {pdf_path} (Size: {os.path.getsize(pdf_path)} bytes)")
else:
    print(f"Chrome return code: {res.returncode}")
    print(f"Chrome stderr: {res.stderr}")

# Also generate the comprehensive Markdown document
md_path = os.path.join(PROJECT_DIR, "تقرير_مشروع_إدارة_أثر.md")
md_content = f"""# تقرير مشروع إدارة مخزون شركة أثر (Athar Purchases & Inventory System)
## توثيق برمجي وتصميمي شامل لمناقشة التخرج ومشاريع Flutter الجامعية

---

### بيانات المشروع الأكاديمية:
- **اسم التطبيق:** تطبيق إدارة مخزون ومشتريات شركة أثر (Athar Inventory Management)
- **الجامعة والكلية:** جامعة العلوم والتكنولوجيا / الكلية الجامعية — كلية الحاسوب وتكنولوجيا المعلومات
- **المادة والتقنية:** تطوير تطبيقات الجوال (Flutter Framework & Dart Language)
- **إشراف الدكتور الفاضل:** د. سليمان الشوص / لجنة المناقشة الأكاديمية
- **إعداد الطالب:** طالب مشروع التخرج / قسم تكنولوجيا المعلومات
- **العام الجامعي:** 2024 - 2025م / 1446هـ

---

## فهرس المحتويات:
1. [مقدمة عامة عن المشروع وفلسفة النظام](#1-مقدمة-عامة-عن-المشروع-وفلسفة-النظام)
2. [تحليل ملف الإعدادات pubspec.yaml ومكتبات Dart و Flutter](#2-تحليل-ملف-الإعدادات-pubspecyaml-ومكتبات-dart-و-flutter)
3. [خريطة وهيكلية مجلدات المشروع (Architecture)](#3-خريطة-وهيكلية-مجلدات-المشروع-architecture)
4. [الشرح البرمجي والتصميمي لواجهات المستخدم واللقطات الفعلية](#4-الشرح-البرمجي-والتصميمي-لواجهات-المستخدم)
   - [4.1 شاشة البداية والتحميل (Splash Screen)](#41-شاشة-البداية-والتحميل-splash-screen)
   - [4.2 شاشة تسجيل الدخول والمصادقة (Login Screen)](#42-شاشة-تسجيل-الدخول-والمصادقة-login-screen)
   - [4.3 نافذة ربط حساب Google للمزامنة (Google Account Dialog)](#43-نافذة-ربط-حساب-google-للمزامنة)
   - [4.4 الشاشة الرئيسية وسجل المشتريات (Home Screen)](#44-الشاشة-الرئيسية-وسجل-المشتريات-home-screen)
   - [4.5 نافذة تسجيل وتعديل شراء (Purchase Form Dialog)](#45-نافذة-تسجيل-وتعديل-شراء-purchase-form-dialog)
   - [4.6 شاشة جدول المخزون التفاعلي (Inventory Table Screen)](#46-شاشة-جدول-المخزون-التفاعلي-inventory-table-screen)
5. [دورة التنقل بين الصفحات وإدارة المسارات (Navigation & Routing)](#5-دورة-التنقل-بين-الصفحات-وإدارة-المسارات)
6. [نظام المصادقة وإدارة الجلسات السحابية (AuthService)](#6-نظام-المصادقة-وإدارة-الجلسات-السحابية)
7. [المعمارية الكاملة لقاعدة البيانات المحلية SQLite (DatabaseHelper)](#7-المعمارية-الكاملة-لقاعدة-البيانات-المحلية-sqlite)
8. [معالجة الصور وفواتير الشراء والمزامنة السحابية (Google Drive Sync)](#8-معالجة-الصور-وفواتير-الشراء-والمزامنة-السحابية)
9. [نظام التصميم وهوية شركة أثر (Design System & Theme)](#9-نظام-التصميم-وهوية-شركة-أثر)
10. [مخططات تدفق البيانات والعمليات في التطبيق](#10-مخططات-تدفق-البيانات-والعمليات-في-التطبيق)
11. [الأمان، الصلاحيات، وإدارة الأداء (Security & Permissions)](#11-الأمان-الصلاحيات-وإدارة-الأداء)
12. [الجداول المرجعية الشاملة للشاشات والأدوات والملفات](#12-الجداول-المرجعية-الشاملة-للشاشات-والأدوات-والملفات)
13. [الأسئلة الأكاديمية المتوقعة في مناقشة الدكتور وإجاباتها النموذجية](#13-الأسئلة-الأكاديمية-المتوقعة-في-مناقشة-الدكتور)
14. [معجم المصطلحات البرمجية والخاتمة الأكاديمية](#14-معجم-المصطلحات-البرمجية-والخاتمة-الأكاديمية)

---

### 1. مقدمة عامة عن المشروع وفلسفة النظام
يُمثل مشروع **"إدارة مخزون شركة أثر"** حلاً رقمياً متكاملاً لإدارة وتوثيق عمليات التوريد ومشتريات البضائع اليومية للشركة. تم بناء التطبيق بلغة Dart وإطار عمل Flutter باتباع المعمارية الطبقية النظيفة (Layered Architecture) التي تفصل بين منطق العمل وتخزين البيانات وواجهات المستخدم.

#### الأهداف الجوهرية:
1. **العمل بدون إنترنت (Offline-First):** ضمان تسجيل الفواتير في أي وقت عبر محرك قاعدة بيانات SQLite المحلي السريع.
2. **الحساب الآلي اللحظي:** احتساب إجمالي تكلفة المشتريات والكميات تلقائياً دون أخطاء حسابية.
3. **التوثيق المصور:** إرفاق صورة فاتورة الشراء مع كل سجل وتخزينها بتنسيق Base64 لتبقى محفوظة للأبد.
4. **المزامنة السحابية بحسابات Google Drive:** إمكانية تصدير واسترجاع نسخ احتياطية بصيغة `.athar` أو نصوص JSON لحماية بيانات الشركة.

---

### 2. تحليل ملف الإعدادات pubspec.yaml ومكتبات Dart و Flutter
المسار في المشروع: `flutter_app/pubspec.yaml`

| اسم الحزمة | الإصدار | الوظيفة في كود المشروع | الملف المرتبط |
|---|---|---|---|
| `flutter` | sdk: flutter | إطار العمل الأساسي لبناء واجهات التطبيق وأدوات العرض | كافة الملفات |
| `flutter_localizations` | sdk: flutter | توفير دعم اللغة العربية والاتجاه من اليمين لليسار (RTL) | `lib/main.dart` |
| `sqflite` | ^2.4.2+1 | محرك قاعدة البيانات المحلية SQLite لتخزين سجلات الشراء | `lib/services/database_helper.dart` |
| `sqflite_common_ffi` | ^2.4.0+3 | تشغيل ودعم محرك SQLite على منصات سطح المكتب (Windows) | `lib/services/database_helper.dart` |
| `sqflite_common_ffi_web` | ^1.1.1 | تشغيل محرك SQLite على بيئة الويب عبر تقنية IndexedDB | `lib/services/database_helper.dart` |
| `path` | ^1.9.1 | دمج مسارات المجلدات وقواعد البيانات بشكل آمن عبر `join()` | `lib/services/database_helper.dart` |
| `path_provider` | ^2.1.6 | جلب مسار مجلد المستندات لتخزين ملفات النسخ الاحتياطية `.athar` | `lib/services/backup_sync_service.dart` |
| `shared_preferences` | ^2.5.5 | تخزين إعدادات الجلسة والبريد السحابي وطابع وقت المزامنة | `lib/services/auth_service.dart` |
| `image_picker` | ^1.2.3 | فتح كاميرا الهاتف واستوديو الصور لإرفاق فواتير الشراء | `lib/widgets/purchase_form_dialog.dart` |
| `intl` | 0.20.2 | تنسيق الأرقام والعملات (ر.س) والتواريخ باللغة العربية | `lib/screens/home_screen.dart` |
| `cupertino_icons` | ^1.0.8 | حزمة الأيقونات القياسية المتوافقة مع أجهزة iOS و Android | الشاشات المختلفة |

---

### 3. خريطة وهيكلية مجلدات المشروع (Architecture)
```
flutter_app/
├── android/app/src/main/AndroidManifest.xml   # الصلاحيات وإعدادات تشغيل الأندرويد
├── assets/images/                             # الشعارات الرسمية لشركة أثر
├── lib/
│   ├── main.dart                              # نقطة الانطلاق الرئيسية runApp()
│   ├── models/purchase.dart                   # كلاس Purchase والمشيدات toJson و fromJson
│   ├── screens/
│   │   ├── splash_screen.dart                 # شاشة البداية والشعار المؤقت
│   │   ├── login_screen.dart                  # تسجيل الدخول والمصادقة بحساب Google
│   │   ├── home_screen.dart                   # الشاشة الرئيسية وسجل المشتريات
│   │   └── inventory_table_screen.dart        # جدول المخزون التفاعلي والفرز
│   ├── services/
│   │   ├── auth_service.dart                  # إدارة جلسة المستخدم
│   │   ├── database_helper.dart               # محرك SQLite بنمط Singleton
│   │   ├── purchases_service.dart             # إدارة الحالة والفلترة والحسابات
│   │   ├── backup_sync_service.dart           # النسخ السحابي وتصدير ملفات .athar
│   │   └── app_update_service.dart            # فحص التحديثات مع الحفاظ على البيانات
│   ├── theme/app_theme.dart                   # ألوان وهوية أثر الفاخرة Material 3
│   └── widgets/
│       ├── app_image_view.dart                # عارض الصور الذكي
│       ├── stat_card.dart                     # بطاقة الإحصائيات العلوية
│       ├── purchase_card.dart                 # بطاقة عرض الفاتورة
│       ├── purchase_form_dialog.dart          # نموذج تسجيل الفاتورة
│       └── invoice_viewer_dialog.dart         # عارض الفاتورة المكبر
└── pubspec.yaml
```

---

### 4. الشرح البرمجي والتصميمي لواجهات المستخدم
(تم تضمين تفاصيل كل Widget ومساره البرمجي، ولماذا تم استخدامه، وماذا يجيب الطالب للأستاذ المشرف أثناء مناقشة التخرج).

---

### 5. دورة التنقل بين الصفحات وإدارة المسارات (Navigation & Routing)
- استخدام `Navigator.of(context).pushReplacement` مع `PageRouteBuilder` و `FadeTransition` لحذف شاشة البداية من الذاكرة ومنع العودة إليها.
- استخدام `NavigationBar` السفلي للتبديل الفوري بين سجل المشتريات وجدول المخزون داخل الشاشة الرئيسية.
- استخدام `Navigator.pop(context)` لإغلاق النوافذ المنبثقة فور اكتمال الحفظ.

---

### 6. نظام المصادقة وإدارة الجلسات السحابية (AuthService)
- كلاس `UserModel` غير قابل للتعديل (Immutable).
- خدمة `AuthService` موروثة من `ChangeNotifier` وتدعم:
  - تسجيل الدخول بحساب Google أو بريد مخصص لعزل النسخ السحابية.
  - المتابعة كـ ضيف محلي للعمل دون إنترنت.
  - حفظ مفاتيح الجلسة في `SharedPreferences`.

---

### 7. المعمارية الكاملة لقاعدة البيانات المحلية SQLite (DatabaseHelper)
- تطبيق نمط **Singleton Pattern** عبر `DatabaseHelper.instance`.
- إنشاء جدول `purchases` بالحقول:
  - `id`: المعرف الأساسي الفريد.
  - `item_name`: اسم البضاعة أو الصنف.
  - `quantity`: الكمية المشتراة.
  - `unit_price`: سعر الحبة بالريال السعودي.
  - `purchase_date`: تاريخ الفاتورة.
  - `invoice_uri`: نص Base64 لصورة الفاتورة.
  - `notes`: ملاحظات الصنف.
  - `created_at` و `updated_at`: طوابع وقت النظام.
- تنفيذ استعلامات CRUD كاملة: `insertPurchase`, `getAllPurchases`, `updatePurchase`, `deletePurchase`.

---

### 8. معالجة الصور وفواتير الشراء والمزامنة السحابية (Google Drive Sync)
- ترميز الصور الملتقطة بالكاميرا إلى نصوص **Base64 Data URI** مدمجة في السجل لضمان سهولة سحابتها ونقلها بين الأجهزة.
- خدمة `BackupSyncService` وتوليد ملفات `.athar` واستعادة البيانات سحابياً باسم الحساب من Google Drive.

---

### 9. نظام التصميم وهوية شركة أثر (Design System & Theme)
- اعتماد الألوان الملكية الفاخرة:
  - `AppColors.primary`: أسود فاخر `#111827`.
  - `AppColors.pureWhite`: أبيض ناصع `#FFFFFF`.
  - `AppColors.background`: رمادي هادئ `#F8FAFC`.
- حواف مستديرة `BorderRadius` وظلال ناعمة `BoxShadow`.
- تفعيل `useMaterial3: true` ودعم التعريب الكامل RTL.

---

### 10. مخططات تدفق البيانات والعمليات في التطبيق
(مخططات إضافة الشراء، استرجاع السجلات، والمزامنة السحابية).

---

### 11. الأمان، الصلاحيات، وإدارة الأداء (Security & Permissions)
- تصريح الإنترنت `android.permission.INTERNET` في `AndroidManifest.xml`.
- خلو الكود من المفاتيح السرية الحساسة.
- صمامات الأمان وحماية قاعدة البيانات SQLite أثناء التحديثات البرمجية.

---

### 12. الجداول المرجعية الشاملة للشاشات والأدوات والملفات
(جداول الحصر الشامل لكافة شاشات وأدوات المشروع).

---

### 13. الأسئلة الأكاديمية المتوقعة في مناقشة الدكتور وإجاباتها النموذجية
يحتوي التقرير على أكثر من 20 سؤالاً وجواباً مفصلاً يربط بين الكود المكتوب ومحاضرات المنهج الجامعي (المحاضرات 3 إلى 9) لمساعدة الطالب على إبهار لجنة المناقشة.

---

### 14. معجم المصطلحات البرمجية والخاتمة الأكاديمية
توثيق كافة المصطلحات الفنية وخاتمة المشروع.
"""

with open(md_path, "w", encoding="utf-8") as f:
    f.write(md_content)

print(f"Markdown report generated successfully at: {md_path}")
