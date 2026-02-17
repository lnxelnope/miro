import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'device_id_service.dart';

final subscriptionServiceProvider = Provider((ref) {
  return SubscriptionService();
});

class SubscriptionService {
  final InAppPurchase _iap = InAppPurchase.instance;

  static const String productId = 'energy_pass_monthly';
  static const String _baseUrl =
      'https://us-central1-miro-d6856.cloudfunctions.net';

  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  Future<bool> isAvailable() async {
    return await _iap.isAvailable();
  }

  Future<List<ProductDetails>> getProducts() async {
    final available = await _iap.isAvailable();
    if (!available) {
      throw Exception('In-app purchase not available');
    }

    final response = await _iap.queryProductDetails({productId});

    if (response.error != null) {
      throw Exception('Failed to query products: ${response.error}');
    }

    return response.productDetails;
  }

  Future<void> subscribe(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);

    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      throw Exception('Purchase failed: $e');
    }
  }

  Future<bool> verifyPurchaseWithServer(PurchaseDetails purchase) async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      String purchaseToken = '';

      if (Platform.isAndroid) {
        final androidDetails = purchase as GooglePlayPurchaseDetails;
        purchaseToken = androidDetails.billingClientPurchase.purchaseToken;
      } else {
        // iOS - use serverVerificationData
        purchaseToken = purchase.verificationData.serverVerificationData;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/verifySubscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': deviceId,
          'purchaseToken': purchaseToken,
          'productId': purchase.productID,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        print('Verification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Verification error: $e');
      return false;
    }
  }

  Future<void> completePurchase(PurchaseDetails purchase) async {
    await _iap.completePurchase(purchase);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  /// Legacy static methods for backward compatibility
  static Future<Map<String, dynamic>> verifySubscription(
    String purchaseToken,
    String productId,
  ) async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final url = Uri.parse('$_baseUrl/verifySubscription');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': deviceId,
          'purchaseToken': purchaseToken,
          'productId': productId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['error'] ?? 'Failed to verify subscription');
      }
    } catch (e) {
      throw Exception('Subscription verification failed: $e');
    }
  }
}
