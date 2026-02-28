# Phase 5 - Task 2: Subscription UI (Flutter)

**Status:** 📝 Ready for Implementation  
**Estimated Time:** 6-8 hours  
**Difficulty:** ⭐⭐⭐⭐ Medium-Hard  
**Prerequisites:** Task 1 (Subscription Backend) must be completed

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Requirements](#requirements)
3. [UI Design](#ui-design)
4. [Step-by-Step Implementation](#step-by-step-implementation)
5. [Testing](#testing)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

สร้าง UI สำหรับ Subscription System:

**Features:**
- หน้าแสดง subscription plans
- Purchase flow (Google Play Billing)
- Success/Error handling
- Subscription management page
- Show benefits badge

---

## 📊 Requirements

### Functional Requirements
- [ ] แสดง subscription plan (Energy Pass)
- [ ] Purchase button with loading state
- [ ] Verify purchase กับ server
- [ ] แสดง subscription status
- [ ] Manage subscription (cancel, restore)
- [ ] Show subscriber badge

### Non-Functional Requirements
- [ ] Purchase flow < 10 seconds
- [ ] Smooth animations
- [ ] Clear error messages
- [ ] iOS + Android compatible

---

## 🎨 UI Design

### Subscription Screen

```
┌────────────────────────────────────┐
│  ← Energy Pass                  ⚡│
├────────────────────────────────────┤
│                                    │
│  💎 Energy Pass                    │
│  Premium                           │
│                                    │
│  ┌──────────────────────────────┐ │
│  │  ✨ Unlimited AI Analysis    │ │
│  │  🎁 Double Streak Rewards    │ │
│  │  👑 Exclusive Badge          │ │
│  │  📱 Priority Support         │ │
│  └──────────────────────────────┘ │
│                                    │
│  ┌──────────────────────────────┐ │
│  │                              │ │
│  │       ฿149 / month           │ │
│  │                              │ │
│  │  [ Subscribe Now ]           │ │
│  │                              │ │
│  │  7-day free trial            │ │
│  │  Cancel anytime              │ │
│  └──────────────────────────────┘ │
│                                    │
│  ℹ️ Your subscription will         │
│     renew automatically            │
│                                    │
└────────────────────────────────────┘
```

### Active Subscription Screen

```
┌────────────────────────────────────┐
│  ← My Subscription              ⚡ │
├────────────────────────────────────┤
│                                    │
│  ✅ Energy Pass Active             │
│                                    │
│  ┌──────────────────────────────┐ │
│  │  Status: Active              │ │
│  │  Renews: Mar 17, 2026        │ │
│  │  Price: ฿149/month           │ │
│  └──────────────────────────────┘ │
│                                    │
│  Your Benefits:                    │
│  ✨ Unlimited AI Analysis          │
│  🎁 Double Rewards                 │
│  👑 Exclusive Badge                │
│                                    │
│  [ Manage Subscription ]           │
│  (Opens Google Play)               │
│                                    │
└────────────────────────────────────┘
```

---

## 🚀 Step-by-Step Implementation

### Step 1: Add Dependencies

#### 1.1 Update pubspec.yaml

```yaml
dependencies:
  in_app_purchase: ^3.1.11
  in_app_purchase_android: ^0.3.0+16
  in_app_purchase_storekit: ^0.3.6+6
```

#### 1.2 Install

```bash
flutter pub get
```

---

### Step 2: Configure Android

#### 2.1 Update AndroidManifest.xml

**File:** `android/app/src/main/AndroidManifest.xml`

```xml
<manifest>
  <application>
    <!-- เพิ่มใน <application> -->
    <meta-data
      android:name="com.google.android.play.billingclient.version"
      android:value="6.0.1" />
  </application>
</manifest>
```

#### 2.2 Update build.gradle

**File:** `android/app/build.gradle`

```gradle
dependencies {
    // เพิ่ม
    implementation 'com.android.billingclient:billing:6.0.1'
}
```

---

### Step 3: Create Subscription Service

#### 3.1 Create Service

**File:** `lib/core/services/subscription_service.dart`

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'device_id_service.dart';
import '../config/firebase_config.dart';

final subscriptionServiceProvider = Provider((ref) {
  return SubscriptionService(
    deviceIdService: ref.read(deviceIdServiceProvider),
  );
});

class SubscriptionService {
  final DeviceIdService deviceIdService;
  final InAppPurchase _iap = InAppPurchase.instance;

  static const String productId = 'energy_pass_monthly';

  SubscriptionService({required this.deviceIdService});

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
      final deviceId = await deviceIdService.getDeviceId();
      String purchaseToken = '';

      if (Platform.isAndroid) {
        final androidDetails = purchase as GooglePlayPurchaseDetails;
        purchaseToken = androidDetails.billingClientPurchase.purchaseToken;
      }

      final response = await http.post(
        Uri.parse('${FirebaseConfig.functionsUrl}/verifySubscription'),
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
}
```

---

### Step 4: Create Subscription Provider

#### 4.1 Create Provider

**File:** `lib/features/subscription/providers/subscription_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../core/services/subscription_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/device_id_service.dart';

// Product Details Provider
final subscriptionProductsProvider = FutureProvider<List<ProductDetails>>((ref) async {
  final service = ref.read(subscriptionServiceProvider);
  return await service.getProducts();
});

// Subscription Status Provider
final subscriptionStatusProvider = StreamProvider<SubscriptionStatus>((ref) async* {
  final deviceId = await ref.read(deviceIdServiceProvider).getDeviceId();

  yield* FirebaseFirestore.instance
      .collection('users')
      .doc(deviceId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) {
      return SubscriptionStatus(isActive: false);
    }

    final data = doc.data()!;
    final subscription = data['subscription'] as Map<String, dynamic>?;

    if (subscription == null) {
      return SubscriptionStatus(isActive: false);
    }

    final expiryTime = (subscription['expiryTime'] as Timestamp?)?.toDate();
    final isActive = subscription['active'] == true && 
        expiryTime != null && 
        expiryTime.isAfter(DateTime.now());

    return SubscriptionStatus(
      isActive: isActive,
      productId: subscription['productId'],
      expiryTime: expiryTime,
    );
  });
});

// Purchase Stream Provider
final purchaseStreamProvider = StreamProvider<List<PurchaseDetails>>((ref) {
  final service = ref.read(subscriptionServiceProvider);
  return service.purchaseStream;
});

class SubscriptionStatus {
  final bool isActive;
  final String? productId;
  final DateTime? expiryTime;

  SubscriptionStatus({
    required this.isActive,
    this.productId,
    this.expiryTime,
  });
}
```

---

### Step 5: Create Subscription Screen

#### 5.1 Create Screen

**File:** `lib/features/subscription/presentation/subscription_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../providers/subscription_provider.dart';
import '../../../core/services/subscription_service.dart';
import 'package:intl/intl.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _listenToPurchaseUpdates();
  }

  void _listenToPurchaseUpdates() {
    ref.listen<AsyncValue<List<PurchaseDetails>>>(
      purchaseStreamProvider,
      (_, state) {
        state.whenData((purchases) async {
          for (var purchase in purchases) {
            if (purchase.status == PurchaseStatus.purchased) {
              // Verify with server
              final verified = await ref
                  .read(subscriptionServiceProvider)
                  .verifyPurchaseWithServer(purchase);

              if (verified) {
                // Complete purchase
                await ref
                    .read(subscriptionServiceProvider)
                    .completePurchase(purchase);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 Subscription activated!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Verification failed'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }

              setState(() => _isPurchasing = false);
            } else if (purchase.status == PurchaseStatus.error) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Purchase failed: ${purchase.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              setState(() => _isPurchasing = false);
            } else if (purchase.status == PurchaseStatus.pending) {
              setState(() => _isPurchasing = true);
            }
          }
        });
      },
    );
  }

  Future<void> _subscribe() async {
    final products = await ref.read(subscriptionProductsProvider.future);

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Product not found')),
      );
      return;
    }

    setState(() => _isPurchasing = true);

    try {
      await ref.read(subscriptionServiceProvider).subscribe(products.first);
    } catch (e) {
      setState(() => _isPurchasing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);
    final products = ref.watch(subscriptionProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Pass'),
        elevation: 0,
      ),
      body: subscriptionStatus.when(
        data: (status) {
          if (status.isActive) {
            return _buildActiveSubscription(status);
          } else {
            return _buildSubscriptionOffer(products);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildActiveSubscription(SubscriptionStatus status) {
    final expiryDate = status.expiryTime;
    final formattedDate = expiryDate != null
        ? DateFormat('MMM dd, yyyy').format(expiryDate)
        : 'Unknown';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 64,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '✅ Energy Pass Active',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Renews: $formattedDate',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Benefits:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildBenefitTile('✨', 'Unlimited AI Analysis', 'No energy cost'),
          _buildBenefitTile('🎁', 'Double Rewards', 'Earn 2x energy from streaks'),
          _buildBenefitTile('👑', 'Exclusive Badge', 'Show your premium status'),
          _buildBenefitTile('📱', 'Priority Support', 'Get help faster'),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              // Open Google Play subscription management
              // ใช้ url_launcher
            },
            icon: const Icon(Icons.settings),
            label: const Text('Manage Subscription'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionOffer(AsyncValue<List<ProductDetails>> productsAsync) {
    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return const Center(child: Text('No products available'));
        }

        final product = products.first;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '💎 Energy Pass Premium',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildBenefitTile('✨', 'Unlimited AI Analysis', 'No energy cost'),
                      _buildBenefitTile('🎁', 'Double Streak Rewards', 'Earn 2x energy'),
                      _buildBenefitTile('👑', 'Exclusive Badge', 'Premium member'),
                      _buildBenefitTile('📱', 'Priority Support', 'Get help faster'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        product.price,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Text(
                        '/ month',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isPurchasing ? null : _subscribe,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isPurchasing
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Subscribe Now',
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '7-day free trial • Cancel anytime',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ℹ️ Your subscription will renew automatically. You can cancel anytime from Google Play.',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildBenefitTile(String emoji, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🧪 Testing

### Test Purchase Flow

1. เปิด subscription screen
2. กด "Subscribe Now"
3. Complete purchase ใน Google Play
4. ตรวจสอบว่า subscription active
5. ตรวจสอบว่าใช้ AI ไม่เสีย energy

### Test Subscription Status

- [ ] Active subscription แสดงสถานะถูกต้อง
- [ ] Expiry date แสดงถูกต้อง
- [ ] Benefits แสดงครบ
- [ ] Badge แสดงใน app

---

## ✅ Completion Checklist

- [ ] Dependencies installed
- [ ] Android configured
- [ ] Service created
- [ ] Providers created
- [ ] UI created
- [ ] Purchase flow tested
- [ ] Verification working
- [ ] Subscription status synced

---

**Documentation Version:** 1.0  
**Last Updated:** 2026-02-17  
**Author:** Senior Developer  
**For:** Junior Developer