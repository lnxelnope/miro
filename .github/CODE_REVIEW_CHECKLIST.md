# Code Review Checklist

## 🎯 Purpose
เอกสารนี้เป็น checklist สำหรับ reviewer ในการตรวจสอบ Pull Request

---

## 📋 General Review

### Code Quality
- [ ] โค้ดอ่านง่าย ตัวแปรและ function ตั้งชื่อชัดเจน
- [ ] ไม่มีโค้ดซ้ำซ้อน (DRY principle)
- [ ] Function ไม่ยาวเกินไป (< 50 lines)
- [ ] ไม่มี magic numbers (ใช้ constants แทน)
- [ ] ไม่มี commented code ที่ไม่จำเป็น
- [ ] ไม่มี console.log หรือ print() ที่ลืมลบ

### Error Handling
- [ ] ทุก API call มี try-catch
- [ ] Error messages ชัดเจนและเป็นมิตร
- [ ] ไม่ throw generic errors (ใช้ custom error types)
- [ ] มี fallback UI สำหรับ error state

### Performance
- [ ] ไม่มี unnecessary re-renders
- [ ] List ใช้ `ListView.builder` (ไม่ใช่ `ListView`)
- [ ] Image ใช้ caching
- [ ] Async operations ไม่ block UI thread

---

## 🎨 Frontend Review (Flutter/Dart)

### UI/UX
- [ ] UI ตรงตาม design spec
- [ ] มี loading state (CircularProgressIndicator)
- [ ] มี error state (แสดง error message)
- [ ] มี empty state (ถ้าไม่มีข้อมูล)
- [ ] Responsive (ทำงานบนหน้าจอทุกขนาด)
- [ ] Accessibility (font size, contrast ratio)

### State Management (Riverpod)
- [ ] ใช้ Provider ถูกต้อง (StateProvider, FutureProvider, etc.)
- [ ] ไม่มี global state ที่ไม่จำเป็น
- [ ] ไม่มี memory leaks (dispose ทุก controller)
- [ ] ref.watch ใช้ใน build() method เท่านั้น
- [ ] ref.listen ไม่ใช้ใน initState()

### Navigation
- [ ] ใช้ named routes
- [ ] มี navigation guard (ถ้าจำเป็น)
- [ ] Back button ทำงานถูกต้อง

### Localization
- [ ] Text ทั้งหมดใช้ l10n (ไม่ hardcode)
- [ ] มี keys ใน app_en.arb และ app_th.arb
- [ ] ทดสอบทั้ง 2 ภาษา

---

## 🔥 Backend Review (Firebase Cloud Functions)

### API Design
- [ ] Endpoint naming สื่อความหมาย (RESTful)
- [ ] HTTP method ถูกต้อง (GET, POST, PUT, DELETE)
- [ ] Request/Response format สม่ำเสมอ (JSON)
- [ ] Error responses มี status code ที่เหมาะสม

### Validation
- [ ] ทุก input ผ่าน validation
- [ ] deviceId ตรวจสอบ format (`/^[a-zA-Z0-9_-]{10,50}$/`)
- [ ] productId whitelist (ไม่รับค่าใดๆ มาก็ได้)
- [ ] amount/quantity เป็น positive integer

### Error Handling
- [ ] ทุก async operation มี try-catch
- [ ] Error logs มี context (deviceId, timestamp)
- [ ] Error response ไม่เปิดเผย internal details
- [ ] มี retry mechanism สำหรับ transient errors

### Security
- [ ] มี rate limiting (ป้องกัน abuse)
- [ ] Server-side validation (ไม่ trust client)
- [ ] ไม่มี sensitive data ใน logs
- [ ] ใช้ Firebase App Check (ป้องกัน bot)

### Performance
- [ ] Firestore queries มี indexes
- [ ] ไม่มี N+1 queries
- [ ] Batch operations สำหรับ multiple writes
- [ ] Cold start time < 1s (ใช้ min instances ถ้าจำเป็น)

### Logging
- [ ] Log ระดับ info สำหรับ important events
- [ ] Log ระดับ error พร้อม stack trace
- [ ] ไม่ log sensitive data (passwords, tokens)
- [ ] Log format สม่ำเสมอ

---

## 💾 Database Review (Firestore)

### Schema Design
- [ ] Document structure flat (ไม่ nested เกินไป)
- [ ] Field names สอดคล้องกัน (camelCase)
- [ ] ไม่มี array > 100 elements
- [ ] ไม่มี document > 1MB

### Queries
- [ ] ใช้ where clause ที่จำเป็นเท่านั้น
- [ ] มี limit() ทุก query (ป้องกัน fetch ข้อมูลเยอะเกินไป)
- [ ] Composite indexes สร้างแล้ว
- [ ] ไม่มี expensive queries (scan ทั้ง collection)

### Security Rules
- [ ] Users collection: read เฉพาะ owner, write เฉพาะ functions
- [ ] Transactions collection: read เฉพาะ owner, write เฉพาะ functions
- [ ] ไม่มี allow read/write: if true;
- [ ] Test security rules ด้วย emulator

### Transactions
- [ ] ใช้ transaction สำหรับ atomic operations
- [ ] ไม่มี race conditions
- [ ] Retry logic สำหรับ transaction conflicts

---

## 💰 IAP Review (In-App Purchases)

### Purchase Flow
- [ ] Duplicate purchase prevention (idempotency)
- [ ] Receipt validation server-side
- [ ] Retry mechanism สำหรับ failed transactions
- [ ] Refund handling

### Testing
- [ ] ทดสอบกับ sandbox account
- [ ] ทดสอบ edge cases (network error, cancel purchase)
- [ ] ทดสอบ restore purchases

---

## 🎮 Quest Bar Review

### Offer Display
- [ ] แสดง offer ที่มี priority สูงสุด
- [ ] Countdown timer อัปเดตทุกวินาที
- [ ] Offer expired → ซ่อนทันที
- [ ] ไม่มี offer → แสดง Streak mode

### Dismiss Functionality
- [ ] Swipe left ซ่อน offer
- [ ] แสดง Snackbar พร้อม "Undo"
- [ ] Dismissed state เก็บใน local (ไม่บันทึก server)
- [ ] "Undo" restore offer

### Claim Button
- [ ] เรียก API claimDailyEnergy
- [ ] แสดง loading state
- [ ] แสดง confetti หลัง claim
- [ ] Disable button หลัง claim แล้ว

### Security
- [ ] Countdown ใช้ server time (ไม่ trust client)
- [ ] Expiry check server-side
- [ ] ไม่มี offer manipulation

---

## 🧪 Testing Review

### Unit Tests
- [ ] Test coverage > 70%
- [ ] Test ทุก edge case
- [ ] Test error scenarios
- [ ] Mock external dependencies

### Integration Tests
- [ ] Test user flows ที่สำคัญ
- [ ] Test API integration
- [ ] Test database operations

### Manual Testing
- [ ] ทดสอบบน real device
- [ ] ทดสอบ offline mode
- [ ] ทดสอบ slow network
- [ ] ทดสอบ different screen sizes

---

## 🔐 Security Review

### Authentication
- [ ] ใช้ Firebase Auth (ไม่ใช้ custom auth)
- [ ] Token validation ทุก request
- [ ] Session timeout เหมาะสม

### Authorization
- [ ] User เข้าถึงได้เฉพาะข้อมูลของตัวเอง
- [ ] Admin endpoints มี admin check
- [ ] Rate limiting ทุก public endpoint

### Data Protection
- [ ] Sensitive data encrypted at rest
- [ ] HTTPS only
- [ ] ไม่เก็บ passwords ใน plain text
- [ ] ไม่ log sensitive data

### Input Validation
- [ ] Sanitize ทุก input จาก client
- [ ] Whitelist > Blacklist
- [ ] ป้องกัน SQL/NoSQL injection
- [ ] ป้องกัน XSS

---

## 📦 Deployment Review

### Pre-Deployment
- [ ] Migration script พร้อมแล้ว (ถ้าเปลี่ยน schema)
- [ ] Rollback plan เตรียมไว้
- [ ] Feature flags ตั้งค่าแล้ว
- [ ] Monitoring/alerts ตั้งค่าแล้ว

### Post-Deployment
- [ ] Smoke tests ผ่านทั้งหมด
- [ ] Monitor error rate (< 0.5%)
- [ ] Monitor performance (API latency < 500ms)
- [ ] ตรวจสอบ user feedback

---

## ✅ Approval Criteria

PR จะถูก approve ก็ต่อเมื่อ:
1. ✅ ผ่าน checklist ทั้งหมดที่เกี่ยวข้อง
2. ✅ ไม่มี linter warnings/errors
3. ✅ Unit tests ผ่านทั้งหมด
4. ✅ Manual testing สำเร็จ
5. ✅ ไม่มี merge conflicts
6. ✅ Documentation อัปเดตแล้ว (ถ้าจำเป็น)

---

## 🚀 Next Steps After Approval

1. Merge to `main` branch
2. Deploy to staging environment
3. Run integration tests
4. Deploy to production (staged rollout)
5. Monitor metrics 24-48 hours
6. 100% rollout (ถ้าไม่มีปัญหา)
