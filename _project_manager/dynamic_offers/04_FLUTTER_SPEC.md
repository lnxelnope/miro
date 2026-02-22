# Flutter Spec — Dynamic Offer Support

> **สำหรับ:** Junior Developer  
> **Stack:** Flutter (Dart)  
> **อ้างอิง:** `_project_manager/dynamic_offers/02_BACKEND_SPEC.md`

---

## #1 — Energy Store: รองรับ free_energy Reward Type

**ไฟล์:** `lib/features/energy/presentation/energy_store_screen.dart`

### ปัญหา
Energy Store ปัจจุบันรองรับ 2 แบบ:
- `special_product` (first_purchase) → แสดง card พิเศษ + IAP purchase
- `bonus_rate` → แสดง banner + apply bonus ให้ regular packages

ยังไม่รองรับ `free_energy` (ให้ energy ฟรี กด claim ได้เลย)

### แก้ไข

#### 1.1 เพิ่ม `_buildFreeEnergyCard(dynamic offer)`

```dart
Widget _buildFreeEnergyCard(dynamic offer) {
  // UI: Card สีเขียว (คล้าย first purchase card)
  // แสดง:
  //   - Icon (จาก offer.icon — emoji)
  //   - Title (offer.title)
  //   - Description (offer.description)
  //   - จำนวน Energy ที่ได้ (จาก offer.metadata.amount)
  //   - Countdown timer (ถ้ามี expiry)
  //   - ปุ่ม CTA (offer.ctaText) → สีเขียว
  //
  // กดปุ่ม CTA:
  //   1. เรียก API: claimFreeEnergyEndpoint(deviceId, offerId)
  //   2. ถ้าสำเร็จ → แสดง SnackBar "ได้รับ X Energy!"
  //   3. Reload offers list
  //   4. Update balance display
}
```

#### 1.2 เปลี่ยน `_buildOfferCards()` ให้ดู rewardType

```dart
Widget _buildOfferCards() {
  // เดิม: switch(offer.type) → 'first_purchase' / 'bonus_40' / 'tier_promo'
  // ใหม่: switch(offer.rewardType ?? offer.type)  ← backward compat
  
  for (final offer in _activeOffers) {
    final rewardType = offer['rewardType'] ?? _inferRewardType(offer['type']);
    
    switch (rewardType) {
      case 'special_product':
        cards.add(_buildFirstPurchaseCard(offer));
        break;
      case 'bonus_rate':
        cards.add(_buildBonusBanner(offer));
        break;
      case 'free_energy':              // ⬅️ NEW
        cards.add(_buildFreeEnergyCard(offer));
        break;
      case 'subscription_deal':
        // Navigate to SubscriptionScreen
        cards.add(_buildSubscriptionDealCard(offer));
        break;
    }
  }
}
```

#### 1.3 Helper: `_inferRewardType()` (backward compat)

```dart
// สำหรับ backward compat ขณะ migration (ก่อน backend rewrite เสร็จ)
String _inferRewardType(String? offerType) {
  switch (offerType) {
    case 'first_purchase':
      return 'special_product';
    case 'bonus_40':
    case 'tier_promo':
      return 'bonus_rate';
    default:
      return 'bonus_rate';
  }
}
```

#### 1.4 API Call: `claimFreeEnergy()`

```dart
Future<void> _claimFreeEnergy(String offerId) async {
  setState(() => _isClaimingFreeEnergy = true);
  
  try {
    final deviceId = await _getDeviceId();
    final url = Uri.parse('https://us-central1-PROJECT_ID.cloudfunctions.net/claimFreeEnergyEndpoint');
    
    final response = await http.post(url, body: jsonEncode({
      'deviceId': deviceId,
      'templateId': offerId,
    }));
    
    final data = jsonDecode(response.body);
    
    if (data['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ได้รับ ${data['energyAdded']} Energy!')),
      );
      _loadOffers();    // Reload offer list
      _loadBalance();   // Update balance display
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['error'] ?? 'ไม่สามารถ claim ได้')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('เกิดข้อผิดพลาด')),
    );
  } finally {
    setState(() => _isClaimingFreeEnergy = false);
  }
}
```

---

## #2 — Notification Deep-Link Handler

### ปัญหา
ปัจจุบัน push notification ไม่ส่ง user ไปหน้าใด ๆ เป็นพิเศษ ต้องเพิ่ม deep-link ให้กดเปิด notification แล้วไปหน้า Energy Store + highlight offer

### แก้ไข

#### 2.1 Push Payload Format

Admin ส่ง push ผ่าน API campaign โดยเพิ่ม data field:

```json
{
  "notification": {
    "title": "โปรพิเศษกำลังจะหมด!",
    "body": "เหลือเวลาอีก 1 ชั่วโมง"
  },
  "data": {
    "action": "open_offer",
    "offerId": "abc123"
  }
}
```

#### 2.2 จุดที่ต้องแก้: `main.dart` หรือ FCM handler

**ไฟล์:** `lib/main.dart` (หรือไฟล์ที่ handle FCM messages)

หา `FirebaseMessaging.onMessageOpenedApp` callback เพิ่ม:

```dart
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  final data = message.data;
  
  if (data['action'] == 'open_offer') {
    final offerId = data['offerId'];
    
    // Navigate to Energy Store with offerId
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => EnergyStoreScreen(highlightOfferId: offerId),
      ),
    );
  }
});

// เช็คตอนเปิด app จาก terminated state
final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
if (initialMessage != null && initialMessage.data['action'] == 'open_offer') {
  final offerId = initialMessage.data['offerId'];
  // Navigate after build complete
  WidgetsBinding.instance.addPostFrameCallback((_) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => EnergyStoreScreen(highlightOfferId: offerId),
      ),
    );
  });
}
```

#### 2.3 EnergyStoreScreen — เพิ่ม parameter

**ไฟล์:** `lib/features/energy/presentation/energy_store_screen.dart`

```dart
class EnergyStoreScreen extends StatefulWidget {
  final String? highlightOfferId;   // ⬅️ เพิ่ม
  
  const EnergyStoreScreen({
    super.key,
    this.highlightOfferId,          // ⬅️ เพิ่ม
  });
  
  // ...
}
```

#### 2.4 Highlight Logic

```dart
@override
void initState() {
  super.initState();
  _loadOffers();
  
  // Highlight offer ถ้ามา from notification
  if (widget.highlightOfferId != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToOffer(widget.highlightOfferId!);
    });
  }
}

void _scrollToOffer(String offerId) {
  // ใช้ GlobalKey + Scrollable.ensureVisible
  // หรือ scroll to index ของ offer ใน list
  // + เพิ่ม highlight animation (border glow / scale pulse)
}
```

### Highlight UI

- Border: สีทอง กระพริบ 2-3 วินาที แล้วหยุด
- หรือ: Scale animation pulse 1 ครั้ง
- ไม่ต้องซับซ้อน — แค่ให้ user สังเกตเห็นว่า offer ไหนสำคัญ

---

## #3 — Quest Bar: ส่ง offerId เมื่อ navigate

**ไฟล์:** `lib/features/energy/widgets/quest_bar.dart`

### ปัญหา
ปัจจุบัน `_handleOfferTap` navigate ไป `EnergyStoreScreen()` เปล่า ๆ ไม่ส่ง offer ID

### แก้ไข

หา function `_handleOfferTap`:

```dart
// ───── ก่อน ─────
void _handleOfferTap(BuildContext context, String offerType) {
  if (offerType == 'winback' || offerType == 'sub_upsell') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EnergyStoreScreen()),
    );
  }
}

// ───── หลัง ─────
void _handleOfferTap(BuildContext context, String offerType, {String? offerId}) {
  if (offerType == 'winback' || offerType == 'sub_upsell') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnergyStoreScreen(highlightOfferId: offerId),
      ),
    );
  }
}
```

แล้วหาจุดที่เรียก `_handleOfferTap` → ส่ง offer.id เพิ่ม:

```dart
_handleOfferTap(context, offer.type, offerId: offer.id);
```

---

## #4 — i18n: ใช้ locale เลือกภาษาจาก offer data

### ปัญหา
Offer content ที่มาจาก backend API จะเป็น string เดียว (title, description, ctaText) ไม่ใช่ map อีกแล้ว เพราะ backend เลือกภาษาให้ตาม locale ที่ส่งไป

### แก้ไข (2 options — เลือก 1)

#### Option A: Backend เลือกภาษาให้ (แนะนำ)

Frontend ส่ง locale ไปกับ request:
```dart
final url = Uri.parse(
  'https://...getActiveOffersEndpoint?deviceId=$deviceId&locale=$locale',
);
```

Backend อ่าน locale → return title/description/ctaText เป็น string ภาษาที่ตรง

**ข้อดี:** Frontend ไม่ต้องเปลี่ยน logic — title ยังเป็น string เหมือนเดิม

#### Option B: Frontend เลือกเอง

Backend return title/description/ctaText เป็น map:
```json
{ "title": { "en": "⚡ Starter Deal", "th": "⚡ ดีลสตาร์ทเตอร์" } }
```

Frontend อ่าน:
```dart
final locale = Localizations.localeOf(context).languageCode; // 'en' or 'th'
final title = offer['title'][locale] ?? offer['title']['en'];
```

> **แนะนำ Option A** — backend เลือกภาษาให้ เพราะ frontend ไม่ต้องเปลี่ยน type จาก string → map

---

## Testing Checklist

| # | ทดสอบ | Expected |
|---|-------|----------|
| 1 | สร้าง offer rewardType=free_energy, amount=10 ผ่าน Admin | Offer ปรากฏใน Energy Store |
| 2 | กด Claim | ได้ 10 Energy, balance อัปเดต, offer หายไป |
| 3 | กด Claim ซ้ำ (refresh หน้า) | ไม่เห็น offer แล้ว |
| 4 | ส่ง push notification ด้วย data.action=open_offer | กด notification → เปิด Energy Store |
| 5 | Offer ที่ highlight ถูก scroll ไป | เห็น highlight animation |
| 6 | Quest Bar กด offer | ไป Energy Store + highlight offer ถูกตัว |
| 7 | Offer มี expiry → หมดเวลา | ไม่แสดงใน list แล้ว |
| 8 | เปลี่ยน locale เป็น TH | Offer แสดงเป็นภาษาไทย |
