import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../utils/logger.dart';
import 'usage_limiter.dart';
import 'energy_service.dart';
import 'welcome_offer_service.dart';

/// จัดการ Google Play In-App Purchase
class PurchaseService {
  /// Product ID — ต้องตรงกับที่ตั้งใน Google Play Console
  static const String proProductId = 'miro_pro';

  // ───────────────────────────────────────────────────────────
  // ENERGY PACKAGE CONSTANTS
  // ───────────────────────────────────────────────────────────

  /// Regular energy packages
  static const String energy100 = 'energy_100';      // $0.99
  static const String energy550 = 'energy_550';      // $4.99
  static const String energy1200 = 'energy_1200';    // $7.99
  static const String energy2000 = 'energy_2000';    // $9.99

  /// Welcome offer packages (40% OFF — 24h only)
  static const String energy100Welcome = 'energy_100_welcome';    // $0.59
  static const String energy550Welcome = 'energy_550_welcome';    // $2.99
  static const String energy1200Welcome = 'energy_1200_welcome';  // $4.79
  static const String energy2000Welcome = 'energy_2000_welcome';  // $5.99

  /// Map: Product ID → Energy amount
  static const Map<String, int> energyAmounts = {
    energy100: 100,
    energy550: 550,
    energy1200: 1200,
    energy2000: 2000,
    energy100Welcome: 100,
    energy550Welcome: 550,
    energy1200Welcome: 1200,
    energy2000Welcome: 2000,
  };

  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;
  static EnergyService? _energyService;
  
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
        debugPrint('[PurchaseService] ℹ️ Available products: ${response.productDetails.map((p) => p.id).toList()}');
        AppLogger.error('Product not found: $proProductId');
        throw Exception('Product "$proProductId" not found. Please check Play Console setup.');
      }

      final product = response.productDetails.first;
      debugPrint('[PurchaseService] ✅ Product found: ${product.title} - ${product.price}');
      
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
    debugPrint('[PurchaseService] 📦 Received ${purchases.length} purchase updates');
    
    for (final purchase in purchases) {
      debugPrint('[PurchaseService] 📦 Product: ${purchase.productID}, Status: ${purchase.status}');
      AppLogger.info('Status: ${purchase.status} for ${purchase.productID}');

      // ────── Handle Energy Products ──────
      if (energyAmounts.containsKey(purchase.productID)) {
        _handleEnergyPurchase(purchase);
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
  static Future<void> _handleEnergyPurchase(PurchaseDetails purchase) async {
    final productId = purchase.productID;
    final energyAmount = energyAmounts[productId];
    
    if (energyAmount == null) {
      debugPrint('[PurchaseService] ⚠️ Unknown energy product: $productId');
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      return;
    }
    
    if (_energyService == null) {
      debugPrint('[PurchaseService] ❌ EnergyService not initialized!');
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      return;
    }
    
    switch (purchase.status) {
      case PurchaseStatus.purchased:
        // เพิ่ม Energy
        await _energyService!.addEnergy(
          energyAmount,
          type: productId.contains('welcome') ? 'welcome_offer' : 'purchase',
          packageId: productId,
          purchaseToken: purchase.verificationData.serverVerificationData,
          description: 'Purchased $energyAmount Energy',
        );
        
        // ถ้าเป็น welcome offer → mark as claimed
        if (productId.contains('welcome')) {
          // ตรวจสอบว่าเคยซื้อแล้วหรือยัง (double-check)
          final hasClaimed = await WelcomeOfferService.hasClaimed();
          if (hasClaimed) {
            debugPrint('[PurchaseService] ⚠️ Welcome offer already claimed! This should not happen.');
            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
            return;
          }
          
          await WelcomeOfferService.markClaimed(productId);
          
          // Analytics: track welcome offer purchase
          await FirebaseAnalytics.instance.logEvent(
            name: 'welcome_offer_purchased',
            parameters: {
              'package_id': productId,
              'amount': energyAmount,
            },
          );
        } else {
          // Analytics: track regular purchase
          await FirebaseAnalytics.instance.logEvent(
            name: 'energy_purchased',
            parameters: {
              'package_id': productId,
              'amount': energyAmount,
            },
          );
        }
        
        debugPrint('[PurchaseService] ✅ Energy purchase completed: +$energyAmount Energy');
        break;
        
      case PurchaseStatus.error:
        debugPrint('[PurchaseService] ❌ Energy purchase error: ${purchase.error}');
        AppLogger.error('Energy purchase error', purchase.error);
        break;
        
      case PurchaseStatus.pending:
        debugPrint('[PurchaseService] ⏳ Energy purchase pending...');
        break;
        
      case PurchaseStatus.canceled:
        debugPrint('[PurchaseService] ⚠️ Energy purchase canceled by user');
        break;
        
      default:
        break;
    }
    
    // Complete purchase (consumable)
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }
  
  /// ซื้อ Energy package
  /// 
  /// Example:
  /// ```dart
  /// await PurchaseService.purchaseEnergy('energy_550');
  /// ```
  static Future<bool> purchaseEnergy(String productId) async {
    try {
      final energyAmount = energyAmounts[productId];
      if (energyAmount == null) {
        throw Exception('Invalid product ID: $productId');
      }
      
      debugPrint('[PurchaseService] 🛒 Querying energy product: $productId');
      
      // เรียก in_app_purchase
      final response = await _iap.queryProductDetails({productId});
      
      if (response.error != null) {
        debugPrint('[PurchaseService] ❌ Query error: ${response.error}');
        throw Exception('Cannot load product: ${response.error!.message}');
      }
      
      if (response.productDetails.isEmpty) {
        debugPrint('[PurchaseService] ❌ Product not found: $productId');
        throw Exception('Product not found: $productId');
      }
      
      final product = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: product);
      
      debugPrint('[PurchaseService] 🛒 Initiating energy purchase: $productId');
      
      // ซื้อ (consumable product)
      final success = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: false, // เราจะ consume เองใน _handleEnergyPurchase
      );
      
      debugPrint('[PurchaseService] 🛒 Energy purchase initiated: $success');
      return success;
    } catch (e) {
      debugPrint('[PurchaseService] ❌ Purchase error: $e');
      AppLogger.error('Energy purchase error', e);
      return false;
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
