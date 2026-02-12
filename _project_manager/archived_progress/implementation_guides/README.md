# Miro App - Implementation Guides

> **คู่มือสำหรับ Junior Developer ในการพัฒนา Miro App**

---

## 📋 ภาพรวม

Miro App เป็นแอปติดตามชีวิตประจำวันที่รวม 3 ฟีเจอร์หลัก:

1. **💰 Finance** - ติดตามรายรับ-รายจ่าย และสินทรัพย์
2. **🍎 Health** - ติดตามอาหาร, ออกกำลังกาย, ผลตรวจสุขภาพ
3. **📅 Tasks** - จัดการงาน, นัดหมาย, Habits

---

## 🗂 รายการไฟล์ Implementation Guide

### Foundation (ต้องทำก่อน)

| ลำดับ | ไฟล์ | เนื้อหา | เวลา |
|-------|------|---------|------|
| 00 | [00_PROJECT_SETUP.md](./00_PROJECT_SETUP.md) | Setup project, dependencies, folder structure | 30 นาที |
| 01 | [01_CORE_MODELS.md](./01_CORE_MODELS.md) | Data models ทั้งหมด (Isar) | 1 ชม. |
| 02 | [02_HOME_SCREEN_TABS.md](./02_HOME_SCREEN_TABS.md) | Home screen, bottom navigation, tabs | 45 นาที |
| 03 | [03_MAGIC_BUTTON_SPEED_DIAL.md](./03_MAGIC_BUTTON_SPEED_DIAL.md) | Magic button with speed dial | 30 นาที |
| 04 | [04_PROFILE_SETTINGS.md](./04_PROFILE_SETTINGS.md) | Profile, API Key, Health Goals | 1 ชม. |

### Health Features

| ลำดับ | ไฟล์ | เนื้อหา | เวลา |
|-------|------|---------|------|
| 05 | [05_HEALTH_TIMELINE.md](./05_HEALTH_TIMELINE.md) | Health timeline, cards, providers | 1.5 ชม. |
| 06 | [06_HEALTH_DIET_TAB.md](./06_HEALTH_DIET_TAB.md) | Diet tab, meal sections, add/edit food | 1.5 ชม. |
| 07 | [07_FOOD_PREVIEW_AI.md](./07_FOOD_PREVIEW_AI.md) | Food preview with AI analysis | 2 ชม. |

### Finance Features

| ลำดับ | ไฟล์ | เนื้อหา | เวลา |
|-------|------|---------|------|
| 08 | [08_FINANCE_TIMELINE.md](./08_FINANCE_TIMELINE.md) | Finance timeline, transaction cards | 1.5 ชม. |

### Task Features

| ลำดับ | ไฟล์ | เนื้อหา | เวลา |
|-------|------|---------|------|
| 09 | [09_TASK_TODAY_TAB.md](./09_TASK_TODAY_TAB.md) | Today tab, quick glance | 1.5 ชม. |

### Chat & AI

| ลำดับ | ไฟล์ | เนื้อหา | เวลา |
|-------|------|---------|------|
| 10 | [10_CHAT_UI.md](./10_CHAT_UI.md) | Chat UI, message display | 1.5 ชม. |

### 🆕 Advanced Features

| ลำดับ | ไฟล์ | เนื้อหา | เวลา |
|-------|------|---------|------|
| 11 | [11_CHAT_AI_INTEGRATION.md](./11_CHAT_AI_INTEGRATION.md) | เชื่อม Chat กับ AI สร้าง Entry อัตโนมัติ | 2-3 ชม. |
| 12 | [12_GOOGLE_CALENDAR_SYNC.md](./12_GOOGLE_CALENDAR_SYNC.md) | Google Calendar Sync | 2-3 ชม. |
| 13 | [13_TASK_CALENDAR_VIEW.md](./13_TASK_CALENDAR_VIEW.md) | Calendar View พร้อม Google Events | 2-3 ชม. |
| 14 | [14_TASK_LISTS.md](./14_TASK_LISTS.md) | Todo Lists & Quick Notes | 2-3 ชม. |
| 15 | [15_TASK_HABITS.md](./15_TASK_HABITS.md) | Habits Tracking & Streaks | 2-3 ชม. |
| 16 | [16_HEALTH_WORKOUT.md](./16_HEALTH_WORKOUT.md) | Workout Programs & Sessions | 3-4 ชม. |
| 17 | [17_FINANCE_ASSETS.md](./17_FINANCE_ASSETS.md) | Assets Portfolio (หุ้น, Crypto, ทอง) | 3-4 ชม. |

### 🚀 Extended Features

| ลำดับ | ไฟล์ | เนื้อหา | เวลา |
|-------|------|---------|------|
| 18 | [18_TASK_TODAY_NUDGES.md](./18_TASK_TODAY_NUDGES.md) | Today Tab + Proactive Nudges | 3-4 ชม. |
| 19 | [19_HEALTH_OTHER_TAB.md](./19_HEALTH_OTHER_TAB.md) | Other Tab (น้ำ, ยา, Biometrics) | 2-3 ชม. |
| 20 | [20_HEALTH_LAB_RESULTS.md](./20_HEALTH_LAB_RESULTS.md) | Lab Results Tracking | 3-4 ชม. |
| 21 | [21_VOICE_INPUT.md](./21_VOICE_INPUT.md) | Voice Input (พูดสั่งงาน) | 2-3 ชม. |
| 22 | [22_WEEKLY_INSIGHTS.md](./22_WEEKLY_INSIGHTS.md) | Weekly/Monthly Insights | 2-3 ชม. |

---

### 🚀 v1.0 Launch — Play Store (Thai)

| ลำดับ | ไฟล์ | เนื้อหา | เวลา |
|-------|------|---------|------|
| 29 | [29_HIDE_UNUSED_FEATURES.md](./done_and_tested/29_HIDE_UNUSED_FEATURES.md) | ซ่อนฟีเจอร์ที่ไม่ใช้ (เหลือ Health เดียว) | 2-3 ชม. |
| 30 | [30_BYOK_API_KEY_GUIDE_UX.md](./done_and_tested/30_BYOK_API_KEY_GUIDE_UX.md) | คู่มือ API Key + Graceful Degradation | 3-4 ชม. |
| 31 | [31_FREEMIUM_IN_APP_PURCHASE.md](./done_and_tested/31_FREEMIUM_IN_APP_PURCHASE.md) | Freemium + Google Play IAP (Pro unlock) | 1.5-2 วัน |
| 32 | [32_ONBOARDING_TDEE.md](./done_and_tested/32_ONBOARDING_TDEE.md) | Onboarding 4 หน้า + TDEE Calculator | 1-2 วัน |
| 33 | [33_PRODUCTION_HARDENING.md](./done_and_tested/33_PRODUCTION_HARDENING.md) | ลบ Debug Code + Logger + Error Handling | 3-4 ชม. |
| 34 | [34_BRANDING_ICON_SPLASH.md](./done_and_tested/34_BRANDING_ICON_SPLASH.md) | App Icon + Splash Screen + ชื่อแอป | 1 วัน |
| 35 | [35_LEGAL_PRIVACY_POLICY.md](./done_and_tested/35_LEGAL_PRIVACY_POLICY.md) | Privacy Policy + Terms of Service | 2-3 ชม. |
| 36 | [36_TESTING_QA_CHECKLIST.md](./done_and_tested/36_TESTING_QA_CHECKLIST.md) | Manual Testing Checklist ครบทุก flow | 1-2 วัน |
| 37 | [37_BUILD_PUBLISH_PLAYSTORE.md](./done_and_tested/37_BUILD_PUBLISH_PLAYSTORE.md) | Build AAB + Publish to Google Play Store | 3-4 ชม. |

### 🌍 v2.0 Global Launch — International

| ลำดับ | ไฟล์ | เนื้อหา | เวลา |
|-------|------|---------|------|
| 38 | [38_LOCALIZATION_I18N.md](./done_and_tested/38_LOCALIZATION_I18N.md) | ตั้ง i18n Framework + แปลง ~550 strings | 3-5 วัน |
| 39 | [39_GLOBAL_FOOD_DB_SEARCH.md](./done_and_tested/39_GLOBAL_FOOD_DB_SEARCH.md) | Food DB English + Search + Chat EN | 1-2 วัน |
| 40 | [40_GLOBAL_UNITS_FORMATTING_STORE.md](./done_and_tested/40_GLOBAL_UNITS_FORMATTING_STORE.md) | Units/Date ตาม locale + EN Store Listing | 1 วัน |

### 📋 Reference & Future Plans

| ไฟล์ | เนื้อหา |
|------|---------|
| [FUTURE_FEATURES.md](./FUTURE_FEATURES.md) | แผนฟีเจอร์อนาคต (AI, Health Connect, etc.) |

---

## 🗺️ Roadmap สรุป

```
v1.0 Thai Launch (Step 29-37)    ~7-8 วัน
  → ซ่อนฟีเจอร์ → BYOK → Freemium → Onboarding
  → Production → Branding → Legal → Test → Publish

v2.0 Global Launch (Step 38-40)  ~5-8 วัน
  → Localization → Food DB EN → Units → Store EN

v2.1+ ภาษาเพิ่มเติม (JA, ZH, KO, ES)

v3.0 เปิด Finance + Tasks กลับมา (Life Assistant)
```

---

## 🎯 วิธีใช้งาน

### สำหรับ Junior Developer

1. **อ่านทีละไฟล์ตามลำดับ**
   - เริ่มจาก `00_PROJECT_SETUP.md`
   - ทำตาม checklist ให้ครบก่อนไปไฟล์ถัดไป

2. **ทุกไฟล์มีโครงสร้างเหมือนกัน**
   - สิ่งที่ต้องทำ
   - ขั้นตอน (พร้อมโค้ดที่ copy ได้เลย)
   - Checklist
   - ไฟล์ที่สร้าง/แก้ไข

3. **ห้ามข้ามขั้นตอน**
   - แต่ละขั้นตอนอ้างอิงกัน
   - ถ้าข้าม จะ error

4. **ทดสอบทุกครั้งหลังทำเสร็จ**
   - รัน `flutter run` หลังทำแต่ละ step
   - ตรวจสอบว่าทำงานได้ก่อนไปต่อ

---

## 📁 โครงสร้าง Project (Final)

```
lib/
├── core/
│   ├── ai/
│   │   ├── gemini_service.dart
│   │   └── llm_service.dart
│   ├── database/
│   │   └── database_service.dart
│   ├── services/
│   │   ├── calendar_service.dart
│   │   ├── google_auth_service.dart
│   │   ├── nudge_service.dart
│   │   ├── price_service.dart
│   │   └── voice_input_service.dart
│   └── theme/
│       ├── app_colors.dart
│       └── app_theme.dart
│
├── features/
│   ├── home/
│   │   ├── presentation/
│   │   │   └── home_screen.dart
│   │   └── widgets/
│   │       └── magic_button.dart
│   │
│   ├── health/
│   │   ├── models/
│   │   │   ├── food_entry.dart
│   │   │   ├── workout_entry.dart
│   │   │   ├── workout_program.dart
│   │   │   ├── other_health_entry.dart
│   │   │   ├── medicine.dart
│   │   │   ├── lab_session.dart
│   │   │   └── lab_item.dart
│   │   ├── presentation/
│   │   │   ├── health_page.dart
│   │   │   ├── health_timeline_tab.dart
│   │   │   ├── health_diet_tab.dart
│   │   │   ├── health_workout_tab.dart
│   │   │   ├── health_other_tab.dart
│   │   │   ├── health_lab_tab.dart
│   │   │   └── food_preview_screen.dart
│   │   └── providers/
│   │       ├── health_provider.dart
│   │       ├── workout_provider.dart
│   │       ├── other_health_provider.dart
│   │       └── lab_provider.dart
│   │
│   ├── finance/
│   │   ├── models/
│   │   │   ├── transaction.dart
│   │   │   ├── asset.dart
│   │   │   └── asset_transaction.dart
│   │   ├── presentation/
│   │   │   ├── finance_page.dart
│   │   │   ├── finance_timeline_tab.dart
│   │   │   └── finance_assets_tab.dart
│   │   └── providers/
│   │       ├── finance_provider.dart
│   │       └── assets_provider.dart
│   │
│   ├── tasks/
│   │   ├── models/
│   │   │   ├── task.dart
│   │   │   ├── task_list.dart
│   │   │   ├── list_item.dart
│   │   │   ├── quick_note.dart
│   │   │   ├── habit.dart
│   │   │   ├── habit_log.dart
│   │   │   └── nudge.dart
│   │   ├── presentation/
│   │   │   ├── tasks_page.dart
│   │   │   ├── tasks_today_tab.dart
│   │   │   ├── tasks_calendar_tab.dart
│   │   │   ├── tasks_lists_tab.dart
│   │   │   └── tasks_habits_tab.dart
│   │   ├── providers/
│   │   │   ├── tasks_provider.dart
│   │   │   ├── calendar_provider.dart
│   │   │   ├── lists_provider.dart
│   │   │   ├── habits_provider.dart
│   │   │   └── today_provider.dart
│   │   └── widgets/
│   │       ├── quick_glance_card.dart
│   │       └── nudge_card.dart
│   │
│   ├── chat/
│   │   ├── models/
│   │   │   ├── chat_message.dart
│   │   │   └── action_result.dart
│   │   ├── services/
│   │   │   └── intent_handler.dart
│   │   ├── presentation/
│   │   │   └── chat_screen.dart
│   │   ├── providers/
│   │   │   └── chat_provider.dart
│   │   └── widgets/
│   │       └── voice_input_button.dart
│   │
│   ├── insights/
│   │   ├── models/
│   │   │   └── weekly_insights.dart
│   │   ├── presentation/
│   │   │   └── weekly_summary_screen.dart
│   │   ├── providers/
│   │   │   └── insights_provider.dart
│   │   └── widgets/
│   │       ├── health_summary_card.dart
│   │       ├── finance_summary_card.dart
│   │       └── tasks_summary_card.dart
│   │
│   └── profile/
│       ├── models/
│       │   └── user_profile.dart
│       ├── presentation/
│       │   ├── profile_screen.dart
│       │   └── api_key_screen.dart
│       └── providers/
│           └── profile_provider.dart
│
└── main.dart
```

---

## ⚠️ สิ่งสำคัญ

1. **อย่าแก้ไขไฟล์ที่ generated**
   - ไฟล์ที่ลงท้ายด้วย `.g.dart` ห้ามแก้ไข
   - ถ้าต้องการแก้ model ให้แก้ไฟล์ต้นฉบับแล้วรัน `build_runner`

2. **เมื่อแก้ model ต้องรัน**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **เมื่อ error ให้**
   - อ่าน error message
   - ตรวจสอบว่าทำตาม step ครบหรือยัง
   - ตรวจสอบ imports

4. **เมื่อ hot reload ไม่ work**
   - Stop app แล้ว run ใหม่
   - รัน `flutter clean` แล้ว `flutter pub get`

---

## 📞 Contact

ถ้ามีคำถาม ให้ถาม Senior Developer หรือ AI Assistant

---

**Last Updated:** 2026-02-11
**Total Steps:** 40 (28 Core + 9 Launch + 3 Global) + Future Plans
