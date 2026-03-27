# ArCal Landing Page — แผนปรับเว็บให้สอดคล้องแบรนด์และ Google Ads

เอกสารนี้สรุปทิศทางการอัปเดตเว็บ (`website/`) จาก **MiRO** เป็น **ArCal — AI Calories Counter** โดยอิงสื่อใน `website/arcal_website_meterial/` (โฟลเดอร์สะกดว่า *meterial* ตามที่มีใน repo) และจุดประสงค์หลักคือ **Landing จาก Google Ads** — เน้น conversion ไป **Play Store / App Store** ชัดเจน

---

## 1. เป้าหมายและ KPI

| เป้าหมาย | การทำบนหน้าเว็บ |
|----------|------------------|
| ผู้คลิกจากโฆษณาเห็นชื่อแอปและประโยชน์ทันที | Hero สั้น 1–2 วินาทีอ่านจบ + ปุ่มสโตร์ใหญ่เหนือ fold (มือถือด้วย) |
| อยากลองใช้ | ชู USP: เปิดมาใช้ได้เลย / ไม่ login / ไม่ถามยาว / มี token เริ่มต้น |
| กดไปสโตร์ได้ทันที | ปุ่ม Google Play + App Store ซ้ำอย่างน้อย 3 จุด: Header (CTA), หลัง Hero, ท้ายหน้า |
| App Store ยังไม่พร้อม | เก็บปุ่มและโครงสร้างไว้ — ใช้ลิงก์ placeholder หรือปุ่ม “เร็วๆ นี้” ตามนโยบายที่ต้องการ (ดู §6) |

**Positioning (ข้อความหลักที่ต้องการชู):**

- **เริ่มใช้ได้ทันที** — ไม่ต้อง login, ไม่มีคำถาม/onboarding วุ่นวาย  
- **มี token ให้เริ่มใช้งานได้เลย** — ลดแรงเสียดทาน “ต้องจ่ายก่อนถึงลอง”  
- **เครื่องมือนับแคลที่ใช้ง่ายและดีที่สุดในโลก** — ใช้เป็นหัวข้อรองหรือ subhead ระวังคำโฆษณาเกินจริงในโฆษณา Google (บนเว็บอาจใช้เป็น brand voice แต่ควรมี bullet รองรับด้วยฟีเจอร์จริง)

---

## 2. สินทรัพย์จาก `arcal_website_meterial/`

| ไฟล์ | การใช้ที่แนะนำ |
|------|------------------|
| `arcal_logo.png` | Header, Footer, favicon/OG (ถ้าทำเพิ่ม), แทนตัวอักษร "M" |
| `store display/1.png` … `7.png` | แทนสกรีนช็อตเดิมใน `/public/miro/*.jpg` และ **แทนที่ส่วนวิดีโอ** ด้วยแกลเลอรี / carousel / grid |

**ขั้นตอนทางเทคนิค (เมื่อลงมือ implement):**

1. คัดลอกไป `website/public/arcal/` (หรือ `public/arcal/`) เพื่อ path ชัดว่าเป็นแบรนด์ใหม่  
   - เช่น `public/arcal/logo.png`, `public/arcal/screens/1.png` … `7.png` (เปลี่ยนชื่อให้ไม่มีช่องว่าง URL จะง่ายกว่า เช่น `screen-01.png`)  
2. อัปเดต `next/image` `src` ทั้งหมดจาก `/miro/...` เป็น `/arcal/...`  
3. ไฟล์วิดีโอ `public/miro-preview.mp4` — **ไม่ใช้บน landing** แล้ว; เก็บหรือลบตามนโยบาย repo

---

## 3. โครงสร้างหน้า — เปลี่ยนอะไรบ้าง

### 3.1 ลบ / แทนที่

| รายการปัจจุบัน | การกระทำ |
|----------------|----------|
| `VideoPreviewSection` + `PREVIEW_VIDEO_URL` | **ลบ** หรือแทนด้วย **Screenshot strip / carousel** จาก `store display/*.png` |
| ข้อความ “MiRO”, “Decode every byte…” | แทนด้วยชื่อ **ArCal** และสื่อ “calorie / AI / ง่าย / เริ่มทันที” |
| รูป Hero `feature-graphic.jpg` | ใช้ graphic ใหม่จากชุด ArCal (อาจเป็น `1.png` หรือ composite — ต้องเลือกจากภาพจริงว่าอันไหนเป็น feature graphic) |

### 3.2 เพิ่มหรือเน้น (ฟีเจอร์)

- **AR Scan / ถ่ายด้วย AR** — ใส่ใน:
  - Hero subcopy หรือ badge รอง
  - `showcaseFeatures` อย่างน้อย 1 แถว (หัวข้อ + คำอธิบาย + รูปที่สอดคล้อง)
  - `features` (grid ไอคอน) — ใช้ไอคอนที่สื่อ AR (เช่น `ScanLine`, `View`, หรือ custom ถ้ามี)
  - `steps` ใน How it works — ขั้นแรกอาจเป็น “ถ่ายด้วย AR หรือกล้อง / พิมพ์ / แชท”

### 3.3 ส่วนที่ควรปรับข้อความให้สอดคล้อง Ads

- **Hero:** headline + บรรทัดเดียวชัดเรื่อง “ไม่ login + มี token เริ่มต้น + AI นับแคล”  
- **USPBanner (`USPBanner`):** แทนที่รายการเดิมด้วยสายพาน เช่น  
  `No login` · `Start instantly` · `Free tokens to try` · `AR scan` · `AI calories` · `Simple & fast`  
- **DownloadSection:** หัวข้อและย่อหน้าเน้น CTA ซ้ำ + trust (privacy สั้นๆ ถ้ายังเป็นจุดขาย)

### 3.4 ตารางเปรียบเทียบ (`ComparisonSection`)

- เปลี่ยนหัวคอลัมน์จาก “MiRO” เป็น **“ArCal”**  
- พิจารณาเพิ่มแถว: **“AR meal scan”** หรือข้อความใกล้เคียงตามฟีเจอร์จริงในแอป

### 3.5 Pricing

- ตรวจสอบให้สอดคล้องแอปปัจจุบัน (ชื่อแพ็กเกจ / Energy Pass ยังมีหรือไม่)  
- ข้อความล่างที่ว่า “10 free Energy on sign up” — ถ้าแอป **ไม่มี sign up** ควรแก้เป็น **“free starter tokens” / “tokens included to start”** ให้ตรงกับ product จริง

---

## 4. Theme / สี — แนวทาง

ปัจจุบัน theme ผูกกับ `tailwind` `brand` (#3390ff) และ gradient ใน `globals.css` (น้ำเงิน–ม่วง–cyan)

**แนวทาง:**

1. เปิด `arcal_logo.png` และสกรีนช็อต — **สุ่มสีหลัก/รอง** (primary, accent, surface)  
2. อัปเดต:
   - `tailwind.config.ts` → `brand.*` scale ใหม่  
   - `globals.css` → `.gradient-text`, `.hero-gradient`, `.section-gradient`, `.glow` ให้เข้าชุดกับ ArCal  
3. ถ้าต้องการความแตกต่างชัดจาก MiRO — พิจารณาเปลี่ยน **font** (ยังใช้ Inter ได้ถ้าสอดคล้องแบรนด์)

---

## 5. Metadata, URL, และไฟล์ที่ต้องแตะ

| ไฟล์ | เนื้อหาที่อัปเดต |
|------|-------------------|
| `src/app/layout.tsx` | `title`, `description`, `keywords`, `metadataBase`, `openGraph`, `twitter` → ArCal + calorie counter + AI |
| `src/components/Header.tsx` | โลโก้ + ชื่อ + CTA |
| `src/components/Footer.tsx` | โลโก้, tagline, บรรทัดลิขสิทธิ์ (ลบ “MiRO — My Intake Record Oracle”) |
| `src/app/page.tsx` | ทุก section, constants `PLAY_STORE_URL`, ลบ video, รูป, ข้อความ |
| หน้า `support`, `privacy`, `terms`, `eula` (ถ้ามีชื่อ MiRO) | แทนที่เป็น ArCal แบบครั้งเดียวเมื่อทำ rebranding ทั้งเว็บ |

**หมายเหตุ `metadataBase`:** ตอนนี้ชี้ `https://www.tnbgrp.com/miro` — ถ้า deploy path เปลี่ยนเป็น `/arcal` หรือโดเมนย่อย ต้องแก้ให้ตรง production จริง

---

## 6. ลิงก์ Play Store / App Store

| แพลตฟอร์ม | แนวทาง |
|-----------|--------|
| **Google Play** | ใช้ลิงก์จริงของแพ็กเกจปัจจุบัน (ในโค้ดเดิม: `com.tanabun.miro`) — เมื่อเปลี่ยน applicationId เป็น ArCal ให้อัปเดต URL ให้ตรง |
| **App Store** | ผู้ใช้ระบุว่ายังไม่ผ่าน review — **แนะนำ:** สร้างค่าคงที่ `APP_STORE_URL` ชี้ไปหน้าเดียวกับที่จะใช้จริงภายหลัง หรือใช้ `https://apps.apple.com/` ชั่วคราว **หรือ** ปุ่มแสดง “Coming soon on the App Store” พร้อม `aria-disabled` / ไม่ลิงก์ — **เลือกอย่างใดอย่างหนึ่ง** ให้สอดคล้องนโยบายโฆษณาและความซื่อสัตย์ต่อผู้ใช้ |

---

## 7. ลำดับงาน implement (สรุป checklist)

1. คัดลอก assets → `public/arcal/` และตั้งชื่อไฟล์ URL-safe  
2. ปรับ `globals.css` + `tailwind.config.ts` ตาม palette ArCal  
3. แก้ `layout.tsx` metadata ทั้งชุด  
4. แก้ `Header` / `Footer` โลโก้และชื่อ  
5. รีไรต์ `page.tsx`: Hero, ลบ video, carousel รูป, เนื้อหา AR + USP ใหม่, comparison, pricing copy  
6. ตรวจลิงก์สโตร์และ placeholder App Store  
7. (ทางเลือก) เพิ่ม `favicon` / `opengraph-image` จาก `arcal_logo.png`  
8. ทดสอบมือถือ: ปุ่มสโตร์กดง่าย, ความเร็วโหลดรูป (ขนาด PNG ใหญ่ควร optimize)

---

## 8. ข้อความตัวอย่าง (ร่างภาษาอังกฤษสำหรับ landing — ปรับได้)

- **Title tag:** `ArCal — AI Calories Counter | Start in seconds, no login`  
- **H1 (แนวหนึ่ง):** `The calorie counter that gets out of your way.`  
- **Sub:** `Open the app and start tracking. No login. No long quiz. Free tokens to try AI-powered logging — including AR scan.`  
- **Secondary line:** `Snap, scan with AR, or type. AI handles the calories.`  

(ถ้าต้องการภาษาไทยบนหน้าเดียวกับ Ads ที่ยิงไทย — อาจทำเวอร์ชัน `/th` หรือ dynamic locale ภายหลัง; ตอนนี้เว็บหลักเป็นภาษาอังกฤษ)

---

## 9. สิ่งที่ต้องยืนยันกับทีมก่อนลงมือโค้ด

- ข้อความ “ดีที่สุดในโลก” ใช้บนเว็บอย่างเดียวหรือใช้ใน Google Ads ด้วย (อาจกระทบนโยบายโฆษณา)  
- รูป `1.png`–`7.png` แต่ละไฟล์สื่อฟีเจอร์อะไร — จะได้ map กับ section ไม่สลับกัน  
- Package ID / ชื่อแอปบน Play หลัง rebrand ว่าจะเปลี่ยนเมื่อไหร่  
- URL production สุดท้ายของเว็บ (path + domain) สำหรับ OG และ Ads final URL  

---

*เอกสารนี้เป็นแผนก่อนลงมือแก้โค้ด — เมื่อยืนยันรายละเอียดด้านบนแล้วค่อย implement ตาม checklist §7*
