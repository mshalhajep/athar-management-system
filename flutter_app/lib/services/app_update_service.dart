import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String releaseNotes;
  final String downloadUrl;
  final bool hasUpdate;
  final String releaseDate;

  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseNotes,
    required this.downloadUrl,
    required this.hasUpdate,
    required this.releaseDate,
  });
}

/// [المرحلة 4]: خدمة فاحص ومثبت التحديثات من داخل التطبيق (In-App Update)
/// تضمن تنزيل وتثبيت التحديثات بضغطة زر دون المساس بقاعدة بيانات SQLite المحلية
class AppUpdateService extends ChangeNotifier {
  static const String currentAppVersion = '1.1.0';
  static const String _remoteVersionKey = 'athar_remote_app_version';

  bool _isChecking = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  bool get isChecking => _isChecking;
  bool get isDownloading => _isDownloading;
  double get downloadProgress => _downloadProgress;

  /// فحص توفر تحديث جديد مقارنة بالإصدار الحالي
  Future<UpdateInfo> checkForUpdates() async {
    _isChecking = true;
    notifyListeners();

    try {
      // محاكاة الاتصال بسيرفر التحديثات أو فحص مستودع التحديثات عن بُعد
      await Future.delayed(const Duration(milliseconds: 700));

      final prefs = await SharedPreferences.getInstance();
      // قراءة الإصدار الأخير المسجل في الخادم (يمكن تعيينه وتحديثه)
      final remoteVersion = prefs.getString(_remoteVersionKey) ?? '1.1.0';

      final hasUpdate = _isVersionHigher(remoteVersion, currentAppVersion);

      return UpdateInfo(
        currentVersion: currentAppVersion,
        latestVersion: remoteVersion,
        releaseNotes: '• ترقية قاعدة البيانات إلى SQLite لأداء أسرع وعمل بدون إنترنت\n• دعم المزامنة السحابية بحساب Google\n• ميزة تصدير واسترجاع ملفات النسخ الاحتياطية (.athar)\n• تحسينات وتأمين البيانات ضد الفقدان',
        downloadUrl: 'https://github.com/athar-org/inventory/releases/download/v$remoteVersion/athar_update.apk',
        hasUpdate: hasUpdate,
        releaseDate: '2026-09-16',
      );
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  /// محاكاة تنزيل التحديث بضغطة زر وتثبيته فوق التطبيق دون لمس قاعدة بيانات SQLite
  Future<bool> downloadAndInstallUpdate({
    required Function(double progress) onProgress,
  }) async {
    _isDownloading = true;
    _downloadProgress = 0.0;
    notifyListeners();

    try {
      // محاكاة مراحل تنزيل الـ APK مع إظهار النسبة المئوية للمستخدم
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 250));
        _downloadProgress = i / 10.0;
        onProgress(_downloadProgress);
        notifyListeners();
      }

      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (e) {
      debugPrint('Update installation error: $e');
      return false;
    } finally {
      _isDownloading = false;
      _downloadProgress = 0.0;
      notifyListeners();
    }
  }

  /// دالة مقارنة أرقام الإصدارات (مثل 1.1.0 أكبر من 1.0.0)
  bool _isVersionHigher(String remote, String current) {
    try {
      final rParts = remote.split('.').map(int.parse).toList();
      final cParts = current.split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        final r = i < rParts.length ? rParts[i] : 0;
        final c = i < cParts.length ? cParts[i] : 0;
        if (r > c) return true;
        if (r < c) return false;
      }
    } catch (_) {}
    return false;
  }
}
