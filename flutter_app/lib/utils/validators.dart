/// [أدوات التحقق - Validators]
/// توفر دوال تحقق قابلة لإعادة الاستخدام لضمان سلامة مدخلات المستخدم وفق شروط العمل.
class AppValidators {
  /// التحقق من اسم الصنف:
  /// 1. لا يمكن أن يكون فارغاً.
  /// 2. يجب تجاهل المسافات في البداية وفحص أول حرف فعلي.
  /// 3. يمنع أن يبدأ برقم (أرقام لاتينية 0-9 أو أرقام عربية/هندية ٠-٩).
  /// 4. يقبل الحروف العربية والإنجليزية.
  static String? validateItemName(String? value) {
    if (value == null) {
      return 'يرجى إدخال اسم الصنف';
    }

    final trimmedLeading = value.trimLeft();
    if (trimmedLeading.isEmpty) {
      return 'يرجى إدخال اسم الصنف';
    }

    final firstChar = trimmedLeading[0];

    // التحقق مما إذا كان الحرف الأول رقماً (سواء لاتيني 0-9 أو عربي مشرق ٠-٩ أو فارسي ۰-۹)
    final isDigit = RegExp(r'[0-9\u0660-\u0669\u06F0-\u06F9]').hasMatch(firstChar);
    if (isDigit) {
      return 'يجب أن يبدأ اسم الصنف بحرف وليس برقم';
    }

    // التحقق من أن الحرف الأول حرف هجائي (عربي أو إنجليزي أو لاتيني)
    final isLetter = RegExp(
      r'^[a-zA-Z\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
    ).hasMatch(firstChar);

    if (!isLetter) {
      return 'يجب أن يبدأ اسم الصنف بحرف وليس برقم أو رمز';
    }

    return null;
  }
}
