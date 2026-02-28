import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class PermissionService {
  static const String _keyFirstLaunch = 'is_first_launch';
  static const String _keyLastScanTime = 'last_scan_timestamp';
  static const String _keyScanDaysBack = 'scan_days_back';

  // Default: scan back 1 day
  static const int defaultScanDaysBack = 1;

  // ========== Permission Requests ==========

  /// ขอ permission เข้าถึง Gallery
  /// return true = ได้รับอนุญาต, false = ไม่ได้รับอนุญาต
  Future<bool> requestGalleryPermission() async {
    AppLogger.info('requestGalleryPermission() starting');

    try {
      // สำหรับ Android 13+ ต้องใช้ READ_MEDIA_IMAGES
      if (Platform.isAndroid) {
        AppLogger.info('Checking Platform: Android');

        // ขอ permission ผ่าน photo_manager
        final PermissionState ps = await PhotoManager.requestPermissionExtend(
          requestOption: const PermissionRequestOption(
            androidPermission: AndroidPermission(
              type: RequestType.image,
              mediaLocation: false,
            ),
          ),
        );

        AppLogger.info('PermissionState: ${ps.name}');
        AppLogger.info('isAuth: ${ps.isAuth}');
        AppLogger.info('hasAccess: ${ps.hasAccess}');

        if (!ps.isAuth && !ps.hasAccess) {
          AppLogger.warn('Permission denied - may need to open Settings');
        }

        return ps.isAuth || ps.hasAccess;
      }

      // iOS และอื่นๆ
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      AppLogger.info('(iOS) PermissionState: ${ps.name}');
      return ps.isAuth;
    } catch (e) {
      AppLogger.error('Error requesting gallery permission', e);
      return false;
    }
  }

  /// ขอ permission เข้าถึง Camera
  /// return true = ได้รับอนุญาต, false = ไม่ได้รับอนุญาต
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// ขอ permission เข้าถึง Calendar
  /// return true = ได้รับอนุญาต, false = ไม่ได้รับอนุญาต
  Future<bool> requestCalendarPermission() async {
    final status = await Permission.calendar.request();
    return status.isGranted;
  }

  /// ขอ permission ทั้งหมดที่จำเป็น
  /// return Map ของ permission และสถานะ
  Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};

    results['gallery'] = await requestGalleryPermission();
    results['camera'] = await requestCameraPermission();
    // Calendar เป็น optional ไม่ต้องบังคับ
    results['calendar'] = await requestCalendarPermission();

    return results;
  }

  // ========== Permission Checks ==========

  /// ตรวจสอบว่ามี Gallery permission หรือยัง (ไม่ request ถ้ายังไม่มี)
  Future<bool> hasGalleryPermission() async {
    AppLogger.info('hasGalleryPermission() checking...');

    try {
      if (Platform.isAndroid) {
        // ใช้ permission_handler ตรวจสอบก่อน
        final photosStatus = await Permission.photos.status;
        AppLogger.info('Photos permission status: ${photosStatus.name}');

        if (photosStatus.isGranted) {
          return true;
        }

        // ถ้า photos ไม่ได้ ลอง storage (สำหรับ Android < 13)
        final storageStatus = await Permission.storage.status;
        AppLogger.info('Storage permission status: ${storageStatus.name}');

        return storageStatus.isGranted;
      }

      // iOS - ใช้ PhotoManager ตรวจสอบ
      final PermissionState ps = await PhotoManager.requestPermissionExtend(
        requestOption: const PermissionRequestOption(
          iosAccessLevel: IosAccessLevel.readWrite,
        ),
      );
      return ps.isAuth;
    } catch (e) {
      AppLogger.error('Error checking gallery permission', e);
      return false;
    }
  }

  /// ตรวจสอบว่ามี Camera permission หรือยัง
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  // ========== First Launch Handling ==========

  /// ตรวจสอบว่าเป็นการเปิดแอปครั้งแรกหรือไม่
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstLaunch) ?? true;
  }

  /// บันทึกว่าได้เปิดแอปแล้ว (ไม่ใช่ครั้งแรกอีกต่อไป)
  Future<void> markFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, false);
  }

  // ========== Last Scan Time ==========

  /// ดึงเวลาที่สแกนล่าสุด
  Future<DateTime?> getLastScanTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_keyLastScanTime);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// บันทึกเวลาที่สแกนล่าสุด
  Future<void> setLastScanTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastScanTime, time.millisecondsSinceEpoch);
  }

  // ========== Scan Days Back Setting (Deprecated - keeping for backward compatibility) ==========

  /// ดึงจำนวนวันที่สแกนย้อนหลัง (Deprecated: ตอนนี้ scan เฉพาะวันที่เลือกแล้ว)
  @Deprecated('Scan now targets specific dates only')
  Future<int> getScanDaysBack() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyScanDaysBack) ?? defaultScanDaysBack;
  }

  /// บันทึกจำนวนวันที่สแกนย้อนหลัง (Deprecated: ตอนนี้ scan เฉพาะวันที่เลือกแล้ว)
  @Deprecated('Scan now targets specific dates only')
  Future<void> setScanDaysBack(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyScanDaysBack, days);
    AppLogger.info('Saved scanDaysBack: $days days (deprecated)');
  }

  /// คำนวณวันที่เริ่มต้นสำหรับการสแกน (Deprecated: ตอนนี้ scan เฉพาะวันที่เลือกแล้ว)
  @Deprecated('Scan now targets specific dates only')
  Future<DateTime> getScanStartDate() async {
    final daysBack = await getScanDaysBack();
    final daysBackDate = DateTime.now().subtract(Duration(days: daysBack));

    AppLogger.info('Using daysBack: $daysBack days → $daysBackDate (deprecated)');
    return daysBackDate;
  }

  // ========== Open Settings ==========

  /// เปิดหน้า Settings ของแอป (กรณี user ปฏิเสธ permission)
  Future<bool> openSettings() async {
    AppLogger.info('Opening app settings...');
    return await openAppSettings(); // จาก permission_handler package
  }

  /// ขอ permission ทั้งหมดตอนเปิดแอปครั้งแรก
  Future<Map<String, bool>> requestInitialPermissions() async {
    AppLogger.info('requestInitialPermissions() starting');

    final results = <String, bool>{};

    // 1. Gallery Permission
    AppLogger.info('Requesting Gallery permission...');
    results['gallery'] = await requestGalleryPermission();
    AppLogger.info('Gallery: ${results['gallery']}');

    // 2. Camera Permission
    AppLogger.info('Requesting Camera permission...');
    results['camera'] = await requestCameraPermission();
    AppLogger.info('Camera: ${results['camera']}');

    AppLogger.info('requestInitialPermissions() complete');
    AppLogger.info('Results: $results');

    return results;
  }
}
