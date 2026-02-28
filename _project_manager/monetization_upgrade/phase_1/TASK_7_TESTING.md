# Task 7: Testing & Verification

**ระยะเวลา:** 2 วัน  
**Complexity:** 🟡 Medium  
**ต้องรู้:** Testing, QA

---

## 🎯 สิ่งที่ต้องทำ

Test ทุก feature ของ Phase 1 ให้ผ่านหมด

---

## 📋 Testing Checklist

### 1. MiRO ID System

```
□ User ใหม่ → ได้ MiRO ID + 100 Energy
□ User เดิม → MiRO ID เดิม (ไม่สร้างซ้ำ)
□ MiRO ID format: MIRO-XXXX-XXXX-XXXX
□ MiRO ID ไม่ซ้ำกัน (query Firestore)
□ Profile แสดง MiRO ID
□ Copy MiRO ID ทำงาน
```

### 2. Free AI

```
□ ครั้งแรกของวัน → ฟรี (balance ไม่ลด)
□ ครั้งที่ 2+ → หัก energy
□ ข้ามวัน → reset (ฟรีอีกครั้ง)
□ Balance = 0 + free AI → ยังใช้ได้
□ Balance = 0 + ไม่มี free AI → error
□ Energy Badge แสดง "FREE" ถูกต้อง
□ Transaction type='free_ai' บันทึกถูกต้อง
```

### 3. Streak System

```
□ Day 1 → streak = 1
□ Day 7 → streak = 7, tier = bronze (+10 Energy)
□ Day 14 → streak = 14, tier = silver (+15 Energy)
□ Day 30 → streak = 30, tier = gold (+30 Energy)
□ Day 60 → streak = 60, tier = diamond (+45 Energy)
□ Streak display แสดงถูกต้อง
□ Tier badge แสดงถูกต้อง
```

### 4. Grace Period

```
□ None tier หยุด 1 วัน → streak reset
□ Bronze tier หยุด 1 วัน → streak reset
□ Silver tier หยุด 1 วัน → streak ต่อ (grace!)
□ Silver tier หยุด 2 วัน → streak reset
□ Gold tier หยุด 2 วัน → streak ต่อ
□ Gold tier หยุด 3 วัน → streak reset
□ Streak reset → tier ไม่หลุด
```

### 5. Backup/Restore

```
□ Backup → ไฟล์มี miroId + streakData
□ Restore → MiRO ID ย้ายมาเครื่องใหม่
□ Restore → Streak data ย้ายมา
□ Restore → เครื่องเดิมหมดสิทธิ์
□ Restore backup เก่า (v1) → ยังทำงานได้
□ Warning แสดงใน Profile
```

### 6. Edge Cases

```
□ เรียก registerUser ซ้ำ → ไม่ได้ gift ซ้ำ
□ Check-in ซ้ำวันเดียวกัน → streak ไม่เพิ่ม
□ Race condition: 2 requests พร้อมกัน → ไม่ได้ free AI 2 ครั้ง
□ Timezone เปลี่ยน → reset ถูกต้อง
□ Offline → online → sync ถูกต้อง
```

### 7. Performance

```
□ registerUser < 2s
□ claimDailyCheckIn < 1s
□ analyzeFood (free AI) < 5s
□ analyzeFood (paid) < 5s
□ Firestore read/write optimized
```

### 8. Security

```
□ Client ส่ง freeAiUsedToday โกง → Server ไม่เชื่อ
□ Client เปลี่ยน timezone โกง → free AI ยังแค่ 1 ครั้ง
□ Client fake streak → Server verify
□ MiRO ID unique (ไม่สามารถสร้าง ID เดียวกันได้)
```

---

## 🐛 Bug Tracking

ถ้าเจอ bug ให้บันทึกที่นี่:

```
Bug #1:
  - อาการ:
  - Steps to reproduce:
  - Expected:
  - Actual:
  - Fixed: [ ] Yes / [ ] No
```

---

## ✅ Final Checklist

ก่อนไป Phase 2:

```
□ ทุก feature test ผ่าน
□ ไม่มี bug critical
□ ไม่มี linter errors/warnings
□ Cloud Functions deploy สำเร็จทั้งหมด
□ Firestore schema ถูกต้อง
□ Transaction logs ครบ
□ Performance เป็นไปตามเป้า
□ Documentation อัพเดทแล้ว
```

---

## 📝 Test Report Template

```markdown
# Phase 1 Test Report

Date: YYYY-MM-DD
Tester: [ชื่อ]

## Summary
- Total tests: XX
- Passed: XX
- Failed: XX
- Blocked: XX

## Failed Tests
1. [Test name] - [Reason]

## Notes
- [หมายเหตุเพิ่มเติม]

## Sign-off
Approved: [ ] Yes / [ ] No
Signature: __________
```

---

## ⏭️ Next Phase

เมื่อ Phase 1 test ผ่านหมด → ไป **Phase 2: Challenges & Milestones**
