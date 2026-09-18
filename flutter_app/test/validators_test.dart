import 'package:flutter_test/flutter_test.dart';
import 'package:athar_purchases/utils/validators.dart';

void main() {
  group('اختبارات التحقق من اسم الصنف (AppValidators.validateItemName)', () {
    test('رفض الأسماء التي تبدأ برقم لاتيني أو عربي', () {
      expect(AppValidators.validateItemName('1234'), 'يجب أن يبدأ اسم الصنف بحرف وليس برقم');
      expect(AppValidators.validateItemName('5 أكواب'), 'يجب أن يبدأ اسم الصنف بحرف وليس برقم');
      expect(AppValidators.validateItemName('10 كيلو أرز'), 'يجب أن يبدأ اسم الصنف بحرف وليس برقم');
      expect(AppValidators.validateItemName('٥ كراتين'), 'يجب أن يبدأ اسم الصنف بحرف وليس برقم');
      expect(AppValidators.validateItemName(' 123 تفاحة'), 'يجب أن يبدأ اسم الصنف بحرف وليس برقم');
      expect(AppValidators.validateItemName('   7 تمر'), 'يجب أن يبدأ اسم الصنف بحرف وليس برقم');
    });

    test('قبول الأسماء التي تبدأ بحرف عربي أو إنجليزي أو بمسافات تليها حروف', () {
      expect(AppValidators.validateItemName('تفاح'), isNull);
      expect(AppValidators.validateItemName('Apple'), isNull);
      expect(AppValidators.validateItemName(' أرز'), isNull);
      expect(AppValidators.validateItemName('   طابعة ليزرية موديل 2026'), isNull);
      expect(AppValidators.validateItemName('سماعات Pro 5'), isNull);
    });

    test('رفض المدخلات الفارغة أو المسافات فقط أو الرموز', () {
      expect(AppValidators.validateItemName(null), 'يرجى إدخال اسم الصنف');
      expect(AppValidators.validateItemName(''), 'يرجى إدخال اسم الصنف');
      expect(AppValidators.validateItemName('   '), 'يرجى إدخال اسم الصنف');
      expect(AppValidators.validateItemName('#صندوق'), 'يجب أن يبدأ اسم الصنف بحرف وليس برقم أو رمز');
    });
  });
}
