# 🗺️ Project Roadmap: Miro (The Offline "Lazy" Assistant)

> **Core Philosophy:** "Record First, Review Later."
> Miro ไม่ใช่แอปที่รอให้ผู้ใช้มาป้อนข้อมูล แต่เป็นแอปที่ "กวาด" ข้อมูลจากชีวิตผู้ใช้ (รูปถ่าย/ข้อความ) มาบันทึกให้อัตโนมัติ แล้วให้ผู้ใช้มีหน้าที่แค่ "ลบสิ่งที่ผิด" ออกไป

---

## 1. 🏗️ Tech Stack & Architecture

### **Platform**
- **Mobile Only:** Android (.apk)
- **Framework:** Flutter (Dart)
- **Target User:** Personal Use (Single User, No Server)

### **The Hybrid Brain Strategy**
1.  **Level 1: Local Intelligence (Always On)**
    - **Vision:** ML Kit + QR Logic (สำหรับกวาดรูป)
    - **NLU (Chat):** **Gemma 3 (On-Device)** สำหรับตีความภาษาธรรมชาติ
    - *Cost: 0, Offline: Yes, Privacy: Max*
2.  **Level 2: Cloud Intelligence (On-Demand)**
    - ใช้ **Gemini 2.5 Flash API**
    - หน้าที่: เมื่อผู้ใช้กด "วิเคราะห์เพิ่ม" (เช่น อยากรู้ Nutrition ละเอียดจากรูปอาหาร หรือวิเคราะห์พอร์ตหุ้นจากกราฟ)
    - *Cost: Free Tier (Personal use), Offline: No*

---

## 2. 📱 Core Features & User Flow

### **A. The "Lazy" Scanner (Automated Input)**
> *ทำงานเมื่อเปิดแอป หรือกด Sync -> เน้นหา "สลิป" กับ "อาหาร"*
1.  **Access:** ขอสิทธิ์เข้าถึง Gallery
2.  **Filter:** ดึงรูปภาพใหม่ (นับจาก Last Sync Timestamp)
3.  **Process (Local Logic):**
    - **Step 1: Check QR Code (Finance)**
        - ถ้าเจอ QR Code -> อ่าน Payload (PromptPay/Bank transfer)
        - Extract: `Receiver Name`, `Amount`, `Date`
        - **Auto-Category Logic:** ค้นหาใน DB เก่าว่า `Receiver Name` นี้เคยอยู่หมวดไหน?
            - เคยเจอ -> Auto-fill หมวดเดิม (เช่น "อาหาร")
            - ไม่เคยเจอ -> Tag: `Uncategorized`
    - **Step 2: Check Image Label (Health)**
        - ถ้า ML Kit บอกว่าเป็น `Food` หรือ `Drink`
        - -> **Tag: Health** -> บันทึกรูปไว้ (รอ User กดถาม Gemini ถ้าอยากรู้แคลอรี่ละเอียด)
    - **Step 3: Others**
        - ไม่ใช่ QR และ ไม่ใช่อาหาร -> **ทิ้ง (Ignore)**

### **B. The "Lazy" Chat (Manual Input)**
> *สำหรับสิ่งที่ไม่มีรูปถ่าย*
1.  **Input:** พิมพ์/พูด เช่น "อกไก่ 300g", "ซื้อทอง 1 บาท", "Bench Press 50kg"
2.  **Process:** ใช้ Local NLP/Regex ตัดคำ
    - "ซื้อ/จ่าย" -> Finance
    - "กิน/ทาน/ชื่ออาหาร" -> Health
    - "ออกกำลัง/ยก/วิ่ง" -> Health (Workout)
    - "เตือน/นัด" -> Task
3.  **Save:** บันทึกลง Database

### **C. The Timeline (Review Interface)**
> *หน้าหลักของแอป*
1.  **Display:** แสดงรายการทั้งหมดเรียงตามเวลา (Time Feed)
2.  **Interaction:**
    - **Swipe Left:** ลบ (Delete)
    - **Tap:** ดูรายละเอียด / แก้ไข
    - **Button "Ask AI":** (เฉพาะรายการรูปภาพ) กดเพื่อส่งรูปไปให้ Gemini วิเคราะห์เพิ่ม

### **D. Data Backup**
- **Export:** ปุ่ม "Backup Data" -> สร้างไฟล์ `.json` หรือ `.csv` (รวมทั้ง Transaction และ Learning Data ของหมวดหมู่) เก็บลงเครื่อง/Google Drive เพื่อย้ายเครื่องได้

---

## 3. 🗄️ Database Schema (Isar)

```dart
@collection
class LifeEntry {
  Id id = Isar.autoIncrement;

  late DateTime timestamp; // เวลาที่เกิดรายการ
  late String type;        // 'finance', 'health', 'task'
  
  String? originalText;    // ข้อความดิบ
  String? imagePath;       // path ของรูปในเครื่อง
  
  // Structured Data
  double? amount;          // สำหรับ Finance
  String? category;        // 'Food', 'Transport', 'Uncategorized'
  String? receiverName;    // ชื่อคนรับเงิน (สำหรับ Smart Category)
  
  String? jsonPayload;     // ข้อมูลเสริมอื่นๆ

  bool isAutoGenerated;    
}

@collection
class PayeeCategory { // ตารางจำชื่อคนรับเงิน
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String payeeName;   // ชื่อผู้รับ เช่น "Mr. Somchai"
  late String category;    // หมวดหมู่ที่ User เคยเลือกให้คนนี้ เช่น "Food"
}
```

---

## 4. 📅 Development Phases

### **Phase 1: The Foundation**
- [ ] Setup Flutter Project
- [ ] Setup Isar Database (LifeEntry + PayeeCategory)
- [ ] Setup Backup/Export Function (JSON)

### **Phase 2: The Eye (Specific Scanner)**
- [ ] Implement QR Code Scanner (อ่านภาพสลิป)
- [ ] Implement Image Labeling (หา Food)
- [ ] Logic: Payee Name Matching (จำชื่อคนรับเงิน)

### **Phase 3: The Brain**
- [ ] Regex Logic สำหรับ Chat Input
- [ ] Integrate Gemini API (เฉพาะปุ่ม "Ask AI")

### **Phase 4: UI & Packaging**
- [ ] Timeline UI
- [ ] Build APK

---
