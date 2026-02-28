import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:http/http.dart' as http;
import 'analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import '../utils/logger.dart';
import 'usage_limiter.dart';
import 'energy_service.dart';
import 'device_id_service.dart';

/// จัดการ Google Play In-App Purchase
class PurchaseService {
  /// Product ID — ต้องตรงกับที่ตั้งใน Google Play Console
  static const String proProductId = 'miro_pro';

  // ───────────────────────────────────────────────────────────
  // ENERGY PACKAGE CONSTANTS
  // ───────────────────────────────────────────────────────────

  /// Regular energy packages
  static const String energy100 = 'energy_100'; // $0.99
  static const String energy550 = 'energy_550'; // $4.99
  static const String energy1200 = 'energy_1200'; // $7.99
  static const String energy2000 = 'energy_2000'; // $9.99

  /// Offer-specific packages (managed by backend offersV2)
  static const String energyFirstPurchase200 = 'energy_first_purchase_200'; // $1.00

  /// Map: Product ID → Energy amount
  static const Map<String, int> energyAmounts = {
    energy100: 100,
    energy550: 550,
    energy1200: 1200,
    energy2000: 2000,
    energyFirstPurchase200: 200,
  };

  /// Approximate THB prices for analytics (actual prices from Google Play)
  static double _getProductPrice(String productId) {
    const prices = {
      'energy_100': 35.0,
      'energy_550': 179.0,
      'energy_1200': 289.0,
      'energy_2000': 359.0,
      'energy_first_purchase_200': 35.0,
    };
    return prices[productId] ?? 0.0;
  }

  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;
  static EnergyService? _energyService;

  // ✅ PHASE 2: Server verification URL
  static const String _verifyPurchaseUrl =
      'https://us-central1-miro-d6856.cloudfunctions.net/verifyPurchase';

  /// Set EnergyService (required for energy purchases)
  static void setEnergyService(EnergyService energyService) {
    _energyService = energyService;
  }

  /// เริ่มต้น — เรียกครั้งเดียวใน main.dart
  static Future<void> initialize() async {
    final available = await _iap.isAvailable();
    debugPrint('[PurchaseService] 🛒 IAP available: $available');

    if (!available) {
      debugPrint('[PurchaseService] ❌ IAP not available on this device');
      return;
    }

    // ฟัง purchase updates
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (error) {
        debugPrint('[PurchaseService] ❌ Stream error: $error');
      },
      onDone: () {
        debugPrint('[PurchaseService] ℹ️ Stream closed');
      },
    );

    debugPrint('[PurchaseService] ✅ Purchase stream listening');

    // Restore purchases (ตรวจว่าเคยซื้อแล้วหรือยัง)
    try {
      await _iap.restorePurchases();
      debugPrint('[PurchaseService] ✅ Restore completed');
    } catch (e) {
      debugPrint('[PurchaseService] ❌ Restore error: $e');
    }
  }

  /// ซื้อ Pro
  static Future<void> buyPro() async {
    try {
      debugPrint('[PurchaseService] 🛒 Querying product: $proProductId');

      final response = await _iap.queryProductDetails({proProductId});

      if (response.error != null) {
        debugPrint('[PurchaseService] ❌ Query error: ${response.error}');
        AppLogger.error('Query error', response.error);
        throw Exception('Cannot load product: ${response.error!.message}');
      }

      if (response.productDetails.isEmpty) {
        debugPrint('[PurchaseService] ❌ Product not found: $proProductId');
        debugPrint(
            '[PurchaseService] ℹ️ Available products: ${response.productDetails.map((p) => p.id).toList()}');
        AppLogger.error('Product not found: $proProductId');
        throw Exception(
            'Product "$proProductId" not found. Please check Play Console setup.');
      }

      final product = response.productDetails.first;
      debugPrint(
          '[PurchaseService] ✅ Product found: ${product.title} - ${product.price}');

      final purchaseParam = PurchaseParam(productDetails: product);

      debugPrint('[PurchaseService] 🛒 Initiating purchase...');
      // Non-consumable = ซื้อครั้งเดียว ใช้ตลอด
      final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      debugPrint('[PurchaseService] 🛒 Purchase initiated: $success');
    } catch (e, stackTrace) {
      debugPrint('[PurchaseService] ❌ Buy error: $e');
      debugPrint('[PurchaseService] ❌ Stack: $stackTrace');
      rethrow;
    }
  }

  /// Handle purchase updates (ซื้อสำเร็จ / ล้มเหลว / restore)
  static void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    debugPrint(
        '[PurchaseService] 📦 Received ${purchases.length} purchase updates');

    for (final purchase in purchases) {
      debugPrint(
          '[PurchaseService] 📦 Product: ${purchase.productID}, Status: ${purchase.status}');
      AppLogger.info('Status: ${purchase.status} for ${purchase.productID}');

      // ────── Handle Energy Products ──────
      if (energyAmounts.containsKey(purchase.productID)) {
        _handleEnergyPurchase(purchase).catchError((e, st) {
          debugPrint('[PurchaseService] ❌ Energy purchase handler error: $e');
          debugPrint('[PurchaseService] ❌ Stack: $st');
        });
        continue;
      }

      // ────── Handle Subscription (Phase 5) ──────
      if (_allSubscriptionProductIds.contains(purchase.productID)) {
        _handleSubscriptionPurchase(purchase).catchError((e, st) {
          debugPrint('[PurchaseService] ❌ Subscription handler error: $e');
          debugPrint('[PurchaseService] ❌ Stack: $st');
        });
        continue;
      }

      // ────── Handle Pro Product ──────
      if (purchase.productID == proProductId) {
        switch (purchase.status) {
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            // ✅ ซื้อสำเร็จ / restore สำเร็จ → ปลดล็อค Pro
            UsageLimiter.setPro(true);
            debugPrint('[PurchaseService] ✅ Pro unlocked!');
            AppLogger.info('Pro unlocked!');
            break;

          case PurchaseStatus.error:
            debugPrint('[PurchaseService] ❌ Purchase error: ${purchase.error}');
            AppLogger.error('Purchase error', purchase.error);
            break;

          case PurchaseStatus.pending:
            debugPrint('[PurchaseService] ⏳ Purchase pending...');
            AppLogger.info('Purchase pending...');
            break;

          case PurchaseStatus.canceled:
            debugPrint('[PurchaseService] ⚠️ Purchase canceled by user');
            AppLogger.info('Purchase canceled');
            break;
        }
      }

      // สำคัญ: ต้อง complete purchase เสมอ
      if (purchase.pendingCompletePurchase) {
        debugPrint('[PurchaseService] 🔄 Completing purchase...');
        _iap.completePurchase(purchase);
      }
    }
  }

  // ───────────────────────────────────────────────────────────
  // ENERGY PURCHASE HANDLING
  // ───────────────────────────────────────────────────────────

  /// Handle Energy purchase
  ///
  /// ✅ FIX: ใช้ consumePurchase แทน completePurchase สำหรับ consumable products
  /// เพื่อให้ Google Play ปล่อย product → ผู้ใช้สามารถซื้อซ้ำได้
  static Future<void> _handleEnergyPurchase(PurchaseDetails purchase) async {
    final productId = purchase.productID;
    final energyAmount = energyAmounts[productId];

    if (energyAmount == null) {
      debugPrint('[PurchaseService] ⚠️ Unknown energy product: $productId');
      await _consumeAndCompletePurchase(purchase);
      return;
    }

    try {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          debugPrint('[PurchaseService] ⏳ Purchase pending: $productId');
          // แสดง loading หรือ pending state — ยังไม่ต้อง consume
          break;

        case PurchaseStatus.purchased:
          debugPrint('[PurchaseService] ✅ Purchase successful: $productId');

          if (_energyService == null) {
            debugPrint(
                '[PurchaseService] ❌ EnergyService not initialized! Saving for retry.');
            await _savePendingPurchase(purchase, productId);
            await _consumeAndCompletePurchase(purchase);
            return;
          }

          // ✅ Verify กับ Server
          final verified = await _verifyPurchaseWithServer(
            purchaseToken: purchase.verificationData.serverVerificationData,
            productId: productId,
          );

          if (verified != null && verified['success'] == true) {
            // Server verify สำเร็จ → เพิ่ม energy
            final newBalance = verified['balance'] as int;
            final energyAdded = verified['energyAdded'] as int;

            // Sync balance จาก server
            await _energyService!.updateFromServerResponse(newBalance);

            debugPrint(
                '[PurchaseService] 💎 Server-verified: +$energyAdded → Balance: $newBalance');

            // Analytics: standard purchase event (Google Ads conversion)
            AnalyticsService.logEnergyPurchase(
              packageId: productId,
              energyAmount: energyAdded,
              price: _getProductPrice(productId),
              currency: 'THB',
            );
          } else if (verified != null && verified['duplicate'] == true) {
            // Duplicate — เคย verify แล้ว (balance ถูก sync แล้วใน _verifyPurchaseWithServer)
            debugPrint(
                '[PurchaseService] ℹ️ Duplicate purchase — already processed');
          } else {
            // Server verify ไม่ได้ (network error, server error)
            debugPrint(
                '[PurchaseService] ⚠️ Server verification failed — saving for retry');
            await _savePendingPurchase(purchase, productId);
          }

          // ✅ สำคัญ: Consume purchase เสมอ (ไม่ว่า verify สำเร็จหรือไม่)
          // Consume = บอก Google Play ว่าส่งของแล้ว → ผู้ใช้ซื้อซ้ำได้
          // (สำหรับ verify ที่ล้มเหลว เรามี pending retry mechanism)
          await _consumeAndCompletePurchase(purchase);
          break;

        case PurchaseStatus.restored:
          // ✅ FIX: Handle restored energy purchases (เคยซื้อแต่ยัง consume ไม่สำเร็จ)
          debugPrint(
              '[PurchaseService] 🔄 Restored energy purchase: $productId');

          if (_energyService != null) {
            // ลอง verify กับ Server (อาจเคย verify แล้ว → ได้ duplicate กลับมา)
            final verified = await _verifyPurchaseWithServer(
              purchaseToken: purchase.verificationData.serverVerificationData,
              productId: productId,
            );

            if (verified != null && verified['success'] == true) {
              // ยังไม่เคย verify — เพิ่ม energy ตอนนี้
              final newBalance = verified['balance'] as int;
              await _energyService!.updateFromServerResponse(newBalance);
              debugPrint(
                  '[PurchaseService] 💎 Restored purchase verified: Balance → $newBalance');
            } else if (verified != null && verified['duplicate'] == true) {
              // เคย verify แล้ว — balance ถูก sync ใน _verifyPurchaseWithServer
              debugPrint(
                  '[PurchaseService] ℹ️ Restored purchase was already verified');
            } else {
              // Verify ไม่ได้ — save for retry
              debugPrint(
                  '[PurchaseService] ⚠️ Restored purchase verification failed — saving for retry');
              await _savePendingPurchase(purchase, productId);
            }
          } else {
            // EnergyService ยังไม่พร้อม → save for retry
            debugPrint(
                '[PurchaseService] ⚠️ EnergyService not ready — saving restored purchase for retry');
            await _savePendingPurchase(purchase, productId);
          }

          // ✅ Consume เพื่อป้องกัน "already owned" error
          await _consumeAndCompletePurchase(purchase);
          break;

        case PurchaseStatus.error:
          debugPrint('[PurchaseService] ❌ Purchase error: ${purchase.error}');
          AppLogger.error('Energy purchase error', purchase.error);
          // Error → ไม่มี purchase ค้าง → ไม่ต้อง consume
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;

        case PurchaseStatus.canceled:
          debugPrint('[PurchaseService] ⚠️ Energy purchase canceled by user');
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
      }
    } catch (e, st) {
      debugPrint('[PurchaseService] ❌ _handleEnergyPurchase error: $e');
      debugPrint('[PurchaseService] ❌ Stack: $st');
      // Safety net: consume/complete เพื่อป้องกัน purchase ค้าง
      try {
        await _consumeAndCompletePurchase(purchase);
      } catch (_) {}
    }
  }

  /// ✅ Consume purchase บน Android (ทำให้ซื้อซ้ำได้)
  ///
  /// สำหรับ consumable products: ต้อง consume (ไม่ใช่แค่ acknowledge)
  /// เพื่อบอก Google Play ว่าส่งของแล้ว → product ถูกปลดออก → ซื้อใหม่ได้
  ///
  /// Note: consumeAsync บน Android จะ acknowledge ให้ด้วยอัตโนมัติ
  static Future<void> _consumeAndCompletePurchase(
      PurchaseDetails purchase) async {
    try {
      if (Platform.isAndroid) {
        final InAppPurchaseAndroidPlatformAddition androidAddition =
            _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        final BillingResultWrapper result =
            await androidAddition.consumePurchase(purchase);

        debugPrint(
            '[PurchaseService] 🔄 Consume result: ${result.responseCode}');

        if (result.responseCode == BillingResponse.ok) {
          debugPrint(
              '[PurchaseService] ✅ Purchase consumed — can be re-purchased');
          return; // Consume สำเร็จ (acknowledge ด้วยแล้ว) → ไม่ต้อง completePurchase
        }

        // Consume ไม่สำเร็จ → fallthrough ไป completePurchase
        debugPrint(
            '[PurchaseService] ⚠️ Consume failed: ${result.responseCode} — falling back to completePurchase');
      }

      // Fallback: completePurchase (สำหรับ non-Android หรือ consume ล้มเหลว)
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    } catch (e) {
      debugPrint('[PurchaseService] ❌ Consume/complete error: $e');
      // Last resort: try completePurchase
      try {
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      } catch (_) {}
    }
  }

  /// Verify purchase กับ Backend
  ///
  /// Returns:
  /// - Map ถ้า verify สำเร็จ: { success: true, balance: xxx, energyAdded: xxx }
  /// - null ถ้า verify ไม่สำเร็จ (error, duplicate, network issue)
  static Future<Map<String, dynamic>?> _verifyPurchaseWithServer({
    required String purchaseToken,
    required String productId,
  }) async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();

      debugPrint('[PurchaseService] 🔍 Verifying with server...');
      debugPrint('[PurchaseService] Product: $productId');
      debugPrint('[PurchaseService] DeviceId: $deviceId');

      final response = await http
          .post(
        Uri.parse(_verifyPurchaseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'purchaseToken': purchaseToken,
          'productId': productId,
          'deviceId': deviceId,
          'platform': Platform.isIOS ? 'ios' : 'android',
        }),
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('[PurchaseService] ⏱️ Verification timeout');
          throw Exception('Verification timeout');
        },
      );

      debugPrint('[PurchaseService] Server response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else if (response.statusCode == 409) {
        // Duplicate purchase — เคย verify แล้ว
        debugPrint(
            '[PurchaseService] ⚠️ Duplicate purchase (already verified)');

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['verified'] == true && data['balance'] != null) {
          // Token เคยใช้แล้ว → sync balance ให้ (ไม่เพิ่มซ้ำ)
          if (_energyService != null) {
            await _energyService!
                .updateFromServerResponse(data['balance'] as int);
          }
        }

        // ✅ Return duplicate marker (แยกจาก error → ไม่ต้อง save pending)
        return {'duplicate': true, 'balance': data['balance'] ?? 0};
      } else {
        // Other errors
        final errorBody = response.body;
        debugPrint('[PurchaseService] ❌ Server error: $errorBody');
        return null;
      }
    } catch (e) {
      debugPrint('[PurchaseService] ❌ Verification error: $e');
      return null;
    }
  }

  /// บันทึก pending purchase สำหรับ retry ทีหลัง
  static Future<void> _savePendingPurchase(
    PurchaseDetails purchase,
    String productId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingKey = 'pending_purchase_${purchase.purchaseID}';

      await prefs.setString(
        pendingKey,
        jsonEncode({
          'purchaseToken': purchase.verificationData.serverVerificationData,
          'productId': productId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );

      debugPrint('[PurchaseService] 💾 Saved pending purchase: $productId');
    } catch (e) {
      debugPrint('[PurchaseService] ❌ Failed to save pending purchase: $e');
    }
  }

  /// Retry pending purchases (เรียกตอน app startup)
  static Future<void> retryPendingPurchases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys =
          prefs.getKeys().where((k) => k.startsWith('pending_purchase_'));

      if (keys.isEmpty) return;

      debugPrint(
          '[PurchaseService] 🔄 Retrying ${keys.length} pending purchases...');

      for (final key in keys) {
        final json = prefs.getString(key);
        if (json == null) continue;

        final data = jsonDecode(json) as Map<String, dynamic>;
        final purchaseToken = data['purchaseToken'] as String;
        final productId = data['productId'] as String;

        // Retry verification
        final verified = await _verifyPurchaseWithServer(
          purchaseToken: purchaseToken,
          productId: productId,
        );

        if (verified != null && verified['success'] == true) {
          // Success — remove from pending + update balance
          await prefs.remove(key);
          if (_energyService != null) {
            await _energyService!
                .updateFromServerResponse(verified['balance'] as int);
          }
          debugPrint('[PurchaseService] ✅ Retry success: $productId');
        } else if (verified != null && verified['duplicate'] == true) {
          // Duplicate — already verified, just remove from pending
          // (balance ถูก sync ใน _verifyPurchaseWithServer แล้ว)
          await prefs.remove(key);
          debugPrint(
              '[PurchaseService] ✅ Retry: already verified (duplicate): $productId');
        }
      }
    } catch (e) {
      debugPrint('[PurchaseService] ❌ Retry error: $e');
    }
  }

  /// Last error message (for debugging — แสดงให้ user เห็น)
  static String? lastPurchaseError;

  /// ซื้อ Energy package
  ///
  /// Returns (success, errorMessage). errorMessage มีค่าเมื่อ success=false
  static Future<({bool success, String? errorMessage})> purchaseEnergyWithError(
      String productId) async {
    lastPurchaseError = null;
    try {
      final energyAmount = energyAmounts[productId];
      if (energyAmount == null) {
        lastPurchaseError = 'Invalid product ID: $productId';
        return (success: false, errorMessage: lastPurchaseError);
      }

      debugPrint('[PurchaseService] 🛒 Querying energy product: $productId');

      final response = await _iap.queryProductDetails({productId});

      if (response.error != null) {
        final msg = 'Query error: ${response.error!.message}';
        debugPrint('[PurchaseService] ❌ $msg');
        lastPurchaseError = msg;
        return (success: false, errorMessage: msg);
      }

      if (response.productDetails.isEmpty) {
        final msg =
            'Product not found: $productId. Check App Store Connect + Paid Agreements.';
        debugPrint('[PurchaseService] ❌ $msg');
        lastPurchaseError = msg;
        return (success: false, errorMessage: msg);
      }

      final product = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: product);

      debugPrint('[PurchaseService] 🛒 Initiating energy purchase: $productId');

      final success = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: false,
      );

      debugPrint('[PurchaseService] 🛒 Energy purchase initiated: $success');
      if (!success) {
        lastPurchaseError =
            'Purchase dialog failed. Try: Sign Out App Store → use Sandbox account.';
        return (success: false, errorMessage: lastPurchaseError);
      }
      return (success: true, errorMessage: null);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      debugPrint('[PurchaseService] ❌ Purchase error: $e');
      AppLogger.error('Energy purchase error', e);
      lastPurchaseError = msg;
      return (success: false, errorMessage: msg);
    }
  }

  /// ซื้อ Energy package (backward compat — returns bool only)
  static Future<bool> purchaseEnergy(String productId) async {
    final result = await purchaseEnergyWithError(productId);
    return result.success;
  }

  /// Restore purchase (สำหรับเปลี่ยนเครื่อง)
  static Future<void> restorePurchase() async {
    await _iap.restorePurchases();
  }

  // ───────────────────────────────────────────────────────────
  // SUBSCRIPTION HANDLING (Phase 5)
  // ───────────────────────────────────────────────────────────

  /// Android: single product with multiple base plans
  static const String subscriptionProductId = 'miro_normal_subscription';

  /// iOS: 3 separate products (App Store structure)
  static const String iosWeeklyProductId = 'miro_energy_pass_weekly';
  static const String iosMonthlyProductId = 'miro_energy_pass_monthly';
  static const String iosYearlyProductId = 'miro_energy_pass_yearly';

  /// All valid subscription product IDs (both platforms)
  static const Set<String> _allSubscriptionProductIds = {
    subscriptionProductId,
    iosWeeklyProductId,
    iosMonthlyProductId,
    iosYearlyProductId,
  };

  /// Handle Subscription purchase
  static Future<void> _handleSubscriptionPurchase(PurchaseDetails purchase) async {
    final actualProductId = purchase.productID;
    try {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          debugPrint('[PurchaseService] ✅ Subscription purchased/restored: $actualProductId');

          final deviceId = await DeviceIdService.getDeviceId();
          final purchaseToken = purchase.verificationData.serverVerificationData;

          try {
            final response = await http
                .post(
                  Uri.parse(
                      'https://us-central1-miro-d6856.cloudfunctions.net/verifySubscription'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'deviceId': deviceId,
                    'purchaseToken': purchaseToken,
                    'productId': actualProductId,
                    'platform': Platform.isIOS ? 'ios' : 'android',
                  }),
                )
                .timeout(const Duration(seconds: 15));

            if (response.statusCode == 200) {
              final data = jsonDecode(response.body) as Map<String, dynamic>;
              debugPrint(
                  '[PurchaseService] ✅ Subscription verified: ${data['status']}');

              AnalyticsService.logSubscribe(
                productId: actualProductId,
                price: 0,
                currency: 'USD',
              );
            } else {
              debugPrint(
                  '[PurchaseService] ⚠️ Subscription verification failed: ${response.statusCode}');
              debugPrint('[PurchaseService] Body: ${response.body}');
            }
          } catch (e) {
            debugPrint(
                '[PurchaseService] ❌ Subscription verification error: $e');
          }

          break;

        case PurchaseStatus.error:
          debugPrint(
              '[PurchaseService] ❌ Subscription error: ${purchase.error}');
          break;

        case PurchaseStatus.pending:
          debugPrint('[PurchaseService] ⏳ Subscription pending...');
          break;

        case PurchaseStatus.canceled:
          debugPrint('[PurchaseService] ⚠️ Subscription canceled');
          break;
      }

      // Complete purchase (acknowledge for subscriptions)
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    } catch (e) {
      debugPrint('[PurchaseService] ❌ _handleSubscriptionPurchase error: $e');
      if (purchase.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchase);
        } catch (_) {}
      }
    }
  }

  /// Cleanup
  static void dispose() {
    _subscription?.cancel();
  }
}
