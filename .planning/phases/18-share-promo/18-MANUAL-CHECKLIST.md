# Phase 18 — Manual UAT checklist

อ้างอิง `18-CONTEXT` D-11 และ ROADMAP success criteria

## Share Card (แผน 01 / ARC2-SHARE-01)

- [ ] เปิด Share creator จากจุดเดิมในแอป — ทุกประเภทการ์ดมีตัวเลือก **16:9** และ **1:1**
- [ ] Capture / share / บันทึกแกลเลอรี — ภาพได้สัดส่วนตามที่เลือก
- [ ] **Food item card:** มี toggle ปริมาณ; เปิดแล้วเห็นปริมาณรายการบนการ์ด; ปิดแล้วไม่เห็น
- [ ] **Daily / Nutrition:** **ไม่มี** toggle ปริมาณรายการอาหารเดี่ยว
- [ ] กรณีไม่มี serving — ตรงตามข้อตกลง (ซ่อน/disable + ข้อความ L10n)
- [ ] Regression: default เดิมยังเป็น 16:9 ได้

## Promo backend + admin (แผน 02 / ARC2-PROMO-02)

- [ ] Admin สร้างโค้ดใหม่ พร้อม max รวม, per-user, expiry (`/promo-codes`)
- [ ] แก้ไข/ปิดใช้โค้ดแล้ว redeem สะท้อนถูกต้อง
- [ ] `curl` POST `redeemPromoCode` → success เมื่อเงื่อนไขผ่าน
- [ ] ยิงซ้ำ user เดิม → `per_user_limit`
- [ ] โค้ดหมดอายุ → `expired`
- [ ] โค้ดถูกใช้ครบ global → `max_reached`

## Settings redeem (แผน 03 / ARC2-PROMO-01)

- [ ] ส่วน Account มีช่องกรอก promo code + ปุ่ม Redeem
- [ ] กรอกโค้ดถูก → SnackBar สั้น (success) + ยอด energy หรือ freepass อัปเดตในแอป
- [ ] โค้ดผิด / หมดอายุ / เกิน limit / ใช้ครบแล้ว → ข้อความชัด (L10n)
- [ ] กด Redeem ขณะ loading → ไม่ยิงซ้ำ (ปุ่ม disabled)

## Build / analyze

- [ ] `flutter analyze --no-fatal-infos --no-fatal-warnings` — **ต้องไม่มี `error •`** (warning/info ยังรับได้ชั่วคราว)
- [ ] `npm run build` ใน `functions/` และ `admin-panel/` ผ่าน

## Deploy (Firebase + admin hosting)

รันบนเครื่องที่ `firebase login` แล้ว และมีสิทธิ์ project **`miro-d6856`**:

```bash
# จาก root repo
firebase deploy --only firestore:rules,firestore:indexes,functions
```

ถ้า CLI ถามว่า **จะลบ index ที่มีในโปรเจกต์แต่ไม่อยู่ในไฟล์หรือไม่** → ตอบ **N** (ไม่ลบ) จนกว่าจะ sync `firestore.indexes.json` กับ index ที่ production ใช้จริง — ไฟล์ใน repo รวม composite สำหรับ `transactions` + `transfer_keys` ที่ admin/fraud/cron ใช้แล้ว

- **Firestore:** `firestore.rules` + `firestore.indexes.json` (รวม index ที่ promo / queries ใช้)
- **Functions:** รวม `redeemPromoCode` และ predeploy `npm run build` ใน `functions/`

**Admin panel (Next.js):** ไม่ได้อยู่ใน `firebase.json` — deploy ตาม stack ของทีม (เช่น Vercel / Cloud Run) หลัง `cd admin-panel && npm run build` ผ่าน; ต้องมี env สำหรับ Firebase Admin + auth เหมือน `.env.local` บนเครื่อง dev

**แอปมือถือ:** store release แยกตามปกติ (ไม่ใช่คำสั่ง Firebase เดียว)

## Sign-off

- [ ] วันที่ / ผู้ทดสอบ: _______________
