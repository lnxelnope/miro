import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:miro_hybrid/core/utils/logger.dart';
import 'dart:io';

class GalleryService {
  static const String _keyScanLimit = 'scan_image_limit';
  static const int defaultScanLimit = 100; // Default: scan 100 images

  /// ดึงจำนวนรูปที่จะสแกน
  Future<int> getScanLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyScanLimit) ?? defaultScanLimit;
  }

  /// บันทึกจำนวนรูปที่จะสแกน
  Future<void> setScanLimit(int limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyScanLimit, limit);
    AppLogger.info('Saved scanLimit: $limit images');
  }

  Future<List<AssetEntity>> fetchNewImages({DateTime? after}) async {
    AppLogger.info('Starting to fetch images from Gallery...');

    // Request Permission — ขอเฉพาะ image เท่านั้น (ไม่ขอ video)
    if (Platform.isWindows) {
      AppLogger.info(
          'Gallery scanning on Windows is limited to Picture Library.');
    }

    AppLogger.info('Requesting Gallery permission...');
    final PermissionState ps;
    if (Platform.isAndroid) {
      ps = await PhotoManager.requestPermissionExtend(
        requestOption: const PermissionRequestOption(
          androidPermission: AndroidPermission(
            type: RequestType.image,
            mediaLocation: false,
          ),
        ),
      );
    } else {
      ps = await PhotoManager.requestPermissionExtend();
    }

    AppLogger.info(
        'PermissionState: ${ps.name}, isAuth: ${ps.isAuth}, hasAccess: ${ps.hasAccess}');

    if (!ps.isAuth && !ps.hasAccess) {
      AppLogger.error('Gallery access denied');
      return [];
    }
    AppLogger.info('Gallery permission granted');

    // Fetch Albums - เรียงตามวันที่แก้ไขล่าสุด
    AppLogger.info('Fetching album list...');
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        orders: [
          // เรียงตามวันที่สร้าง ใหม่ไปเก่า
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    if (albums.isEmpty) {
      AppLogger.warn('No image albums found');
      return [];
    }
    AppLogger.info('Found albums: ${albums.length}');

    // ดึงจำนวนรูปทั้งหมดในอัลบั้ม
    final totalAssets = await albums[0].assetCountAsync;
    AppLogger.info('Total images in album: $totalAssets');

    // ดึงจำนวน limit จาก settings
    final scanLimit = await getScanLimit();
    final fetchCount = scanLimit > totalAssets ? totalAssets : scanLimit;
    AppLogger.info(
        'Fetching images (limit $fetchCount from $totalAssets images)...');

    // ดึงรูปภาพตาม limit (เรียงใหม่ไปเก่าแล้ว)
    List<AssetEntity> media =
        await albums[0].getAssetListRange(start: 0, end: fetchCount);
    AppLogger.info('Fetched images: ${media.length}');

    // Debug: แสดงวันที่ของรูปแรกและรูปสุดท้าย
    if (media.isNotEmpty) {
      AppLogger.info('First image (newest): ${media.first.createDateTime}');
      AppLogger.info('Last image (oldest): ${media.last.createDateTime}');
    }

    // Filter by Date (if provided)
    if (after != null) {
      final beforeCount = media.length;
      media =
          media.where((asset) => asset.createDateTime.isAfter(after)).toList();
      AppLogger.info(
          'Filtered by date (after ${after.toString()}): $beforeCount → ${media.length} images');
    }

    AppLogger.info('Returning images: ${media.length}');
    return media;
  }

  Future<File?> getFile(AssetEntity asset) async {
    return await asset.file;
  }
}
