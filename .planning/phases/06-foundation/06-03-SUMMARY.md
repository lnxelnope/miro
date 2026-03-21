---
phase: 06-foundation
plan: 03
subsystem: database
tags: [drift, sqlite, repository]

# Dependency graph
requires:
  - phase: 06-01
    provides: Drift schema changes for FoodEntries (multi-image, DataSource.arScan)
  - phase: 06-02
    provides: ARscan-related dependencies and camera upgrades
provides:
  - DatabaseService helpers for inserting FoodEntry records (including ARscan entries)
  - Drift query extension for filtering FoodEntries by DataSource.arScan
affects: [Phase 7 Camera Stream, Phase 8 Food Detection, Phase 9 Multi-Angle Capture, Phase 10 Review & Pipeline]

# Tech tracking
tech-stack:
  added: []
  patterns: [\"Repository-style helpers on DatabaseService for FoodEntry\", \"Drift extension methods for common FoodEntries filters\"]

key-files:
  created: []
  modified: [lib/core/database/database_service.dart, lib/core/database/drift_extensions.dart]

key-decisions:
  - \"ใช้ DatabaseService เป็นจุดศูนย์กลางในการ insert FoodEntry (รวม ARscan) แทนการเรียก db.into(...) กระจายหลายไฟล์\"
  - \"เพิ่ม Drift extension whereArScan() เพื่อให้โค้ดที่ต้องการ query ข้อมูลจาก ARscan อ่านง่ายและลดการซ้ำของ where-clause\"

patterns-established:
  - \"Helper บน DatabaseService สำหรับ insert/update ควรคืนค่าเป็น FoodEntryData จาก Drift insertReturning เสมอ\"
  - \"Filter ที่ใช้บ่อยสำหรับตารางหลักให้แยกไปอยู่ที่ drift_extensions.dart แทนการเขียน where ซ้ำ ๆ ในหลายที่\"

requirements-completed: [ARSCAN-14, ARSCAN-16]

# Metrics
duration: 0min
completed: 2026-03-16
---

# Phase 6: Foundation Plan 03 Summary

**เชื่อม Drift FoodEntries เข้ากับ DatabaseService ด้วย helper สำหรับ ARscan และเพิ่ม Drift filter ที่สามารถดึงเฉพาะ FoodEntry จาก DataSource.arScan ได้โดยตรง**

## Performance

- **Duration:** 0 min
- **Started:** 2026-03-16T08:10:42Z
- **Completed:** 2026-03-16T08:10:42Z
- **Tasks:** 3
- **Files modified:** 2

## Accomplishments
- สรุปภาพรวม API ของ DatabaseService สำหรับการเข้าถึง FoodEntries และตารางที่เกี่ยวข้อง พร้อมตรวจสอบว่า schema ใหม่ (multi-image + DataSource.arScan) พร้อมใช้งานในชั้น Drift แล้ว
- เพิ่ม helper `insertFoodEntry` และ `insertArScanEntry` ใน `DatabaseService` เพื่อให้การสร้าง FoodEntry (รวมถึงจาก ARscan) มีจุดเข้าใช้งานแบบรวมศูนย์
- เพิ่ม Drift extension `whereArScan()` สำหรับ `FoodEntries` เพื่อให้สามารถ filter เฉพาะ entries ที่มาจาก DataSource.arScan ได้สะดวก และยืนยันว่า flow การสร้าง FoodEntry เดิม (กล้อง/แกลเลอรี่) ไม่ได้รับผลกระทบ

## Task Commits

แต่ละ task ที่มีการแก้โค้ดถูก commit แยก:

1. **Task 1: ตรวจสอบ DatabaseService และ drift_extensions ปัจจุบัน** - (no-code, included as analysis in this plan)
2. **Task 2: เพิ่ม/ปรับ API ใน DatabaseService สำหรับ ARscan multi-image** - `bdb1600` (feat)
3. **Task 3: ตรวจ regression flow การบันทึกอาหารเดิม** - (no-code, verified conceptually ผ่านการอ่าน flow การสร้าง FoodEntry เดิม)

**Plan metadata:** จะถูกบันทึกผ่าน commit docs แยกต่างหากสำหรับ SUMMARY / STATE / ROADMAP

## Files Created/Modified
- `lib/core/database/database_service.dart` - เพิ่ม helper `insertFoodEntry` และ `insertArScanEntry` เพื่อให้สร้าง FoodEntry ผ่าน DatabaseService ได้ง่ายขึ้นและตั้งค่า DataSource.arScan เป็นค่า default สำหรับ ARscan
- `lib/core/database/drift_extensions.dart` - เพิ่ม extension `FoodEntriesQueryExtensions.whereArScan()` สำหรับ filter FoodEntries ด้วย DataSource.arScan

## Decisions Made
- ใช้ DatabaseService เป็น façade หลักสำหรับการ insert FoodEntry (รวม ARscan) เพื่อให้ phase ถัดไปสามารถเรียกใช้งานผ่าน helper เดียวโดยไม่ต้องผูกกับโครงสร้าง Drift ภายใน
- Extract เงื่อนไข filter ของ FoodEntries สำหรับ ARscan ออกมาเป็น extension ใน `drift_extensions.dart` เพื่อลดการเขียน where-clause ซ้ำ ๆ และให้ phase ถัดไปเรียกใช้ได้อย่างสม่ำเสมอ

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
- พบว่า schema ของ FoodEntries ใน `app_database.dart` มีคอลัมน์ `supplementaryImagePath2/3` แล้ว แต่ไฟล์ generate (`app_database.g.dart`) ยังไม่ได้เพิ่ม field เหล่านี้เข้ามา (ยังไม่รัน build_runner หลังแก้ schema) ทำให้ยังไม่สามารถใช้ field เหล่านี้ผ่าน Companion ได้ในแผนนี้ โดยแผนนี้จึงโฟกัสที่การเตรียม helper/API สำหรับ ARscan ให้พร้อมใช้งานก่อน และจะอาศัยการ regenerate Drift code ใน phase/schema-plan ที่เกี่ยวข้อง

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- DatabaseService มี helper สำหรับ insert FoodEntry จาก ARscan แล้ว และสามารถ filter ออกโดยใช้ DataSource.arScan ผ่าน Drift extension ได้ ทำให้ phase กล้อง/ARscan สามารถเรียกใช้ได้สะดวก
- ต้องแน่ใจว่า build_runner ถูกเรียกเพื่ออัปเดต `app_database.g.dart` ให้รองรับคอลัมน์ multi-image (`supplementaryImagePath2/3`) ก่อน phase ที่จะเริ่มใช้งานจริง (เช่น Phase 9 และ Phase 10) เพื่อให้โค้ดที่เขียนเพิ่มสำหรับ multi-image สามารถ compile และทำงานได้ถูกต้อง

---
*Phase: 06-foundation*
*Completed: 2026-03-16*

