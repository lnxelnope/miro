# ⚡ MIRO Energy System — Migration Plan
## BYOK → Centralized API Key + Energy Monetization

---

## 📊 1. Cost Analysis: Gemini API Per Call

### Model: `gemini-2.0-flash`
| Metric | Price |
|--------|-------|
| Input tokens | **$0.10 / 1M tokens** |
| Output tokens | **$0.40 / 1M tokens** |

### Estimated Token Usage Per Food Analysis Call

#### A. Image Analysis (`analyzeFoodImage`)
| Component | Estimated Tokens | Direction |
|-----------|-----------------|-----------|
| System prompt (instructions + JSON template) | ~600 tokens | Input |
| Image (base64, ~200-500KB JPEG) | ~1,000 tokens | Input |
| Response (JSON with nutrition data) | ~400-600 tokens | Output |
| **Total Input** | **~1,600 tokens** | |
| **Total Output** | **~500 tokens** | |

**Cost per image analysis:**
```
Input:  1,600 tokens × $0.10/1M = $0.000160
Output:   500 tokens × $0.40/1M = $0.000200
─────────────────────────────────────────
Total:                              $0.000360 per call
                                    ≈ $0.00036 per call
```

#### B. Text-Only Analysis (`analyzeFoodByName`)
| Component | Estimated Tokens | Direction |
|-----------|-----------------|-----------|
| System prompt | ~500 tokens | Input |
| Response (JSON) | ~400-600 tokens | Output |
| **Total Input** | **~500 tokens** | |
| **Total Output** | **~500 tokens** | |

**Cost per text analysis:**
```
Input:    500 tokens × $0.10/1M = $0.000050
Output:   500 tokens × $0.40/1M = $0.000200
─────────────────────────────────────────
Total:                              $0.000250 per call
                                    ≈ $0.00025 per call
```

#### C. Nutrition Label / Barcode Analysis
Similar to Image Analysis: **~$0.00036 per call**

### 📌 Summary: Cost Per Energy
| Analysis Type | Cost per Call | Rounded |
|---------------|---------------|---------|
| Image analysis | $0.000360 | **$0.0004** |
| Text-only analysis | $0.000250 | **$0.0003** |
| Label/Barcode analysis | $0.000360 | **$0.0004** |
| **Average (weighted)** | | **~$0.00035** |

> **1 Energy ≈ $0.00035 actual cost to us**

---

## 💰 2. Energy Packages — Pricing & Profit Margin

### Package Pricing

| Package | Energy | Price (USD) | Price/Energy | Our Cost | **Profit** | **Margin** |
|---------|--------|-------------|--------------|----------|------------|------------|
| Welcome Gift | 100 | FREE | - | $0.035 | -$0.035 | (acquisition cost) |
| Starter Kick | 100 | $0.99 | $0.0099 | $0.035 | **$0.955** | **96.5%** |
| Value Pack | 550 | $4.99 | $0.0090 | $0.193 | **$4.797** | **96.1%** |
| Power User | 1,200 | $7.99 | $0.0066 | $0.420 | **$7.570** | **94.7%** |
| Ultimate Saver | 2,000 | $9.99 | $0.0049 | $0.700 | **$9.290** | **93.0%** |

> ⚠️ **Note**: Google Play/App Store takes 15-30% commission
> - First $1M/year revenue: **15% cut** (Small Business Program)
> - After $1M: **30% cut**

### After 15% Google Play Commission — Regular Prices

| Package | Revenue After Cut | Our Cost | **Net Profit** |
|---------|-------------------|----------|----------------|
| Starter Kick ($0.99) | $0.841 | $0.035 | **$0.806** |
| Value Pack ($4.99) | $4.241 | $0.193 | **$4.048** |
| Power User ($7.99) | $6.791 | $0.420 | **$6.371** |
| Ultimate Saver ($9.99) | $8.491 | $0.700 | **$7.791** |

### After 15% Google Play Commission — Welcome Offer (40% OFF)

| Package | Price (40% OFF) | Revenue After Cut | Our Cost | **Net Profit** | Margin |
|---------|-----------------|-------------------|----------|----------------|--------|
| Starter Kick | $0.59 | $0.501 | $0.035 | **$0.466** | 93.0% |
| Value Pack | $2.99 | $2.541 | $0.193 | **$2.348** | 92.4% |
| Power User | $4.79 | $4.071 | $0.420 | **$3.651** | 89.7% |
| Ultimate Saver | $5.99 | $5.091 | $0.700 | **$4.391** | 86.3% |

> ✅ แม้ลด 40% ก็ยังได้กำไรมากกว่า 86% ทุก package!
> Welcome offer เป็น **conversion tool** — ช่วยให้ผู้ใช้ใหม่กล้าซื้อครั้งแรก

---

## 🔒 3. API Key Security — Centralized Key

### Current (BYOK — Remove This)
```
User device → User's API Key → Google Gemini API
```
**Problems:**
- ❌ Users struggle to create API Keys
- ❌ Quota exceeded errors for non-technical users
- ❌ Security risk (key exposed on device)
- ❌ Cannot control/monitor usage

### New Architecture (Centralized)
```
Option A (Direct — Simple):
User device → Our API Key (embedded/obfuscated) → Google Gemini API

Option B (Backend Proxy — Recommended for production):
User device → Our Backend Server → Google Gemini API
                    ↓
              Validate Energy
              Deduct 1 Energy
              Forward to Gemini
              Return result
```

### ⚠️ Recommendation: Start with Option A, migrate to Option B later

**Option A (MVP — Ship fast):**
- Embed API key in app (obfuscated)
- Energy tracking is local (SharedPreferences/Isar)
- Pros: No backend needed, ship immediately
- Cons: Key can be extracted (low risk for calorie tracker)
- **Good for: Closed Beta → First 1,000 users**

**Option B (Production — Scale):**
- Build simple backend (Firebase Cloud Functions / Google Cloud Functions)
- API key stays on server only
- Energy balance tracked server-side
- Pros: Key is 100% secure, can track analytics
- Cons: Need to build/maintain a backend
- **Good for: After product-market fit, scaling**

**✅ เลือก Option B - Firebase Cloud Functions** (integrate กับระบบที่มีอยู่แล้ว)
---

## 🔐 3.5. Anti-Abuse: Device ID Binding

### Problem
ผู้ใช้สามารถลบแอป → ลงใหม่ → รับ 100 Energy ฟรีซ้ำได้เรื่อยๆ

### Solution: Device Fingerprint (UUID/IDFV)

```
┌─ Android ─────────────────────────────────┐
│ Settings.Secure.ANDROID_ID                │
│ → Unique per app + device                 │
│ → Survives app uninstall/reinstall        │
│ → Resets only on factory reset            │
└───────────────────────────────────────────┘

┌─ iOS ─────────────────────────────────────┐
│ UIDevice.identifierForVendor (IDFV)       │
│ → Unique per vendor + device              │
│ → Resets if ALL apps from vendor removed  │
│ + Keychain backup (survives reinstall)    │
└───────────────────────────────────────────┘
```

### Implementation

```dart
class DeviceIdService {
  /// Get persistent device ID
  /// Android: ANDROID_ID (survives reinstall)
  /// iOS: IDFV + Keychain backup
  static Future<String> getDeviceId() async { ... }
}
```

### How It Works

```
1. User installs app for first time
   → Generate/read Device ID: "abc123"
   → Check SharedPreferences: 'welcome_claimed_abc123' = null
   → Grant 100 Energy ✅
   → Save: 'welcome_claimed_abc123' = true

2. User uninstalls → reinstalls
   → Read Device ID: "abc123" (same device = same ID)
   → Check SharedPreferences: 'welcome_claimed_abc123' = true ❌
   → No free Energy — must purchase

3. User changes Google account
   → Read Device ID: "abc123" (same device = same ID)
   → Already claimed ❌
```

### Dependencies
```yaml
# Android: android_id package
# iOS: device_info_plus + flutter_secure_storage (Keychain)
device_info_plus: ^10.1.0  # Cross-platform device info
```

### Storage Strategy
| Data | Storage | Survives Reinstall? |
|------|---------|---------------------|
| Device ID | `ANDROID_ID` / `IDFV` | ✅ Yes (Android) / ⚠️ Partial (iOS) |
| Welcome claimed flag | `SharedPreferences` + `SecureStorage` (Keychain) | ✅ Keychain survives on iOS |
| Energy balance | `Isar` + `SharedPreferences` | ❌ Lost on reinstall |
| Purchase history | Google Play / App Store | ✅ Always restorable |

### Reinstall Recovery Flow
```
App starts → Check Isar for energy balance
  ↓ (empty = fresh install or reinstall)
Check Device ID → 'welcome_claimed_{id}'?
  ├─ No  → First time! Grant 100 Energy
  └─ Yes → Check Google Play purchase history
            ├─ Has purchases → Restore energy from receipts
            └─ No purchases → Balance = 0 (must buy)
```

---

## ⏰ 3.6. Welcome Offer — 24-Hour Limited Discount (40% OFF)

### Trigger
เมื่อผู้ใช้กด **วิเคราะห์ AI ครั้งแรก** (ใช้ Energy ครั้งแรก)

### Flow

```
User does first AI analysis (Energy 100 → 99)
  ↓
Save timestamp: 'first_ai_usage_time' = DateTime.now()
  ↓
Show "Welcome Offer" banner in app
  ↓
┌──────────────────────────────────────┐
│  🎉 Welcome Offer! 40% OFF          │
│                                      │
│  ⏰ Expires in: 23:41:22            │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ 🎯 Starter Kick               │  │
│  │ ⚡ 100 Energy                  │  │
│  │ ~~$0.99~~  → $0.59            │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ 💎 Value Pack         +10%    │  │
│  │ ⚡ 550 Energy                  │  │
│  │ ~~$4.99~~  → $2.99            │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ 🔥 Power User        +20%    │  │
│  │ ⚡ 1,200 Energy                │  │
│  │ ~~$7.99~~  → $4.79            │  │
│  └────────────────────────────────┘  │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ 🏆 Ultimate Saver    +50%    │  │
│  │ ⚡ 2,000 Energy                │  │
│  │ ~~$9.99~~  → $5.99            │  │
│  └────────────────────────────────┘  │
│                                      │
│  ⚡ Energy never expires!            │
│  🔥 This offer won't come back!     │
│                                      │
│         [ Maybe Later ]              │
└──────────────────────────────────────┘


```

### IAP Product IDs — Separate Discount Products

| Regular Product | Price | Discount Product | Price (40% OFF) |
|-----------------|-------|------------------|-----------------|
| `energy_100` | $0.99 | `energy_100_welcome` | $0.59 |
| `energy_550` | $4.99 | `energy_550_welcome` | $2.99 |
| `energy_1200` | $7.99 | `energy_1200_welcome` | $4.79 |
| `energy_2000` | $9.99 | `energy_2000_welcome` | $5.99 |

> ⚠️ **ต้องสร้าง IAP product แยก** เพราะ Google Play ไม่รองรับ dynamic pricing
> ทั้งหมด **8 products** (4 ปกติ + 4 welcome offer)

### Timer Logic

```dart
class WelcomeOfferService {
  static const String _keyFirstAiUsage = 'first_ai_usage_time';
  static const String _keyOfferClaimed = 'welcome_offer_claimed';
  static const Duration offerDuration = Duration(hours: 24);

  /// Check if welcome offer is still active
  static Future<WelcomeOfferStatus> getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Already bought a welcome offer
    if (prefs.getBool(_keyOfferClaimed) == true) {
      return WelcomeOfferStatus.claimed;
    }
    
    // Check first AI usage time
    final firstUsageMs = prefs.getInt(_keyFirstAiUsage);
    if (firstUsageMs == null) {
      return WelcomeOfferStatus.notStarted; // Haven't used AI yet
    }
    
    final firstUsage = DateTime.fromMillisecondsSinceEpoch(firstUsageMs);
    final expiresAt = firstUsage.add(offerDuration);
    final now = DateTime.now();
    
    if (now.isBefore(expiresAt)) {
      return WelcomeOfferStatus.active; // Timer still running
    }
    
    return WelcomeOfferStatus.expired; // 24 hours passed
  }
  
  /// Get remaining time for offer
  static Future<Duration?> getRemainingTime() async {
    final prefs = await SharedPreferences.getInstance();
    final firstUsageMs = prefs.getInt(_keyFirstAiUsage);
    if (firstUsageMs == null) return null;
    
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(firstUsageMs)
        .add(offerDuration);
    final remaining = expiresAt.difference(DateTime.now());
    
    return remaining.isNegative ? null : remaining;
  }
  
  /// Start the 24h timer (called after first AI analysis)
  static Future<void> startTimer() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt(_keyFirstAiUsage) != null) return; // Already started
    await prefs.setInt(_keyFirstAiUsage, DateTime.now().millisecondsSinceEpoch);
  }
  
  /// Mark offer as claimed (after purchase)
  static Future<void> markClaimed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOfferClaimed, true);
  }
}

enum WelcomeOfferStatus {
  notStarted,  // Haven't used AI yet
  active,      // Timer running, show offer
  expired,     // 24h passed
  claimed,     // Already purchased welcome offer
}
```

### UI Integration Points

| Location | Behavior |
|----------|----------|
| **After first AI analysis** | Popup: "Welcome Offer! 40% OFF — 24h only!" |
| **AppBar energy badge** | Show pulsing glow when offer active |
| **Energy Store screen** | Show discounted prices at top with countdown |
| **Home screen** | Small banner "🔥 40% OFF — 23:41 left" (dismissible) |
| **Before AI analysis** | If offer active, show reminder before confirming |

### Anti-Abuse for Welcome Offer

| Attack | Defense |
|--------|---------|
| Reinstall to get offer again | Device ID binding — `first_ai_usage_time` stored in Keychain/SecureStorage |
| Change system clock forward | Timer based on `first_ai_usage_time` which is already saved |
| Change system clock backward | Could extend offer slightly, but low risk (they still have to pay) |

---

## 📋 4. Implementation Plan

### Phase 1: Remove BYOK System
**Files to modify:**

| File | Change |
|------|--------|
| `lib/core/ai/gemini_service.dart` | Replace `SecureStorageService.getGeminiApiKey()` → embedded key |
| `lib/core/services/secure_storage_service.dart` | Remove API key methods (or repurpose) |
| `lib/features/profile/presentation/api_key_screen.dart` | **DELETE** entire file |
| `lib/features/profile/presentation/profile_screen.dart` | Remove "Set up API Key" menu item |
| `lib/features/onboarding/presentation/onboarding_screen.dart` | Remove API key setup step |

### Phase 2: Create Energy System + Device ID Binding
**New files to create:**

| File | Purpose |
|------|---------|
| `lib/core/services/energy_service.dart` | Energy balance CRUD (local DB) |
| `lib/core/services/device_id_service.dart` | Device fingerprint (ANDROID_ID / IDFV) |
| `lib/core/services/welcome_offer_service.dart` | 24h welcome offer timer + status |
| `lib/core/models/energy_transaction.dart` | Isar model for energy transactions |
| `lib/features/energy/presentation/energy_store_screen.dart` | Energy purchase UI (store) |
| `lib/features/energy/widgets/energy_badge.dart` | Shows remaining energy in AppBar |
| `lib/features/energy/widgets/no_energy_dialog.dart` | Shown when energy = 0 |
| `lib/features/energy/widgets/welcome_offer_dialog.dart` | 40% OFF popup with countdown |
| `lib/features/energy/widgets/welcome_offer_banner.dart` | Dismissible banner on home screen |

**New dependency:**
```yaml
device_info_plus: ^10.1.0  # For Device ID (ANDROID_ID / IDFV)
```

**Modify existing files:**

| File | Change |
|------|--------|
| `lib/core/services/usage_limiter.dart` | Replace Pro/Free system → Energy system |
| `lib/core/services/purchase_service.dart` | Replace single Pro product → 8 Energy packages (4 regular + 4 welcome) |
| `lib/core/ai/gemini_service.dart` | Check energy before API call, deduct after success, trigger welcome offer on first use |
| `lib/features/home/presentation/home_screen.dart` | Add energy badge to AppBar + welcome offer banner |

### Phase 3: In-App Purchase Setup
**Google Play Console — Regular Packages:**

| Product ID | Type | Price |
|------------|------|-------|
| `energy_100` | Consumable | $0.99 |
| `energy_550` | Consumable | $4.99 |
| `energy_1200` | Consumable | $7.99 |
| `energy_2000` | Consumable | $9.99 |

**Google Play Console — Welcome Offer (40% OFF, separate products):**

| Product ID | Type | Price | Discount |
|------------|------|-------|----------|
| `energy_100_welcome` | Consumable | $0.59 | 40% OFF |
| `energy_550_welcome` | Consumable | $2.99 | 40% OFF |
| `energy_1200_welcome` | Consumable | $4.79 | 40% OFF |
| `energy_2000_welcome` | Consumable | $5.99 | 40% OFF |

> ⚠️ Energy packages are **Consumable** (can buy multiple times)
> Unlike Pro which was **Non-consumable** (one-time)
> Welcome products are **one-time purchase** (limited to 24h window)

### Phase 4: Device ID Binding + Welcome Gift
| Scenario | Behavior |
|----------|----------|
| Fresh install (new device) | Check Device ID → grant **100 free Energy** → flag as claimed |
| Reinstall (same device) | Check Device ID → **already claimed** → restore purchases only |
| New Google account (same device) | Check Device ID → **already claimed** → no free energy |
| Factory reset (rare) | ANDROID_ID resets → gets 100 Energy again (acceptable loss) |

### Phase 5: Welcome Offer Integration
| Event | Action |
|-------|--------|
| First AI analysis | Save timestamp → start 24h countdown |
| After analysis completes | Show "Welcome Offer! 40% OFF" popup |
| While offer active | Show banner on home screen + pulsing badge |
| User opens Energy Store | Show welcome prices at top with countdown |
| After 24 hours | Remove all welcome UI, show regular prices only |
| After purchase of welcome offer | Mark as claimed, remove all welcome UI |

### Phase 6: Migration for Existing Users
| User Type | Migration |
|-----------|-----------|
| Existing free users | Get **100 free Energy** (welcome gift, bound to device ID) |
| Existing Pro users | Get **2,000 free Energy** (thank you for supporting early!) |
| New installs | Get **100 free Energy** automatically (bound to device ID) |
| Beta testers | Get **200 free Energy** (extra thanks!) |

---

## 🗂️ 5. Energy Service — Database Schema

### EnergyTransaction (Isar Collection)
```dart
@collection
class EnergyTransaction {
  Id id = Isar.autoIncrement;
  
  late String type;        // 'welcome_gift', 'purchase', 'usage', 'refund', 'pro_migration', 'welcome_offer'
  late int amount;         // +100, -1, +550, etc.
  late int balanceAfter;   // Running balance after transaction
  
  String? packageId;       // 'energy_100', 'energy_550_welcome', etc.
  String? description;     // 'Food image analysis', 'Text analysis', etc.
  String? purchaseToken;   // Google Play purchase token (for verification)
  String? deviceId;        // Device fingerprint (for welcome gift tracking)
  
  late DateTime timestamp;
}
```

### Energy Balance (SharedPreferences — fast access)
```dart
class EnergyService {
  static const String _keyBalance = 'energy_balance';
  static const String _keyWelcomeClaimed = 'welcome_claimed_'; // + deviceId
  static const int welcomeGift = 100;
  
  /// Get current balance
  static Future<int> getBalance() async { ... }
  
  /// Check if user has energy
  static Future<bool> hasEnergy() async { ... }
  
  /// Deduct 1 energy (after successful AI call)
  static Future<bool> consumeEnergy({String? description}) async { ... }
  
  /// Add energy (after purchase)
  static Future<void> addEnergy(int amount, {String? packageId, String? purchaseToken}) async { ... }
  
  /// Initialize welcome gift — DEVICE ID BOUND
  /// Only grants once per physical device (survives reinstall)
  static Future<bool> initializeWelcomeGift() async {
    final deviceId = await DeviceIdService.getDeviceId();
    final key = '${_keyWelcomeClaimed}$deviceId';
    final prefs = await SharedPreferences.getInstance();
    
    if (prefs.getBool(key) == true) {
      // Already claimed on this device
      return false;
    }
    
    // Also check SecureStorage (survives reinstall on iOS)
    final secureFlag = await SecureStorageService.read('welcome_$deviceId');
    if (secureFlag == 'claimed') {
      return false;
    }
    
    // Grant welcome gift
    await addEnergy(welcomeGift, description: 'Welcome Gift');
    await prefs.setBool(key, true);
    await SecureStorageService.write('welcome_$deviceId', 'claimed');
    return true;
  }
}
```

---

## 🎨 6. UI Changes

### AppBar — Energy Badge
```
┌──────────────────────────────────┐
│ ← MIRO            ⚡ 87  👤     │
│                    ^^^^          │
│             Energy Badge         │
│             (tap → store)        │
└──────────────────────────────────┘
```

### No Energy Dialog (replaces "Upgrade to Pro")
```
┌──────────────────────────────────┐
│  ⚡ Out of Energy!               │
│                                  │
│  You need 1 Energy to analyze    │
│  food with AI.                   │
│                                  │
│  ┌────────────────────────────┐  │
│  │ ⚡ 100 Energy    $0.99    │  │
│  │ ⚡ 550 Energy    $4.99    │  │  ← Best value badges
│  │ ⚡ 1,200 Energy  $7.99   │  │
│  │ ⚡ 2,000 Energy  $9.99   │  │
│  └────────────────────────────┘  │
│                                  │
│  💡 You can still log food       │
│     manually without Energy      │
│                                  │
│         [ Maybe Later ]          │
└──────────────────────────────────┘
```

### Energy Store Screen (tap ⚡ badge)
```
┌──────────────────────────────────┐
│ ← Energy Store      ⚡ 87       │
├──────────────────────────────────┤
│                                  │
│  Your Energy: ⚡ 87              │
│  ─────────────────────────       │
│                                  │
│  ┌───────────────────────────┐   │
│  │ 🎯 Starter Kick          │   │
│  │ ⚡ 100 Energy             │   │
│  │ $0.99                     │   │
│  └───────────────────────────┘   │
│                                  │
│  ┌───────────────────────────┐   │
│  │ 💎 Value Pack     +10%   │   │
│  │ ⚡ 550 Energy             │   │
│  │ $4.99                     │   │
│  └───────────────────────────┘   │
│                                  │
│  ┌───────────────────────────┐   │
│  │ 🔥 Power User    +20%   │   │
│  │ ⚡ 1,200 Energy           │   │
│  │ $7.99          POPULAR   │   │
│  └───────────────────────────┘   │
│                                  │
│  ┌───────────────────────────┐   │
│  │ 🏆 Ultimate Saver +50%  │   │
│  │ ⚡ 2,000 Energy           │   │
│  │ $9.99          BEST DEAL │   │
│  └───────────────────────────┘   │
│                                  │
│  ℹ️ Energy never expires         │
│  1 Energy = 1 AI food analysis   │
└──────────────────────────────────┘
```

---

## 📅 7. Timeline

| Phase | Task | Duration |
|-------|------|----------|
| **Phase 1** | Remove BYOK system | 1 day |
| **Phase 2** | Create Energy Service + Device ID Binding | 1 day |
| **Phase 3** | Create Welcome Offer Service (24h timer) | 0.5 day |
| **Phase 4** | Update Purchase Service (8 products: 4 regular + 4 welcome) | 1 day |
| **Phase 5** | Build Energy Store UI + Welcome Offer UI | 1.5 days |
| **Phase 6** | Update all AI call points to check energy + trigger welcome offer | 1 day |
| **Phase 7** | Google Play Console: Create 8 IAP products | 0.5 day |
| **Phase 8** | Testing + Polish | 1-2 days |
| **Total** | | **7-9 days** |

---

## ⚠️ 8. Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| API key exposed in app binary | Obfuscate key, split into parts, use `--obfuscate` build flag. Move to backend server later. |
| Users abuse free Energy (reinstall) | **Device ID Binding** — `ANDROID_ID` survives reinstall. Double-check with `SecureStorage` (Keychain on iOS). |
| Users abuse welcome offer (reinstall) | `first_ai_usage_time` stored in `SecureStorage` + Device ID. Timer cannot be restarted. |
| Users change system clock | Welcome offer timestamp is saved once and is immutable. Clock-forward = offer expires faster (good). Clock-backward = mild extension (low risk, they still pay). |
| Factory reset (Android) | `ANDROID_ID` resets → user gets 100 Energy again. Acceptable loss (~$0.035 cost). Rare enough to not be abused. |
| API cost spike (viral growth) | Set Google Cloud budget alerts, rate limit per user, can reduce output tokens |
| Purchase not delivered (IAP failure) | Log all transactions in Isar, provide "Restore Purchases" button |
| Energy lost when reinstalling | Use Google Play purchase history to restore. Welcome gift tracked by Device ID. |
| 8 IAP products confusing | Welcome offer products are **hidden from store** unless offer is active. User only sees 4 products at a time. |

---

## 🔑 9. Key Decisions Needed

1. **Option A or B?** — Embedded key (ship fast) vs Backend proxy (more secure)
2. **Welcome gift for beta testers** — 100 or 200? (they helped test!)
3. **API Key storage** — Environment variable? Firebase Remote Config? Hardcoded + obfuscated?
4. **Analytics** — Track which type of analysis is most popular?
5. **Refund policy** — What if AI gives bad results? Refund energy?
6. **Welcome offer timing** — Show popup immediately after first analysis, or after 2-3 uses?
7. **Welcome offer limit** — Can user buy multiple welcome-priced packages, or just 1 total?
8. **Device ID fallback** — If `ANDROID_ID` unavailable (rare), use `device_info_plus` hardware fingerprint?

---

## 💡 10. Quick Cost Reference

| Scenario | Energy Used/Month | API Cost/Month |
|----------|-------------------|----------------|
| Casual user (3 analyses/day) | 90 energy | $0.032 |
| Regular user (10 analyses/day) | 300 energy | $0.105 |
| Power user (30 analyses/day) | 900 energy | $0.315 |
| 1,000 users (avg 5/day) | 150,000 energy | $52.50 |
| 10,000 users (avg 5/day) | 1,500,000 energy | $525.00 |

> **Even at 10,000 active users doing 5 analyses/day, API cost is only ~$525/month**
> 
> Revenue from those users (if each buys Value Pack once): 10,000 × $4.99 = **$49,900**
