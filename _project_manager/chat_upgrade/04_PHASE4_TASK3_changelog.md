# Phase 4 Task 3: อัปเดต CHANGELOG

## เป้าหมาย
บันทึกการเปลี่ยนแปลงทั้งหมดของ Chat System Upgrade ใน CHANGELOG.md

## ขั้นตอน

### 1. เปิดไฟล์
ตำแหน่ง: `CHANGELOG.md`

### 2. เพิ่ม Version ใหม่ (v1.1.0) ด้านบนสุด

หาบรรทัดแรกหลัง `# Changelog` และเพิ่ม:

```markdown
## [1.1.0] - 2026-02-XX

### Added
- **Dual AI Chat Mode** — Users can now choose between Local AI (free) and Miro AI (1 Energy/chat)
  - Local AI: Free, English-only, basic regex-based parsing
  - Miro AI: 1 Energy per message, multi-language support, smart multi-food parsing
- **AI Mode Toggle** — Easy switch between Local and Miro AI modes in Chat screen
- **Smart Greeting** — Miro AI greets users with personalized calorie info when switched on
- **Multi-Food Parsing** — Miro AI can extract multiple food items from a single message
- **Quick Action Buttons** — Contextual quick actions based on selected AI mode
  - Miro AI: Log Food, Suggest Menu, Weekly/Monthly Summary, Tips
  - Local AI: Log Food, Today's Summary, Help
- **Weekly/Monthly Summary** — Free local database queries for calorie summaries (no Energy cost)
- **Menu Suggestions** — AI-powered meal suggestions based on food history (costs 1 Energy)
- **Energy Cost Indicator** — Badge showing "⚡1" next to Send button in Miro AI mode
- **Feature Tour** — Interactive tutorial for first-time users highlighting:
  - Energy System
  - Pull-to-Refresh Photo Scan
  - Chat with Miro AI
- **Show Tutorial Again** — Option in Profile to replay the feature tour

### Changed
- Chat system now supports multiple languages in Miro AI mode (Thai, Japanese, Chinese, etc.)
- Improved food parsing accuracy with Gemini AI backend
- Energy confirmation is now implicit (badge visible) rather than explicit dialog

### Updated
- Terms of Service — Added section 4.4 for AI Chat Feature disclaimers
- Backend function — Added support for `type: 'chat'` and `type: 'menu_suggestion'`

### Fixed
- Serving unit validation — Invalid units from AI are now replaced with "serving"
- Energy deduction — Only deducted on successful backend response (with retry logic)

### Technical
- New files:
  - `lib/features/chat/models/chat_ai_mode.dart`
  - `lib/core/ai/gemini_chat_service.dart`
  - `lib/features/home/widgets/feature_tour.dart`
- New dependency: `tutorial_coach_mark: ^1.2.11`
- Backend updates in `functions/index.js` for chat and menu suggestion types

---
```

### 3. อัปเดตวันที่

แก้ `2026-02-XX` เป็นวันที่จริงที่ deploy (เช่น `2026-02-15`)

### 4. เพิ่ม Link ที่ด้านล่างสุดของไฟล์ (ถ้ามี version links)

หาส่วนที่มี:
```markdown
[1.0.0]: https://github.com/...
```

เพิ่ม:
```markdown
[1.1.0]: https://github.com/YOUR_USERNAME/miro/compare/v1.0.0...v1.1.0
```

## Format Explanation

### Version Number
- **Major.Minor.Patch** (Semantic Versioning)
- `1.1.0` = Minor update (new features, backward compatible)
- ถ้ามี breaking changes ใช้ `2.0.0`

### Sections
- **Added** — ฟีเจอร์ใหม่
- **Changed** — เปลี่ยนแปลงพฤติกรรม
- **Updated** — อัปเดตเนื้อหา/เอกสาร
- **Fixed** — แก้ bug
- **Technical** — รายละเอียดสำหรับ developers

## ทดสอบ
1. เปิดไฟล์ `CHANGELOG.md`
2. เช็คว่า version `[1.1.0]` อยู่ด้านบนสุด
3. อ่านเนื้อหาให้ครบถ้วน
4. เช็ค markdown rendering (ถ้าดูใน GitHub)

## เสร็จแล้ว
✅ Task 3 เสร็จ — CHANGELOG อัปเดตแล้ว
➡️ ไปต่อ Task 4: `04_PHASE4_TASK4_final_testing.md`
