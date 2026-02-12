import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../utils/logger.dart';
import 'usage_limiter.dart';

/// จัดการ Google Play In-App Purchase
class PurchaseService {
  /// Product ID — ต้องตรงกับที่ตั้งใน Google Play Console
  static const String proProductId = 'miro_cal_pro';

  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// เริ่มต้น — เรียกครั้งเดียวใน main.dart
  static Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) {
      debugPrint('[PurchaseService] IAP not available');
      return;
    }

    // ฟัง purchase updates
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (error) {
        debugPrint('[PurchaseService] Stream error: $error');
      },
    );

    // Restore purchases (ตรวจว่าเคยซื้อแล้วหรือยัง)
    await _iap.restorePurchases();
  }

  /// ซื้อ Pro
  static Future<void> buyPro() async {
    try {
      final response = await _iap.queryProductDetails({proProductId});

      if (response.error != null) {
        AppLogger.error('Query error', response.error);
        return;
      }

      if (response.productDetails.isEmpty) {
        AppLogger.error('Product not found: $proProductId');
        return;
      }

      final product = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: product);

      // Non-consumable = ซื้อครั้งเดียว ใช้ตลอด
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('[PurchaseService] Buy error: $e');
    }
  }

  /// Handle purchase updates (ซื้อสำเร็จ / ล้มเหลว / restore)
  static void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      AppLogger.info('Status: ${purchase.status} for ${purchase.productID}');

      if (purchase.productID == proProductId) {
        switch (purchase.status) {
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            // ✅ ซื้อสำเร็จ / restore สำเร็จ → ปลดล็อค Pro
            UsageLimiter.setPro(true);
            AppLogger.info('Pro unlocked!');
            break;

          case PurchaseStatus.error:
            AppLogger.error('Purchase error', purchase.error);
            break;

          case PurchaseStatus.pending:
            AppLogger.info('Purchase pending...');
            break;

          case PurchaseStatus.canceled:
            AppLogger.info('Purchase canceled');
            break;
        }
      }

      // สำคัญ: ต้อง complete purchase เสมอ
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  /// Restore purchase (สำหรับเปลี่ยนเครื่อง)
  static Future<void> restorePurchase() async {
    await _iap.restorePurchases();
  }

  /// Cleanup
  static void dispose() {
    _subscription?.cancel();
  }
}
