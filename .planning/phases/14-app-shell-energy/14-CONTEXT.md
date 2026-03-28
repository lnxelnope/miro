# Phase 14: App shell & energy - Context

**Gathered:** 2026-03-29  
**Status:** Ready for planning

<domain>
## Phase Boundary

ส่งมอบ **shell เดียวสำหรับผู้ใช้ปลายทาง**: โหมด **Basic เป็นหลักเสมอ**, **ไม่มีปุ่มสลับ Pro**, **AppBar มีทางเข้า My Meal** แทนที่ `ModeToggle`, **ซ่อน QuestBar** บนหน้าหลักที่กำหนด, **ซ่อนแชท** (Basic + ทางเข้า Pro เดิม) โดย **ไม่ลบ** ไฟล์โค้ดแชท, และ **ถอด free energy legacy** ออกจาก `EnergyStoreScreen` ในขณะที่ **free pass / seasonal / offer อื่นที่ไม่ใช่ claimFreeEnergy** ยังทำงานได้

**ไม่อยู่ในเฟสนี้:** `FoodSandbox` กลุ่มมื้อ / วันที่อนาคต (Phase 15); โครงสร้าง ingredients (Phase 13); UI ล็อก main ใน sheet (Phase 16)

**อ้างอิงก่อนหน้า:** Phase 13 — ไม่มี dependency บังคับ; ผลิตภัณฑ์ v3.0 ยืนยันแล้วว่า **ไม่มีทางเข้า Pro สำหรับผู้ใช้** และ **ไม่ใช้ feature flag**

</domain>

<decisions>
## Implementation Decisions

### AppMode และ persistence (ARC2-SHELL-01)

- **D-01:** ผู้ใช้ทุกคนเห็นเฉพาะประสบการณ์ **Basic** — **ไม่มี** UI ที่สลับไป Pro
- **D-02:** หลังอัปเดตแอป ต้อง **บังคับ `AppMode.basic` สำหรับการวาด UI** แม้ `SharedPreferences` เก็บ `'pro'` ไว้ (เช่น บังคับใน `HomeScreen` / notifier ให้ state ที่ใช้ branch UI เป็น basic หรือเขียนทับ prefs เป็น `basic` ครั้งเดียวตอน bootstrap — เลือกวิธีใดวิธีหนึ่งที่ทำให้ไม่มีทางกลับไป Pro บนหน้าจอ)
- **D-03:** โค้ด `AppMode.pro`, `IndexedStack` เดิม, `ChatScreen` ฯลฯ **เก็บใน repo** ตามสเปก upgrade_basic (dead path / import ได้) — **ไม่ลบ** ไฟล์แชทในเฟสนี้

### AppBar: My Meal แทน ModeToggle (ARC2-SHELL-02)

- **D-04:** เอา `const ModeToggle()` ออกจาก `HomeScreen` `actions`
- **D-05:** ใส่ปุ่ม (แนะนำ `IconButton` + `Icons.restaurant_menu` หรือเทียบเท่า) ที่ `Navigator.push` ไปหน้าที่ห่อ **`HealthMyMealTab`** ด้วย `Scaffold` + `AppBar` มี **ปุ่มกลับ** ชัดเจน + title จาก **L10n** (เช่น `appBarMyMeals` / `navMyMeals` — ใช้ key ที่มีอยู่แล้ว ห้าม hardcode ข้อความ)
- **D-06:** ลำดับ actions แนะนำ: **[My Meal] [Profile]** — สอดคล้องตำแหน่งเดิมของ toggle

### แชทซ่อน (ARC2-SHELL-03)

- **D-07:** **`BasicModeTab`:** ซ่อน `_buildChatInput` — ใช้ `Visibility(visible: false, maintainState: true)` หรือไม่ใส่ใน tree (เก็บเมธอดไว้ในไฟล์ได้) เพื่อให้โค้ดยังอ่านได้เมื่อเปิดใช้ในอนาคต
- **D-08:** **`HomeScreen`:** เมื่อ shell ถูกบังคับเป็น basic เท่านั้น สาขา `IndexedStack` ที่มี `ChatScreen` จะ **ไม่ถูกใช้** — ถ้ายังคงสาขาไว้เพื่ออนาคต ต้องให้ **branch ที่ผู้ใช้จริงไปที่ `BasicModeTab` เท่านั้น** (ไม่เปิด Pro จาก prefs)
- **D-09:** ตรวจ **ทางเข้าแชทอื่น** (เช่น `magic_button.dart` ถ้ายังถูกอ้างจากหน้าอื่น): ถ้ายังมี route ที่ผู้ใช้ถึงได้จาก UI หลักหลังเฟสนี้ ให้ซ่อน/ปิดทางนั้นด้วย — **ขอบเขตเฟส:** เฉพาะ shell หลัก + Energy ที่ระบุ; ถ้าพบจุดที่ซ่อนอยู่นอก Home ให้บันทึกในแผนเป็นงานย่อย

### Bottom nav / My Meals ซ้ำ (ARC2-SHELL-04)

- **D-10:** โหมด Basic เดิม **ไม่มี** bottom nav — หลังบังคับ basic ทั้งแอป **ไม่เพิ่ม** แท็บ My Meals ใน bottom bar; ผู้ใช้เข้า My Meal ทาง **AppBar เท่านั้น** (ลดซ้ำกับเดิม Pro index 1)

### QuestBar (ARC2-SHELL-05)

- **D-11:** ลบ `QuestBar` ออกจาก tree บน **หน้าหลักที่ผู้ใช้เห็นในโหมด basic** — อย่างน้อย `basic_mode_tab.dart` (Sliver `QuestBar`) และ **หาก** `HealthTimelineTab` ยังถูก embed ที่ใดที่ผู้ใช้เห็น ให้ซ่อนที่นั่นด้วย — ตาม ROADMAP: ไม่แสดงบน main timeline / basic home
- **D-12:** **ไม่**ต้องมี UI แทน QuestBar สำหรับ streak — logic ใน `gamificationProvider` ทำงานเบื้องหลังได้ตามเดิม (สเปก arcal2-01)

### Energy Store — ถอด free energy legacy (ARC2-ENERGY-01)

- **D-13:** ลบ **ทั้ง** UI tile / ปุ่มที่เรียก **`_claimFreeEnergy`** และเมธอด **`_claimFreeEnergy`** / state `_isClaimingFreeEnergy` ที่ใช้เฉพาะ flow นี้ และการเรียก **`claimFreeEnergyEndpoint`**
- **D-14:** **คง** flow **free pass**: `_claimFreepass`, `claimFreepassEndpoint`, ส่วนแปลง energy → freepass, badge/section ที่มีอยู่
- **D-15:** Offer cards ประเภทอื่นที่ **ไม่ใช่** free energy legacy — คงไว้ถ้ายังเป็นส่วนของ seasonal/IAP; หาก offer type ผูกกับ `_claimFreeEnergy` เท่านั้น ให้ถอดการ์ดนั้นออกไปพร้อม endpoint
- **D-16:** `EnergyStoreScreen(highlightOfferId: …)` จาก `QuestBar` จะถูกเรียกน้อยลงเมื่อซ่อน QuestBar — ยังคงรองรับการเปิด Store จากจุดอื่น (เช่น badge) ได้; **audit** ว่าไม่มีทางลัดไปการ์ดที่เรียก `claimFreeEnergy` เหลือ

### การตรวจสอบ (ตาม success criteria ใน ROADMAP)

- **D-17:** Checklist ก่อนปิดเฟส: (1) ไม่มี `ModeToggle` บน AppBar (2) แตะ My Meal → เปิด My Meal → กลับได้ (3) ไม่เห็น QuestBar บน basic home (4) ใน Energy Store ไม่มีการกดรับ free energy legacy; free pass ยังกด/รับได้อย่างน้อยหนึ่งเส้นทางที่ออกแบบไว้

### Claude's Discretion

- วิธีบังคับ basic ที่สะอาดที่สุดใน Riverpod (`AppModeNotifier` vs อ่านค่าแยกใน `HomeScreen`)
- การห่อ `HealthMyMealTab` เป็น route แยก vs ใช้ `MaterialPageRoute` + `Scaffold` ธรรมดา
- การลบ import ที่ไม่ใช้หลังตัด Pro branch จาก build path (หรือเก็บ ignore unused ชั่วคราว)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Product

- `_project_manager/arcal_2_00/arcal2-01.md` — §2.1a ModeToggle→My Meal, §2.6 QuestBar + free energy vs free pass, §2.7 แชทซ่อน, §4 การตัดสินใจ (Pro ปิดทุกทาง, ไม่ feature flag)
- `.planning/research/ARC2-00-POINTERS.md`

### Requirements

- `.planning/REQUIREMENTS.md` — **ARC2-SHELL-01** … **ARC2-SHELL-05**, **ARC2-ENERGY-01**

### Prior phase

- `.planning/phases/13-ingredients-schema-recompute/13-CONTEXT.md` — ขอบเขตข้อมูล ingredients (ไม่ทับเฟส 14)

### Engineering

- `.cursorrules` — L10n ห้าม hardcode string ใน widget

### Code (จุดแตะหลัก)

- `lib/features/home/presentation/home_screen.dart` — AppBar, `ModeToggle`, `_buildBody`, `_buildBottomNavOrNull`, IndexedStack / BasicModeTab
- `lib/core/widgets/mode_toggle.dart` — ถอดการใช้งานจาก AppBar (ไฟล์อาจเก็บไว้)
- `lib/core/providers/app_mode_provider.dart` — persistence `app_mode`
- `lib/features/home/presentation/basic_mode_tab.dart` — `QuestBar`, `_buildChatInput`
- `lib/features/health/presentation/health_timeline_tab.dart` — `QuestBar`
- `lib/features/health/presentation/health_my_meal_tab.dart` — ปลายทาง My Meal
- `lib/features/energy/presentation/energy_store_screen.dart` — `_claimFreeEnergy`, `_claimFreepass`, offer cards
- `lib/features/energy/widgets/quest_bar.dart` — ลิงก์ไป Store + highlight (ซ่อน widget นี้จาก home ไม่ใช่ลบไฟล์ทั้งหมดถ้ายังมีที่อื่นอ้าง — ตรวจ grep)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- **`HealthMyMealTab`** — มีอยู่แล้ว; ใช้ซ้ำเป็น body ของ route ใหม่พร้อม Scaffold บาง
- **`EnergyBadgeRiverpod`** — ยังอยู่ leading AppBar; ไม่ใช่ QuestBar

### Established Patterns

- **Basic:** ไม่มี bottom nav; ปุ่ม Gallery / AR / Add อยู่ใน `BasicModeTab`
- **Pro:** bottom nav 5 ช่อง; index 4 = AI Chat; `stackIndex = _currentIndex <= 1 ? _currentIndex : _currentIndex - 2` สำหรับ AR/Gallery แยกเต็มจอ

### Integration Points

- การบังคับ basic ทำให้ **Pro navigation ไม่ถูกแสดง** — ต้องตรวจ `PopScope` / `_currentIndex` ว่าไม่ก่อ edge case เมื่อเหลือแต่ basic
- **Gamification:** ไม่พึ่ง QuestBar สำหรับการนับ streak ใน provider

</code_context>

<specifics>
## Specific Ideas

- arcal2-01: **Free pass** แยกจาก free energy legacy — ห้ามลบ `_claimFreepass` พร้อม legacy

</specifics>

<deferred>
## Deferred Ideas

- กลุ่มมื้อใน sandbox, วันที่อนาคต — **Phase 15**
- Ingredients schema — **Phase 13** (แยกงาน)
- ล็อก main ใน Add/Edit food — **Phase 16**

### Reviewed Todos (not folded)

- ไม่มีจาก `todo match-phase 14`

</deferred>

---

*Phase: 14-app-shell-energy*  
*Context gathered: 2026-03-29*
