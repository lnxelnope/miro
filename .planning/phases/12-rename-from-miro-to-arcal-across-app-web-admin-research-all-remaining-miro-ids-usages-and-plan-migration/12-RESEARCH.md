# Phase 12: Rename from Miro to ArCal across app, web, admin — Research & Inventory

**Gathered:** (เติมวันที่เมื่อเริ่มทำจริง)
**Status:** Draft — structure ready for inventory

---

## 1. Summary

Phase นี้ตั้งเป้ารวบรวมทุกจุดที่ยังใช้คำว่า `miro` หรืออ้างถึง Miro ใน ecosystem ของ ArCal ให้ครบ 100% แล้วจัดหมวดหมู่/ตัดสินใจเบื้องต้นสำหรับแต่ละรายการ ว่าจะ:

- เปลี่ยนทันที (rename-now)
- เปลี่ยนพร้อม migration (rename-with-migration)
- เก็บเป็น legacy (keep-legacy)

เอกสารนี้จะเป็น single source of truth สำหรับงาน rename/migration ทั้งใน Phase 12 และ phase อื่นในอนาคต

---

## 2. Search Strategy & Scope

**ภายใน repo ปัจจุบัน:**
- โฟลเดอร์เป้าหมาย: `lib/`, `android/`, `ios/`, `web/`, `assets/`, `.planning/`, docs อื่น ๆ
- คีย์เวิร์ดหลัก: `"Miro"`, `"miro"`, `"MIRO"`
- เครื่องมือแนะนำ: `rg` (ripgrep) หรือ search ของ Cursor

**ระบบ/รีโปภายนอก (ต้องตาม audit เพิ่ม):**
- Web Miro frontend
- Admin-panel web
- Backend/API services ที่ใช้ prefix/namespace `miro`
- Analytics providers (GA, Firebase, Mixpanel, ฯลฯ) ที่ใช้ event/collection ที่มีคำว่า `miro`

เมื่อเริ่มทำจริง ให้บันทึกคำสั่งที่ใช้ค้น และผลลัพธ์สำคัญไว้ในส่วน Inventory ด้านล่าง

---

## 3. Inventory by Category

> เติมตารางจากผล search จริง โดยใช้คอลัมน์ด้านล่างให้ครบ

### 3.1 Mobile App Code (Flutter + Native)

| Location (file / module) | Snippet / Key | Type (user-facing / internal-id / env-config / analytics / docs / other) | System | Decision (rename-now / rename-with-migration / keep-legacy) | Notes |
|--------------------------|--------------|-------------------------------------------------------------------------|--------|-------------------------------------------------------------|-------|

### 3.2 Web App / Landing / Marketing

| Location | Snippet / Key | Type | System | Decision | Notes |
|----------|---------------|------|--------|----------|-------|

### 3.3 Admin-panel / Internal Tools

| Location | Snippet / Key | Type | System | Decision | Notes |
|----------|---------------|------|--------|----------|-------|

### 3.4 Backend Services / API / DB / Migrations

| Location | Snippet / Key | Type | System | Decision | Notes |
|----------|---------------|------|--------|----------|-------|

### 3.5 Config & Environments (ENV, Secrets, CI/CD)

| Location | Snippet / Key | Type | System | Decision | Notes |
|----------|---------------|------|--------|----------|-------|

### 3.6 3rd-party & Analytics

| Location | Snippet / Key | Type | System | Decision | Notes |
|----------|---------------|------|--------|----------|-------|

### 3.7 Docs / Other References

| Location | Snippet / Key | Type | System | Decision | Notes |
|----------|---------------|------|--------|----------|-------|

---

## 4. External Systems to Audit (Out of This Repo)

> ใช้ section นี้จดสิ่งที่ต้องตามไปดูใน repo/ระบบอื่น พร้อม owner และ next step

| System / Repo | Owner / Contact | What to check (keywords, tables, events) | Status (not-started / in-progress / done) | Notes |
|---------------|-----------------|------------------------------------------|-------------------------------------------|-------|

---

## 5. Open Questions / Decisions Needed

- (เติมเมื่อเจอ case ที่ยังตัดสินใจไม่ได้ เช่น ID สำคัญที่ผูกหลายระบบ)

---

## 6. Completeness Checklist

- [ ] Mobile Flutter code (`lib/`) scanned for `"Miro"` / `"miro"`
- [ ] Android native (Manifest, resources, Gradle) scanned for `"Miro"` / `"miro"`
- [ ] iOS native (Info.plist, project.pbxproj, strings) scanned for `"Miro"` / `"miro"`
- [ ] Web (`web/` + assets) scanned for `"Miro"` / `"miro"`
- [ ] Docs / Markdown / README / CHANGELOG scanned for `"Miro"` / `"miro"`
- [ ] Known external systems (web Miro, admin-panel, backend, analytics) listedในตาราง External Systems

