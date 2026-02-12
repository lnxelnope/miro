# Miro Monetization Plan — Freemium + Upsell

---

## คำตอบสั้น: ทำ 1 แอป + In-App Purchase (ไม่ต้อง 2 version)

### ทำไมไม่ควรทำ 2 version?

| | 1 แอป + IAP | 2 แอป (Free + Paid) |
|---|-------------|---------------------|
| Maintain | 1 codebase | 2 codebase (nightmare) |
| User experience | อัปเกรดในแอปเลย | ต้องลบแอปเก่า โหลดใหม่ ย้ายข้อมูล |
| Play Store | 1 listing, review ดีรวมกัน | 2 listing, review แยก |
| Analytics | เห็น conversion rate ชัด | ติดตามยาก |
| Update | push ทีเดียว | push 2 ที |
| Google นิยม | Google แนะนำวิธีนี้ | ล้าสมัย |

**สรุป: ทำ 1 แอป + In-App Purchase เท่านั้นครับ**

---

## โมเดลธุรกิจที่แนะนำ

```
┌─────────────────────────────────────────────────────┐
│                  Miro Cal (Free)                     │
│                                                      │
│  ✅ บันทึกอาหารด้วยมือ        ← ไม่จำกัด            │
│  ✅ Quick Add                  ← ไม่จำกัด            │
│  ✅ สร้าง My Meal              ← ไม่จำกัด            │
│  ✅ ดูสรุป kcal / macro         ← ไม่จำกัด            │
│  ✅ ตั้งเป้าหมายสุขภาพ          ← ไม่จำกัด            │
│  ✅ ค้นหาจากฐานข้อมูล           ← ไม่จำกัด            │
│  ✅ แชทบันทึก (ใช้ local DB)    ← ไม่จำกัด            │
│                                                      │
│  🔒 AI วิเคราะห์รูปอาหาร       ← 3 ครั้ง/วัน        │
│  🔒 AI วิเคราะห์จากชื่อ (Gemini)← 3 ครั้ง/วัน        │
│  🔒 AI ค้นหาวัตถุดิบ            ← 3 ครั้ง/วัน         │
│                                                      │
│  📢 "ปลดล็อค AI ไม่จำกัด" banner                     │
│                                                      │
├─────────────────────────────────────────────────────┤
│              🔓 Miro Cal Pro (จ่ายครั้งเดียว)         │
│                      199-299 บาท                     │
│                                                      │
│  ✅ AI วิเคราะห์ไม่จำกัด                              │
│  ✅ ไม่มี banner โฆษณา                                │
│  ✅ รองรับ feature ใหม่ในอนาคต                        │
│                                                      │
│  (ผู้ใช้ยังต้อง BYOK — ใส่ Gemini API Key เอง)       │
└─────────────────────────────────────────────────────┘
```

---

## Architecture — วิธี Implement

### 1. ใช้ Google Play Billing (In-App Purchase)

**Package:** `in_app_purchase` (official Flutter plugin)

```yaml
# pubspec.yaml
dependencies:
  in_app_purchase: ^3.2.0
```

**Product Type:** Non-consumable (ซื้อครั้งเดียว ใช้ตลอด)

### 2. โครงสร้าง Code

```
lib/
  core/
    services/
      purchase_service.dart    ← จัดการ IAP + ตรวจสถานะ Pro
      usage_limiter.dart       ← นับจำนวน AI calls/วัน
```

### 3. Usage Limiter — นับ AI calls

```dart
// lib/core/services/usage_limiter.dart
import 'package:shared_preferences/shared_preferences.dart';

class UsageLimiter {
  static const int freeAiCallsPerDay = 3;
  static const String _keyDate = 'ai_usage_date';
  static const String _keyCount = 'ai_usage_count';
  static const String _keyIsPro = 'is_pro_user';

  /// ตรวจว่าเป็น Pro user หรือไม่
  static Future<bool> isPro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPro) ?? false;
  }

  /// ตั้ง Pro status (เรียกหลังซื้อสำเร็จ)
  static Future<void> setPro(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPro, value);
  }

  /// ตรวจว่ายังใช้ AI ได้อีกไหม
  static Future<bool> canUseAi() async {
    if (await isPro()) return true; // Pro ไม่จำกัด
    
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10); // "2026-02-07"
    final savedDate = prefs.getString(_keyDate) ?? '';
    
    if (savedDate != today) {
      // วันใหม่ → reset counter
      await prefs.setString(_keyDate, today);
      await prefs.setInt(_keyCount, 0);
      return true;
    }
    
    final count = prefs.getInt(_keyCount) ?? 0;
    return count < freeAiCallsPerDay;
  }

  /// เพิ่ม counter หลังใช้ AI สำเร็จ
  static Future<void> recordAiUsage() async {
    if (await isPro()) return; // Pro ไม่ต้องนับ
    
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString(_keyDate) ?? '';
    
    if (savedDate != today) {
      await prefs.setString(_keyDate, today);
      await prefs.setInt(_keyCount, 1);
    } else {
      final count = prefs.getInt(_keyCount) ?? 0;
      await prefs.setInt(_keyCount, count + 1);
    }
  }

  /// เหลือกี่ครั้งวันนี้
  static Future<int> remainingToday() async {
    if (await isPro()) return -1; // -1 = ไม่จำกัด
    
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString(_keyDate) ?? '';
    
    if (savedDate != today) return freeAiCallsPerDay;
    
    final count = prefs.getInt(_keyCount) ?? 0;
    return (freeAiCallsPerDay - count).clamp(0, freeAiCallsPerDay);
  }
}
```

### 4. Purchase Service — จัดการ IAP

```dart
// lib/core/services/purchase_service.dart
import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'usage_limiter.dart';

class PurchaseService {
  static const String proProductId = 'miro_cal_pro'; // ตั้งใน Play Console
  
  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  /// เริ่มต้น — เรียกใน main.dart
  static Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) return;
    
    // ฟัง purchase updates
    _subscription = _iap.purchaseStream.listen(_onPurchaseUpdate);
    
    // ตรวจ purchase เก่า (restore)
    await _iap.restorePurchases();
  }
  
  /// ซื้อ Pro
  static Future<void> buyPro() async {
    final response = await _iap.queryProductDetails({proProductId});
    if (response.productDetails.isEmpty) return;
    
    final product = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }
  
  /// Handle purchase result
  static void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID == proProductId) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          // ปลดล็อค Pro!
          UsageLimiter.setPro(true);
        }
      }
      
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }
  
  static void dispose() {
    _subscription?.cancel();
  }
}
```

### 5. จุดที่ต้องเช็ค Limit (Gate Points)

ทุกจุดที่เรียก Gemini API → เช็ค `UsageLimiter.canUseAi()` ก่อน

| จุด | ไฟล์ | ทำอะไร |
|-----|------|--------|
| ถ่ายรูป/เลือกรูป → วิเคราะห์ | `food_preview_screen.dart` | เช็คก่อนส่งไป Gemini |
| กด Gemini วิเคราะห์ในรายละเอียด | `food_detail_bottom_sheet.dart` | เช็คก่อนเรียก |
| กด Gemini ค้นหา ingredient | `gemini_analysis_sheet.dart` | เช็คก่อนเรียก |
| กด Gemini ใน Create Meal | `create_meal_sheet.dart` | เช็คก่อนเรียก |
| กด Gemini ใน Edit Food | `edit_food_bottom_sheet.dart` | เช็คก่อนเรียก |
| Chat → Gemini lookup | `intent_handler.dart` | เช็คก่อนเรียก |

**ทำ helper method กลาง:**

```dart
// ใน gemini_service.dart เพิ่ม
static Future<bool> checkAndConsumeUsage(BuildContext context) async {
  final canUse = await UsageLimiter.canUseAi();
  if (canUse) {
    await UsageLimiter.recordAiUsage();
    return true;
  }
  
  // แสดง Upsell Dialog
  if (context.mounted) {
    _showUpgradeDialog(context);
  }
  return false;
}

static void _showUpgradeDialog(BuildContext context) {
  final remaining = 0; // ใช้หมดแล้ว
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.lock, color: Colors.orange),
          SizedBox(width: 8),
          Text('ใช้ AI ครบ 3 ครั้งแล้ววันนี้'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ปลดล็อคเพื่อใช้ AI วิเคราะห์อาหารไม่จำกัด:'),
          SizedBox(height: 12),
          Text('✅ วิเคราะห์รูปอาหารไม่จำกัด'),
          Text('✅ AI ค้นหาโภชนาการไม่จำกัด'),
          Text('✅ จ่ายครั้งเดียว ใช้ตลอดชีพ'),
          SizedBox(height: 12),
          Text(
            '💡 ยังบันทึกอาหารด้วยมือได้ตามปกติ\nหรือรอพรุ่งนี้จะได้ 3 ครั้งใหม่',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('ไว้ก่อน'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(ctx);
            PurchaseService.buyPro();
          },
          icon: const Icon(Icons.star),
          label: const Text('อัปเกรด Pro'),
        ),
      ],
    ),
  );
}
```

### 6. Upsell Banner — แสดงใน Timeline

```dart
// แสดงถ้าไม่ใช่ Pro + เหลือ AI < 3 ครั้ง
Widget _buildUpsellBanner() {
  return FutureBuilder<bool>(
    future: UsageLimiter.isPro(),
    builder: (context, snapshot) {
      if (snapshot.data == true) return const SizedBox.shrink();
      
      return FutureBuilder<int>(
        future: UsageLimiter.remainingToday(),
        builder: (context, countSnapshot) {
          final remaining = countSnapshot.data ?? 3;
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade50, Colors.blue.shade50],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.purple),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI วิเคราะห์: เหลือ $remaining/${UsageLimiter.freeAiCallsPerDay} ครั้งวันนี้',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const Text(
                        'อัปเกรด Pro เพื่อใช้ไม่จำกัด',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => PurchaseService.buyPro(),
                  child: const Text('อัปเกรด', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
```

---

## Play Store Setup

### Product ID & Pricing

ตั้งใน Google Play Console → In-app products:

| Product ID | Type | ราคา TH | ราคา US |
|------------|------|---------|---------|
| `miro_cal_pro` | Non-consumable (ซื้อครั้งเดียว) | 199-299 THB | $4.99-6.99 |

### Play Store Listing

**ราคาแอป:** ฟรี (Free)
**In-App Purchases:** Yes
**Description ต้องระบุ:**
```
ใช้ฟรี! บันทึกอาหารได้ไม่จำกัด
AI วิเคราะห์อาหารฟรี 3 ครั้ง/วัน
อัปเกรด Pro เพื่อใช้ AI ไม่จำกัด (จ่ายครั้งเดียว)
```

---

## Conversion Funnel (กลยุทธ์ให้คนซื้อ)

```
ดาวน์โหลดฟรี (100%)
    │
    ├── ใช้ manual mode เรื่อยๆ (60%) ← ก็ดี มี user base
    │
    ├── ลองถ่ายรูป AI (30%)
    │       │
    │       ├── ว้าว AI เจ๋ง! ใช้ 3 ครั้ง → ซื้อ Pro (10-15%) ← 💰 Revenue!
    │       │
    │       └── ไม่ซื้อ แต่รอวันละ 3 ครั้ง (15-20%) ← ก็ดี ยัง engage
    │
    └── ตั้งค่า API Key ไม่เป็น ไม่ใช้ AI (10%) ← ต้องทำคู่มือให้ง่าย
```

**เป้า Conversion Rate:** 5-15% → ดีมากสำหรับ Freemium

---

## สิ่งสำคัญ — Trigger Points (จุดที่ควรแสดง Upsell)

### 1. หลังใช้ AI ครั้งที่ 3 → แสดง Dialog ทันที
"วันนี้คุณใช้ AI ครบ 3 ครั้งแล้ว ปลดล็อคเลย?"

### 2. ตอนกด AI ครั้งที่ 4 → แสดง Paywall
ไม่ให้ใช้ แต่ **แสดงสิ่งที่จะได้** ถ้าซื้อ

### 3. Upsell Banner ใน Timeline → แสดงเสมอ (ถ้าไม่ใช่ Pro)
"เหลือ 2/3 ครั้ง" → สร้าง urgency

### 4. ใน Profile/Settings → ปุ่ม "อัปเกรด Pro"
ให้หาซื้อได้ง่าย

### 5. หลังใช้ AI สำเร็จ (wow moment)
"ว้าว! AI วิเคราะห์ได้เลย ปลดล็อคเพื่อใช้ไม่จำกัด?"

---

## Timeline

| งาน | เวลา |
|------|------|
| สร้าง `UsageLimiter` | 1-2 ชม. |
| เพิ่ม gate check ทุกจุด Gemini (~6 จุด) | 2-3 ชม. |
| สร้าง Upsell Dialog + Banner | 2-3 ชม. |
| Implement `PurchaseService` (IAP) | 3-4 ชม. |
| ทดสอบ IAP (ใช้ Play Console test mode) | 2-3 ชม. |
| **รวม** | **~1.5-2 วัน** |

> **หมายเหตุ:** ต้องมี Google Play Console account ก่อนถึงจะทดสอบ IAP ได้
> ใช้ "License testing" ใน Play Console เพื่อทดสอบโดยไม่ต้องจ่ายเงินจริง

---

## ข้อควรระวัง

### 1. อย่าใช้ SharedPreferences เก็บ Pro status เพียงอย่างเดียว
- User สามารถ clear app data → กลับเป็น free
- **แก้:** ใช้ `_iap.restorePurchases()` ตอนเปิดแอป → ตรวจ purchase จริงจาก Google

### 2. Google Play Policy
- ต้องบอก user ชัดเจนว่าอะไรฟรี อะไร Pro
- ต้องมี "Restore Purchase" button (สำหรับเปลี่ยนเครื่อง)
- In-app purchase ต้องผ่าน Google Play Billing (ห้ามใช้ช่องทางอื่น)

### 3. Gemini API Key ยังต้อง BYOK
- Free user → BYOK + 3 AI/day
- Pro user → BYOK + unlimited AI
- **ทั้งคู่ต้องมี API Key** → คู่มือสำคัญมาก

### 4. อย่าลืม consumable vs non-consumable
- ใช้ **Non-consumable** (ซื้อครั้งเดียว ใช้ตลอด)
- ไม่ใช่ Subscription (ผู้ใช้ไม่ชอบจ่ายรายเดือนสำหรับแอปเล็ก)

---

## อัปเดต Roadmap

เพิ่ม Phase ใหม่ใน `LAUNCH_V1_ROADMAP.md`:

```
Phase 1  — ซ่อนฟีเจอร์
Phase 2  — BYOK + คู่มือ API Key
Phase 2.5 — ★ Freemium + IAP (ใหม่!) ★
Phase 3  — Onboarding
Phase 4  — Debug cleanup
Phase 5  — Branding
Phase 6  — Legal
Phase 7  — Testing
Phase 8  — Build & Publish (Free + IAP)
```

**เปลี่ยน Phase 8 → Publish as FREE app (ไม่ใช่ Paid)**
