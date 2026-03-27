import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription_data.dart';
import '../models/subscription_plan.dart';
import '../../../core/services/device_id_service.dart';

/// Subscription Service
///
/// Product queries, purchase initiation, and status checks.
/// Purchase stream handling is done by PurchaseService (single listener).
class SubscriptionService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  // Android: single product with multiple base plans
  static const String kSubscriptionProductId = 'miro_normal_subscription';

  // Android base plan keys
  static const String kSubscriptionMonthlyBasePlan = 'energy-pass-monthly';
  static const String kSubscriptionYearlyBasePlan = 'energy-pass-yearly';

  // iOS: each plan = 1 product (App Store structure)
  static const String kIosMonthlyProductId = 'miro_energy_pass_monthly';
  static const String kIosYearlyProductId = 'miro_energy_pass_yearly';

  static Set<String> get _subscriptionProductIds {
    if (Platform.isIOS) {
      return {kIosMonthlyProductId, kIosYearlyProductId};
    }
    return {kSubscriptionProductId};
  }

  /// Check if in-app purchase is available
  Future<bool> isAvailable() async {
    return await _inAppPurchase.isAvailable();
  }

  /// Get available subscription products
  /// Android: 1 product (miro_normal_subscription) with base plans
  /// iOS: 3 products (miro_energy_pass_weekly, monthly, yearly)
  Future<List<ProductDetails>> getProducts() async {
    debugPrint('🔍 [SubscriptionService] Fetching products: $_subscriptionProductIds');

    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_subscriptionProductIds);

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
    for (final p in response.productDetails) {
      debugPrint('   📦 ${p.id}: ${p.price} — ${p.title}');
      if (Platform.isAndroid) {
        try {
          final android = p as GooglePlayProductDetails;
          final offers = android.productDetails.subscriptionOfferDetails ?? [];
          for (final o in offers) {
            debugPrint(
              '      └─ basePlan=${o.basePlanId} offerId=${o.offerId} '
              'phases=${o.pricingPhases.length}',
            );
            for (var i = 0; i < o.pricingPhases.length; i++) {
              final ph = o.pricingPhases[i];
              debugPrint(
                '         phase[$i] ${ph.formattedPrice} '
                '(${ph.priceAmountMicros} micros / ${ph.priceCurrencyCode}) '
                'recurrence=${ph.recurrenceMode} billing=${ph.billingPeriod}',
              );
            }
          }
        } catch (_) {}
      }
    }
    return response.productDetails;
  }

  /// Purchase a subscription — รองรับ Base Plan selection
  ///
  /// [product]     — ProductDetails จาก queryProductDetails
  /// [basePlanId]  — Base Plan ที่ต้องการ เช่น 'energy-pass-monthly'
  ///                 ถ้าไม่ระบุ → ใช้ base plan แรกที่เจอ (Android only)
  Future<bool> purchaseSubscription(
    ProductDetails product, {
    String? basePlanId,
  }) async {
    debugPrint('💰 [SubscriptionService] Purchasing: ${product.id} basePlan: $basePlanId');

    try {
      PurchaseParam purchaseParam;

      if (Platform.isAndroid) {
        final androidDetails = product as GooglePlayProductDetails;
        final offerDetails = androidDetails.productDetails.subscriptionOfferDetails;

        if (offerDetails == null || offerDetails.isEmpty) {
          debugPrint('⚠️ [SubscriptionService] No offer details found');
          return false;
        }

        SubscriptionOfferDetailsWrapper targetOffer;
        if (basePlanId != null) {
          final matchingOffers =
              offerDetails.where((o) => o.basePlanId == basePlanId).toList();
          if (matchingOffers.isEmpty) {
            targetOffer = offerDetails.first;
          } else {
            // Prefer the standard offer (no offerId) to match displayed price
            final standard =
                matchingOffers.where((o) => o.offerId == null).toList();
            targetOffer = standard.isNotEmpty ? standard.first : matchingOffers.first;
          }
        } else {
          targetOffer = offerDetails.first;
        }

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

  /// Per base plan: recurring price from Play (prefers offer without [offerId]).
  static Map<String, SubscriptionBasePlanPricing> extractBasePlanPricing(
    ProductDetails product,
  ) {
    final result = <String, SubscriptionBasePlanPricing>{};
    if (!Platform.isAndroid) return result;

    try {
      final androidDetails = product as GooglePlayProductDetails;
      final offers = androidDetails.productDetails.subscriptionOfferDetails;
      if (offers == null || offers.isEmpty) return result;

      final byBase = <String, List<SubscriptionOfferDetailsWrapper>>{};
      for (final o in offers) {
        byBase.putIfAbsent(o.basePlanId, () => []).add(o);
      }

      for (final entry in byBase.entries) {
        final list = entry.value;
        final withoutOfferId =
            list.where((o) => o.offerId == null).toList();
        final chosen =
            withoutOfferId.isNotEmpty ? withoutOfferId.first : list.first;

        final phase = _selectRecurringPricingPhase(chosen.pricingPhases);
        if (phase == null) continue;

        result[entry.key] = SubscriptionBasePlanPricing(
          formattedPrice: phase.formattedPrice,
          priceAmountMicros: phase.priceAmountMicros,
          priceCurrencyCode: phase.priceCurrencyCode,
        );
      }
    } catch (e) {
      debugPrint('⚠️ [SubscriptionService] extractBasePlanPricing error: $e');
    }
    return result;
  }

  static PricingPhaseWrapper? _selectRecurringPricingPhase(
    List<PricingPhaseWrapper> phases,
  ) {
    if (phases.isEmpty) return null;
    for (final p in phases) {
      if (p.recurrenceMode == RecurrenceMode.infiniteRecurring &&
          p.priceAmountMicros > 0) {
        return p;
      }
    }
    for (final p in phases.reversed) {
      if (p.priceAmountMicros > 0) return p;
    }
    return phases.last;
  }

  static Map<String, String> extractBasePlanPrices(ProductDetails product) {
    return extractBasePlanPricing(product)
        .map((k, v) => MapEntry(k, v.formattedPrice));
  }

  /// ดึงราคาจาก products (iOS: แต่ละ product มี price ของตัวเอง)
  static Map<String, String> extractProductPrices(List<ProductDetails> products) {
    final prices = <String, String>{};
    for (final p in products) {
      prices[p.id] = p.price;
    }
    return prices;
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    debugPrint('🔄 [SubscriptionService] Restoring purchases...');
    await _inAppPurchase.restorePurchases();
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

  /// Verify subscription with backend (callable from outside if needed)
  Future<Map<String, dynamic>?> verifyWithBackend({
    required String purchaseToken,
    required String productId,
  }) async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();

      final response = await http
          .post(
            Uri.parse(
                'https://us-central1-miro-d6856.cloudfunctions.net/verifySubscription'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'deviceId': deviceId,
              'purchaseToken': purchaseToken,
              'productId': productId,
              'platform': Platform.isIOS ? 'ios' : 'android',
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint(
            '❌ [SubscriptionService] Verification failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ [SubscriptionService] Verification error: $e');
      return null;
    }
  }

  /// Get subscription benefits
  static List<String> getSubscriptionBenefits() {
    return SubscriptionPlan.energyPassMonthly().benefits;  // fallback English (no context in service)
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

/// Recurring price for one Google Play base plan (from Billing Library).
class SubscriptionBasePlanPricing {
  const SubscriptionBasePlanPricing({
    required this.formattedPrice,
    required this.priceAmountMicros,
    required this.priceCurrencyCode,
  });

  final String formattedPrice;
  final int priceAmountMicros;
  final String priceCurrencyCode;
}
