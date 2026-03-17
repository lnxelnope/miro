# Phase 8: Food Detection - Context

**Gathered:** 2026-03-16
**Status:** Ready for planning

<domain>
## Phase Boundary

แสดง bounding box รอบอาหารหลัก (main dish) แบบ real-time บน ARscan camera preview โดยใช้ ML Kit on-device เท่านั้น และต้องทำงานได้แม่นยำบนหลายความละเอียดหน้าจอ / หลายเครื่อง Android โดย phase นี้ยังไม่รวม multi‑angle capture หรือ bottom sheet review (อยู่ Phase 9–10)

</domain>

<decisions>
## Implementation Decisions

### ขอบเขตการตรวจจับอาหาร + semantics ของผลลัพธ์
- เป้าหมายหลักคือ **อาหารจานหลัก (main dish)** ไม่ใช่ออบเจกต์ทั้งหมดในเฟรม
- ในโหมด streaming ให้แสดงเฉพาะ **กล่องหลักเพียงกล่องเดียว (primary box)** ไม่แสดงกล่องอื่นเพื่อลดความรก
- ถ้า ML เจอหลาย bounding boxes ให้เลือกกล่องที่มี **confidence สูงสุด** เป็น primary โดยไม่ต้องรอให้มีหลายเฟรมซ้อนกัน (เลี่ยงเคสที่ “ถ่ายไม่ติดสักที”)
- ออบเจกต์ที่ไม่ใช่อาหาร แต่เกี่ยวข้องกับฉาก (จาน ช้อน โต๊ะ ฯลฯ) **ไม่ต้องแสดงใน streaming overlay** แต่สามารถถูกใช้/แสดงใน **thumbnail และ view full photo mode** (Phase 9–10) ได้ภายหลัง
- Output ที่ส่งต่อให้ Phase 9/10 ควรเก็บข้อมูลครบ: `label`, `confidence`, `boundingBox (normalized)`, `trackingId` (ถ้ามีจาก ML Kit), flag ว่า `isFood` หรือไม่ และข้อมูล timestamp/เฟรมล่าสุดที่เห็น

### ประสบการณ์ผู้ใช้ของ bounding box overlay (UI/UX)
- ใช้ **สีเดียวกับโหมด photo scan เดิม** เพื่อความคงเส้นคงวา:  
  - กรอบอาหาร (food) = เส้นสีเขียว  
  - กรอบออบเจกต์อื่น (object) = เส้นสีดำ (แต่ใน Phase 8 จะแสดงเฉพาะกล่องหลักเท่านั้น)
- Overlay ควรเรียบ (minimal) ใกล้เคียง implementation ปัจจุบัน: แสดงกรอบ + label สั้นๆ เท่าที่จำเป็น ไม่ต้องโชว์ score ตัวเลขขนาดใหญ่
- เมื่อ “ไม่พบอาหาร” ให้แสดงข้อความสั้นๆ ที่มุมจอ เช่น **"Food not detect"** (ตามสำนวนที่ใช้ในแอป) โดยไม่วางทับกลางจอหรือกวนสายตา
- มี state หลักอย่างน้อย 3 ระดับสำหรับ downstream phases:  
  - `searching` – ยังไม่พบอาหารเลยหรือ confidence ต่ำกว่า threshold  
  - `food_found` – พบกล่องอาหารหลักแล้ว แต่ยังไม่เกี่ยวกับ multi‑angle  
  - `ready_for_capture` – state นี้ใช้จริงเต็มๆ ใน Phase 9; ใน Phase 8 สามารถ map เป็น “food_found, detection stable” เพื่อเตรียมต่อยอด

### Performance vs Accuracy ของ ML Kit Detection
- ความถี่การรัน detection:  
  - ไม่รันทุกเฟรม แต่ **throttle ~ทุก 200–300 ms** (ขึ้นกับอุปกรณ์) โดยใช้ timestamp ล่าสุดของ detection  
  - ถ้า state อยู่ที่ `food_found` และกล่องหลักยังนิ่ง (ตำแหน่งเปลี่ยนไม่มาก) สามารถเพิ่ม interval (เช่น 400–500 ms) เพื่อลดโหลด CPU/GPU
- ค่า threshold เบื้องต้น:  
  - ใช้แนวทางใกล้เคียง `VisionProcessor` ปัจจุบัน (image labeling 0.7) แต่สำหรับ object detection ตั้ง **base threshold ประมาณ 0.6** สำหรับ food classes เพื่อให้จับจานยากๆ ได้ง่ายขึ้น  
  - ถ้า label เป็น non‑food แต่ confidence สูง ให้ mark เป็น object แต่ยังคงไม่แสดงใน streaming overlay (ใช้ภายหลังเท่านั้น)
- พฤติกรรมข้ามแพลตฟอร์ม:  
  - **เป้าหมายคือ UX ใกล้เคียงกัน** มากกว่าจะบังคับ FPS เท่ากัน:  
    - iOS: target ~15 fps preview + detection ทุก 200–300 ms  
    - Android: ยอมรับ FPS ต่ำกว่าเล็กน้อย (8–12 fps) ตราบใดที่ bounding box ขยับตามของจริงได้ลื่นตา
- Degrade gracefully บนอุปกรณ์ช้า:  
  - ลดขนาดภาพ input ให้ ML Kit (downscale) ก่อนส่งเข้า detection  
  - เพิ่ม detection interval แบบ dynamic ถ้าใช้เวลาประมวลผลนานเกิน threshold (เช่น >150 ms)  
  - ปิดการ debug overlay/label ที่ไม่จำเป็นเมื่ออยู่ในโหมด production เพื่อลดงานวาด

### Integration กับกล้อง/โค้ดเดิม (CameraScreen/Scanner stack)
- สร้าง **ARscan เป็น screen ใหม่** แยกจาก `CameraScreen` เดิม (เพื่อรักษา flow การถ่ายรูปปกติ + ให้ผู้ใช้สลับไปใช้โหมดเดิมได้ง่าย)
- หน้าจอ ARscan ใช้โครงสร้างแบบ `Stack` วางลำดับดังนี้:  
  - ชั้นล่าง: camera preview (จาก `camera` package / Phase 7)  
  - ชั้นกลาง: ชั้นสำหรับ gesture/controls (ปุ่มออก, ปุ่มสลับโหมดถ่ายเอง ฯลฯ)  
  - ชั้นบน: widget `ArScanBoundingBoxOverlay` ที่รับรายการ bounding boxes แบบ normalized + state (`searching`, `food_found`, …) แล้ววาด UI ตามนั้น
- แยกความรับผิดชอบเป็น 3 ส่วนชัดเจนสำหรับ downstream agents:  
  - **Stream controller** (เช่น `ArScanController` ใน `features/scanner/logic`): ดูแลกล้อง, lifecycle, throttling detection, จัดการ state machine (searching/food_found/ready_for_capture)  
  - **Detection service** (เช่น `ArScanDetectionService` หรือ reuse แนว `VisionProcessor`): รับ frame แปลงเป็น `InputImage` แล้วคุยกับ ML Kit, คืนค่า list ของผล detection (พร้อม label/confidence/box/trackingId)  
  - **UI overlay widget** (`ArScanBoundingBoxOverlay`): รับข้อมูลเชิงสัญลักษณ์ (primary box, state, ข้อความ "Food not detect") แล้ว render เท่านั้น ไม่รู้เรื่องกล้อง/ML Kit โดยตรง
- ฟอร์แมต data ที่ Phase 9/10 ใช้ต่อ:  
  - โครงสร้างกลางๆ เช่น `TrackedObject` หรือ `ArScanDetection` ที่มี:  
    - `id`/`trackingId`  
    - `label`  
    - `confidence`  
    - `normalizedRect` (0–1 สำหรับ x/y/width/height) เพื่อรองรับหลาย resolution  
    - `isFood` / `isPrimary`  
    - `lastSeenAt` และ `stableFrameCount` สำหรับตัดสินใจใน multi‑angle capture  
  - Phase 8 ต้องทำให้ฟอร์แมตนี้พร้อมใช้งาน แม้จะยังไม่ใช้ field ทั้งหมดใน phase นี้ก็ตาม

### Claude's Discretion
- ค่า exact interval detection บนอุปกรณ์ต่างๆ (ภายในกรอบ 200–500 ms) และ heuristic การขยาย/ลด interval แบบ dynamic
- exact visual details ของ animation กล่อง (fade/scale/slide) ตราบใดที่ไม่ขัดกับหลัก minimal และใช้สีตามที่กำหนด
- วิธีจัดกลุ่ม class/label จาก ML Kit ให้ map เป็น `isFood` vs `isObject` อย่างเจาะจง (mapping table, keyword list ฯลฯ)
- รายละเอียด implementation ของ data model `TrackedObject/ArScanDetection` ภายใต้กรอบ field ที่ระบุ

</decisions>

<specifics>
## Specific Ideas

- Streaming mode เน้นแค่ main dish หนึ่งกล่อง เพื่อไม่ให้ผู้ใช้สับสนและถ่ายยาก
- ถ้า confident เกินได้ 1 กล่องหลัก ก็ใช้เลย ไม่ต้องรอให้มีหลาย candidate
- ใช้สีเขียว/ดำแบบเดียวกับโหมด photo scan เดิม เพื่อให้ผู้ใช้รู้สึกว่าเป็น family เดียวกัน
- ข้อความ "Food not detect" ใช้เป็น indicator เบาๆ เมื่อยังไม่เจออาหาร แทนการขึ้น popup เตือนรบกวนสายตา

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `VisionProcessor` ใน `features/scanner/services/vision_processor.dart` แสดง pattern การใช้ ML Kit image labeling / barcode / text recognition ซึ่งช่วยเป็น reference สำหรับการหุ้ม ML Kit Object Detection ภายใต้ service เดียวกัน
- `CameraScreen` + `ImageAnalysisPreviewScreen` แสดง flow ปัจจุบันของการถ่ายรูปแล้วส่งไปวิเคราะห์ Gemini ซึ่ง ARscan ควรรักษา integration point กับ pipeline นี้ใน Phase 9–10

### Established Patterns
- ใช้ service ชั้นกลาง (เช่น `VisionProcessor`) ซ่อนรายละเอียดของ ML Kit ออกจาก UI layer ซึ่งควรทำแบบเดียวกันสำหรับ ARscan detection
- การใช้ `Stack` วาง preview + overlay ถูกใช้ในบางหน้าจออยู่แล้ว สามารถ reuse แนวคิดนี้มาสร้าง `ArScanBoundingBoxOverlay`

### Integration Points
- ARscan screen ใหม่จะเชื่อมกับ camera streaming infrastructure ที่สร้างใน Phase 7 และส่งผล detection + captured frames ไปยัง review / Gemini pipeline ที่จะเพิ่มใน Phase 9–10

</code_context>

<deferred>
## Deferred Ideas

- การใช้ custom TFLite model สำหรับอาหารเอเชีย/ไทย โดยเฉพาะ — อยู่ใน v3.0 requirements ไม่รวมใน Phase 8
- Multi‑food per session / การเลือกหลายจานในเฟรมเดียว — defer ไป phase อื่นของ v3.0+
- Visual angle gauge overlay (เช่น protractor แสดงองศากล้อง) — อยู่ใน requirement ระยะยาว ไม่อยู่ใน Phase 8

</deferred>

---

*Phase: 08-food-detection*
*Context gathered: 2026-03-16*

