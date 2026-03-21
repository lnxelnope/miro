# Phase 9: Multi-Angle Capture - Context

**Gathered:** 2026-03-16  
**Status:** Ready for planning

<domain>
## Phase Boundary

แอปพาผู้ใช้ถ่ายอาหาร 3 มุม (top-down ~0°, diagonal ~45°, side ~70°) บน ARscan screen เดิม โดยใช้ sensor ตรวจมุมกล้อง + auto-capture เป็นหลัก มี progress 1/3, 2/3, 3/3 และ reset เมื่อกล้องหนีจากอาหาร ตาม semantics ของ primary food box ที่ได้จาก Phase 8 โดย phase นี้ยังไม่ยุ่งกับ bottom sheet / Gemini (อยู่ Phase 10)

</domain>

<decisions>
## Implementation Decisions

### มุมกล้อง & tolerance ของ sensor
- ระบบไม่ต้องเคร่งมากกับมุม 0° / 45° / 70° จุดประสงค์หลักคือช่วยเพิ่มความแม่นยำและใช้เป็นกิมมิก marketing สร้างความต่าง ไม่ใช่ calibration แบบวิทยาศาสตร์
- ควรใช้ tolerance ค่อนข้างกว้าง (เช่น ช่วง ±15–20° รอบ target angle) โดยเน้นว่ามุมอยู่ “โซนถูกต้อง” มากกว่าค่าองศาเป๊ะ
- ถ้ามุมยังไม่เข้าโซน ให้ใช้ **visual gauge แบบง่าย ๆ** (เช่น indicator ที่ดูออกว่าต้องเอียงเพิ่มหรือลด) แทนข้อความเตือนยาว ๆ
- สำหรับ sensor ที่ noisy (โดยเฉพาะ Android) ไม่ต้อง strict: ใช้ช่วงกว้าง + ขอให้ค่ามุม “ค่อนข้าง stable” ประมาณ 0.5–1 วินาที แล้วจึงยอมรับ capture

### ลำดับการจับภาพ & auto vs manual priority
- **auto-capture เป็น default behavior**: เมื่อมุมและ detection อยู่ในเกณฑ์ ระบบควรยิง capture เองโดยไม่ต้องให้ผู้ใช้กดทุกครั้ง
- ปุ่ม manual shutter มีไว้เป็น **fallback** สำหรับเคสที่ auto ไม่ติด แต่ไม่ต้องเด่นเท่า auto และไม่ต้องเน้น messaging ว่า “ต้องกดเอง”
- ถ้าผู้ใช้กด manual ซ้ำในมุมเดิม ให้ **ทับรูปเดิม** (ถือเป็นการถ่ายใหม่ของมุมนั้น ไม่สะสมหลายช็อต)
- ถ้าระบบกำลังจะ auto-capture แต่ผู้ใช้กด manual พร้อมกัน ให้ **manual ชนะ** (ใช้รูปจาก manual เป็นผลลัพธ์ของมุมนั้น และ cancel trigger ของ auto frame นั้น)

### พฤติกรรมเมื่อ flow ไม่ครบ 3 มุม / การ reset
- ดีไซน์ UX ให้ **ผลักผู้ใช้ไปสู่การถ่ายครบ 3 รูป** เป็นค่าเริ่มต้น (auto-capture + on-screen progress) มากกว่าการ support ทางลัดจบที่ 1–2 รูป
- ไม่จำเป็นต้องมี flow พิเศษให้ “จบที่ <3 รูป” ใน Phase 9; ถ้าผู้ใช้ไม่อยากเล่น flow เต็ม เขาสามารถสลับไปใช้โหมดกล้องเดิมแทน หรือกด manual ให้ครบ 3 รูปเอง
- ถ้ากล้องหลุดออกจากจาน/อาหารตาม semantics ของ ARSCAN-04: ให้รอประมาณ **1 วินาที** (กัน jitter เล็กน้อย) ก่อนจะ reset progress เป็น 0/3
- เมื่อ reset เพราะกล้องหายจากอาหาร **ไม่ต้องถามยืนยัน** (“Restart หรือ Keep progress”) — รีเซ็ตอัตโนมัติเลยเพื่อให้ UX ตรงไปตรงมา
- ถ้าเก็บครบ 3 รูปแล้วและผู้ใช้ “อยากเริ่มใหม่ทั้งชุด” ให้ behavior ง่ายที่สุดคือ **เริ่ม session ใหม่** แทนการมีปุ่ม Reset เฉพาะใน flow นี้

### Feedback ตอน capture สำเร็จ
- น้ำหนัก feedback ต้อง **เบา ๆ พอรู้ตัว** ไม่ให้รบกวนมาก: haptic เล็ก + เสียงสั้นๆ
- ใช้ **เสียงเบา ๆ + animation ชัด** (เช่น flash/scale card ของมุมนั้น หรือ progress circle jump) เพื่อให้ผู้ใช้ “รู้สึก” ว่าจับภาพแล้วโดยไม่ต้องเงยสายตาอ่านอะไรเยอะ
- ทุกครั้งที่ capture สำเร็จ (auto หรือ manual) ให้มี **ข้อความยืนยันบนจอเล็ก ๆ** เช่น “Top angle captured (1/3)” ตำแหน่งที่ไม่บังจานอาหาร
- ถ้า capture fail (เช่น ภาพเบลอมากหรือ detection หายไประหว่าง trigger) ให้ **ไม่ต้องมีข้อความเตือน**; ปล่อยให้ระบบลอง capture frame ถัดไปไปเรื่อย ๆ แทน (user แค่ถือกล้องนิ่ง ๆ ต่อ)

### Claude's Discretion
- ค่า tolerance ที่แน่ชัดต่อมุมแต่ละแบบ (เช่น 0° ±15°, 45° ±20°, 70° ±20°) รวมถึง heuristic การถ่วงเวลาให้ stable 0.5–1 วิ ก่อน auto-capture
- รูปแบบ visual gauge ที่ใช้บอกทิศทางการเอียง (เช่น arc + indicator, ghost outline ของจาน ฯลฯ) ตราบใดที่เข้าใจง่ายและไม่รกจอ
- รายละเอียด animation ของ feedback (ระยะเวลา, easing, รูปทรง, การเปลี่ยนสถานะ progress indicator) ภายใต้ข้อกำหนด “เสียงเบา ๆ / animation ชัด”
- เงื่อนไขภายในว่ากรณีไหนให้ถือว่าเป็น “มุมเดิม” เวลากด manual ซ้ำ (ใช้ sensor + ทิศดูประกอบ) เพื่อทับรูปอย่างถูกต้อง

</decisions>

<specifics>
## Specific Ideas

- Concept มุม 0° / 45° / 70° เน้นเพื่อ **เพิ่มความแม่นยำ + เป็นกิมมิก marketing** ว่าถ่ายหลายมุม ไม่ได้ต้อง precise ทางเทคนิคมาก
- ผู้ใช้ทั่วไปไม่อยากคิดเยอะ แค่อยาก “เปิดกล้องแล้วแอปจัดการให้” → auto-capture เป็น default จึงสำคัญ
- ถ้าผู้ใช้ไม่พอใจกับรูปในมุมใด เขาสามารถกด manual ทับได้ทันที โดยไม่ต้องมี dialog พิเศษ
- เมื่อ flow พัง (หลุดออกจากจาน) ให้รีเซ็ตแบบเงียบ ๆ หลัง 1 วิ แทนการถามผู้ใช้ซ้ำหลายขั้น

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `ArScanDetection` / `TrackedObject` semantics จาก Phase 8 (primary food box + normalized rect + tracking/stability fields) สามารถ reuse เป็นฐานสำหรับตัดสินใจว่า “มุมนี้จับภาพได้หรือยัง” และตรวจสอบว่ากล้องยังชี้ไปที่อาหารเดิมอยู่หรือไม่
- โครงสร้าง `ArScanController` / detection service / overlay ที่วางไว้ใน Phase 8 ช่วยให้ Phase 9 เติม logic multi-angle capture ลงใน controller/state machine เดิม โดย overlay ยังเป็น consumer ของ state เช่น progress 1/3, 2/3, 3/3

### Established Patterns
- Pattern แยก logic (controller/service) ออกจาก UI overlay ตามที่กำหนดใน Phase 8 ยังใช้เหมือนเดิม: multi-angle capture ควรเป็นส่วนหนึ่งของ state machine ใน controller มากกว่าจะผูกกับ widget โดยตรง
- การใช้ normalized rect และ trackingId จาก ML Kit เป็น “แหล่งความจริง” ของว่าเรายังโฟกัสที่จานเดิมอยู่ สอดคล้องกับ semantics reset ใน Phase 8 และต่อยอดมาใช้กับการ reset progress 0/3 ใน Phase 9

### Integration Points
- Phase 9 นั่งอยู่บน ARscan camera stream + detection pipeline ของ Phase 7–8: controller เดียวกันจะต้องส่งต่อผลลัพธ์ “ชุดรูป 3 มุม + metadata” ไปให้ Phase 10 ใช้เปิด bottom sheet / ส่ง Gemini
- Progress state (0/3 → 3/3) และ feedback flags (เช่น capture success per angle) จะเป็นข้อมูลสำคัญที่ Phase 10 ใช้ในการตัดสินว่าเมื่อไหร่ควรแสดง review bottom sheet

</code_context>

<deferred>
## Deferred Ideas

- การปรับเปลี่ยนจำนวนมุม (เช่น 2 มุม หรือ 4+ มุม) ตามประเภทอาหาร — เก็บไว้เป็น idea สำหรับ v3.0+ ไม่อยู่ใน Phase 9
- ตัวช่วยเชิงภาพที่ซับซ้อนกว่า visual gauge ง่าย ๆ (เช่น protractor เต็มจอ, AR-style overlay ขั้นสูง) — เข้าข่าย requirement ระยะยาว/ARscan-D04 มากกว่า phase ปัจจุบัน

</deferred>

---

*Phase: 09-multi-angle-capture*  
*Context gathered: 2026-03-16*

