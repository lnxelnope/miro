# Phase 5: Complete Cleanup — Hardcoded Styles Migration

> **Priority**: CRITICAL — ต้องทำทุกไฟล์ให้ครบ ก่อน merge  
> **ผู้รับผิดชอบ**: Junior Developer  
> **ผู้ตรวจ**: Senior Developer  
> **สถานะ**: 🔴 ยังไม่เริ่ม

---

## 📋 ภาพรวม

Phase 2 และ Phase 4 ทำ migration ไม่สมบูรณ์ ยังมี hardcoded styles ตกค้างกว่า **800+ จุด** ทั่วแอป  
Phase นี้ต้อง **กวาดให้หมด** โดย replace ด้วย Design System tokens ที่มีอยู่แล้ว

---

## 🎯 Design System Reference

### Imports ที่ต้องมีในทุกไฟล์ที่มี UI

```dart
import 'package:miro_hybrid/core/theme/app_colors.dart';
import 'package:miro_hybrid/core/theme/app_tokens.dart';
```

### Color Mapping Table

| Hardcoded | → Replace with |
|-----------|----------------|
| `Colors.green` / `Colors.green[xxx]` / `Colors.green.shade*` | `AppColors.success` |
| `Colors.red` / `Colors.red[xxx]` / `Colors.red.shade*` | `AppColors.error` |
| `Colors.orange` / `Colors.orange[xxx]` / `Colors.amber` | `AppColors.warning` |
| `Colors.blue` / `Colors.blue[xxx]` / `Colors.blue.shade*` | `AppColors.info` |
| `Colors.purple` / `Colors.purple[xxx]` / `Colors.deepPurple` | `AppColors.premium` |
| `Colors.indigo` / `Colors.indigo[xxx]` | `AppColors.ai` |
| `Colors.teal` / `Colors.teal[xxx]` | `AppColors.primary` |
| `Colors.grey[50]` / `Colors.grey.shade50` | `AppColors.background` |
| `Colors.grey[100]` / `Colors.grey.shade100` | `AppColors.surfaceVariant` |
| `Colors.grey[200]` / `Colors.grey.shade200` | `AppColors.divider` |
| `Colors.grey[300]` / `Colors.grey.shade300` | `AppColors.divider` |
| `Colors.grey[400]` / `Colors.grey.shade400` | `AppColors.textTertiary` |
| `Colors.grey[500]` / `Colors.grey.shade500` | `AppColors.textSecondary` |
| `Colors.grey[600]` / `Colors.grey.shade600` | `AppColors.textSecondary` |
| `Colors.grey[700]` / `Colors.grey.shade700` | `AppColors.surfaceVariantDark` |
| `Colors.grey[800]` / `Colors.grey.shade800` | `AppColors.surfaceDark` |
| `Colors.grey[900]` / `Colors.grey.shade900` | `AppColors.textPrimary` |
| `Colors.grey` (ไม่ระบุ shade) | `AppColors.textSecondary` (context-dependent) |
| `Color(0xFFEF4444)` | `AppColors.error` |
| `Color(0xFF22C55E)` | `AppColors.success` |
| `Color(0xFFF59E0B)` | `AppColors.warning` |
| `Color(0xFF3B82F6)` | `AppColors.info` |
| `Color(0xFF6366F1)` | `AppColors.ai` |
| `Color(0xFF7C3AED)` | `AppColors.premium` |
| `Color(0xFF10B981)` | `AppColors.finance` |
| `Color(0xFF2D8B75)` | `AppColors.primary` |

#### ⚠️ ข้อยกเว้น — ห้าม replace:
- `Colors.white` ที่ใช้เป็น text foreground บน colored background → **คงไว้**
- `Colors.black` ที่ใช้เป็น text → **คงไว้** (หรือใช้ `AppColors.textPrimary`)
- `Colors.transparent` → **คงไว้**
- `Colors.white` / `Colors.black` ใน `LinearGradient` / overlay → **คงไว้**
- สีที่ใช้ `.withOpacity()` หรือ `.withValues(alpha:)` → replace เฉพาะสี base เป็น AppColors แล้วคง `.withValues(alpha: X)` ไว้ (**ห้ามใช้ `.withOpacity()` ใน code ใหม่ — ใช้ `.withValues(alpha:)` แทน**)

### BorderRadius Mapping Table

| Hardcoded | → Replace with |
|-----------|----------------|
| `BorderRadius.circular(4)` | `AppRadius.sm` (ใกล้สุด = 8) หรือ `BorderRadius.circular(4)` ถ้า 8 ใหญ่ไป |
| `BorderRadius.circular(6)` | `AppRadius.sm` |
| `BorderRadius.circular(8)` | `AppRadius.sm` |
| `BorderRadius.circular(10)` | `AppRadius.md` (ใกล้สุด = 12) |
| `BorderRadius.circular(12)` | `AppRadius.md` |
| `BorderRadius.circular(14)` | `AppRadius.lg` (ใกล้สุด = 16) |
| `BorderRadius.circular(16)` | `AppRadius.lg` |
| `BorderRadius.circular(20)` | `AppRadius.xl` |
| `BorderRadius.circular(24)` | `AppRadius.xxl` |
| `BorderRadius.circular(30+)` / `BorderRadius.circular(50)` / `BorderRadius.circular(100)` | `AppRadius.pill` |

#### ⚠️ ข้อยกเว้น:
- `BorderRadius.vertical(top: ...)` สำหรับ BottomSheet → ใช้ `AppRadius.sheetTop`
- `BorderRadius.only(...)` ที่ custom → ใช้ `BorderRadius.only(topLeft: Radius.circular(AppRadius.lgValue), ...)` (ใช้ค่า value)

### Spacing Mapping Table

| Hardcoded | → Replace with |
|-----------|----------------|
| `2` / `2.0` | `AppSpacing.xxs` |
| `4` / `4.0` | `AppSpacing.xs` |
| `6` / `6.0` | `AppSpacing.sm` (ใกล้สุด = 8) หรือ `6` ถ้าจำเป็น |
| `8` / `8.0` | `AppSpacing.sm` |
| `10` / `10.0` | `AppSpacing.md` (ใกล้สุด = 12) |
| `12` / `12.0` | `AppSpacing.md` |
| `14` / `14.0` | `AppSpacing.lg` (ใกล้สุด = 16) |
| `16` / `16.0` | `AppSpacing.lg` |
| `20` / `20.0` | `AppSpacing.xl` |
| `24` / `24.0` | `AppSpacing.xxl` |
| `32` / `32.0` | `AppSpacing.xxxl` |
| `40` / `40.0` | `AppSpacing.xxxxl` |
| `48` / `48.0` | `AppSizes.buttonMedium` (ถ้าเป็น button height) |

#### ใช้กับ:
- `SizedBox(height: X)` → `SizedBox(height: AppSpacing.xx)`
- `SizedBox(width: X)` → `SizedBox(width: AppSpacing.xx)`
- `EdgeInsets.all(X)` → `AppSpacing.paddingXx` หรือ `EdgeInsets.all(AppSpacing.xx)`
- `EdgeInsets.symmetric(horizontal: X, vertical: Y)` → `EdgeInsets.symmetric(horizontal: AppSpacing.xx, vertical: AppSpacing.yy)`
- `EdgeInsets.only(...)` → `EdgeInsets.only(left: AppSpacing.xx, ...)`

#### ⚠️ ข้อยกเว้น:
- ตัวเลขที่ไม่ใช่ spacing เช่น `fontSize`, `iconSize`, `strokeWidth`, `height` ของ container ที่เป็น layout-specific → **ห้าม replace**
- `SizedBox(width: X, height: Y)` ที่ทั้งสองค่าเป็น specific size (เช่น icon container) → ใช้วิจารณญาณ

---

## 📁 ไฟล์ที่ต้องแก้ (เรียงตามความสำคัญ)

### 🔴 Tier 1 — Critical (เยอะที่สุด ต้องทำก่อน)

#### 1. `lib/features/health/widgets/add_food_bottom_sheet.dart`
- **Colors.***: ~15+ จุด
- **BorderRadius.circular()**: ~50+ จุด
- **Hardcoded EdgeInsets**: ~6 จุด
- **Color(0xFF...)**: ~15+ จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅
- **วิธีทำ**:
  1. grep หา `Colors.` ทั้งหมดในไฟล์ → replace ตาม Color Mapping Table
  2. grep หา `BorderRadius.circular` ทั้งหมด → replace ตาม Radius Mapping Table
  3. grep หา `Color(0x` ทั้งหมด → replace ตาม Color Mapping Table
  4. grep หา `EdgeInsets.` ที่มีตัวเลข hardcoded → replace ตาม Spacing Table
  5. grep หา `SizedBox(` ที่มีตัวเลข → replace ตาม Spacing Table

#### 2. `lib/features/health/widgets/edit_food_bottom_sheet.dart`
- **Colors.***: ~15+ จุด
- **BorderRadius.circular()**: ~50+ จุด
- **Hardcoded EdgeInsets**: ~6 จุด
- **Color(0xFF...)**: ~15+ จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅
- **หมายเหตุ**: ไฟล์นี้ structure คล้าย add_food_bottom_sheet.dart มาก ใช้แนวทางเดียวกัน

#### 3. `lib/features/health/widgets/create_meal_sheet.dart`
- **Colors.***: ~20+ จุด
- **BorderRadius.circular()**: ~50+ จุด
- **Hardcoded EdgeInsets**: ~5 จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 4. `lib/features/health/widgets/gemini_analysis_sheet.dart`
- **Colors.***: ~20+ จุด
- **BorderRadius.circular()**: ~20 จุด
- **Hardcoded EdgeInsets**: ~4 จุด
- **SizedBox**: ~15+ จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 5. `lib/features/health/widgets/food_detail_bottom_sheet.dart`
- **Colors.***: ~8+ จุด
- **BorderRadius.circular()**: ~30+ จุด
- **Hardcoded EdgeInsets**: ~3 จุด
- **Color(0xFF...)**: ~5 จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 6. `lib/features/profile/presentation/profile_screen.dart`
- **Colors.***: ~20+ จุด
- **BorderRadius.circular()**: ~4 จุด
- **Hardcoded EdgeInsets**: ~25+ จุด
- **SizedBox**: ~30+ จุด
- **Color(0xFF...)**: ~5 จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

---

### 🟠 Tier 2 — Important (ปานกลาง)

#### 7. `lib/features/energy/widgets/quest_bar.dart`
- **Colors.***: ~30+ จุด
- **BorderRadius.circular()**: ~8 จุด
- **Hardcoded EdgeInsets**: ~4 จุด
- **SizedBox**: ~30+ จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 8. `lib/features/chat/presentation/chat_screen.dart`
- **Colors.***: ~25+ จุด
- **BorderRadius.circular()**: ~12 จุด
- **Hardcoded EdgeInsets**: ~6 จุด
- **SizedBox**: ~20+ จุด
- **Color(0xFF...)**: ~1 จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 9. `lib/features/energy/presentation/tier_benefits_screen.dart`
- **Colors.***: ~2 จุด
- **BorderRadius.circular()**: ~7 จุด
- **Hardcoded EdgeInsets**: ~8 จุด
- **SizedBox**: ~20+ จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 10. `lib/features/energy/widgets/seasonal_quest_card.dart`
- **Colors.***: ~3 จุด
- **BorderRadius.circular()**: ~3 จุด
- **Hardcoded EdgeInsets**: ~1 จุด
- **SizedBox**: ~10+ จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 11. `lib/features/energy/widgets/tier_celebration_card.dart`
- **Colors.***: ~1 จุด
- **BorderRadius.circular()**: ~1 จุด
- **Hardcoded EdgeInsets**: ~1 จุด
- **SizedBox**: ~5+ จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 12. `lib/features/energy/widgets/tier_up_overlay.dart`
- **Colors.***: ~1 จุด
- **SizedBox**: ~4 จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 13. `lib/features/energy/widgets/claim_button.dart`
- **Colors.***: ~1 จุด
- **SizedBox**: ~1 จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 14. `lib/features/subscription/presentation/subscription_screen.dart`
- **Colors.***: ~3 จุด
- **BorderRadius.circular()**: ~2 จุด
- **Hardcoded EdgeInsets**: ~7 จุด
- **SizedBox**: ~20+ จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 15. `lib/features/profile/presentation/health_goals_screen.dart`
- **Colors.***: ~2 จุด
- **BorderRadius.circular()**: ~2 จุด
- **Hardcoded EdgeInsets**: ~8 จุด
- **SizedBox**: ~15+ จุด
- **Color(0xFF...)**: ~4 จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

---

### 🟡 Tier 3 — Normal (น้อย)

#### 16. `lib/features/onboarding/presentation/onboarding_screen.dart`
- **Colors.***: ~6 จุด
- **BorderRadius.circular()**: ~3 จุด
- **Hardcoded EdgeInsets**: ~5 จุด
- **SizedBox**: ~20+ จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 17. `lib/features/referral/presentation/referral_screen.dart`
- **Colors.***: ~3 จุด
- **Hardcoded EdgeInsets**: ~5 จุด
- **SizedBox**: ~15+ จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 18. `lib/features/health/widgets/edit_ingredient_sheet.dart`
- **Colors.***: ~3 จุด
- **BorderRadius.circular()**: ~12 จุด
- **Hardcoded EdgeInsets**: ~2 จุด
- **Color(0xFF...)**: ~1 จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 19. `lib/features/health/presentation/image_analysis_preview_screen.dart`
- **Colors.***: ~5 จุด
- **BorderRadius.circular()**: ~4 จุด
- **Hardcoded EdgeInsets**: ~1 จุด
- **SizedBox**: ~2 จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 20. `lib/features/camera/presentation/camera_screen.dart`
- **Colors.***: ~15+ จุด (ส่วนใหญ่ white/black — ให้คงไว้)
- **SizedBox**: ~1 จุด
- **Imports**: ❌ **ไม่มี** app_colors — ต้องเพิ่ม

---

### 🟢 Tier 4 — Minor (น้อยมาก)

#### 21. `lib/features/legal/presentation/disclaimer_screen.dart`
- **Colors.***: ~2 จุด (Colors.blue.shade900)
- **Hardcoded EdgeInsets**: ~2 จุด
- **SizedBox**: ~5 จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 22. `lib/features/profile/presentation/terms_screen.dart`
- **Hardcoded EdgeInsets**: ~2 จุด
- **SizedBox**: ~8 จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 23. `lib/features/profile/presentation/privacy_policy_screen.dart`
- **Hardcoded EdgeInsets**: ~2 จุด
- **SizedBox**: ~8 จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 24. `lib/features/energy/widgets/weekly_challenge_card.dart`
- **SizedBox**: ~2 จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 25. `lib/features/energy/widgets/milestone_progress_card.dart`
- **SizedBox**: ~1 จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 26. `lib/core/widgets/search_mode_selector.dart`
- **Colors.***: ~2 จุด
- **Hardcoded EdgeInsets**: ~1 จุด
- **SizedBox**: ~1 จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 27. `lib/core/widgets/disclaimer_widget.dart`
- **SizedBox**: ~2 จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

#### 28. `lib/core/widgets/analytics_consent_dialog.dart`
- **Colors.***: ~1 จุด
- **SizedBox**: ~6 จุด
- **Imports**: มี app_colors ✅ / มี app_tokens ✅

---

### 🔧 Missing Imports (ต้องเพิ่ม)

ไฟล์เหล่านี้ **ยังไม่มี import ที่จำเป็น** ต้องเพิ่มก่อนทำ migration:

| File | ต้องเพิ่ม |
|------|----------|
| `lib/features/health/presentation/health_timeline_tab.dart` | `app_tokens.dart` |
| `lib/features/health/presentation/health_my_meal_tab.dart` | `app_tokens.dart` |
| `lib/features/health/presentation/food_preview_screen.dart` | `app_tokens.dart` |
| `lib/features/health/presentation/barcode_scanner_screen.dart` | `app_tokens.dart` |
| `lib/features/health/presentation/nutrition_label_screen.dart` | `app_tokens.dart` |
| `lib/features/energy/presentation/energy_store_screen.dart` | `app_tokens.dart` |
| `lib/features/onboarding/presentation/tutorial_food_analysis_screen.dart` | `app_tokens.dart` |
| `lib/features/home/presentation/feature_tour.dart` | `app_tokens.dart` |
| `lib/features/home/widgets/magic_button.dart` | `app_tokens.dart` |
| `lib/features/chat/widgets/message_bubble.dart` | `app_tokens.dart` |
| `lib/features/camera/presentation/camera_screen.dart` | `app_colors.dart` |

---

## ✅ Checklist สำหรับแต่ละไฟล์

ทำตามลำดับนี้ทุกไฟล์:

- [ ] 1. เพิ่ม import `app_colors.dart` (ถ้ายังไม่มี)
- [ ] 2. เพิ่ม import `app_tokens.dart` (ถ้ายังไม่มี)
- [ ] 3. Replace `Colors.*` ตาม Color Mapping Table
- [ ] 4. Replace `Color(0xFF...)` / `Color(0x...)` ตาม Color Mapping Table
- [ ] 5. Replace `BorderRadius.circular(X)` ตาม Radius Mapping Table
- [ ] 6. Replace `EdgeInsets.*` hardcoded numbers ตาม Spacing Table
- [ ] 7. Replace `SizedBox(width/height: X)` hardcoded numbers ตาม Spacing Table
- [ ] 8. Replace `.withOpacity(X)` → `.withValues(alpha: X)` ทุกตัว
- [ ] 9. ตรวจว่าไม่มี linter error
- [ ] 10. ตรวจว่า UI ไม่เสีย (ไม่ต้อง run แต่ให้ใช้วิจารณญาณ)

---

## ⛔ กฎที่ห้ามทำเด็ดขาด

1. **ห้ามเปลี่ยน logic / behavior** — แก้แค่ styling tokens เท่านั้น
2. **ห้ามลบ widget หรือเปลี่ยน layout structure**
3. **ห้าม replace `Colors.white` ที่เป็น text foreground** บน colored background
4. **ห้าม replace `Colors.transparent`**
5. **ห้าม replace font sizes** — ตอนนี้ยังไม่มี font token (อนาคต)
6. **ห้ามเปลี่ยน icon** — แก้แค่ size ให้ใช้ `AppSizes.iconXx` ถ้าตรง
7. **ห้ามเปลี่ยนตัวเลข spacing ที่ไม่ได้ตรงกับ token ใดเลย** — ถ้า hardcoded `14` ไม่ตรงกับ token ใด ให้เลือกตัวที่ใกล้ที่สุด (`AppSpacing.md = 12` หรือ `AppSpacing.lg = 16`) โดยดูจาก context ว่าอันไหนเหมาะกว่า
8. **ห้ามเพิ่ม token ใหม่ใน app_colors.dart / app_tokens.dart** — ถ้าขาดให้แจ้ง Senior

---

## 📊 เกณฑ์ตรวจรับงาน (Definition of Done)

Senior จะตรวจด้วยการ grep ทั้ง codebase:

```bash
# ต้องเหลือ 0 ผลลัพธ์ (ยกเว้น exceptions ข้างบน)
rg "Colors\.(green|red|orange|blue|purple|indigo|teal|amber|deepPurple)" lib/features/ lib/core/widgets/
rg "BorderRadius\.circular\(" lib/features/ lib/core/widgets/
rg "Color\(0xFF" lib/features/ lib/core/widgets/
rg "\.withOpacity\(" lib/features/ lib/core/widgets/

# ต้องตรวจว่า exceptions ที่เหลือเป็นกรณียกเว้นจริงๆ
rg "Colors\.(white|black|transparent)" lib/features/ lib/core/widgets/
```

---

## 🔢 ลำดับการทำงาน

1. **ทำ Tier 1 ทั้ง 6 ไฟล์ก่อน** (ไฟล์ใหญ่ ปัญหาเยอะสุด)
2. **ทำ Tier 2 ทั้ง 9 ไฟล์** 
3. **ทำ Tier 3 ทั้ง 5 ไฟล์**
4. **ทำ Tier 4 ทั้ง 8 ไฟล์**
5. **เพิ่ม Missing Imports** ในไฟล์ที่ตกหล่น
6. **Run `dart analyze`** — ต้อง 0 error ที่เกี่ยวกับ token migration
7. **แจ้ง Senior ว่าเสร็จแล้ว** พร้อมรายงานว่าแก้กี่ไฟล์ กี่จุด

---

## 📝 ตัวอย่างการ replace ที่ถูกต้อง

### ตัวอย่าง 1: Color

```dart
// ❌ ก่อน
color: Colors.green,
backgroundColor: Colors.red.withOpacity(0.1),
color: Color(0xFF6366F1),

// ✅ หลัง
color: AppColors.success,
backgroundColor: AppColors.error.withValues(alpha: 0.1),
color: AppColors.ai,
```

### ตัวอย่าง 2: BorderRadius

```dart
// ❌ ก่อน
borderRadius: BorderRadius.circular(16),
borderRadius: BorderRadius.circular(20),
borderRadius: BorderRadius.circular(100),

// ✅ หลัง
borderRadius: AppRadius.lg,
borderRadius: AppRadius.xl,
borderRadius: AppRadius.pill,
```

### ตัวอย่าง 3: Spacing

```dart
// ❌ ก่อน
SizedBox(height: 16),
SizedBox(width: 8),
padding: EdgeInsets.all(16),
padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),

// ✅ หลัง
SizedBox(height: AppSpacing.lg),
SizedBox(width: AppSpacing.sm),
padding: AppSpacing.paddingLg,
padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
```

### ตัวอย่าง 4: Complex case

```dart
// ❌ ก่อน
Container(
  padding: EdgeInsets.only(left: 8, top: 4, right: 8, bottom: 4),
  decoration: BoxDecoration(
    color: Colors.green.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.green.withOpacity(0.3)),
  ),
  child: Text('Active', style: TextStyle(color: Colors.green)),
)

// ✅ หลัง
Container(
  padding: EdgeInsets.only(
    left: AppSpacing.sm, top: AppSpacing.xs,
    right: AppSpacing.sm, bottom: AppSpacing.xs,
  ),
  decoration: BoxDecoration(
    color: AppColors.success.withValues(alpha: 0.1),
    borderRadius: AppRadius.md,
    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
  ),
  child: Text('Active', style: TextStyle(color: AppColors.success)),
)
```

---

## ⚡ Tips สำหรับ Junior

1. **ทำทีละไฟล์** — อย่าทำพร้อมกันหลายไฟล์จะงง
2. **เริ่มจาก Colors → BorderRadius → EdgeInsets → SizedBox** ในแต่ละไฟล์
3. **ระวัง `grey` shades** — แต่ละ shade map ไปคนละ AppColor ดู table ให้ดี
4. **ระวัง `Colors.white` บน colored button** — ห้ามเปลี่ยน
5. **ถ้าไม่แน่ใจ** สีไหนควรใช้ AppColors อะไร → ดูจาก context (เช่น error message ใช้ `AppColors.error`, income ใช้ `AppColors.income`)
6. **Color(0xFF...)** ตรวจสอบค่า hex กับ AppColors — ถ้าตรงกันให้ replace ถ้าไม่ตรงเลยให้แจ้ง Senior
7. **อย่ามั่วเลข spacing** — ถ้า hardcoded เป็น `5` ซึ่งไม่ตรง token ใดเลย ให้เลือก `AppSpacing.xs (4)` หรือ `AppSpacing.sm (8)` ตาม context
