import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:athar_purchases/services/app_update_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({
      'athar_remote_app_version': '1.2.0',
    });
  });

  group('اختبارات فاحص ومثبت التحديثات الذكية (المرحلة 4)', () {
    test('فحص التحديثات واكتشاف الإصدار الأحدث', () async {
      final updateService = AppUpdateService();

      final info = await updateService.checkForUpdates();
      expect(info.currentVersion, '1.1.0');
      expect(info.latestVersion, '1.2.0');
      expect(info.hasUpdate, isTrue);
      expect(info.releaseNotes.isNotEmpty, isTrue);
    });

    test('محاكاة تنزيل وتثبيت التحديث مع إشعار التقدم', () async {
      final updateService = AppUpdateService();

      double lastProgress = 0.0;
      final ok = await updateService.downloadAndInstallUpdate(
        onProgress: (progress) {
          lastProgress = progress;
        },
      );

      expect(ok, isTrue);
      expect(lastProgress, 1.0);
    });
  });
}
