# 📋 Task: Phase 4 — Migrate Rest of App ไปใช้ Design System

## 🎯 เป้าหมาย

Migrate หน้าที่เหลือทั้งหมดให้ใช้ Design System จาก Phase 1:
- แก้ hardcoded colors → `AppColors.xxx`
- แก้ hardcoded spacing → `AppSpacing.xxx`
- แก้ hardcoded border radius → `AppRadius.xxx`
- แก้ปุ่ม → `AppButton.xxx`
- แก้ bottom sheets → ใช้ `AppBottomSheet` wrapper

## 📂 ไฟล์ที่ต้อง Migrate

### กลุ่ม A: Home & Navigation (ทำก่อน)

| ไฟล์ | ปัญหาหลัก |
|------|-----------|
| `lib/features/home/presentation/home_screen.dart` | hardcoded colors, spacing |
| `lib/features/home/widgets/magic_button.dart` | custom FAB styling |
| `lib/main.dart` | อาจมี hardcoded colors |

### กลุ่ม B: Energy & Gamification

| ไฟล์ | ปัญหาหลัก |
|------|-----------|
| `lib/features/energy/presentation/tier_benefits_screen.dart` | hardcoded tier colors |
| `lib/features/energy/widgets/energy_badge.dart` | hardcoded colors |
| `lib/features/energy/widgets/milestone_progress_card.dart` | Colors.grey usage |
| `lib/features/energy/widgets/weekly_challenge_card.dart` | Colors.grey, hardcoded radius |
| `lib/features/energy/widgets/no_energy_dialog.dart` | custom dialog styling |
| `lib/features/energy/widgets/claim_button.dart` | Colors.green hardcoded |
| `lib/features/energy/widgets/quest_bar.dart` | hardcoded colors |
| `lib/features/energy/widgets/seasonal_quest_card.dart` | hardcoded colors |
| `lib/features/energy/widgets/tier_celebration_card.dart` | hardcoded colors |
| `lib/features/energy/widgets/tier_up_overlay.dart` | hardcoded colors |

### กลุ่ม C: Profile & Settings

| ไฟล์ | ปัญหาหลัก |
|------|-----------|
| `lib/features/profile/presentation/profile_screen.dart` | gradient buttons, Colors.purple |
| `lib/features/profile/presentation/health_goals_screen.dart` | hardcoded colors |
| `lib/features/profile/presentation/privacy_policy_screen.dart` | hardcoded colors |
| `lib/features/profile/presentation/terms_screen.dart` | hardcoded colors |

### กลุ่ม D: Subscription & Referral

| ไฟล์ | ปัญหาหลัก |
|------|-----------|
| `lib/features/subscription/presentation/subscription_screen.dart` | Color(0xFF7C3AED) → AppColors.premium |
| `lib/features/referral/presentation/referral_screen.dart` | hardcoded colors |

### กลุ่ม E: Camera & Chat

| ไฟล์ | ปัญหาหลัก |
|------|-----------|
| `lib/features/camera/presentation/camera_screen.dart` | hardcoded colors |
| `lib/features/chat/presentation/chat_screen.dart` | hardcoded colors |
| `lib/features/scanner/logic/scan_controller.dart` | hardcoded colors |

### กลุ่ม F: Onboarding & Legal

| ไฟล์ | ปัญหาหลัก |
|------|-----------|
| `lib/features/onboarding/presentation/onboarding_screen.dart` | hardcoded colors |
| `lib/features/legal/presentation/disclaimer_screen.dart` | hardcoded colors |

### กลุ่ม G: Core Widgets

| ไฟล์ | ปัญหาหลัก |
|------|-----------|
| `lib/core/widgets/analytics_consent_dialog.dart` | Colors.grey, Colors.green |
| `lib/core/widgets/disclaimer_widget.dart` | Colors.orange, Colors.blue |
| `lib/core/widgets/search_mode_selector.dart` | ตรวจว่าใช้ AppColors หรือยัง |

---

## 🔧 วิธีทำงาน (ทำซ้ำสำหรับแต่ละไฟล์)

### สำหรับทุกไฟล์:

**ขั้นตอนที่ 1:** เพิ่ม import (ถ้ายังไม่มี):
```dart
import 'package:miro_hybrid/core/theme/app_tokens.dart';
// ถ้าใช้ปุ่ม:
import 'package:miro_hybrid/core/widgets/app_button.dart';
```

**ขั้นตอนที่ 2:** ทำ Find & Replace ทั้งไฟล์:

#### สี (Colors)

| ค้นหา | แทนที่ด้วย |
|-------|-----------|
| `const Color(0xFF6366F1)` | `AppColors.ai` |
| `Color(0xFF6366F1)` | `AppColors.ai` |
| `const Color(0xFF7C3AED)` | `AppColors.premium` |
| `Color(0xFF7C3AED)` | `AppColors.premium` |
| `const Color(0xFF10B981)` | `AppColors.finance` |
| `Color(0xFF10B981)` | `AppColors.finance` |
| `const Color(0xFFEF4444)` | `AppColors.error` |
| `Color(0xFFEF4444)` | `AppColors.error` |
| `const Color(0xFF3B82F6)` | `AppColors.info` |
| `Color(0xFF3B82F6)` | `AppColors.info` |
| `const Color(0xFFF59E0B)` | `AppColors.warning` |
| `Color(0xFFF59E0B)` | `AppColors.warning` |
| `const Color(0xFF22C55E)` | `AppColors.success` |
| `Color(0xFF22C55E)` | `AppColors.success` |
| `Colors.green` | `AppColors.success` |
| `Colors.red` | `AppColors.error` |
| `Colors.orange` | `AppColors.warning` |
| `Colors.blue` | `AppColors.info` |
| `Colors.purple` | `AppColors.ai` |
| `Colors.grey.shade600` | `AppColors.textSecondary` |
| `Colors.grey.shade500` | `AppColors.textSecondary` |
| `Colors.grey.shade400` | `AppColors.textTertiary` |
| `Colors.grey.shade300` | `AppColors.divider` |
| `Colors.grey.shade200` | `AppColors.divider` |
| `Colors.grey.shade100` | `AppColors.surfaceVariant` |
| `Colors.grey[600]` | `AppColors.textSecondary` |
| `Colors.grey[400]` | `AppColors.textTertiary` |
| `Colors.grey[300]` | `AppColors.divider` |

**⚠️ ระวัง:**
- `Colors.white` → ใช้ `AppColors.surface` หรือ `Theme.of(context).cardColor` (สำหรับ background)
- `Colors.white` → คงไว้ถ้าเป็น `foregroundColor` ของปุ่ม (text color บนปุ่มสี)
- `Colors.black` → ใช้ `AppColors.textPrimary` (สำหรับ text), คงไว้ถ้าเป็น shadow

#### Border Radius

| ค้นหา | แทนที่ด้วย |
|-------|-----------|
| `BorderRadius.circular(24)` | `AppRadius.xxl` |
| `BorderRadius.circular(20)` | `AppRadius.xl` |
| `BorderRadius.circular(18)` | `AppRadius.xl` |
| `BorderRadius.circular(16)` | `AppRadius.lg` |
| `BorderRadius.circular(12)` | `AppRadius.md` |
| `BorderRadius.circular(10)` | `AppRadius.md` |
| `BorderRadius.circular(8)` | `AppRadius.sm` |
| `BorderRadius.circular(6)` | `AppRadius.sm` |
| `BorderRadius.circular(4)` | `AppRadius.sm` |

#### Spacing (SizedBox)

| ค้นหา | แทนที่ด้วย |
|-------|-----------|
| `SizedBox(height: 2)` | `SizedBox(height: AppSpacing.xxs)` |
| `SizedBox(height: 4)` | `SizedBox(height: AppSpacing.xs)` |
| `SizedBox(height: 8)` | `SizedBox(height: AppSpacing.sm)` |
| `SizedBox(height: 12)` | `SizedBox(height: AppSpacing.md)` |
| `SizedBox(height: 16)` | `SizedBox(height: AppSpacing.lg)` |
| `SizedBox(height: 20)` | `SizedBox(height: AppSpacing.xl)` |
| `SizedBox(height: 24)` | `SizedBox(height: AppSpacing.xxl)` |
| `SizedBox(height: 32)` | `SizedBox(height: AppSpacing.xxxl)` |
| `SizedBox(width: 2)` | `SizedBox(width: AppSpacing.xxs)` |
| `SizedBox(width: 4)` | `SizedBox(width: AppSpacing.xs)` |
| `SizedBox(width: 8)` | `SizedBox(width: AppSpacing.sm)` |
| `SizedBox(width: 12)` | `SizedBox(width: AppSpacing.md)` |
| `SizedBox(width: 16)` | `SizedBox(width: AppSpacing.lg)` |
| `SizedBox(width: 20)` | `SizedBox(width: AppSpacing.xl)` |

**⚠️ ระวัง:** ลบ `const` keyword ออกจาก `SizedBox` เมื่อใช้ `AppSpacing.xxx` เพราะมันไม่ใช่ `const` expression

#### EdgeInsets

| ค้นหา | แทนที่ด้วย |
|-------|-----------|
| `EdgeInsets.all(8)` | `AppSpacing.paddingSm` |
| `EdgeInsets.all(12)` | `AppSpacing.paddingMd` |
| `EdgeInsets.all(16)` | `AppSpacing.paddingLg` |
| `EdgeInsets.all(20)` | `AppSpacing.paddingXl` |

**ขั้นตอนที่ 3:** compile ตรวจสอบ → แก้ error → ไปไฟล์ถัดไป

---

## ⚠️ ข้อควรระวัง

1. **ทำทีละกลุ่ม** — compile ผ่านทุกไฟล์ในกลุ่มก่อนไปกลุ่มถัดไป
2. **ระวัง context-dependent colors** — บาง `Colors.white` ใช้เป็น text on button ไม่ใช่ background
3. **ระวัง .withOpacity()** — ถ้าเจอให้เปลี่ยนเป็น `.withValues(alpha:)` ด้วย
4. **ระวัง conditional colors** — เช่น `isDark ? X : Y` ให้ใช้ dark variants จาก AppColors
5. **อย่าแก้ logic** — แก้เฉพาะ styling

## ✅ Definition of Done

- [ ] กลุ่ม A (Home): ไม่มี hardcoded `Color(0xFF...)` หรือ `Colors.xxx` ที่มี AppColors equivalent
- [ ] กลุ่ม B (Energy): ไม่มี hardcoded colors
- [ ] กลุ่ม C (Profile): ไม่มี `Color(0xFF7C3AED)`, ใช้ `AppColors.premium`
- [ ] กลุ่ม D (Subscription): ไม่มี hardcoded purple
- [ ] กลุ่ม E (Camera/Chat): ไม่มี hardcoded colors
- [ ] กลุ่ม F (Onboarding): ไม่มี hardcoded colors
- [ ] กลุ่ม G (Core Widgets): ไม่มี hardcoded colors
- [ ] `dart analyze lib/` ไม่มี error ใหม่
- [ ] แอป compile ได้ปกติ
- [ ] Dark mode ไม่มีปัญหา

## 🚀 ต้อง Deploy หรือไม่?

- [x] ไม่ต้อง Deploy (Flutter client-side only)
