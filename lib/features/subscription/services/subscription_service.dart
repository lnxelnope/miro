import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/subscription_data.dart';
import '../models/subscription_plan.dart';

/// Subscription Service
/// 
/// Handles Google Play Billing and subscription verification
class SubscriptionService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Firebase Functions endpoints
  static const String _verifySubscriptionUrl =
      'https://verifysubscription-lkfwupvm7a-uc.a.run.app';

  // Product IDs
  static const String kEnergyPassMonthlyId = 'energy_pass_monthly';

  /// Initialize the service
  Future<void> initialize() async {
    debugPrint('🔧 [SubscriptionService] Initializing...');

    // Android-specific initialization
    if (Platform.isAndroid) {
      final InAppPurchaseAndroidPlatformAddition androidAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      // enablePendingPurchases() is deprecated and no longer needed
      // The library handles this automatically
    }

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
      kEnergyPassMonthlyId,
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

  /// Purchase a subscription
  Future<bool> purchaseSubscription(ProductDetails product) async {
    debugPrint('💰 [SubscriptionService] Purchasing: ${product.id}');

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: product,
    );

    try {
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

  /// Get device ID (implement based on your existing service)
  Future<String> _getDeviceId() async {
    // TODO: Implement using your existing DeviceIdService
    // For now, return a placeholder
    return 'device-id-placeholder';
  }

  /// Check subscription status from Firestore
  Future<SubscriptionData> checkSubscriptionStatus(String deviceId) async {
    // This will be implemented in the provider
    // For now, return empty
    return SubscriptionData.empty();
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
