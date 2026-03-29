# 14-02 — Summary

**สถานะ:** เสร็จ

## สิ่งที่ส่งมอบ

- **`energy_store_screen.dart`** — ถอด `free_energy` offer path, `_buildFreeEnergyCard`, `_claimFreeEnergy`, `_isClaimingFreeEnergy`; คง freepass flow (`_buildFreepassOfferCard`, `_claimFreepass`)
- **`14-MANUAL-CHECKLIST.md`** — เช็กมือครบ shell + Energy Store + free pass

## การตรวจ

- `rg "claimFreeEnergy" lib/` / `claimFreeEnergyEndpoint` — ไม่พบ
- `flutter analyze` — ไม่มี **error** ในไฟล์ที่แตะ (มี warning/info เดิมใน `energy_store_screen` / `health_timeline_tab`)

## `flutter test` (รากโปรเจกต์)

- **`test/widget_test.dart`** — ปรับเป็น smoke harness (ProviderScope + MaterialApp) เพราะ `ArCalApp` ดึง `FirebaseAnalytics.instance` ตอน import `main` ซึ่ง VM unit test ไม่มี Firebase โดยค่าเริ่มต้น
- **ยัง fail (ไม่เกี่ยวกับเฟส 14 โดยตรง):**
  - `test/core/database/food_entry_extensions_test.dart` — assertion บรรทัด ~119
  - `test/features/arscan/domain/angle_zone_test.dart` — `outOfRange` vs `top`
  - `test/integration/quest_bar_test.dart` — **คอมไพล์ไม่ผ่าน** (`DeviceIdService.deviceId`, mock `Uri`)

## หมายเหตุ

- Regression เต็มชุด green รอแก้เทสต์ด้านบนหรือแยกรันเทสต์ที่เกี่ยวข้องกับ milestone
