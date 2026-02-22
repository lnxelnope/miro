# Performance Optimization Guide

## 🎯 เป้าหมาย
- API Latency < 500ms (p95)
- Cold start < 1s
- Firestore read operations < 100 reads/user/day
- App startup time < 2s

---

## 🔥 Firestore Optimization

### 1. Composite Indexes

สร้าง indexes สำหรับ queries ที่ซับซ้อน:

```javascript
// firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "transactions",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "deviceId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "transactions",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "type", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "tier", "order": "ASCENDING" },
        { "fieldPath": "balance", "order": "DESCENDING" }
      ]
    }
  ]
}
```

**Deploy indexes:**
```bash
firebase deploy --only firestore:indexes
```

### 2. Query Optimization

**❌ Bad: Fetch ทั้ง collection**
```typescript
const users = await db.collection('users').get();
users.forEach(user => { /* ... */ });
```

**✅ Good: ใช้ limit + where**
```typescript
const users = await db.collection('users')
  .where('tier', '==', 'gold')
  .limit(10)
  .get();
```

**❌ Bad: N+1 queries**
```typescript
for (const userId of userIds) {
  const user = await db.collection('users').doc(userId).get();
}
```

**✅ Good: Batch read**
```typescript
const users = await db.getAll(
  ...userIds.map(id => db.collection('users').doc(id))
);
```

### 3. Pagination

**ใช้ cursor-based pagination:**
```typescript
let lastDoc = null;

async function getNextPage(pageSize = 20) {
  let query = db.collection('transactions')
    .orderBy('createdAt', 'desc')
    .limit(pageSize);
  
  if (lastDoc) {
    query = query.startAfter(lastDoc);
  }
  
  const snapshot = await query.get();
  lastDoc = snapshot.docs[snapshot.docs.length - 1];
  
  return snapshot.docs.map(doc => doc.data());
}
```

### 4. Caching Strategy

**Client-side caching:**
```typescript
// Enable offline persistence
await enableIndexedDbPersistence(db);

// Get data (cached if available)
const snapshot = await db.collection('users')
  .doc(deviceId)
  .get({ source: 'cache' }); // Try cache first
```

---

## ⚡ Cloud Functions Optimization

### 1. Cold Start Reduction

**ใช้ min instances (สำหรับ critical endpoints):**
```typescript
// functions/src/index.ts

export const getActiveOffers = functions
  .runWith({
    minInstances: 1, // Keep 1 instance warm
    maxInstances: 10,
    memory: '256MB',
    timeoutSeconds: 10,
  })
  .https.onRequest(getActiveOffersEndpoint);
```

**Cost:** ~$6/month per instance

**เลือก functions ที่ต้อง warm:**
- ✅ `getActiveOffers` (Quest Bar load time critical)
- ✅ `syncBalance` (App startup)
- ❌ `verifyPurchase` (ไม่จำเป็น - ไม่ถูกเรียกบ่อย)

### 2. Function Bundling

**แยก functions ออกเป็นไฟล์ย่อย:**
```typescript
// functions/src/index.ts
export { getActiveOffers } from './energy/offersV2';
export { claimDailyEnergy } from './energy/claimDailyEnergy';
export { verifyRewardedAd } from './energy/rewardedAd';
```

**ประโยชน์:** ลด cold start time (ไม่ต้อง load code ทั้งหมด)

### 3. Connection Pooling

**ใช้ global variable สำหรับ Firestore client:**
```typescript
// ❌ Bad: สร้าง client ใหม่ทุกครั้ง
export const myFunction = functions.https.onRequest(async (req, res) => {
  const db = admin.firestore();
  // ...
});

// ✅ Good: Reuse client
const db = admin.firestore();

export const myFunction = functions.https.onRequest(async (req, res) => {
  // Use db directly
});
```

### 4. Parallel Requests

**❌ Bad: Sequential requests**
```typescript
const user = await db.collection('users').doc(deviceId).get();
const transactions = await db.collection('transactions')
  .where('deviceId', '==', deviceId)
  .get();
```

**✅ Good: Parallel requests**
```typescript
const [user, transactions] = await Promise.all([
  db.collection('users').doc(deviceId).get(),
  db.collection('transactions')
    .where('deviceId', '==', deviceId)
    .get(),
]);
```

---

## 📱 Flutter App Optimization

### 1. Widget Optimization

**ใช้ const constructors:**
```dart
// ❌ Bad
return Text('Hello');

// ✅ Good
return const Text('Hello');
```

**ใช้ ListView.builder แทน ListView:**
```dart
// ❌ Bad: สร้าง widget ทั้งหมดทันที
ListView(
  children: items.map((item) => ItemTile(item)).toList(),
);

// ✅ Good: สร้างเฉพาะที่แสดงบนหน้าจอ
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemTile(items[index]),
);
```

### 2. Image Optimization

**ใช้ cached_network_image:**
```dart
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: 'https://example.com/image.png',
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  cacheKey: 'unique-key', // Custom cache key
  maxHeightDiskCache: 400, // Limit cache size
);
```

**ลด image size:**
```dart
// ใช้ width/height parameters
Image.network(
  'https://example.com/large-image.png',
  width: 300,
  height: 200,
  fit: BoxFit.cover,
);
```

### 3. State Management Optimization

**ใช้ select() เพื่อลด rebuilds:**
```dart
// ❌ Bad: rebuild เมื่อ gamification state เปลี่ยน
final gamification = ref.watch(gamificationProvider);
return Text('${gamification.balance}E');

// ✅ Good: rebuild เฉพาะเมื่อ balance เปลี่ยน
final balance = ref.watch(gamificationProvider.select((s) => s.balance));
return Text('${balance}E');
```

**ใช้ family providers สำหรับ parameters:**
```dart
final offerProvider = FutureProvider.family<Offer, String>((ref, offerId) async {
  return fetchOffer(offerId);
});

// Usage
final offer = ref.watch(offerProvider('first_purchase'));
```

### 4. Async Operations

**ใช้ FutureBuilder หรือ AsyncValue:**
```dart
// Using AsyncValue (Riverpod)
final offersAsync = ref.watch(offersProvider);

return offersAsync.when(
  loading: () => const CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
  data: (offers) => OffersList(offers),
);
```

**Debounce user input:**
```dart
Timer? _debounce;

void _onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  
  _debounce = Timer(const Duration(milliseconds: 300), () {
    // Perform search
    _search(query);
  });
}
```

---

## 🚀 Quest Bar Specific Optimization

### 1. API Call Optimization

**Cache offers locally:**
```dart
class QuestBarState {
  List<Offer> _cachedOffers = [];
  DateTime? _lastFetch;
  
  Future<List<Offer>> getOffers() async {
    // ถ้า cache ยังไม่หมดอายุ (< 5 นาที)
    if (_lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < const Duration(minutes: 5)) {
      return _cachedOffers;
    }
    
    // Fetch from API
    _cachedOffers = await fetchOffersFromAPI();
    _lastFetch = DateTime.now();
    
    return _cachedOffers;
  }
}
```

### 2. Countdown Timer Optimization

**ใช้ Timer.periodic แทน Stream:**
```dart
// ✅ Good: Efficient timer
Timer.periodic(const Duration(seconds: 1), (timer) {
  setState(() {
    _remainingTime = _offerExpiryTime.difference(DateTime.now());
  });
  
  if (_remainingTime.isNegative) {
    timer.cancel();
    _loadData(); // Refresh
  }
});
```

**Cancel timer on dispose:**
```dart
@override
void dispose() {
  _countdownTimer?.cancel();
  super.dispose();
}
```

### 3. Dismissed Offers Storage

**ใช้ SharedPreferences แทน Firestore:**
```dart
final prefs = await SharedPreferences.getInstance();

// Save dismissed offers
await prefs.setStringList('dismissed_offers', dismissedOfferIds);

// Load dismissed offers
final dismissedOffers = prefs.getStringList('dismissed_offers') ?? [];
```

---

## 📊 Monitoring & Metrics

### 1. Firebase Performance Monitoring

**เพิ่ม custom traces:**
```dart
import 'package:firebase_performance/firebase_performance.dart';

Future<void> loadQuestBar() async {
  final trace = FirebasePerformance.instance.newTrace('quest_bar_load');
  await trace.start();
  
  try {
    await _loadData();
  } finally {
    await trace.stop();
  }
}
```

### 2. Cloud Functions Monitoring

**เพิ่ม timing logs:**
```typescript
export const getActiveOffers = functions.https.onRequest(async (req, res) => {
  const startTime = Date.now();
  
  try {
    const offers = await fetchOffers(deviceId);
    
    const duration = Date.now() - startTime;
    console.log(`[PERF] getActiveOffers took ${duration}ms`);
    
    res.json({ success: true, offers });
  } catch (error) {
    console.error('[ERROR]', error);
    res.status(500).json({ success: false, error });
  }
});
```

### 3. Key Metrics to Monitor

| Metric | Target | Action if exceeded |
|--------|--------|-------------------|
| API Latency (p95) | < 500ms | Optimize queries, add caching |
| Cold Start Time | < 1s | Add min instances |
| Firestore Reads/User/Day | < 100 | Add client-side caching |
| App Startup Time | < 2s | Lazy load features |
| Quest Bar Load Time | < 300ms | Cache offers locally |

---

## ✅ Performance Checklist

- [ ] Firestore indexes created
- [ ] Queries use limit()
- [ ] No N+1 queries
- [ ] Client-side caching enabled
- [ ] Min instances set for critical endpoints
- [ ] Global Firestore client used
- [ ] Parallel requests where possible
- [ ] ListView.builder used for lists
- [ ] Images cached with cached_network_image
- [ ] Const constructors used
- [ ] Timer cancelled on dispose
- [ ] Firebase Performance Monitoring enabled
- [ ] Custom traces for critical flows
- [ ] Metrics monitored regularly

---

## 🎯 Expected Results

**Before optimization:**
- API Latency: 800ms (p95)
- Cold Start: 2s
- Quest Bar load: 600ms

**After optimization:**
- API Latency: 400ms (p95) ✅
- Cold Start: 800ms ✅
- Quest Bar load: 250ms ✅

**Cost impact:**
- Min instances: +$12/month (2 functions)
- Savings from reduced reads: -$5/month
- **Net cost:** +$7/month
