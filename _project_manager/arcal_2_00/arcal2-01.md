# ARCAL2-01 — บันทึกความต้องการอัปเกรดใหญ่ + ผลการศึกษาโค้ด

**สถานะ:** ✅ ประเด็นเปิดทั้งหมดได้รับคำตอบแล้ว — พร้อมเข้าสู่ขั้น implementation  
**วันที่:** 2026-03-29  
**ที่เกี่ยวข้อง:** [arcal2-00.md](./arcal2-00.md) (sub-ingredients / main lock / AI ingestion)

---

## สารบัญ

1. [สรุปผู้มีส่วนได้ส่วนเสีย](#1-สรุปผู้มีส่วนได้ส่วนเสีย)
2. [Big change — ความต้องการ + สถานะโค้ด](#2-big-change--ความต้องการ--สถานะโค้ด)
   - [2.1 แซนด์บ็อกซ์ + กลุ่มมื้อ](#21-รวม-pro-เข้า-basic--ทำงานแบบ-group-base-เช้า--กลางวัน--เย็น--ว่าง)
   - [2.1a ถอด ModeToggle → My Meal](#21a-ถอดปุ่มสลับ-basicpro--เหลือโหมดเดียวช่องเดิมเป็น-my-meal)
   - [2.2 ลำดับชั้นข้อมูล](#22-ลำดับชั้น-วัน--มื้อ--รายการอาหาร--main-ingredients--sub-ingredient)
   - [2.3 Long-press สร้างกลุ่ม (Group/Merge)](#23-long-press-สร้างกลุ่ม--merge-หลายรายการเป็น-1-entry)
   - [2.4 Thumbnail ingredient](#24-thumbnail-เล็กมากในรายการ-ingredient--แตะดูภาพเต็ม-bounding-box-ถ้ามี)
   - [2.5 สร้างเมนูใหม่ — ปุ่มรูปภาพ](#25-สร้างเมนูใหม่--เพิ่มปุ่มรูปภาพ-gallery-คู่กับปุ่ม-search-magnifier)
   - [2.6 ซ่อน QuestBar + ถอด free energy legacy](#26-ซ่อน-questbar-ถอด-free-energy-legacy-ใน-energy-store-ออกทั้งหมด)
   - [2.7 ซ่อนแชท + เก็บ AnalyzeBar](#27-ซ่อนระบบแชท-เก็บ-analyzebar-แถวล่าง-basic--3-ปุ่ม)
3. [Minor change — ความต้องการ + สถานะโค้ด](#3-minor-change--ความต้องการ--สถานะโค้ด)
   - [3.1 Promo code](#31-โค้ดพิเศษ-influencer--marketing--admin-จัดการ-crud--จำกัดการใช้)
   - [3.2 เลือกวันอนาคต](#32-เลือกวันพรุ่งนี้และวันถัดไป-วางแผนล่วงหน้า)
   - [3.3 Share card](#33-share-card-ปริมาณบนภาพ-aspect-169--11-toggle-แสดงปริมาณ)
   - [3.4 ย้ายรายการข้ามมื้อ](#34-ย้ายรายการข้ามมื้อลาก--ux-เทียบเท่า)
4. [การตัดสินใจทั้งหมด (รวม 14 ข้อ)](#4-การตัดสินใจทั้งหมด-รวม-14-ข้อ)
5. [Dependency map + ลำดับงาน](#5-dependency-map--ลำดับงาน)
6. [ขอบเขตไฟล์ที่ต้องแก้ (สรุป)](#6-ขอบเขตไฟล์ที่ต้องแก้-สรุป)

---

## 1. สรุปผู้มีส่วนได้ส่วนเสีย

| หัวข้อ | ความหมายในโปรเจกต์ |
|--------|---------------------|
| **โหมด Basic / Pro** | **ไม่เคยแยกสิทธิ์ผู้ใช้** — แยกแค่ความซับซ้อนของ UI; หลังอัปเกรดใช้ **Basic เป็น main** เก็บโค้ด Pro ไว้ (`upgrade_basic`). สิ่งที่ Pro ยัง "เก่งกว่า" แคบลงเหลือ: **การแสดงผล sub-ingredients** กับ **การแสดงผลมื้ออาหาร** เท่านั้น — จะดึงความสามารถนี้เข้า Basic |
| **ปุ่ม My Meal ใน AppBar** | แทนที่ตำแหน่ง `ModeToggle` — นำทางไปหน้าเมนู/วัตถุดิบ (`HealthMyMealTab`: แท็บ Meals + Ingredients) |
| **มื้ออาหารเป็นกลุ่ม (group base)** | ข้อมูลยังอิง `MealType` ใน `FoodEntry` — **ไม่ใช้** layout แบบ Pro ที่แยก `MealSection` เป็นบล็อกใหญ่; เป้าหมายคือ **คงสไตล์แซนด์บ็อกซ์** + **กลุ่มมื้อแบบเบา** (แท็บ / กรอบล้อม) เพื่อประหยัดพื้นที่ |
| **Group (long-press)** | **Merge** หลาย `FoodEntry` → สร้าง entry ใหม่ 1 อัน (ชื่อ `group_xxx`); entry เดิมลบ/ซ่อน; nutrition รวม |
| **Energy / Streak / Tier** | `gamificationProvider`, `QuestBar`, `EnergyStoreScreen`, Cloud Functions `claimFreeEnergyEndpoint` / `claimFreepassEndpoint` |
| **Pro access หลังอัปเกรด** | **ปิดทุกทาง** — ล็อก `appMode = basic` ไม่มี debug toggle / hidden gesture |
| **Feature flags** | **ไม่ใช้** — ปล่อย version bump ทีเดียว |

---

## 2. Big change — ความต้องการ + สถานะโค้ด

### 2.1 รวม Pro เข้า Basic — ทำงานแบบ group base (เช้า / กลางวัน / เย็น / ว่าง)

**ความต้องการ (ชี้แจงจากผู้ใช้ — อัปเดตความหมาย)**

- **Basic ยังแทบจะเหมือนเดิม:** ยังแสดงผลหลักเป็น **แซนด์บ็อกซ์** (`FoodSandbox`) — **ไม่ได้ตั้งใจย้ายไป layout แบบ Pro** ที่แยกเป็นหัวข้อมื้อใหญ่ (`MealSection` × 4) เหมือน `HealthTimelineTab`
- **เพิ่มเพียง "กลุ่มมื้อ" แบบประหยัดพื้นที่:** อาจใช้ **แท็บ** หรือ **bounding box / กรอบล้อมรอบกลุ่ม** ให้เห็นชัดว่าก้อนนี้เป็น *อาหารเช้า* ก้อนถัดไปต่อกันในแนวตั้งเป็น *อาหารกลางวัน* ฯลฯ — รายการ **เรียงต่อกันใน feed เดียว** ไม่กินพื้นที่แยกบล็อกมื้อแบบ Pro
- **เหตุผลผลิตภัณฑ์:** จากการใช้งานจริงเกือบเดือน พบว่าการแสดงแบบแซนด์บ็อกซ์ + จัดกลุ่มมื้อเบาๆ **ใช้พื้นที่หน้าจอดีกว่า** และ **รู้สึกดีกว่าการแยกมื้อแบบ Pro** — จึงเป็นที่มาของแนวคิด **ถอด Pro ออก**

**ผลการศึกษา (โค้ดปัจจุบัน)**

- `BasicModeTab`: `FoodSandbox` รวมรายการตามวันที่เลือก — ยังไม่มีกรอบมื้อ / แท็บมื้อ; มี `DailySummaryCard`, `QuestBar`, `AnalyzeBar`, แถวปุ่ม, ช่องแชท
- `HealthTimelineTab` (Pro): `MealSection` ต่อมื้อ = แยกหัวข้อและพื้นที่ชัด — **เป็นสิ่งที่ผู้ใช้ไม่ต้องการนำมาเป็นหน้าหลัก**
- ข้อมูลมื้ออยู่แล้วใน `FoodEntry.mealType` — ฝั่ง UI แค่ต้อง **จัดเรียง + ฉลากกลุ่ม** (กรอบหรือแท็บ) โดยไม่เปลี่ยนโมเดลบังคับ

**ช่องว่าง / ประเด็นออกแบบ**

- เลือกรูปแบบ: **แท็บสลับมื้อ** vs **สกรอลล์ยาว + กรอบล้อมแต่ละมื้อ** vs ผสม (เช่น chip บอกมื้อ + กรอบอ่อน)
- ลำดับรายการใน sandbox: เรียงตามเวลา, ตามมื้อ, หรือทั้งคู่
- **ย้ายรายการข้ามมื้อ** — สเปกและ gap อยู่ข้อ **[3.4](#34-ย้ายรายการข้ามมื้อลาก--ux-เทียบเท่า)**
- ความสัมพันธ์กับ [2.1a](#21a-ถอดปุ่มสลับ-basicpro--เหลือโหมดเดียวช่องเดิมเป็น-my-meal): เหลือ shell เดียวแล้วโฟกัสพัฒนา `FoodSandbox` + กลุ่มมื้อ

---

### 2.1a ถอดปุ่มสลับ Basic/Pro — เหลือโหมดเดียว; ช่องเดิมเป็น My Meal

**ความต้องการ**

- **เอาปุ่มสลับ Basic / Pro ออก** — ผู้ใช้ไม่สลับโหมดแล้ว; เหลือ **ประสบการณ์เดียว**
- **เก็บ "Pro" ในโค้ดไว้แต่ไม่ใช้** — ล็อก `AppMode = basic` คงที่; **ปิดทุกทาง** ทั้ง production และ debug (ไม่มี hidden gesture)
- **ตำแหน่งเดิมของ `ModeToggle` ใน AppBar** เปลี่ยนเป็น **ปุ่ม / ไอคอน My Meal** → นำทางไป `HealthMyMealTab` (แท็บ Meals + Ingredients)

**ผลการศึกษา**

- `ModeToggle` อยู่ใน `lib/core/widgets/mode_toggle.dart` — ใช้ใน `HomeScreen._buildAppBar()` (`const ModeToggle()`)
- `HealthMyMealTab` มีอยู่แล้ว: `TabController(length: 2)` + `TabBarView`: **My Meals** + **Ingredients**
- ปัจจุบัน `HealthMyMealTab` เป็นหน้าแท็บที่สองของ Pro (`IndexedStack` index 1) — ไม่มีใน bottom bar ของ Basic

**ช่องว่าง / implementation notes**

- แทนที่ `ModeToggle` ด้วย `IconButton` ที่ `Navigator.push` → `HealthMyMealTab` (ห่อ `Scaffold` + title + back)
- ล็อก `appModeProvider` → `basic` คงที่; ลบ setter / listener ของ `ModeToggle` ออกจาก UI flow
- ถ้า bottom nav Pro ถูกถอด แท็บ "My Meals" เดิมอาจซ้ำกับ entry ใหม่จาก AppBar — ป้องกัน duplicate

---

### 2.2 ลำดับชั้น: วัน → มื้อ → รายการอาหาร → main ingredients → sub-ingredient

**ความต้องการ (schema เป้าหมาย)**

หนึ่ง **รายการอาหาร** (หนึ่ง `FoodEntry` ต่อหนึ่งการ์ดใน timeline) ต้องอธิบายครบด้วยฟิลด์หลักดังนี้:

| ชั้นในโมเดล | ความหมาย |
|-------------|----------|
| **ชื่อ** | ชื่อรายการที่ผู้ใช้เห็น (จานรวม / ชื่อหลัก) |
| **ปริมาณ** | serving รวม — เมื่อมี sub ควร **สอดคล้อง**กับผลรวมทางกายภาพจาก sub |
| **Macro** | แคลอรี่ + P / C / F |
| **Micro** | ไฟเบอร์, น้ำตาล, โซเดียม ฯลฯ |
| **Main ingredients** | ชั้น "หลัก" ใต้รายการ (composite line) |
| **Sub-ingredients** | ชั้นละเอียดภายใต้ main — **source of truth** ของโภชนาการ |

**กฎที่ตัดสินใจแล้ว:**

| กฎ | รายละเอียด |
|----|-----------|
| Source of truth | เมื่อมี sub → macro/micro ของ main **derive จาก sub เสมอ** |
| ไม่มี sub | entry ธรรมดา → เก็บ nutrition ตรงบน entry เหมือนเดิม (**ไม่บังคับ** ว่าทุก entry ต้องมี main/sub) |
| AI multi-root | แต่ละ root ใน `ingredients_detail` = **main ingredient** ใต้ชื่อจาน; sub ของ root อีกชั้นถ้ามี |
| ความลึก | **2 ระดับเท่านั้น** (main + sub) — ถ้า AI คืนลึกกว่า **ยุบ/flatten** ให้เหลือ 2 ชั้น |
| สเกลปริมาณรวม | **แก้ได้** → sub สเกลตามสัดส่วนเดิมอัตโนมัติ |
| Lock main | เมื่อมี sub → ล็อก nutrition fields ของ main; **ปริมาณรวม** ยังแก้ได้ (trigger scale sub) |

**ผลการศึกษา (โค้ดปัจจุบัน)**

- **วัน / มื้อ:** `timestamp`, `mealType` บน `FoodEntries` — มีอยู่แล้ว
- **Macro / micro ระดับ entry:** คอลัมน์ `calories`, `protein`, … — มีอยู่แล้ว แต่ **ยังไม่บังคับ** ว่าต้องคำนวณจาก sub เสมอ
- **main + sub:** มักเก็บใน `ingredientsJson` — โครงสร้างซ้อนกับ MyMeal (`parentId`) ไม่เหมือนกัน — gap ล็อก main หลัง AI อยู่ใน **arcal2-00**

**ช่องว่าง / งาน schema**

- นิยาม **JSON schema หรือโมเดล Dart เดียว** สำหรับ `ingredientsJson`: โหนด `main_ingredients[]` แต่ละอันมี `sub_ingredients[]`; จำกัดความลึก 2 ระดับ
- ฟังก์ชัน **recompute entry**: `sub → main → รายการ` เรียกทุกครั้งที่ sub เปลี่ยน + ตอนบันทึกจาก AI
- **Backwards-compatible:** อ่าน format เก่าได้ บันทึกใหม่ใช้ format ใหม่ (ไม่ต้อง migrate ข้อมูลเก่าทั้งหมด)
- **ซิงก์การแสดง:** ทุกจุด (sandbox, sheet แก้ไข, share card) อ่านชุดฟิลด์เดียวกัน

---

### 2.3 Long-press สร้างกลุ่ม — Merge หลายรายการเป็น 1 entry

**ความต้องการ:** เมื่อกดค้างเลือกหลายรายการ → กด **ปุ่ม Group** บนแถบ action ด้านบน

**พฤติกรรม (ตัดสินใจแล้ว):**

| ขั้นตอน | รายละเอียด |
|---------|-----------|
| เลือกหลายรายการ | ใช้ long-press + tap ที่มีอยู่แล้ว; แถบ action ด้านบนจะมีปุ่ม Group ใหม่ |
| กด Group | **Merge** → สร้าง `FoodEntry` ใหม่ 1 อัน; entry เดิม **ลบ/ซ่อน** |
| ชื่อ default | `group_xxx` (xxx = ลำดับหรือ timestamp); ผู้ใช้เปลี่ยนชื่อภายหลังได้ |
| Nutrition | **รวม** จากทุก entry ที่เลือก |
| โครงสร้างภายใน | entry เดิม → กลายเป็น main ingredients ภายใน entry ใหม่; ถ้า entry เดิมมี main/sub อยู่แล้ว → ยุบ sub เข้า main ก่อน merge (ห้าม sub-sub) |
| ดูรายละเอียด | **ปุ่ม detail แบบเดิม** (simple) |
| ความลึก | **2 ระดับ** ใต้รายการ (main + sub) — ห้าม sub-sub |

**ผลการศึกษา**

- `FoodEntries` มี `groupId`, `groupSource`, `groupOrder`, `isGroupOriginal` — มีแนวคิดกลุ่มอยู่แล้ว แต่ยังไม่พบ flow "long-press → merge เป็น entry ใหม่ + ลบเดิม"
- `FoodSandbox` มี selection mode / ลบ / analyze / move date — เป็นจุดที่ต่อยอด

**ช่องว่าง:**

- State machine การรวมกลุ่ม: validation (มื้อเดียวกัน? ข้ามมื้อได้ไหม?), สร้าง entry ใหม่, ย้ายข้อมูลลง `ingredientsJson`, ลบ entry เก่า, invalidate providers
- Edge cases: หน่วยต่างกัน, entry ไม่มีรูป, entry ที่เป็น group อยู่แล้ว (ป้องกัน nested group)
- Migration: `groupId` เดิมยังใช้ได้ไหม หรือต้องเปลี่ยน semantic

---

### 2.4 Thumbnail เล็กมากในรายการ ingredient + แตะดูภาพเต็ม (bounding box ถ้ามี)

**ความต้องการ:** ในมุมมองที่มีหลาย ingredient ต้องมี **thumbnail ขนาดเล็กมาก**; แตะแล้วขยายดูรูป; ถ้ามี bounding box ให้แสดงบนภาพขยาย

**แหล่งรูป (ตัดสินใจแล้ว):** **มีรูปก็แสดง ไม่มีก็ข้าม** — ไม่ต้อง placeholder; รูปมาจาก `FoodEntry.imagePath` (crop จาก bounding box ถ้ามี)

**ผลการศึกษา**

- `FoodEntry`: `imagePath`, `supplementaryImagePath2/3`, `arBoundingBox`, `arImageWidth` / `arImageHeight` — ข้อมูลรองรับภาพและกล่อง AR อยู่แล้ว
- UI รายการ ingredient ส่วนใหญ่เป็น text-first — **ยังไม่มี pattern "micro thumbnail + full-screen preview with overlay"**

**ช่องว่าง:**

- Widget กลาง (เช่น `IngredientThumb`) + นโยบาย cache/ขนาดรูป
- แมป `arBoundingBox` จากพิกัด normalized → overlay บน `Image`
- กรณี text-only analysis (ไม่มีรูป): ไม่แสดง thumbnail → ไม่มีปัญหา

---

### 2.5 สร้างเมนูใหม่ — เพิ่มปุ่มรูปภาพ (gallery) คู่กับปุ่ม search (magnifier)

**ความต้องการ:** นอกจากปุ่มค้น (`Icons.search` บนแถว sub ใน `create_meal_sheet.dart`) ให้มีปุ่ม **เลือกรูปจาก gallery** → ทำงาน **เหมือน flow วิเคราะห์อาหารด้วยรูปปกติ**

**ผลการศึกษา**

- `create_meal_sheet.dart` บรรทัดราว 953–966: ปุ่ม AI/sub ใช้ `Icons.search` + `_lookupSubIngredient`
- Flow วิเคราะห์รูป: `ImageAnalysisPreviewScreen`, `ImagePickerService`, `GeminiService` — มีอยู่แล้ว

**ช่องว่าง:** เชื่อม picker → ได้ `File`/path → เรียก pipeline เดียวกับ image food analysis → map ผลลัพธ์เข้าแถววัตถุดิบ (ชื่อ, ปริมาณ, โภชนาการ) โดยไม่ทำลายกฎ food pattern ใน `.cursorrules`

---

### 2.6 ซ่อน QuestBar; ถอด free energy legacy ใน Energy Store ออกทั้งหมด

**ความต้องการ:**

- **ซ่อน `QuestBar` ไปเลย** — ไม่ต้องมีที่อื่นมาแทน; ลดความสับสนครั้งแรก + ประหยัดพื้นที่
- **Streak / tier ใน logic** ยังทำงานได้ตามเดิม (bonus ตอนซื้อ token)
- **Free energy legacy ใน Energy Store: ถอดออกเลย** — แจกซ้ำ/ซ้อนมาก; ลืมลบมานาน

**ชี้แจง — Free pass / seasonal / QuestBar:**

- **Free pass ไม่ได้แจกผ่าน QuestBar** — จุดประสงค์: burn excess energy token + แจกในงาน/เทศกาล
- **Seasonal offer:** ยังสร้างและใช้งานได้ — ไม่อยู่ใน QuestBar

**ผลการศึกษา**

- `QuestBar` ใช้ใน `HealthTimelineTab` + `BasicModeTab` — ซ่อน widget **ไม่หยุด** streak counting
- `EnergyStoreScreen`: `_claimFreeEnergy` (`claimFreeEnergyEndpoint`) = **ลบ**; `_claimFreepass` (`claimFreepassEndpoint`) = **คง**

**ช่องว่าง / checklist:**

- ถอด tile / flow ที่เรียก `claimFreeEnergy` + endpoint (หรือปิดฝั่งเซิร์ฟเวอร์)
- Audit `highlightOfferId` / ทางเข้า Energy Store ว่าไม่เหลือทางลัดแจก energy แบบเดิม
- ซ่อน `QuestBar` widget จากทั้ง 2 หน้า

---

### 2.7 ซ่อนระบบแชท; เก็บ AnalyzeBar; แถวล่าง Basic = 3 ปุ่ม

**ความต้องการ (ยืนยัน)**

- **`AnalyzeBar` เก็บไว้**
- **แชท: ซ่อน UI ไว้ก่อน** (ไม่ลบโค้ด) — อนาคตอาจใช้ใหม่
- **แถวล่าง Basic:** คง **3 ปุ่ม** (Gallery, AR, Add)
- **Search:** ใช้ของเดิมที่ปุ่มเพิ่มรายการ + `AddFoodBottomSheet` — **ไม่สร้าง search ใหม่**

**ผลการศึกษา**

- **Pro:** `IndexedStack` มี `ChatScreen` เป็นแท็บ; `BottomNavigationBar` 5 รายการ
- **Basic:** `_buildActionButtons` = 3 ปุ่ม; `AnalyzeBar` = **คง**; `_buildChatInput` = **ซ่อน**

**ช่องว่าง:**

- ซ่อน `_buildChatInput` + ทางเข้าแชทใน Pro (แท็บ / route) ด้วย flag หรือ `Visibility` — **ไม่ลบ** `ChatScreen` / `chat_provider`
- ตรวจ energy / analytics ที่ผูกแชทเมื่อซ่อน — ไม่ให้ error

---

## 3. Minor change — ความต้องการ + สถานะโค้ด

### 3.1 โค้ดพิเศษ (influencer / marketing) + Admin จัดการ CRUD + จำกัดการใช้

**ความต้องการ (UX + รางวัล)**

- ผู้ใช้ **กรอกโค้ดในแอป** — ตำแหน่ง: หน้า **Settings** แบบ redeem code เกมมือถือ
- **รางวัลตั้งค่าต่อโค้ด** — เช่น energy, free pass (หรือประเภทอื่น)
- Admin: เพิ่ม/ลบ/แก้โค้ด, จำกัดจำนวนครั้ง (รวม + ต่อผู้ใช้), วันหมดอายุ

**ผลการศึกษา**

- `admin-panel` มี Offers system — ไม่ใช่ promo code แบบ influencer
- ในแอปยังไม่มีช่อง redeem code ใน Settings

**ช่องว่าง:** ออกแบบ collection (code, `reward_type`, payload, `max_redemptions`, `per_user_limit`, `expiry`), API redeem (verify + idempotent), admin CRUD, audit log, ป้องกัน abuse

---

### 3.2 เลือกวันพรุ่งนี้และวันถัดไป (วางแผนล่วงหน้า)

**ความต้องการ:** เลื่อนวันไปอนาคตได้

**ผลการศึกษา**

- `DailySummaryCard`: ลูกศรขวา **disabled เมื่อ `isToday`**; `showDatePicker` → `lastDate: DateTime.now()`
- `DateNavigationBar._showPicker`: เดียวกัน `lastDate: DateTime.now()`
- `EditFoodBottomSheet._pickDate`: `lastDate: DateTime.now().add(Duration(days: 1))` — ไม่สอดคล้อง

**ช่องว่าง:** กำหนด `lastDate` = today+N (เช่น 7 หรือ 30 วัน); อัปเดตลูกศรขวา; ตรวจ `healthTimelineProvider` / timestamp ว่ารองรับอนาคต

---

### 3.3 Share card: ปริมาณบนภาพ, aspect 16:9 / 1:1, toggle แสดงปริมาณ

**ความต้องการ:** เพิ่มปริมาณ, รองรับ 16:9 และ 1:1, toggle ใส่ปริมาณลงภาพ

**ผลการศึกษา**

- `ShareCardConfig`: มี toggles `showCalories`, `showMacros`, ฯลฯ — **ยังไม่มี** field สำหรับ aspect ratio / "show serving size"
- `CardCaptureService`: capture จาก `RepaintBoundary` — ขนาดตาม widget ไม่ใช่ preset

**ช่องว่าง:** เพิ่ม enum aspect ใน config; wrapper ขนาดคงที่ก่อน capture; ขยาย l10n สำหรับป้ายกำกับปริมาณ

---

### 3.4 ย้ายรายการข้ามมื้อ (ลาก / UX เทียบเท่า)

**ความต้องการ:** ย้ายรายการอาหารจากมื้อหนึ่งไปอีกมื้อ — เลือกรายการแล้วลาก หรือปุ่ม "ย้ายไปมื้อ…" บนแถบเลือกหลายรายการ

**สถานะปัจจุบัน — ยังทำไม่ได้**

- **`FoodSandbox`**: ยังไม่มีการเปลี่ยน `MealType` แบบลากข้ามกลุ่มมื้อ
- **`MealSection`** (Pro): มีปัดขวา (swipe) เปิด `_ChangeMealBottomSheet` — ไม่ใช่ drag-and-drop

**ช่องว่าง:**

- ทำหลังมี **กลุ่มมื้อใน UI หลัก** (ข้อ 2.1) — กำหนด `DragTarget` หรือปุ่มย้ายมื้อในแถบ selection
- อัปเดต `FoodEntry.mealType` (+ `timestamp` ถ้าต้องการ) แล้ว `updateFoodEntry` + invalidate providers
- พิจารณา accessibility (ลากอาจยากบนจอเล็ก — อาจมีทางเลือกปุ่มเสมอ)

---

## 4. การตัดสินใจทั้งหมด (รวม 14 ข้อ)

บันทึกจากผู้ใช้ — ทุกประเด็นเปิดตอบแล้ว

| # | หัวข้อ | คำตอบ |
|---|--------|-------|
| 1 | Basic / Pro กับสิทธิ์ | **ไม่เคยแยกสิทธิ์** — แค่ UI complexity; หลังอัปเกรดใช้ Basic เป็น main |
| 2 | Long-press Group | เพิ่มปุ่ม Group บนแถบ action → **Merge** เป็น entry ใหม่ 1 อัน; ชื่อ default `group_xxx`; entry เดิมลบ; ดูด้วย detail แบบเดิม |
| 3 | QuestBar | **ซ่อนไปเลย** ไม่ต้อง UI แทน — ลดพื้นที่ + ลดงงตอนดาวน์โหลดครั้งแรก |
| 4 | Free energy legacy | **ถอดออกเลย** — แจกซ้ำ/ซ้อนเยอะ ลืมลบมานาน; free pass + seasonal คง |
| 5 | Chat | **ซ่อนไว้ก่อน** (ไม่ลบโค้ด); `AnalyzeBar` คง; ไม่ทำ search ใหม่ |
| 6 | สเกลปริมาณรวม (main lock) | **แก้ปริมาณรวมได้** → sub สเกลตามสัดส่วนเดิมอัตโนมัติ |
| 7 | AI multi-root | แต่ละ root จาก AI = **main ingredient** ใต้ชื่อจาน |
| 8 | Group: merge vs visual | **Merge** → สร้าง FoodEntry ใหม่ 1 อัน ลบตัวเดิม nutrition รวม |
| 9 | Entry ไม่มี sub | **ไม่บังคับ** — เก็บ nutrition ตรงบน entry เหมือนเดิม |
| 10 | Nested sub จาก AI | **แบน 2 ระดับเสมอ** (main + sub) ใน UI/DB; ถ้า AI คืนลึกกว่า ยุบ |
| 11 | Thumbnail source | **มีรูปก็แสดง ไม่มีก็ข้าม** (ไม่ต้อง placeholder) |
| 12 | Migration ข้อมูลเก่า | **Backwards-compatible** — อ่าน format เก่าได้ บันทึกใหม่ใช้ format ใหม่ |
| 13 | Pro access หลังอัปเกรด | **ปิดทุกทาง** — ล็อก `appMode = basic` ไม่มี debug toggle |
| 14 | Feature flags | **ไม่ใช้** — ปล่อย version bump ทีเดียว |

---

## 5. Dependency map + ลำดับงาน

```
Phase 0: Foundation
  ┌─ T1: กำหนด JSON schema (ingredientsJson v2) + โมเดล Dart
  │     backwards-compatible กับ format เก่า
  │     flatten logic สำหรับ AI nested > 2 ระดับ
  │     recompute function: sub → main → entry
  │
  └─ T2: ล็อก AppMode = basic; ถอด ModeToggle
        แทนที่ด้วยปุ่ม My Meal → HealthMyMealTab

Phase 1: Core UI restructure  [ต้องจบ T1, T2 ก่อน]
  ┌─ T3: ปรับ FoodSandbox ให้มีกลุ่มมื้อ (tab / กรอบล้อม)
  │     ไม่ใช้ MealSection layout; คง feed เดียว
  │
  ├─ T4: ซ่อน QuestBar (HealthTimelineTab + BasicModeTab)
  │     ถอด free energy legacy ใน EnergyStore
  │     (claimFreeEnergy + endpoint) — คง free pass + seasonal
  │
  └─ T5: ซ่อน Chat UI (Basic + Pro); เก็บ AnalyzeBar
        ปรับ bottom nav ไม่เพิ่ม search ใหม่

Phase 2: Data & ingredient logic  [ต้องจบ T1 ก่อน]
  ┌─ T6: ปรับ AddFoodBottomSheet / EditFoodBottomSheet
  │     ให้ lock main เมื่อมี sub; derive nutrition จาก sub
  │     AI root → main ingredient; สเกลปริมาณรวมได้
  │     (สอดคล้อง arcal2-00 + CreateMealSheet)
  │
  ├─ T7: ปรับ GeminiAnalysisSheet / IntentHandler
  │     ให้ใช้ schema + recompute เดียวกัน
  │
  └─ T8: ปรับ AI prompt / post-process
        sum(root) ≈ total; flatten nested; ไม่ double-count

Phase 3: UX enhancements  [ต้องจบ T3 ก่อน]
  ┌─ T9: ปุ่ม Group บนแถบ selection
  │     merge หลาย entry → 1 entry ใหม่ (group_xxx)
  │     ลบ entry เดิม; ยุบ sub → main ก่อน merge (ห้าม sub-sub)
  │
  ├─ T10: ย้ายรายการข้ามมื้อ
  │      ลากหรือปุ่ม "ย้ายไปมื้อ…" บนแถบ selection
  │
  └─ T11: Thumbnail ingredient + full view + bbox overlay

Phase 4: Feature additions  [ทำ parallel ได้]
  ┌─ T12: Create meal: ปุ่ม gallery → image analysis pipeline
  │
  ├─ T13: ปรับ navigation วันที่อนาคต (lastDate = today+N)
  │
  ├─ T14: Share card: aspect enum + ปริมาณ + toggles
  │
  └─ T15: Promo code: backend collection + admin CRUD
        + ช่อง redeem ใน Settings
        (reward_type: energy, freepass, …)
```

**ลำดับแนะนำ:**

| ลำดับ | Task | Dependencies | ความสำคัญ |
|-------|------|-------------|-----------|
| 1 | T1 — JSON schema v2 | — | 🔴 Blocker (T6, T7, T8, T9 ต้องใช้) |
| 2 | T2 — ถอด ModeToggle + ปุ่ม My Meal | — | 🔴 ง่าย ทำได้เลย |
| 3 | T6 — Lock main + derive nutrition (AddFood/EditFood) | T1 | 🔴 Core business logic |
| 4 | T7 — GeminiAnalysisSheet / IntentHandler sync | T1 | 🔴 ครอบคลุมทุกจุด |
| 5 | T8 — AI prompt / post-process | T1 | 🟡 ปรับ prompt ให้สอดคล้อง |
| 6 | T3 — FoodSandbox กลุ่มมื้อ | T2 | 🔴 UX หลักอัปเกรด |
| 7 | T4 — ซ่อน QuestBar + ถอด free energy | — | 🟡 ทำ parallel ได้ |
| 8 | T5 — ซ่อน Chat | — | 🟡 ทำ parallel ได้ |
| 9 | T13 — วันที่อนาคต | — | 🟢 Minor, ทำ parallel ได้ |
| 10 | T9 — Group/Merge | T1, T3 | 🟡 หลัง schema + กลุ่มมื้อนิ่ง |
| 11 | T10 — ย้ายข้ามมื้อ | T3 | 🟡 หลังกลุ่มมื้อ |
| 12 | T11 — Thumbnail | T1 | 🟢 |
| 13 | T12 — Create meal gallery button | — | 🟢 |
| 14 | T14 — Share card aspect + ปริมาณ | — | 🟢 |
| 15 | T15 — Promo code | — | 🟢 ทำ parallel / แยก sprint |

---

## 6. ขอบเขตไฟล์ที่ต้องแก้ (สรุป)

| กลุ่ม | ไฟล์ | งาน |
|-------|------|-----|
| **Mode / Navigation** | `mode_toggle.dart`, `home_screen.dart`, `app_mode_provider.dart` | ถอด toggle; ล็อก basic; เพิ่มปุ่ม My Meal |
| **Sandbox / กลุ่มมื้อ** | `basic_mode_tab.dart`, `food_sandbox.dart` | กลุ่มมื้อ visual; ซ่อน QuestBar; ซ่อน ChatInput |
| **Pro cleanup** | `health_timeline_tab.dart` | ซ่อน QuestBar |
| **Ingredient logic** | `add_food_bottom_sheet.dart`, `edit_food_bottom_sheet.dart`, `create_meal_sheet.dart`, `gemini_analysis_sheet.dart`, `intent_handler.dart` | lock main; derive nutrition; flatten AI; scale sub |
| **AI** | `gemini_service.dart` | ปรับ prompt; post-process flatten; sum validation |
| **Database** | `app_database.dart`, `database_service.dart` | Schema migration (backwards-compatible); `ingredientsJson` v2 |
| **Energy** | `energy_store_screen.dart`, `quest_bar.dart` | ถอด `_claimFreeEnergy`; ซ่อน QuestBar widget |
| **Chat** | `chat_screen.dart` (Pro), `basic_mode_tab.dart` | ซ่อน UI; คงโค้ด |
| **Date nav** | `daily_summary_card.dart`, `date_navigation_bar.dart`, `edit_food_bottom_sheet.dart` | เปิดวันอนาคต |
| **Share** | `share_card_config.dart`, `share_card_creator_screen.dart`, `share_card_food_item.dart` | Aspect enum; serving toggle |
| **Group/Merge** | `food_sandbox.dart` (selection bar) | ปุ่ม Group; merge logic |
| **Move across meals** | `food_sandbox.dart` | ลาก/ปุ่มย้ายมื้อ |
| **Thumbnail** | widget ใหม่ `IngredientThumb` (หรือ inline ใน sheets) | micro thumbnail + full view + bbox |
| **Create meal gallery** | `create_meal_sheet.dart` | ปุ่ม gallery + image pipeline |
| **Promo code** | หน้าตั้งค่า (ใหม่), admin-panel, backend | CRUD; redeem API; Settings UI |

---

*เอกสารนี้สังเคราะห์จากความต้องการของผู้ใช้ ผลการอ่านโค้ด และ 14 คำตอบที่ตัดสินใจแล้ว — พร้อมเข้าสู่ task breakdown / milestone*
