# Phase 18 — Plan 02 summary (promo backend + admin)

- Firestore: `promo_codes` + subcollection `redemptions` ใน rules (client deny); index `code` + `active`
- Cloud Function `redeemPromoCode`: POST `deviceId` + `code`, transaction idempotent, รางวัล energy/freepass
- Admin panel: `GET/POST /api/promo-codes`, `GET/PUT/DELETE /api/promo-codes/[id]`, หน้า list/create/edit, `PromoCodeForm.tsx`, ลิงก์ Sidebar **Promo Codes**
- Build: `functions` และ `admin-panel` ผ่าน `npm run build`
