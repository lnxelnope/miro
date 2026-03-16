# Google Ads — คู่มือสำหรับทีมพัฒนา

คู่มือนี้สำหรับ **นักพัฒนา** ที่ต้องแก้ไขโค้ดเพื่อให้ระบบ Google Ads Conversion Tracking ทำงานได้เต็มประสิทธิภาพ

---

## 🎯 วัตถุประสงค์

1. เพิ่ม User Properties ที่จำเป็นสำหรับการทำ Audience Segmentation ใน Google Ads
2. เพิ่ม Events เพิ่มเติมเพื่อติดตามพฤติกรรมผู้ใช้ที่ละเอียดขึ้น
3. ปรับปรุง Existing Code ให้เป็นมาตรฐาน Google Analytics 4

---

## 📋 สิ่งที่ขาดหาย (จาก Audit)

### ❌ User Properties ที่ยังไม่มี

| Property | ค่าที่แนะนำ | วัตถุประสงค์ | ความสำคัญ |
|----------|-----------|-------------|------------|
| `user_type` | `'free'`, `'premium'`, `'high_value'` | แยกกลุ่มผู้ใช้งานตามมูลค่า | ⭐⭐⭐ สูงมาก |
| `purchase_frequency` | `'none'`, `'one_time'`, `'recurring'` | ประเมิน Lifetime Value | ⭐⭐สูง |
| `first_purchase_date` | ISO 8601 date | ติดตามระยะเวลาซื้อครั้งแรก | ⭐⭐สูง |
| `last_purchase_date` | ISO 8601 date | หาผู้ใช้ที่อาจ Churn | ⭐⭐สูง |

### ❌ Events ที่ยังไม่มี

| Event | พารามิเตอร์ | วัตถุประสงค์ | ความสำคัญ |
|-------|------------|-------------|------------|
| `repeat_purchase` | `package_id`, `days_since_last` | ติดตามการซื้อซ้ำ | ⭐⭐⭐ สูงมาก |
| `failed_payment` | `error_type`, `product_id` | หาจุดล้มเหลวในกระบวนการซื้อ | ⭐⭐สูง |

---

## 🔧 ขั้นตอนการแก้ไข

### 1. เพิ่ม User Properties ใหม่

**ไฟล์:** [`lib/core/services/analytics_service.dart`](../../lib/core/services/analytics_service.dart)

**เพิ่มที่ Line ~40 (หลัง setUserProperty ที่มีอยู่):**

```dart
// ใน method initialize() และ updateUserProperties()
if (totalSpent != null) {
  await _analytics.setUserProperty(
    name: 'user_type', 
    value: totalSpent > 100 ? 'high_value' : 'free_user',
  );
  
  await _analytics.setUserProperty(
    name: 'purchase_frequency',
    value: isSubscriber ? 'recurring' : (totalSpent > 0 ? 'one_time' : 'none'),
  );
}

// เพิ่มสำหรับ tracking purchase timeline (เรียกเมื่อมี purchase event)
await _analytics.setUserProperty(
  name: 'last_purchase_date',
  value: DateTime.now().toIso8601String().split('T')[0], // เฉพาะวันที่
);
```

**เหตุผล:**
- `user_type` ช่วยสร้าง Custom Audience ใน Google Ads เช่น "High Value Users" สำหรับ Lookalike
- `purchase_frequency` ช่วยแยกผู้ซื้อครั้งเดียว vs ผู้สมัครสมาชิก เพื่อทำ Retargeting ที่ต่างกัน

---

### 2. เพิ่ม Method `logRepeatPurchase()`

**ไฟล์:** [`lib/core/services/analytics_service.dart`](../../lib/core/services/analytics_service.dart)

**เพิ่มหลัง Line 184 (ท้าย method `logEnergyPurchase`):**

```dart
/// Track repeat purchase (ผู้ซื้อซ้ำ)
static Future<void> logRepeatPurchase({
  required String packageId,
  required int daysSinceLastPurchase,
}) async {
  await _logEvent('repeat_purchase', {
    'package_id': packageId,
    'days_since_last_purchase': daysSinceLastPurchase,
  });
}

/// Track failed payment (การชำระเงินล้มเหลว)
static Future<void> logPaymentFailed({
  required String productId,
  required String errorType, // เช่น 'insufficient_funds', 'network_error'
}) async {
  await _logEvent('payment_failed', {
    'product_id': productId,
    'error_type': errorType,
  });
}
```

**เหตุผล:**
- `repeat_purchase` ช่วย Google Ads หา Pattern ของผู้ซื้อซ้ำ เพื่อไปหาผู้ใช้แบบเดียวกัน
- `payment_failed` ช่วยหาจุดล้มเหลว (เช่น Error type อะไรบ่อยที่สุด)

---

### 3. เรียกใช้ Method ใหม่ใน Purchase Service

**ไฟล์:** [`lib/core/services/purchase_service.dart`](../../lib/core/services/purchase_service.dart)

**เพิ่ม Logic ตรวจสอบการซื้อซ้ำ:**

```dart
// ใน method _handleEnergyPurchase() (Line ~256), หลัง AnalyticsService.logEnergyPurchase():

// ตรวจสอบว่านี่เป็นการซื้อซ้ำหรือไม่
final lastPurchaseDate = await energyService.getLastPurchaseDate();
if (lastPurchaseDate != null) {
  final daysSinceLast = DateTime.now().difference(lastPurchaseDate).inDays;
  
  // เรียก logRepeatPurchase ถ้าไม่ใช่ครั้งแรก
  AnalyticsService.logRepeatPurchase(
    packageId: productId,
    daysSinceLastPurchase: daysSinceLast,
  );
}

// บันทึกวันที่ซื้อล่าสุด
await energyService.setLastPurchaseDate(DateTime.now());
```

**เพิ่ม Error Tracking:**

```dart
// ใน method _handleEnergyPurchase() (Line ~319), กรณี PurchaseStatus.error:

AnalyticsService.logPaymentFailed(
  productId: productId,
  errorType: purchase.error?.code ?? 'unknown',
);
```

---

### 4. เพิ่ม Event Tracking สำหรับ Onboarding Completion

**ไฟล์:** [`lib/core/services/analytics_service.dart`](../../lib/core/services/analytics_service.dart)

**เพิ่ม Method ใหม่หลัง Line 246 (ท้าย `logOnboardingComplete`):**

```dart
/// Onboarding completed with subscription signup
static Future<void> logOnboardingSubscribe({
  required String planType, // 'weekly', 'monthly', 'yearly'
}) async {
  await _logEvent('onboarding_subscribe', {
    'plan_type': planType,
  });
}
```

**ไฟล์:** [`lib/features/onboarding/presentation/`](../../lib/features/onboarding/)

**เพิ่มการเรียกใน Onboarding Screen (หลังผู้ใช้สมัครสมาชิกสำเร็จ):**

```dart
AnalyticsService.logOnboardingSubscribe(
  planType: selectedPlan.toString(), // 'weekly', 'monthly', 'yearly'
);
```

---

## ✅ Checklist หลังแก้ไข

- [ ] เพิ่ม User Properties (`user_type`, `purchase_frequency`)
- [ ] เพิ่ม Method `logRepeatPurchase()` และ `logPaymentFailed()`
- [ ] เรียกใช้ Methods ใหม่ใน Purchase Service
- [ ] เพิ่ม Event tracking สำหรับ Onboarding Subscribe
- [ ] รัน `flutter gen-l10n` (ถ้ามี string ใหม่)
- [ ] Test บน Staging environment ก่อน Deploy

---

## 🧪 การทดสอบ

### 1. ทดสอบ User Properties

```bash
# รัน app แล้วเปิด Firebase Console → Analytics → Events
# ตรวจสอบว่า user_tier, is_subscriber, user_type, purchase_frequency ถูกส่งไป
```

### 2. ทดสอบ Purchase Event

```dart
// ใน test environment:
AnalyticsService.logEnergyPurchase(
  packageId: 'test_package',
  energyAmount: 100,
  price: 35.0,
  currency: 'THB',
);

// ตรวจสอบใน Firebase Console → Events → purchase
```

### 3. ทดสอบ Repeat Purchase Event

```dart
// Mock last purchase date เป็น 7 วันที่แล้ว
await energyService.setLastPurchaseDate(DateTime.now().subtract(Duration(days: 7)));

// ทำการซื้ออีกครั้ง → ควร log repeat_purchase
AnalyticsService.logEnergyPurchase(...);
```

---

## 📊 การตั้งค่าใน Google Ads (สำหรับทีม Marketing)

**หมายเหตุ:** ส่วนนี้ไม่ต้องแก้โค้ด แต่ต้องแจ้งทีม Marketing ให้ไปทำใน Console

### User Properties ที่ส่งไปแล้ว:

| Property | ค่าที่เป็นไปได้ | ใช้สร้าง Audience ได้ว่า |
|----------|----------------|-------------------------|
| `user_tier` | `'free'`, `'basic'`, `'premium'` | ผู้ใช้ตามระดับ |
| `is_subscriber` | `'true'`, `'false'` | สมาชิก vs ไม่สมาชิก |
| `total_energy_spent` | `'0'`, `'1-49'`, `'50-199'`, ... | ผู้ใช้จ่ายตามยอด |
| `streak_days` | `'0'`, `'1-2'`, `'3-6'`, ... | ผู้ใช้ที่ Active ตาม streak |

### User Properties ที่ต้องเพิ่ม (หลังแก้โค้ด):

| Property | ค่าที่เป็นไปได้ | ใช้สร้าง Audience ได้ว่า |
|----------|----------------|-------------------------|
| `user_type` | `'free_user'`, `'high_value'` | **High Value Users** (Lookalike) |
| `purchase_frequency` | `'none'`, `'one_time'`, `'recurring'` | **Repeat Buyers**, **Churned Users** |

---

## 🚨 ข้อควรระวัง

1. **ห้าม Hardcode Prices:** ต้องใช้ `_getProductPrice()` หรือดึงจาก Google Play API
2. **Currency ต้องถูกต้อง:** ส่ง `currency: 'THB'` ไม่ใช่ `'บาท'` (ต้องเป็น ISO 4217)
3. **Respect Consent:** ตรวจสอบ `AnalyticsService.isEnabled` ก่อน log event
4. **Test Before Deploy:** ทดสอบบน Staging environment ก่อน production

---

## 📚 เอกสารอ้างอิง

- [Firebase Analytics Event Reference](https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics)
- [Google Ads Conversion Tracking](https://support.google.com/google-ads/answer/6095438)
- [Custom Dimensions & Metrics](https://support.google.com/analytics/answer/9016768)

---

## 🔄 Version History

| Version | วันที่ | ผู้แก้ไข | การเปลี่ยนแปลง |
|---------|-------|---------|---------------|
| 1.0 | 2026-03-11 | AI Assistant | สร้างคู่มือฉบับแรก |
