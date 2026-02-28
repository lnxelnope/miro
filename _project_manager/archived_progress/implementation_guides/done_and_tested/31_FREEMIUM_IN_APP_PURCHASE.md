# Step 31: Freemium + In-App Purchase (IAP)

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 1.5-2 วัน
> **ความยาก:** สูง (ต้องเข้าใจ IAP flow)
> **ต้องทำก่อน:** Step 30 (BYOK API Key Guide)

---

## 🎯 เป้าหมาย

1. **Free Tier** — บันทึกอาหารด้วยมือไม่จำกัด + AI 3 ครั้ง/วัน
2. **Pro Tier** — AI ไม่จำกัด (จ่ายครั้งเดียว 199-299 บาท)
3. **Usage Limiter** — นับจำนวน AI calls ต่อวัน
4. **Purchase Service** — จัดการ Google Play In-App Purchase
5. **Upsell UI** — Dialog + Banner แนะนำซื้อ Pro

---

## 📐 Business Model

```
┌──────────────────────────────────────────┐
│           Miro Cal (Free)                │
│                                          │
│  ✅ บันทึกอาหารด้วยมือ — ไม่จำกัด       │
│  ✅ Quick Add — ไม่จำกัด                 │
│  ✅ My Meal — ไม่จำกัด                   │
│  ✅ ดูสรุป kcal/macro — ไม่จำกัด         │
│  ✅ ตั้งเป้าหมาย — ไม่จำกัด             │
│  ✅ ค้นหาจาก DB — ไม่จำกัด              │
│                                          │
│  🔒 AI วิเคราะห์รูป — 3 ครั้ง/วัน       │
│  🔒 AI วิเคราะห์ชื่อ — 3 ครั้ง/วัน      │
│  🔒 AI ค้นหาวัตถุดิบ — 3 ครั้ง/วัน      │
│                                          │
├──────────────────────────────────────────┤
│     🔓 Pro (จ่ายครั้งเดียว 199-299 บาท) │
│                                          │
│  ✅ AI ไม่จำกัด                          │
│  ✅ ไม่มี Banner upsell                  │
└──────────────────────────────────────────┘
```

---

## 📂 ไฟล์ที่เกี่ยวข้อง

| ไฟล์ | Action | คำอธิบาย |
|------|--------|----------|
| `lib/core/services/usage_limiter.dart` | CREATE | นับ AI calls/วัน |
| `lib/core/services/purchase_service.dart` | CREATE | จัดการ Google Play IAP |
| `lib/core/ai/gemini_service.dart` | EDIT | เพิ่ม checkAndConsumeUsage() |
| `lib/features/health/presentation/food_preview_screen.dart` | EDIT | เพิ่ม gate check |
| `lib/features/health/widgets/food_detail_bottom_sheet.dart` | EDIT | เพิ่ม gate check |
| `lib/features/health/widgets/gemini_analysis_sheet.dart` | EDIT | เพิ่ม gate check |
| `lib/features/health/widgets/create_meal_sheet.dart` | EDIT | เพิ่ม gate check |
| `lib/features/health/widgets/edit_food_bottom_sheet.dart` | EDIT | เพิ่ม gate check |
| `lib/features/chat/services/intent_handler.dart` | EDIT | เพิ่ม gate check |
| `lib/features/health/presentation/health_timeline_tab.dart` | EDIT | เพิ่ม Upsell Banner |
| `lib/features/profile/presentation/profile_screen.dart` | EDIT | เพิ่มปุ่ม "อัปเกรด Pro" + "Restore" |
| `lib/main.dart` | EDIT | เรียก PurchaseService.initialize() |
| `pubspec.yaml` | EDIT | เพิ่ม in_app_purchase dependency |

---

## 🔧 ขั้นตอนการทำงาน

### Step 1: เพิ่ม Dependency

**ไฟล์:** `pubspec.yaml`
**Action:** EDIT

```yaml
dependencies:
  # ... dependencies เดิม ...
  in_app_purchase: ^3.2.0
```

แล้วรัน:
```bash
flutter pub get
```

---

### Step 2: สร้าง UsageLimiter

**ไฟล์:** `lib/core/services/usage_limiter.dart`
**Action:** CREATE

```dart
import 'package:shared_preferences/shared_preferences.dart';

/// นับจำนวน AI calls ต่อวัน
/// Free user ใช้ได้ 3 ครั้ง/วัน
/// Pro user ใช้ได้ไม่จำกัด
class UsageLimiter {
  static const int freeAiCallsPerDay = 3;

  // SharedPreferences keys
  static const String _keyDate = 'ai_usage_date';
  static const String _keyCount = 'ai_usage_count';
  static const String _keyIsPro = 'is_pro_user';

  // ============ Pro Status ============

  /// ตรวจว่าเป็น Pro user หรือไม่
  static Future<bool> isPro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPro) ?? false;
  }

  /// ตั้ง Pro status (เรียกหลังซื้อสำเร็จ หรือ restore สำเร็จ)
  static Future<void> setPro(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPro, value);
  }

  // ============ Usage Check ============

  /// ตรวจว่ายังใช้ AI ได้อีกไหม
  /// return true = ใช้ได้ / false = ใช้ครบแล้ว
  static Future<bool> canUseAi() async {
    // Pro ไม่จำกัด
    if (await isPro()) return true;

    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final savedDate = prefs.getString(_keyDate) ?? '';

    // วันใหม่ → reset counter
    if (savedDate != today) {
      await prefs.setString(_keyDate, today);
      await prefs.setInt(_keyCount, 0);
      return true;
    }

    final count = prefs.getInt(_keyCount) ?? 0;
    return count < freeAiCallsPerDay;
  }

  /// เพิ่ม counter หลังใช้ AI สำเร็จ
  /// *** เรียกหลังจาก Gemini response กลับมาสำเร็จแล้วเท่านั้น ***
  static Future<void> recordAiUsage() async {
    // Pro ไม่ต้องนับ
    if (await isPro()) return;

    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
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
  /// return -1 ถ้าเป็น Pro (ไม่จำกัด)
  static Future<int> remainingToday() async {
    if (await isPro()) return -1;

    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final savedDate = prefs.getString(_keyDate) ?? '';

    if (savedDate != today) return freeAiCallsPerDay;

    final count = prefs.getInt(_keyCount) ?? 0;
    return (freeAiCallsPerDay - count).clamp(0, freeAiCallsPerDay);
  }

  // ============ Helper ============

  /// วันที่ปัจจุบัน format "2026-02-11"
  static String _todayString() {
    return DateTime.now().toIso8601String().substring(0, 10);
  }
}
```

---

### Step 3: สร้าง PurchaseService

**ไฟล์:** `lib/core/services/purchase_service.dart`
**Action:** CREATE

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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
        debugPrint('[PurchaseService] Query error: ${response.error}');
        return;
      }

      if (response.productDetails.isEmpty) {
        debugPrint('[PurchaseService] Product not found: $proProductId');
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
      debugPrint('[PurchaseService] Status: ${purchase.status} for ${purchase.productID}');

      if (purchase.productID == proProductId) {
        switch (purchase.status) {
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            // ✅ ซื้อสำเร็จ / restore สำเร็จ → ปลดล็อค Pro
            UsageLimiter.setPro(true);
            debugPrint('[PurchaseService] Pro unlocked!');
            break;

          case PurchaseStatus.error:
            debugPrint('[PurchaseService] Purchase error: ${purchase.error}');
            break;

          case PurchaseStatus.pending:
            debugPrint('[PurchaseService] Purchase pending...');
            break;

          case PurchaseStatus.canceled:
            debugPrint('[PurchaseService] Purchase canceled');
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
```

---

### Step 4: เพิ่ม Gate Check ใน GeminiService

**ไฟล์:** `lib/core/ai/gemini_service.dart`
**Action:** EDIT

เพิ่ม method กลางสำหรับเช็ค usage limit:

```dart
import '../services/usage_limiter.dart';
import '../services/purchase_service.dart';

class GeminiService {
  // ... code เดิม ...

  /// เช็ค limit + record usage
  /// return true = ใช้ได้ → ดำเนินการต่อ
  /// return false = ใช้ครบแล้ว → แสดง Upsell Dialog
  static Future<bool> checkAndConsumeUsage(BuildContext context) async {
    final canUse = await UsageLimiter.canUseAi();
    if (canUse) {
      // *** ยังไม่ record ตรงนี้ ***
      // record หลังจาก Gemini call สำเร็จจริงๆ
      return true;
    }

    // ใช้ครบแล้ว → แสดง Upsell Dialog
    if (context.mounted) {
      _showUpgradeDialog(context);
    }
    return false;
  }

  /// Upsell Dialog
  static void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(child: Text('ใช้ AI ครบ 3 ครั้งแล้ววันนี้')),
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
}
```

---

### Step 5: เพิ่ม Gate Check ในทุกจุดที่เรียก Gemini

**ทำซ้ำ pattern นี้ใน 6 ไฟล์:**

| # | ไฟล์ | หา method | ใส่ guard ตรงไหน |
|---|------|-----------|-----------------|
| 1 | `food_preview_screen.dart` | `_analyzeImage()` หรือที่เรียก Gemini | ก่อน Gemini call |
| 2 | `food_detail_bottom_sheet.dart` | method กด Gemini ค้นหา | ก่อน Gemini call |
| 3 | `gemini_analysis_sheet.dart` | method เรียก Gemini | ก่อน Gemini call |
| 4 | `create_meal_sheet.dart` | method Gemini ค้นหา ingredient | ก่อน Gemini call |
| 5 | `edit_food_bottom_sheet.dart` | method Gemini | ก่อน Gemini call |
| 6 | `intent_handler.dart` | method ที่เรียก Gemini lookup | ก่อน Gemini call |

**Pattern ที่ใส่ในแต่ละจุด:**

```dart
// ===== เพิ่ม Gate Check =====
// 1. เช็คว่ามี API Key ไหม (จาก Step 30)
final hasKey = await GeminiService.hasApiKey();
if (!hasKey) {
  if (mounted) GeminiService.showNoApiKeyDialog(context);
  return;
}

// 2. เช็คว่ายังเหลือโควต้า AI ไหม (ใหม่ Step 31)
final canUse = await GeminiService.checkAndConsumeUsage(context);
if (!canUse) return; // Upsell dialog จะแสดงเอง
// ===== จบ Gate Check =====

// ... เรียก Gemini ตามปกติ ...
// ... หลังสำเร็จ:
await UsageLimiter.recordAiUsage();  // ← นับ 1 ครั้ง
```

> **สำคัญ:** เรียก `recordAiUsage()` **หลัง** Gemini ตอบกลับสำเร็จเท่านั้น!
> ถ้า Gemini error → ไม่นับ

---

### Step 6: เพิ่ม Upsell Banner ใน Timeline

**ไฟล์:** `lib/features/health/presentation/health_timeline_tab.dart`
**Action:** EDIT

```dart
import '../../../core/services/usage_limiter.dart';
import '../../../core/services/purchase_service.dart';

// เพิ่ม method นี้ใน class
Widget _buildUpsellBanner() {
  return FutureBuilder<bool>(
    future: UsageLimiter.isPro(),
    builder: (context, proSnapshot) {
      // เป็น Pro → ไม่แสดง
      if (proSnapshot.data == true) return const SizedBox.shrink();

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
                  child: const Text('อัปเกรด',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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

เพิ่มใน build() ของ Timeline (หลัง API Key Banner จาก Step 30):

```dart
_buildApiKeyBanner(),   // จาก Step 30
_buildUpsellBanner(),   // ← เพิ่มใหม่
```

---

### Step 7: เพิ่มปุ่ม "อัปเกรด Pro" + "Restore" ใน Profile

**ไฟล์:** `lib/features/profile/presentation/profile_screen.dart`
**Action:** EDIT

#### 7.1 เพิ่ม ListTile สำหรับ Pro

```dart
// เพิ่มใน profile menu (ก่อน "เกี่ยวกับแอป")
FutureBuilder<bool>(
  future: UsageLimiter.isPro(),
  builder: (context, snapshot) {
    final isPro = snapshot.data ?? false;

    if (isPro) {
      // แสดง badge ว่าเป็น Pro แล้ว
      return ListTile(
        leading: const Icon(Icons.star, color: Colors.amber),
        title: const Text('Miro Cal Pro'),
        subtitle: const Text('ขอบคุณที่สนับสนุน! AI ไม่จำกัด'),
        trailing: const Icon(Icons.check_circle, color: Colors.green),
      );
    }

    // ยังไม่ Pro → แสดงปุ่ม upgrade
    return ListTile(
      leading: const Icon(Icons.star_outline, color: Colors.purple),
      title: const Text('อัปเกรด Pro'),
      subtitle: const Text('ใช้ AI วิเคราะห์อาหารไม่จำกัด'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => PurchaseService.buyPro(),
    );
  },
),
```

#### 7.2 เพิ่ม Restore Purchase

```dart
// เพิ่มใต้ปุ่ม upgrade
ListTile(
  leading: const Icon(Icons.restore),
  title: const Text('กู้คืนการซื้อ'),
  subtitle: const Text('สำหรับเปลี่ยนเครื่อง'),
  onTap: () async {
    await PurchaseService.restorePurchase();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กำลังตรวจสอบการซื้อ...')),
      );
    }
  },
),
```

---

### Step 8: Initialize ใน main.dart

**ไฟล์:** `lib/main.dart`
**Action:** EDIT

เพิ่มใน `main()`:

```dart
import 'core/services/purchase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ... initialization อื่นๆ ที่มีอยู่แล้ว ...

  // Initialize In-App Purchase
  await PurchaseService.initialize();

  runApp(
    // ... app เดิม ...
  );
}
```

---

## ⚠️ ข้อควรระวัง

### 1. อย่าใช้ SharedPreferences เก็บ Pro status เพียงอย่างเดียว
- User สามารถ clear app data → กลับเป็น free
- **ทำไปแล้ว:** `PurchaseService.initialize()` จะ `restorePurchases()` ทุกครั้งที่เปิดแอป

### 2. Google Play Policy
- ต้องบอก user ชัดเจนว่าอะไรฟรี อะไร Pro
- ต้องมี "Restore Purchase" button
- In-app purchase ต้องผ่าน Google Play Billing เท่านั้น

### 3. ใช้ Non-consumable (ซื้อครั้งเดียว)
- ไม่ใช่ Subscription
- ไม่ใช่ Consumable

### 4. ทดสอบ IAP ต้องมี Google Play Console
- ใช้ "License testing" เพื่อทดสอบโดยไม่จ่ายเงินจริง
- เพิ่ม email ใน Google Play Console → Setup → License testing

---

## ✅ Checklist

### หลังทำเสร็จ ต้องตรวจสอบ:

- [ ] ใช้ AI ได้ 3 ครั้ง → ครั้งที่ 4 แสดง Upsell Dialog
- [ ] Dialog มีปุ่ม "อัปเกรด Pro" + "ไว้ก่อน"
- [ ] กด "ไว้ก่อน" → ปิด dialog → ยังบันทึกอาหารด้วยมือได้
- [ ] Banner ใน Timeline แสดงจำนวนครั้งที่เหลือ ("เหลือ 2/3 ครั้ง")
- [ ] วันใหม่ → counter reset → ใช้ได้อีก 3 ครั้ง
- [ ] Profile → เห็นปุ่ม "อัปเกรด Pro" (ถ้ายังไม่ซื้อ)
- [ ] Profile → เห็นปุ่ม "กู้คืนการซื้อ"
- [ ] เปิดแอปใหม่ → PurchaseService.initialize() ไม่ crash
- [ ] ไม่มี error ใน console

### ⚠️ ทดสอบ IAP จริง (ต้องมี Play Console)
- [ ] ตั้ง Product ID `miro_cal_pro` ใน Google Play Console
- [ ] เพิ่ม test email ใน License testing
- [ ] ทดสอบซื้อ → Pro status เป็น true
- [ ] ทดสอบ restore → Pro status กลับมา

---

## 🔍 Troubleshooting

### Q: `_iap.isAvailable()` return false
**สาเหตุ:** กำลังทดสอบบน emulator หรือไม่ได้ตั้ง Google Play
**แก้:** ทดสอบบนเครื่องจริงที่มี Google Play Store

### Q: Product not found
**สาเหตุ:** ยังไม่ได้สร้าง product ใน Google Play Console หรือ ID ไม่ตรง
**แก้:** ตรวจ Product ID ว่าตรงกัน (`miro_cal_pro`)

### Q: ซื้อแล้วแต่ Pro ไม่ปลดล็อค
**สาเหตุ:** `_onPurchaseUpdate` อาจไม่ถูกเรียก
**แก้:** ตรวจ debugPrint ว่ามี log จาก `_onPurchaseUpdate` ไหม

---

## 🎉 เสร็จแล้ว! ไปต่อ Step 32 →

ไปทำ **Step 32: Onboarding + TDEE Calculator** ได้เลย
