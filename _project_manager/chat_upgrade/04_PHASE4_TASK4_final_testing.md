# Phase 4 Task 4: Final Testing Checklist

## เป้าหมาย
ทดสอบทุกฟีเจอร์ที่เพิ่มมาให้แน่ใจว่าทำงานถูกต้อง

## Testing Checklist

### ✅ Phase 1: Core Chat Upgrade

#### 1.1 AI Mode Toggle
- [ ] เปิด Chat screen → เห็น toggle "🧠 Local AI" และ "⚡ Miro AI"
- [ ] กด Local AI → ปุ่มไฮไลท์ (มีขอบสีน้ำเงิน)
- [ ] กด Miro AI → ปุ่มไฮไลท์
- [ ] Toggle ทำงานเรียบร้อย ไม่มี lag

#### 1.2 Local AI Mode
- [ ] เลือก Local AI
- [ ] พิมพ์ "chicken 100g and rice 200g"
- [ ] กด Send → ข้อความถูกส่ง
- [ ] ได้ response กลับมา (อาจเป็น 0 kcal)
- [ ] Energy balance **ไม่เปลี่ยน** (ฟรี)

#### 1.3 Miro AI Mode — Single Food
- [ ] เลือก Miro AI
- [ ] เช็ค Energy >= 1
- [ ] พิมพ์ "I ate fried rice for breakfast"
- [ ] เห็น badge "⚡1" ข้าง Send button
- [ ] กด Send
- [ ] รอ response (~5-10 วินาที)
- [ ] ได้ response พร้อม nutrition data
- [ ] แสดง "⚡ -1 Energy" ใน response
- [ ] Energy balance ลดลง 1

#### 1.4 Miro AI Mode — Multi-Food
- [ ] พิมพ์ "breakfast: 2 eggs and toast, lunch: chicken salad, dinner: pizza 2 slices"
- [ ] กด Send
- [ ] ได้ response แยกเป็น 3+ รายการ
- [ ] แต่ละรายการมี meal_type ถูกต้อง (breakfast/lunch/dinner)
- [ ] แต่ละรายการมี nutrition data
- [ ] Energy ลดลง 1 (ไม่ใช่ 3)

#### 1.5 Energy Check
- [ ] ทำให้ Energy = 0 (ใช้จนหมด)
- [ ] พยายามส่งข้อความใน Miro AI mode
- [ ] เห็น error "Not enough Energy. Please purchase more..."
- [ ] Local AI mode ยังใช้งานได้ปกติ

---

### ✅ Phase 2: Smart Conversation

#### 2.1 Smart Greeting
- [ ] เริ่มที่ Local AI mode
- [ ] สลับไป Miro AI mode
- [ ] เห็น greeting message ปรากฏอัตโนมัติ
- [ ] Greeting แสดงข้อมูล calories ที่เหลือ
- [ ] ข้อความเป็นภาษาอังกฤษ

#### 2.2 Quick Action Buttons — Miro AI
- [ ] อยู่ใน Miro AI mode
- [ ] เห็นปุ่ม: Log Food, Suggest Menu, Weekly, Monthly, Tips
- [ ] กด "📝 Log Food" → text field แสดง hint
- [ ] กด "📊 Weekly" → แสดงสรุปสัปดาห์ (ฟรี)
- [ ] กด "📊 Monthly" → แสดงสรุปเดือน (ฟรี)
- [ ] กด "🍽️ Suggest Menu" → ใช้ 1 Energy, แสดงเมนู 3 รายการ
- [ ] กด "💡 Tips" → ใช้ 1 Energy, แสดง tips

#### 2.3 Quick Action Buttons — Local AI
- [ ] สลับไป Local AI mode
- [ ] เห็นปุ่ม: Log Food, Today's Summary, Help
- [ ] กด "🍔 Log Food" → text field แสดง example
- [ ] กด "📊 Today's Summary" → ส่งข้อความ "How many calories today?"
- [ ] กด "❓ Help" → แสดง format guide

#### 2.4 Weekly/Monthly Summary
- [ ] มีรายการอาหารอย่างน้อย 3-5 วัน
- [ ] กด "📊 Weekly"
- [ ] เห็นสรุปแต่ละวันพร้อม ✅/⚠️
- [ ] เห็น Average, Target, Result
- [ ] Energy **ไม่เปลี่ยน** (ฟรี)
- [ ] กด "📊 Monthly" → เห็นสรุปเดือน

---

### ✅ Phase 3: Feature Tour

#### 3.1 First Launch
- [ ] Uninstall app (หรือ clear data)
- [ ] Install ใหม่
- [ ] ผ่าน onboarding
- [ ] ผ่าน permission dialog
- [ ] **Feature Tour แสดงอัตโนมัติ**
- [ ] Step 1: Energy Badge ไฮไลท์
- [ ] กด "Next" → Step 2: Pull-to-Refresh
- [ ] กด "Next" → Step 3: Chat Button
- [ ] กด "Got it!" → Tour จบ

#### 3.2 Skip Tour
- [ ] Reset tour (clear data)
- [ ] เปิด app อีกครั้ง
- [ ] Tour แสดง
- [ ] กด "SKIP" → Tour ปิดทันที
- [ ] Flag ถูก save

#### 3.3 Show Again
- [ ] Tour เสร็จแล้ว (หรือ skip)
- [ ] เปิด Profile → "💡 Show Tutorial Again"
- [ ] กดปุ่ม → confirmation dialog
- [ ] กด "Show Tutorial" → SnackBar "Tutorial reset!"
- [ ] กลับไป Home → Tour แสดงอีกครั้ง

---

### ✅ Phase 4: Polish & Legal

#### 4.1 Menu Suggestion
- [ ] อยู่ใน Miro AI mode
- [ ] Energy >= 1
- [ ] กด "🍽️ Suggest Menu"
- [ ] เห็น loading message
- [ ] รอ ~5-10 วินาที
- [ ] เห็นเมนู 3 รายการพร้อม nutrition
- [ ] แต่ละเมนูมี emoji, calories, P/C/F
- [ ] แสดง "⚡ -1 Energy"
- [ ] Energy balance ลดลง 1

#### 4.2 Terms of Service
- [ ] เปิด Profile → Terms of Service
- [ ] Scroll หา Section 4.4 "AI Chat Feature"
- [ ] เห็นเนื้อหาครบถ้วน:
  - Local AI vs Miro AI
  - Energy cost
  - Disclaimer
  - Non-refundable

#### 4.3 CHANGELOG
- [ ] เปิดไฟล์ `CHANGELOG.md`
- [ ] เห็น version `[1.1.0]` ด้านบนสุด
- [ ] เนื้อหาครบถ้วนทุกฟีเจอร์

---

### ✅ Edge Cases & Error Handling

#### Error Cases
- [ ] พิมพ์ข้อความที่ไม่ใช่อาหารใน Miro AI → AI ตอบสนทนาปกติ (ไม่ error)
- [ ] Backend timeout → แสดง error message
- [ ] Backend ส่ง invalid JSON → แสดง error message
- [ ] Energy = 0 + พยายามใช้ Miro AI → แสดง error
- [ ] No internet + Miro AI → แสดง network error

#### Serving Unit Validation
- [ ] Gemini ส่ง unit ที่ไม่รองรับ (เช่น "handful")
- [ ] Backend แปลงเป็น "serving" แทน
- [ ] App ไม่ crash

#### Multi-language (Miro AI only)
- [ ] พิมพ์ภาษาไทย: "ทานข้าวผัดไข่ 1 จาน"
- [ ] ได้ response เป็นภาษาอังกฤษ
- [ ] `food_name_local` เป็นภาษาไทย (ถูกต้อง)
- [ ] พิมพ์ภาษาญี่ปุ่น → ได้ response (ถ้ารองรับ)

---

### ✅ Performance

- [ ] Chat screen เปิดไว < 2 วินาที
- [ ] Toggle AI mode ไม่มี lag
- [ ] Gemini response ได้ภายใน 10 วินาที
- [ ] App ไม่ crash ระหว่างใช้งาน
- [ ] Memory leak ไม่มี (ทดสอบสลับ mode หลายครั้ง)

---

### ✅ UI/UX

- [ ] UI text ทั้งหมดเป็นภาษาอังกฤษ
- [ ] ไม่มี typo หรือ grammar error
- [ ] สี theme สอดคล้องกับ app
- [ ] Button size เหมาะสม (กดง่าย)
- [ ] Accessibility: Screen reader รองรับ (ถ้าต้องการ)

---

## หลังทดสอบเสร็จ

### ✅ ผ่านทั้งหมด
➡️ พร้อม deploy!

### ⚠️ มี bug
1. บันทึก bug ลง issue tracker
2. ระบุ step to reproduce
3. แก้ไข
4. ทดสอบอีกครั้ง

---

## เสร็จแล้ว
✅ Task 4 เสร็จ — Testing สำเร็จ
🎉 **Phase 4 เสร็จสมบูรณ์!**

## 🎊 Chat System Upgrade Complete!

### สรุปการทำงาน
- ✅ Phase 1: Core Chat Upgrade
- ✅ Phase 2: Smart Conversation
- ✅ Phase 3: Feature Tour
- ✅ Phase 4: Polish & Legal

### Files Created
- 14 MD files ใน `_project_manager/chat_upgrade/`
- 3 new source files
- 1 new dependency
- Backend updates

### Ready for
- Code review
- QA testing
- Production deployment

**Great job! 🚀**
