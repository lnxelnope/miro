# Phase 14 — Technical research: App shell & energy

**Phase:** 14 — app-shell-energy  
**Date:** 2026-03-29  
**Question:** What do we need to know to PLAN and IMPLEMENT this phase well?

## RESEARCH COMPLETE

---

## 1. App mode และ HomeScreen

- **`lib/core/providers/app_mode_provider.dart`:** โหลด `SharedPreferences` key `app_mode`; ค่า `'pro'` → `AppMode.pro` — ต้อง **migrate เป็น basic** และ/หรือ **บล็อกการตั้งเป็น pro** ตาม `14-CONTEXT` D-02
- **`lib/features/home/presentation/home_screen.dart`:** `actions` มี `const ModeToggle()` (บรรทัด ~293); `_buildBody` แยก `BasicModeTab` เมื่อ `mode == basic` มิฉะนั้น `IndexedStack` รวม `ChatScreen`
- **หลังล็อก basic:** branch Pro ใน `IndexedStack` ไม่ถูกใช้สำหรับผู้ใช้ แต่เก็บโค้ดได้ — UI วาดเฉพาะ `BasicModeTab` เมื่อ state ถูกบังคับเป็น basic

## 2. My Meal route

- **`HealthMyMealTab`** อยู่ที่ `lib/features/health/presentation/health_my_meal_tab.dart` — ใช้เป็น `body` ของ `Scaffold` ใหม่
- **L10n:** `navMyMeals`, `appBarMyMeals` มีใน ARB แล้ว — ใช้ `L10n.of(context)!.appBarMyMeals` (หรือ `navMyMeals`) สำหรับ title + tooltip ปุ่ม AppBar

## 3. QuestBar และแชท

- **`basic_mode_tab.dart`:** `SliverToBoxAdapter(child: QuestBar())` และ `_buildChatInput` ใน column หลัก
- **`health_timeline_tab.dart`:** มี `QuestBar()` ใน tree — ซ่อนเมื่อ tab นี้ไม่ถูกแสดงใน shell หลักของผู้ใช้; ตาม CONTEXT ถ้ายัง embed ที่ใดให้ซ่อน — ปัจจุบัน Pro ใช้ `HealthTimelineTab` ใน IndexedStack; หลังบังคับ basic ผู้ใช้ไม่เห็น แต่ควรลบ/ซ่อน QuestBar ในไฟล์นี้เพื่อความสอดคล้อง ROADMAP และกรณี reuse widget อื่น

## 4. ทางเข้าแชทอื่น

- **`magic_button.dart`:** เปิด `ChatScreen` — `grep` ไม่พบ `MagicButton(` ที่ไฟล์อื่น (ยกเว้นคำจำกัดความ) — **ไม่มีทางเข้า UI หลักจาก MagicButton ในปัจจุบัน**
- **ChatScreen** ยังอยู่ใน repo ตาม D-03

## 5. Energy Store — free energy legacy

- **`energy_store_screen.dart`:** `rewardType == 'free_energy'` → `_buildFreeEnergyCard` → `_claimFreeEnergy` → POST `claimFreeEnergyEndpoint`
- **`claimFreeEnergy`** / endpoint **มีเฉพาะไฟล์นี้** (grep ทั้ง `lib/`)
- **`freepass`** แยก: `_buildFreepassOfferCard`, `_claimFreepass` — **ห้ามลบ**
- การถอด: ลบ case `free_energy` จาก switch (หรือ `continue` ข้าม offer นั้น), ลบเมธอดการ์ด + `_claimFreeEnergy` + state `_isClaimingFreeEnergy`

## 6. การทดสอบที่มีอยู่

- `test/integration/quest_bar_test.dart` อ้าง `QuestBar` — ไฟล์ widget ยังอยู่; การซ่อนจาก home **ไม่** ลบ `quest_bar.dart` — เทสต์อาจยังผ่านหากไม่พึ่ง `BasicModeTab` โดยตรง
- แนะนำหลังแก้: `flutter analyze lib/features/home lib/features/energy/presentation/energy_store_screen.dart lib/core/providers/app_mode_provider.dart` และ `flutter test` (ยอมรับว่าอาจต้องอัปเดตเทสต์ถ้าแตก)

---

## Validation Architecture

### ช่องทางตรวจ

1. **Static:** `flutter analyze` บนชุดไฟล์ที่แตะ
2. **Grep gates (ในแผน):** ไม่มี `ModeToggle` ใน `home_screen.dart` actions; ไม่มี `claimFreeEnergyEndpoint` / `_claimFreeEnergy` ใน repo
3. **Manual (D-17):** checklist ใน `14-MANUAL-CHECKLIST.md` — เปิดแอป: My Meal จาก AppBar, ไม่เห็น QuestBar บน home, Energy Store ไม่มีการ์ด free energy, free pass ยังใช้ได้

### Gate ก่อนปิดเฟส

- ครบ success criteria ใน ROADMAP ข้อ 1–4
- ไม่มี regression ที่ analyzer error

---

*End of research*
