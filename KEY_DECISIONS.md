# 🔑 Key Decisions — Finalized

> **Status:** ✅ All decisions made  
> **Date:** February 13, 2026  
> **Owner:** Product Owner

---

## 1. Backend Architecture
**Decision:** ✅ **Option B — Backend Proxy (Firebase Cloud Functions)**

**Rationale:**
- API key อยู่บน server only (ปลอดภัย 100%)
- สามารถ track analytics ได้แบบ real-time
- Scalable และเพิ่ม features ได้ในอนาคต
- Firebase มี free tier ดีและ integrate กับ Firebase Analytics/Auth/Firestore ที่ใช้อยู่แล้ว
- ใช้ ecosystem เดียวกัน ไม่ต้องจัดการหลาย platform

---

## 2. Welcome Gift — Beta Testers
**Decision:** ✅ **1,000 Energy**

**Rationale:**
- Beta testers ช่วยเราทดสอบมาตลอด สมควรได้รางวัลพิเศษ
- 1,000 Energy = ~$0.35 cost, ~285 AI analyses
- ไม่มากเกินไปจนทำให้ไม่ซื้อเพิ่ม แต่มากพอที่จะใช้สบายๆ

**Implementation:**

**Step 1: สร้างไฟล์ Beta Tester List**
```dart
// lib/core/config/beta_testers.dart
class BetaTesters {
  /// รายชื่อ email ของ beta testers
  /// TODO: เพิ่ม email addresses ของ beta testers ทั้งหมดตรงนี้
  static const List<String> emails = [
    'tester1@example.com',
    'tester2@gmail.com',
    'beta.user@company.com',
    // ... เพิ่มต่อ
  ];
  
  /// ตรวจสอบว่า email นี้เป็น beta tester หรือไม่
  static bool isBetaTester(String? email) {
    if (email == null || email.isEmpty) return false;
    
    // Case-insensitive comparison
    final normalizedEmail = email.trim().toLowerCase();
    return emails.any((e) => e.toLowerCase() == normalizedEmail);
  }
  
  /// สำหรับ debug: ดูว่าตัวเองเป็น beta tester หรือไม่
  static void printStatus(String? userEmail) {
    if (isBetaTester(userEmail)) {
      print('🌟 Beta Tester: $userEmail');
    } else {
      print('👤 Regular User: $userEmail');
    }
  }
}
```

**Step 2: ใช้ใน Migration Code**
```dart
// ใน main.dart หรือ migration script
import 'package:firebase_auth/firebase_auth.dart';
import 'package:miro/core/config/beta_testers.dart';

Future<void> migrateExistingUsers() async {
  // ดึง email จาก Firebase Auth
  final user = FirebaseAuth.instance.currentUser;
  final email = user?.email;
  
  // ตรวจสอบว่าเป็น beta tester หรือไม่
  final isBetaTester = BetaTesters.isBetaTester(email);
  
  if (isBetaTester) {
    print('🌟 Beta tester detected: $email');
  }
  
  // เรียก migration
  await energyService.migrateFromProSystem(
    wasProUser: await _wasProUser(),
    isBetaTester: isBetaTester,
  );
}
```

**How to identify beta testers:**
- ✅ **Option B: Manual list of tester emails** (เลือกอันนี้)
  - สร้างไฟล์ `lib/core/config/beta_testers.dart` 
  - เก็บ list ของ email addresses
  - Compare กับ user's email (จาก Firebase Auth / Google Sign-In)
  
- ❌ Option A: Check install date < launch date (ไม่แม่นยำ)
- ❌ Option C: Check if user has "beta" flag in Firestore/Supabase (ซับซ้อนเกินไป)

---

## 3. API Key Storage
**Decision:** ✅ **Environment Variable (Firebase Functions Config)**

**Storage location:**
- Backend: `Firebase Functions → Environment Configuration → GEMINI_API_KEY`
- Set via: `firebase functions:secrets:set GEMINI_API_KEY`
- Never stored in app code
- Never in git repository

**Backup plan:**
- Keep API key also in password manager (1Password/Bitwarden)
- Rotate key every 6 months

---

## 4. Analytics Tracking
**Decision:** ✅ **Yes — Track analysis types**

**What to track:**
| Event | Data |
|-------|------|
| `ai_analysis_success` | type (image/text/barcode), duration, energy_used |
| `ai_analysis_failed` | type, error_message, energy_refunded? |
| `energy_purchased` | package_id, amount, price |
| `welcome_offer_shown` | timestamp |
| `welcome_offer_purchased` | package_id |
| `no_energy_shown` | context (where user tried to analyze) |

**Tool:** Firebase Analytics (already integrated in MIRO)

**Implementation:**
```dart
// ใน gemini_service.dart
await FirebaseAnalytics.instance.logEvent(
  name: 'ai_analysis_success',
  parameters: {
    'type': type, // 'image', 'text', 'barcode'
    'duration_ms': duration.inMilliseconds,
    'energy_used': 1,
  },
);
```

**Privacy:**
- ✅ No PII (Personally Identifiable Information)
- ✅ No food names or images logged
- ✅ Only aggregate statistics

---

## 5. Refund Policy
**Decision:** ✅ **No automatic energy refund**

**Rationale:**
- AI อาจผิดพลาดได้ แต่ผู้ใช้ก็ได้ข้อมูลแล้ว
- ถ้า refund → ผู้ใช้อาจ abuse โดยบอกว่าผลลัพธ์ผิดทุกครั้ง
- ราคาถูกมาก ($0.00035/call) ไม่คุ้มกับความซับซ้อนของ refund system

**Alternative:**
- แสดงความ confident (`confidence: 0.0-1.0`) ให้ผู้ใช้เห็น
- ถ้า confidence < 0.5 → แจ้งเตือนว่า "ผลลัพธ์อาจไม่แม่นยำ กรุณาตรวจสอบและแก้ไขเอง"
- ให้ผู้ใช้แก้ไขข้อมูลได้ฟรี (ไม่ใช้ Energy)

**Exception:**
- ถ้า API error (500, timeout) → **ไม่หัก Energy**
- ถ้า AI return empty/invalid JSON → **ไม่หัก Energy**
- ใช้ try-catch เพื่อ handle ก่อนหัก Energy

```dart
try {
  final result = await _callBackend(...);
  
  // ตรวจสอบว่าผลลัพธ์ valid หรือไม่
  if (result == null || result['name'] == null) {
    throw Exception('Invalid API response');
  }
  
  // Valid → หัก Energy
  await energyService.consumeEnergy(description: '...');
  return result;
  
} catch (e) {
  // Error → ไม่หัก Energy
  print('❌ Error (no energy deducted): $e');
  rethrow;
}
```

---

## 6. Welcome Offer Timing
**Decision:** ✅ **Show after 3 AI uses** (not immediately after first use)

**Rationale:**
- หลังจากใช้ 1 ครั้ง → ผู้ใช้อาจยังไม่เห็นคุณค่า
- หลังจากใช้ 3 ครั้ง → ผู้ใช้เริ่มเห็นว่า AI มีประโยชน์ → มี conversion rate สูงกว่า
- Psychological: "ฉันใช้ไปแล้ว 3 ครั้ง ชอบมาก ซื้อเลยดีกว่า"

**Implementation:**
```dart
// ใน energy_service.dart
Future<bool> consumeEnergy({String? description}) async {
  // ... deduct energy ...
  
  // ────── ตรวจสอบจำนวนครั้งที่ใช้ AI ──────
  final prefs = await SharedPreferences.getInstance();
  final usageCount = prefs.getInt('ai_usage_count') ?? 0;
  final newCount = usageCount + 1;
  await prefs.setInt('ai_usage_count', newCount);
  
  // ถ้าใช้ครั้งที่ 3 → เริ่ม Welcome Offer timer
  if (newCount == 3) {
    await WelcomeOfferService.startTimer();
    print('🎉 3rd AI usage! Welcome Offer activated.');
  }
  
  return true;
}
```

**UI Flow:**
```
User uses AI: 1st time → (silent)
User uses AI: 2nd time → (silent)
User uses AI: 3rd time → Show popup:
  
  ┌──────────────────────────────────┐
  │  🎉 You've unlocked a special   │
  │     Welcome Offer!               │
  │                                  │
  │  40% OFF all packages            │
  │  ⏰ Valid for 24 hours only!    │
  │                                  │
  │  [ See Offers ]  [ Maybe Later ] │
  └──────────────────────────────────┘
```

---

## 7. Welcome Offer Limit
**Decision:** ✅ **1 package total** (not 1 of each)

**Rationale:**
- ป้องกัน abuse (ซื้อทุก package ราคาลด)
- เพิ่ม urgency → "เลือกให้ดีนะ มีโอกาสแค่ครั้งเดียว!"
- ถ้าให้ซื้อได้หลาย package → ผู้ใช้จะซื้อ Ultimate Saver อย่างเดียว

**Implementation:**
```dart
// ใน welcome_offer_service.dart
static Future<void> markClaimed() async {
  final deviceId = await DeviceIdService.getDeviceId();
  final key = '$_keyOfferClaimed$deviceId';
  final prefs = await SharedPreferences.getInstance();
  
  await prefs.setBool(key, true);
  await _storage.write(key: 'offer_$deviceId', value: 'claimed');
  
  // บันทึกว่าซื้อ package ไหน (สำหรับ analytics)
  await FirebaseAnalytics.instance.logEvent(
    name: 'welcome_offer_claimed',
    parameters: {'package_id': packageId},
  );
  
  print('✅ Welcome Offer claimed (1/1 used)');
}
```

**Purchase Service:**
```dart
Future<void> _handlePurchase(PurchaseDetails purchase) async {
  final productId = purchase.productID;
  
  // ถ้าเป็น welcome offer → mark as claimed
  if (productId.contains('welcome')) {
    // ตรวจสอบว่าเคยซื้อแล้วหรือยัง (double-check)
    final hasClaimed = await WelcomeOfferService.hasClaimed();
    if (hasClaimed) {
      // ไม่ควรเกิดขึ้น (IAP ควร block ไว้แล้ว)
      print('⚠️ Welcome offer already claimed!');
      return;
    }
    
    await WelcomeOfferService.markClaimed();
  }
  
  // ... add energy ...
}
```

**UI Change:**
หลังซื้อ welcome offer แล้ว → ซ่อนทุก welcome products → แสดงแค่ regular prices

---

## 8. Device ID Fallback
**Decision:** ✅ **Use hardware fingerprint as fallback**

**Rationale:**
- `ANDROID_ID` หาย = เกิดขึ้นได้หายากมากๆ (< 0.01% cases)
- แต่ถ้าเกิด → ดีกว่าให้ error

**Implementation:**
```dart
static Future<String> getDeviceId() async {
  // ... try ANDROID_ID / IDFV first ...
  
  if (deviceId.isEmpty || deviceId == 'unknown') {
    // Fallback: hardware fingerprint
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = '${androidInfo.brand}_${androidInfo.device}_${androidInfo.model}'
            .replaceAll(' ', '_')
            .toLowerCase();
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = '${iosInfo.name}_${iosInfo.model}'
            .replaceAll(' ', '_')
            .toLowerCase();
      } else {
        // Web/Desktop: generate UUID and save to localStorage/SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        deviceId = prefs.getString('fallback_device_id');
        if (deviceId == null) {
          deviceId = 'web_${DateTime.now().millisecondsSinceEpoch}';
          await prefs.setString('fallback_device_id', deviceId);
        }
      }
    } catch (e) {
      // Last resort: generate random ID
      deviceId = 'unknown_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
  
  return deviceId;
}
```

**Risk:**
- Hardware fingerprint อาจเหมือนกันในรุ่นเครื่องที่เหมือนกัน (Samsung Galaxy S23 → `samsung_s23_...`)
- แต่โอกาสหาย ANDROID_ID น้อยมากอยู่แล้ว

---

## 📊 Summary Table

| Decision | Choice | Impact |
|----------|--------|--------|
| **Architecture** | Backend Proxy (Firebase Functions) | 🔐 Secure, scalable |
| **Beta Tester Gift** | 1,000 Energy | 🎁 ~285 analyses, fair reward |
| **API Key Storage** | Environment variable | 🔑 Zero exposure risk |
| **Analytics** | Yes (Firebase) | 📊 Better product decisions |
| **Refund Policy** | No (except errors) | ⚡ Prevent abuse |
| **Welcome Offer Timing** | After 3 uses | 🎯 Higher conversion |
| **Welcome Offer Limit** | 1 package total | 💰 Urgency + fair pricing |
| **Device ID Fallback** | Hardware fingerprint | 🛡️ Handle edge cases |

---

## 🚀 Next Steps

1. ✅ Update `ENERGY_IMPLEMENTATION_GUIDE.md` with these decisions
2. ✅ Update code examples to match (3 uses, analytics, etc.)
3. ✅ Create migration script for beta testers
4. ⬜ Implement analytics events
5. ⬜ Test welcome offer flow (3 uses → popup)
6. ⬜ Deploy and monitor

---

**Status:** 🟢 Ready to implement!
