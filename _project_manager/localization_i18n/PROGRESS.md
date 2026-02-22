# 📊 Localization Progress Tracker

> อัพเดททุกครั้งที่ทำเสร็จแต่ละไฟล์

---

## 🎯 เป้าหมายรวม

- **ไฟล์ทั้งหมด:** 24 ไฟล์ (Widget 18 + Provider/Service 6)
- **Strings โดยประมาณ:** ~700 strings
- **เวลาโดยประมาณ:** ~18 ชั่วโมง (สำหรับ junior, เฉพาะงานที่เหลือ)
- **แบ่งงาน:** ทำทีละ 2-3 ไฟล์/วัน

---

## ✅ Phase 1: Core Screens (Priority High)

| # | Screen | File Path | Strings | Status | Developer | Date | Tested |
|---|--------|-----------|---------|--------|-----------|------|--------|
| 1 | Profile Screen | `lib/features/profile/presentation/profile_screen.dart` | ~60 | ✅ Done | - | 19/02/26 | ✅ |
| 2 | Home Screen | `lib/features/home/presentation/home_screen.dart` | ~15 | ✅ Done | AI Assistant | 19/02/26 | ✅ |
| 3 | Health Goals | `lib/features/profile/presentation/health_goals_screen.dart` | ~25 | ✅ Done | AI Assistant | 19/02/26 | ✅ |
| 4 | Onboarding | `lib/features/onboarding/presentation/onboarding_screen.dart` | ~40 | ✅ Done | AI Assistant | 19/02/26 | ✅ |

---

## 📱 Phase 2: Health & Diet Screens

| # | Screen | File Path | Strings | Status | Developer | Date | Tested |
|---|--------|-----------|---------|--------|-----------|------|--------|
| 5 | My Meal Tab | `lib/features/health/presentation/health_my_meal_tab.dart` | ~20 | ✅ Done | AI Assistant | 19/02/26 | ✅ |
| 6 | Timeline Tab | `lib/features/health/presentation/health_timeline_tab.dart` | ~25 | ✅ Done | AI Assistant | 19/02/26 | ✅ |
| 7 | Image Preview | `lib/features/health/presentation/image_analysis_preview_screen.dart` | ~15 | ✅ Done | AI Assistant | 19/02/26 | ✅ |
| 8 | Add Food Sheet | `lib/features/health/widgets/add_food_bottom_sheet.dart` | ~20 | ✅ Done | AI Assistant | 19/02/26 | ✅ |
| 9 | Edit Food Sheet | `lib/features/health/widgets/edit_food_bottom_sheet.dart` | ~20 | ✅ Done | AI Assistant | 19/02/26 | ✅ |
| 10 | Edit Ingredient | `lib/features/health/widgets/edit_ingredient_sheet.dart` | ~15 | ✅ Done | AI Assistant | 19/02/26 | ✅ |
| 11 | Meal Section | `lib/features/health/widgets/meal_section.dart` | ~10 | ✅ Done | AI Assistant | 19/02/26 | ✅ |

---

## 💬 Phase 3: Chat & AI Screens

| # | Screen | File Path | Strings | Status | Developer | Date | Tested |
|---|--------|-----------|---------|--------|-----------|------|--------|
| 12 | Chat Screen | `lib/features/chat/presentation/chat_screen.dart` | ~30 | ✅ Done | AI Assistant | 19/02/26 | ✅ |
| 13 | Chat Provider | `lib/features/chat/providers/chat_provider.dart` | ~5 | ⚠️ Skip | | | |

> ⚠️ Chat Provider: มี ~5 user-facing strings แต่ต้อง refactor เพราะไม่มี Context  
> ส่วนใหญ่เป็น AI prompts / debug logs → ไม่ต้องแปล — **แนะนำข้ามไปก่อน**

---

## 📸 Phase 4: Camera & Scanner

| # | Screen | File Path | Strings | Status | Developer | Date | Tested |
|---|--------|-----------|---------|--------|-----------|------|--------|
| 14 | Camera Screen | `lib/features/camera/presentation/camera_screen.dart` | ~5 | ✅ Done | AI Assistant | 19/02/26 | ✅ |
| 15 | Scan Controller | `lib/features/scanner/logic/scan_controller.dart` | ~15 | ⏳ Pending | | | |

---

## 🎁 Phase 5: Subscription & Referral

| # | Screen | File Path | Strings | Status | Developer | Date | Tested |
|---|--------|-----------|---------|--------|-----------|------|--------|
| 16 | Subscription Screen | `lib/features/subscription/presentation/subscription_screen.dart` | ~21 | ✅ Done | AI Assistant | 19/02/26 | ✅ |
| 17 | Referral Screen | `lib/features/referral/presentation/referral_screen.dart` | ~21 | ✅ Done | AI Assistant | 19/02/26 | ✅ |
| 18 | Tier Benefits | `lib/features/energy/presentation/tier_benefits_screen.dart` | ~22 | ✅ Done | AI Assistant | 19/02/26 | ✅ |

---

## 📄 Phase 6: Legal & Info Screens

| # | Screen | File Path | Strings | Status | Developer | Date | Tested |
|---|--------|-----------|---------|--------|-----------|------|--------|
| 19 | Privacy Policy | `lib/features/profile/presentation/privacy_policy_screen.dart` | ~15 | ✅ Done | AI Assistant | 19/02/26 | ✅ |
| 20 | Terms Screen | `lib/features/profile/presentation/terms_screen.dart` | ~15 | ✅ Done | AI Assistant | 19/02/26 | ✅ |
| 21 | Disclaimer | `lib/features/legal/presentation/disclaimer_screen.dart` | ~8 | ✅ Done | AI Assistant | 19/02/26 | ✅ |

---

## 🔧 Phase 7: Core Services & Utilities

> ⚠️ **ส่วนใหญ่เป็น AI prompts / debug logs → ไม่ต้องแปล**  
> เฉพาะ Error Messages ที่ user เห็นเท่านั้นที่ต้องทำ แต่ต้อง refactor (ไม่มี Context)

| # | Component | File Path | Strings | Status | Developer | Date | Tested |
|---|-----------|-----------|---------|--------|-----------|------|--------|
| 22 | Gemini Service | `lib/core/ai/gemini_service.dart` | ~15 | ⏳ Pending | | | |
| 23 | Gemini Chat | `lib/core/ai/gemini_chat_service.dart` | ~10 | ⏳ Pending | | | |
| 24 | Error Messages | `lib/core/utils/error_handler.dart` | ~20 | ⏳ Pending | | | |

---

## 📈 สถิติรวม

### ความคืบหน้า
- **เสร็จแล้ว:** 19/24 (79%)
- **กำลังทำ:** 0/24 (0%)
- **รอทำ:** 5/24 (21%)

### Strings
- **เพิ่มแล้ว:** ~467/700 (67%)
- **คงเหลือ:** ~233/700 (33%)

### เวลาที่ใช้
- **ใช้ไปแล้ว:** ~2 ชม.
- **คาดการณ์คงเหลือ:** ~18 ชม.

---

## 🏆 Milestones

- [x] **Milestone 1:** Phase 1 เสร็จ (Core Screens) ✅
- [x] **Milestone 2:** Phase 2 เสร็จ (Health Screens) ✅
- [ ] **Milestone 3:** Phase 3-4 เสร็จ (Chat + Camera) — Chat Screen ✅, Camera Screen ✅, เหลือ Chat Provider + Scan Controller
- [x] **Milestone 4:** Phase 5-6 เสร็จ (Premium Features) ✅ — Subscription ✅, Referral ✅, Tier Benefits ✅, Legal Screens ✅
- [ ] **Milestone 5:** Phase 7 เสร็จ (Services)
- [ ] **Final:** ทดสอบทั้งระบบ ทั้ง 2 ภาษา

---

## 📝 Notes

### Strings ที่เพิ่มไปแล้ว

**app_th.arb:** 627 strings (+30)  
**app_en.arb:** 627 strings (+30)

### Strings ที่ต้องเพิ่มเพิ่ม (โดยประมาณ)

- Profile Screen: +60 strings ✅
- Home Screen: +15 strings ✅
- Health Screens: +125 strings ✅
- Onboarding Screen: +20 strings ✅
- Chat Screen: +30 strings ✅
- Chat Provider: ~5 strings (⚠️ ต้อง refactor, แนะนำข้าม)
- Camera Screen: +5 strings ✅
- Referral Screen: +21 strings ✅
- Tier Benefits Screen: +22 strings ✅
- Subscription Screen: +21 strings ✅
- Legal: +130 strings
- Services: ~45 strings (ส่วนใหญ่เป็น AI prompts ไม่ต้องแปล)

**รวมที่ต้องทำจริง:** ~315 strings (ไม่รวม Provider/Service ที่ข้ามได้)

---

## 🎯 Priority Order (แนะนำสำหรับ Junior)

### ✅ เสร็จแล้ว (ไม่ต้องทำ)
1. ✅ Profile Screen
2. ✅ Home Screen
3. ✅ Health Goals Screen
4. ✅ Onboarding Screen
5. ✅ Health Screens (7 ไฟล์: My Meal, Timeline, Image Preview, Add/Edit Food, Edit Ingredient, Meal Section)
6. ✅ Chat Screen
7. ✅ Camera Screen
8. ✅ Referral Screen
9. ✅ Tier Benefits Screen
10. ✅ Subscription Screen
11. ✅ Disclaimer Screen (UI strings only - full disclaimer text skipped)
12. ✅ Privacy Policy Screen (section titles + UI strings only - content text skipped)
13. ✅ Terms Screen (section titles + UI strings only - content text skipped)

### 📋 ยังไม่ได้ทำ (เรียงตามความง่าย → ยาก)
1. **Tier Benefits Screen** - medium, ~30 strings
4. **Subscription Screen** - medium-hard, ~40 strings
5. **Legal Screens** (3 ไฟล์) - ง่ายแต่ strings เยอะ, ~130 strings รวม
6. ⚠️ **Chat Provider** - ยาก, ต้อง refactor (Context issue) — **ข้ามไปก่อนได้**
7. ⚠️ **Scan Controller** - ยาก, เป็น logic class
8. ⚠️ **Gemini Service / Chat Service** - ส่วนใหญ่เป็น AI prompts **ไม่ต้องแปล** — ข้ามได้
9. ⚠️ **Error Handler** - อาจต้อง refactor เพื่อรับ context

> **⚠️ หมายเหตุ:** ไฟล์ที่มี ⚠️ เป็น Provider/Service ไม่มี `BuildContext`  
> ถ้าจะแปลต้อง refactor (ดู TROUBLESHOOTING_CONTEXT_ISSUE.md)  
> **แนะนำให้ทำ Widget ก่อน แล้วค่อยกลับมาทำพวกนี้ทีหลัง**

---

## 🚨 Issues & Blockers

| Issue | Description | Status | Solution |
|-------|-------------|--------|----------|
| ⚠️ Context ไม่มีให้ใช้ใน Provider | `L10n.of(context)` ใช้ไม่ได้ใน Provider/Service/Notifier เพราะไม่มี BuildContext | ✅ Documented | ดู `TROUBLESHOOTING_CONTEXT_ISSUE.md` |

---

**Last Updated:** 19 ก.พ. 2026 (Privacy Policy & Terms Screens completed ✅ - 19/24 files done)  
**Next Review:** 20 ก.พ. 2026

> **หมายเหตุ:** 
> - Disclaimer Screen: แปล UI strings แล้ว (title, bullets, button) แต่ `AppDisclaimer.full` (ข้อความยาวๆ) ยังใช้ constant เดิมอยู่
> - Privacy Policy & Terms Screens: แปล section titles + UI strings แล้ว แต่ content text (ข้อความยาวๆ ใน sections) ยังใช้ hardcoded strings อยู่
