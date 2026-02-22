import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription_data.dart';
import '../models/subscription_plan.dart';
import '../../../core/services/device_id_service.dart';

/// Subscription Service
/// 
/// Handles Google Play Billing and subscription verification
class SubscriptionService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Firebase Functions endpoints
  static const String _verifySubscriptionUrl =
      'https://us-central1-miro-d6856.cloudfunctions.net/verifySubscription';

  // Product ID (single subscription product with multiple base plans)
  static const String kSubscriptionProductId = 'miro_normal_subscription';

  /// Initialize the service
  Future<void> initialize() async {
    debugPrint('🔧 [SubscriptionService] Initializing...');

    // Android-specific initialization
    // Android: enablePendingPurchases() deprecated — handled automatically by BL5+

    // Listen to purchase updates
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        debugPrint('❌ [SubscriptionService] Purchase stream error: $error');
      },
    );

    debugPrint('✅ [SubscriptionService] Initialized');
  }

  /// Check if in-app purchase is available
  Future<bool> isAvailable() async {
    return await _inAppPurchase.isAvailable();
  }

  /// Get available subscription products
  Future<List<ProductDetails>> getProducts() async {
    debugPrint('🔍 [SubscriptionService] Fetching products...');

    final Set<String> productIds = {
      kSubscriptionProductId,
    };

    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint(
          '⚠️ [SubscriptionService] Products not found: ${response.notFoundIDs}');
    }

    if (response.error != null) {
      debugPrint(
          '❌ [SubscriptionService] Error fetching products: ${response.error}');
      return [];
    }

    debugPrint(
        '✅ [SubscriptionService] Found ${response.productDetails.length} products');
    return response.productDetails;
  }

  /// Purchase a subscription — รองรับ Base Plan selection
  ///
  /// [product]     — ProductDetails จาก queryProductDetails
  /// [basePlanId]  — Base Plan ที่ต้องการ เช่น 'energy-pass-monthly'
  ///                 ถ้าไม่ระบุ → ใช้ base plan แรกที่เจอ
  Future<bool> purchaseSubscription(
    ProductDetails product, {
    String? basePlanId,
  }) async {
    debugPrint('💰 [SubscriptionService] Purchasing: ${product.id} basePlan: $basePlanId');

    try {
      PurchaseParam purchaseParam;

      if (Platform.isAndroid) {
        // Google Play Billing: ต้องใช้ GooglePlayPurchaseParam พร้อม offerToken
        final androidDetails = product as GooglePlayProductDetails;
        final offerDetails = androidDetails.productDetails.subscriptionOfferDetails;

        if (offerDetails == null || offerDetails.isEmpty) {
          debugPrint('⚠️ [SubscriptionService] No offer details found');
          return false;
        }

        // หา offer ที่ตรงกับ basePlanId ที่ต้องการ
        // ถ้าไม่ระบุ basePlanId → ใช้ offer แรก
        final targetOffer = basePlanId != null
            ? offerDetails.firstWhere(
                (o) => o.basePlanId == basePlanId,
                orElse: () => offerDetails.first,
              )
            : offerDetails.first;

        debugPrint(
          '💳 [SubscriptionService] Using offerIdToken for basePlan: ${targetOffer.basePlanId}',
        );

        purchaseParam = GooglePlayPurchaseParam(
          productDetails: product,
          offerToken: targetOffer.offerIdToken,
        );
      } else {
        purchaseParam = PurchaseParam(productDetails: product);
      }

      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      debugPrint('💳 [SubscriptionService] Purchase initiated: $success');
      return success;
    } catch (e) {
      debugPrint('❌ [SubscriptionService] Purchase error: $e');
      return false;
    }
  }

  /// ดึง offer details สำหรับ base plan ที่ระบุ
  /// ใช้สำหรับแสดงราคาจริงจาก Google Play
  static Map<String, String> extractBasePlanPrices(ProductDetails product) {
    final prices = <String, String>{};
    if (!Platform.isAndroid) return prices;

    try {
      final androidDetails = product as GooglePlayProductDetails;
      final offerDetails = androidDetails.productDetails.subscriptionOfferDetails;
      if (offerDetails == null) return prices;

      for (final offer in offerDetails) {
        // pricingPhases เป็น List<PricingPhaseWrapper> โดยตรง
        if (offer.pricingPhases.isNotEmpty) {
          // ใช้ phase สุดท้าย = ราคาปกติ (หลังจบ trial/intro)
          final phase = offer.pricingPhases.last;
          prices[offer.basePlanId] = phase.formattedPrice;
        }
      }
    } catch (e) {
      debugPrint('⚠️ [SubscriptionService] extractBasePlanPrices error: $e');
    }
    return prices;
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    debugPrint('🔄 [SubscriptionService] Restoring purchases...');
    await _inAppPurchase.restorePurchases();
  }

  /// Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    debugPrint(
        '📦 [SubscriptionService] Purchase update: ${purchaseDetailsList.length} items');

    for (final PurchaseDetails purchase in purchaseDetailsList) {
      debugPrint('   - ${purchase.productID}: ${purchase.status}');

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Verify with backend
        _verifyPurchaseWithBackend(purchase);
      }

      if (purchase.status == PurchaseStatus.error) {
        debugPrint('❌ [SubscriptionService] Purchase error: ${purchase.error}');
      }

      // Complete the purchase
      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }
    }
  }

  /// Verify purchase with backend
  Future<void> _verifyPurchaseWithBackend(PurchaseDetails purchase) async {
    debugPrint('🔐 [SubscriptionService] Verifying with backend...');

    try {
      // Get device ID (you'll need to implement this)
      final String deviceId = await _getDeviceId();

      final response = await http.post(
        Uri.parse(_verifySubscriptionUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'deviceId': deviceId,
          'purchaseToken': purchase.verificationData.serverVerificationData,
          'productId': purchase.productID,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('✅ [SubscriptionService] Verification success: $data');
      } else {
        debugPrint(
            '❌ [SubscriptionService] Verification failed: ${response.statusCode}');
        debugPrint('   Body: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ [SubscriptionService] Verification error: $e');
    }
  }

  /// Get device ID from DeviceIdService
  Future<String> _getDeviceId() async {
    return await DeviceIdService.getDeviceId();
  }

  /// Check subscription status from Firestore
  Future<SubscriptionData> checkSubscriptionStatus(String deviceId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(deviceId)
          .get();

      if (!doc.exists) return SubscriptionData.empty();

      final data = doc.data();
      final subData = data?['subscription'] as Map<String, dynamic>?;
      return SubscriptionData.fromFirestore(subData);
    } catch (e) {
      debugPrint('❌ [SubscriptionService] checkSubscriptionStatus error: $e');
      return SubscriptionData.empty();
    }
  }

  /// Dispose the service
  void dispose() {
    _subscription?.cancel();
    debugPrint('🔌 [SubscriptionService] Disposed');
  }

  /// Get subscription benefits
  static List<String> getSubscriptionBenefits() {
    return SubscriptionPlan.energyPassMonthly().benefits;
  }

  /// Check if user has unlimited AI access
  static bool hasUnlimitedAI(SubscriptionData subscription) {
    return subscription.isActive;
  }

  /// Check if user gets double rewards
  static bool hasDoubleRewards(SubscriptionData subscription) {
    return subscription.isActive;
  }

  /// Check if user has exclusive badge
  static bool hasExclusiveBadge(SubscriptionData subscription) {
    return subscription.isActive;
  }
}
