# Phase 4 Task 2: อัปเดต Terms of Service

## เป้าหมาย
เพิ่ม section ใหม่ใน Terms of Service เกี่ยวกับ AI Chat Feature

## ขั้นตอน

### 1. เปิดไฟล์
ตำแหน่ง: `docs/terms-of-service.html`

### 2. หา Section 4 (Features and Services)

มักจะอยู่ใกล้กับ Section เกี่ยวกับ "AI Analysis" หรือ "Services"

### 3. เพิ่ม Subsection 4.4 (หรือ section ที่เหมาะสม)

```html
<h3>4.4 AI Chat Feature</h3>
<ul>
    <li>Miro Cal offers two chat modes:</li>
    <li><strong>Local AI (Free):</strong>
        <ul>
            <li>Uses on-device text processing (regex-based)</li>
            <li><strong>Supports English language only</strong></li>
            <li>Lower accuracy — may not correctly parse complex food descriptions</li>
            <li>Cannot parse multiple food items from a single message</li>
            <li>No Energy cost</li>
        </ul>
    </li>
    <li><strong>Miro AI (Powered by AI):</strong>
        <ul>
            <li>Uses cloud-based AI (Google Gemini) for intelligent food parsing</li>
            <li>Supports multiple languages (English, Thai, Japanese, Chinese, and more)</li>
            <li>Higher accuracy — can parse multiple food items from a single message</li>
            <li>Can detect meal types (breakfast, lunch, dinner, snack) from context</li>
            <li><strong>Costs 1 Energy per message sent</strong></li>
            <li>Energy is deducted when the message is sent, regardless of the response quality</li>
        </ul>
    </li>
    <li><strong>Important Disclaimers:</strong>
        <ul>
            <li>AI-generated nutritional estimates are <strong>approximate values</strong> and should not be used as medical advice</li>
            <li>Nutrition data may vary significantly from actual food consumed</li>
            <li>Menu suggestions from AI are for reference only and may not account for allergies, dietary restrictions, or medical conditions</li>
            <li>Users are responsible for verifying the accuracy of AI-generated data</li>
            <li>We are not liable for any health consequences resulting from reliance on AI estimates</li>
        </ul>
    </li>
    <li><strong>Energy Refunds:</strong>
        <ul>
            <li>Energy is non-refundable once consumed</li>
            <li>If an AI request fails due to technical issues on our end, we may provide Energy credit at our discretion</li>
            <li>Energy used for successful responses (even if inaccurate) is not refundable</li>
        </ul>
    </li>
</ul>
```

### 4. อัปเดตไฟล์อื่นด้วย (ถ้ามี)

เปิดไฟล์: `_project_manager/github-pages/terms-of-service.html`

เพิ่ม section เดียวกัน (ถ้ามีไฟล์นี้)

### 5. อัปเดตไฟล์ใน lib (ถ้ามี)

เปิดไฟล์: `lib/features/profile/presentation/terms_screen.dart`

ถ้า Terms แสดงใน app → ต้อง sync HTML content ด้วย

## เนื้อหาสำคัญที่ต้องมี

### ✅ ต้องระบุ:
1. **Local AI vs Miro AI** — ความแตกต่างชัดเจน
2. **Energy Cost** — 1 Energy/message สำหรับ Miro AI
3. **Accuracy Disclaimer** — AI estimates เป็นค่าประมาณ
4. **No Medical Advice** — ไม่ใช่คำแนะนำทางการแพทย์
5. **Non-Refundable** — Energy ไม่สามารถคืนได้
6. **Language Support** — Local AI (EN only) vs Miro AI (Multi-language)

### ✅ ต้องปกป้อง:
- ผู้ใช้ต้องเข้าใจว่า AI อาจผิดพลาดได้
- บริษัทไม่รับผิดชอบต่อความเสียหายจากการใช้ AI estimates
- Energy ถูกหักเมื่อส่งข้อความ (ไม่ใช่เมื่อได้ผลลัพธ์)

## ทดสอบ
1. เปิด app → Profile → Terms of Service
2. Scroll หา Section 4.4
3. อ่านให้แน่ใจว่าเนื้อหาครบถ้วน
4. เช็คว่าลิงก์ทำงาน (ถ้ามี)

## เสร็จแล้ว
✅ Task 2 เสร็จ — Terms of Service อัปเดตแล้ว
➡️ ไปต่อ Task 3: `04_PHASE4_TASK3_changelog.md`
