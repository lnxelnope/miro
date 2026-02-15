# Chat System Upgrade — Overview

## เป้าหมาย
อัปเกรดระบบ Chat ให้ผู้ใช้เลือกได้ระหว่าง:
- **Local AI (ฟรี)** — รองรับเฉพาะภาษาอังกฤษ, ความแม่นยำต่ำ
- **Miro AI (1 Energy/chat)** — รองรับทุกภาษา, ความแม่นยำสูง, แยกอาหารหลายรายการได้

## ฟีเจอร์หลัก
1. **Dual AI Mode** — Toggle สลับระหว่าง Local AI กับ Miro AI
2. **Multi-Food Parsing** — Gemini แยกอาหารหลายรายการจากข้อความเดียว
3. **Smart Conversation** — Greeting อัตโนมัติ, รองรับหลายภาษา
4. **Quick FAQ Buttons** — ปุ่มลัดสำหรับคำถามยอดนิยม
5. **Feature Tour** — Tutorial แนะนำฟีเจอร์สำคัญครั้งแรก

## โครงสร้างการทำงาน

```
User types message
       ↓
┌─── Check AI Mode ───┐
│                      │
▼                      ▼
LOCAL AI              MIRO AI
(Free)                (1 Energy)
│                      │
│ Regex parsing        │ Gemini AI
│ English only         │ All languages
│ Single food          │ Multi-food
│                      │
▼                      ▼
Save FoodEntry         Save FoodEntry[]
```

## Files ที่จะสร้าง/แก้ไข

### New Files
- `lib/features/chat/models/chat_ai_mode.dart`
- `lib/core/ai/gemini_chat_service.dart`
- `lib/features/home/widgets/feature_tour.dart`

### Modified Files
- `lib/features/chat/presentation/chat_screen.dart`
- `lib/features/chat/providers/chat_provider.dart`
- `lib/features/chat/services/intent_handler.dart`
- `lib/core/ai/gemini_service.dart`
- `lib/features/home/presentation/home_screen.dart`
- `lib/features/home/widgets/magic_button.dart`
- `lib/features/profile/presentation/profile_screen.dart`
- `functions/index.js` (Backend)
- `docs/terms-of-service.html`

## Implementation Phases
1. **Phase 1** — Core Chat Upgrade (Dual AI Mode, Multi-food parsing)
2. **Phase 2** — Smart Conversation (Greeting, Quick FAQ)
3. **Phase 3** — Feature Tour (Guided Tutorial)
4. **Phase 4** — Polish & Legal (Menu suggestion, Terms update)

## เริ่มต้นทำงาน
อ่านไฟล์ตามลำดับ:
1. `01_PHASE1_*` — ทำงาน Phase 1 ทีละไฟล์
2. `02_PHASE2_*` — ทำงาน Phase 2
3. `03_PHASE3_*` — ทำงาน Phase 3
4. `04_PHASE4_*` — ทำงาน Phase 4

แต่ละไฟล์มี:
- ✅ โค้ดสำเร็จรูป copy-paste ได้เลย
- ✅ ขั้นตอนละเอียด
- ✅ ไม่ต้องคิดเอง ทำตามได้เลย
