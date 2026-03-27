# ArCal — Google Ads Campaign Guide  
# สำหรับตลาดไทย & เวียดนาม (App Install Campaigns)

คู่มือนี้เขียนสำหรับ **เจ้าของแอป ArCal** ที่ต้องการยิง Google Ads เพื่อหาคนมาโหลดแอป โดยเน้นตลาดไทยและเวียดนามเป็นหลัก

---

## 1. สรุปกลยุทธ์ภาพรวม

```
Landing Page (เว็บนี้)  ←  Google Search / Display / YouTube
         ↓
   Play Store / App Store  ←  Google App Campaigns (UAC)
```

**แนะนำรัน 2 แบบคู่กัน:**

| ประเภท | จุดประสงค์ | ปลายทาง |
|--------|-----------|---------|
| **Google App Campaign (UAC)** | หา install โดยตรง — Google optimize ให้อัตโนมัติ | Play Store / App Store |
| **Search + Display → Landing Page** | จับคนที่กำลัง "หาข้อมูล" เรื่องนับแคล → ปิดด้วย landing page แล้วส่งต่อไปสโตร์ | Landing page (เว็บนี้) |

**เหตุผล:** UAC ให้ install ถูกที่สุด แต่คุณ**ไม่สามารถควบคุม ad creative ได้ละเอียด** — Search/Display landing เสริมให้คนที่ยังลังเลได้เห็น USP เต็มๆ ก่อนตัดสินใจ

---

## 2. Campaign Type #1 — Google App Campaign (UAC)

### 2.1 ตั้งค่าแคมเปญ

| Setting | ค่าที่แนะนำ |
|---------|-----------|
| Campaign goal | **App promotion → App installs** |
| Target OS | Android + iOS (แนะนำแยกแคมเปญ/asset group ตาม OS เพื่อคุม KPI ได้ชัด) |
| Target locations | **ไทย** (TH) + **เวียดนาม** (VN) — **แยกคนละแคมเปญ** เพราะภาษาและ CPI ต่างกัน |
| Languages | TH: ไทย + อังกฤษ / VN: เวียดนาม + อังกฤษ |
| Budget | เริ่มที่ **$10–20/วัน** ต่อประเทศ (7 วันแรกให้ Google เรียนรู้) |
| Bidding | **Target CPI (Cost per Install)** เริ่มที่ ฿15–25 (TH) / 5,000–10,000 VND (VN) |
| Campaign subtype | ถ้ามี in-app events → ใช้ **Target CPA** แทนภายหลัง (เช่น optimize ต่อ "first scan") |

### 2.2 Ad Assets ที่ต้องเตรียม (UAC ใช้ asset-based)

**Google UAC ต้องการ asset 4 ประเภท — เตรียมอย่างน้อยเท่านี้:**

#### A. Headlines (สูงสุด 5 บรรทัด, ≤30 ตัวอักษรแต่ละบรรทัด)

**สำหรับไทย (TH):**
1. `นับแคลด้วย AI ง่ายที่สุด`
2. `ถ่ายรูป รู้แคลทันที`
3. `ไม่ต้อง login เปิดใช้เลย`
4. `AR สแกนอาหาร ตัวแรก!`
5. `ฟรีโทเค็นเริ่มต้นทันที`

**สำหรับเวียดนาม (VN):**
1. `Đếm calo bằng AI dễ nhất`
2. `Chụp ảnh, biết calo ngay`
3. `Không cần đăng nhập`
4. `AR quét thức ăn đầu tiên!`
5. `Token miễn phí để bắt đầu`

**English (ใช้ได้ทั้ง 2 ตลาด):**
1. `AI Calorie Counter — Free`
2. `Snap a photo, get calories`
3. `No login. Start instantly.`
4. `AR food scan — first ever`
5. `Free tokens to try AI`

#### B. Descriptions (สูงสุด 5 บรรทัด, ≤90 ตัวอักษร)

**ไทย:**
1. `เปิดแอปแล้วใช้ได้เลย ไม่ต้องสมัคร ไม่มีคำถามยาว มีโทเค็นฟรีให้เริ่มทันที`
2. `สแกน AR หรือถ่ายรูปอาหาร AI วิเคราะห์ทุกวัตถุดิบแยกแคลให้ภายใน 10 วินาที`
3. `รองรับอาหารไทย 15 ชาติ ต้มยำคือต้มยำ ไม่ใช่ Tom yum soup แบบฝรั่ง`
4. `ข้อมูลอยู่ในเครื่องคุณ 100% ไม่ upload ไม่ track ปลอดภัยหมด`
5. `ไม่มี subscription บังคับ ซื้อโทเค็นครั้งเดียว ใช้ได้ตลอดไป`

**เวียดนาม:**
1. `Mở app dùng ngay, không đăng ký, không câu hỏi dài. Token miễn phí để bắt đầu`
2. `AR scan hoặc chụp ảnh — AI phân tích từng nguyên liệu trong 10 giây`
3. `Hỗ trợ 15 nền ẩm thực. Phở là Phở, không phải "beef noodle soup"`
4. `Dữ liệu 100% trên máy bạn. Không upload, không theo dõi`
5. `Không subscription bắt buộc. Mua token 1 lần, dùng mãi mãi`

#### C. Images (ขนาด / สัดส่วนที่ต้องเตรียม)

| สัดส่วน | ขนาดแนะนำ | ใช้รูปจาก |
|---------|----------|----------|
| 1:1 (Square) | 1200×1200 px | crop จาก `hero-banner.png` หรือ `ar-scan.png` |
| 1.91:1 (Landscape) | 1200×628 px | `hero-banner.png` (1.png) ใช้ได้เลย |
| 4:5 (Portrait) | 1200×1500 px | `ar-scan.png`, `zero-setup.png`, `dashboard.png` |

**Tips:**
- ใส่ข้อความบนรูปให้น้อยที่สุด (Google ลด reach ถ้า text >20% ของภาพ)
- รูปจาก store display ที่มีอยู่**มี text เยอะ** — แนะนำ crop เอาส่วนมือถือ + อาหารเป็นหลัก หรือทำ creative ใหม่ที่เรียบกว่า
- ต้องมี **อย่างน้อย 3 รูป** แต่ยิ่งมากยิ่งดี (ให้ Google test)

#### D. Videos (ถ้ามี — optional แต่ช่วยมาก)

- ยังไม่มีวิดีโอ → **แนะนำทำ screen recording 15–30 วินาที** แสดง:
  1. เปิดแอป (ไม่มี login)
  2. AR scan อาหาร
  3. เห็นผลแคลอรี่
- อัปโหลดขึ้น YouTube แล้วลิงก์ใน UAC
- ขนาดแนะนำ: **Portrait (9:16)** สำหรับมือถือ + **Landscape (16:9)** สำหรับ YouTube

### 2.3 Conversion Tracking

**สำคัญมาก:** ต้องติดตั้ง Firebase + Google Analytics for Firebase แล้วตั้ง conversion events:

| Event | ความสำคัญ | ใช้ทำอะไร |
|-------|----------|----------|
| `first_open` | สูง | นับ install จริง |
| `first_scan` (custom) | สูงมาก | วัดว่าคนใช้งานจริง — ใช้เป็น CPA target ภายหลัง |
| `energy_purchase` (custom) | สูงสุด | วัด ROAS (return on ad spend) |

ถ้ายังไม่มี Firebase → **ต้องติดก่อนยิง ads** ไม่งั้นจะ optimize ไม่ได้เลย

---

## 3. Campaign Type #2 — Search Ads → Landing Page

### 3.1 ทำไมต้องมี Search ด้วย?

คนที่ค้นหา "แอปนับแคล", "calorie counter app" คือคนที่มี **intent สูงมาก** — พร้อมโหลดแล้ว UAC จับคนกลุ่มนี้ได้บ้าง แต่ Search Ads ให้คุณ**ควบคุม keyword + ad copy** ได้เต็มที่

### 3.2 Keyword Strategy

**ไทย — Keywords กลุ่มหลัก:**

| กลุ่ม | Keywords | Match Type |
|-------|----------|------------|
| Brand intent | `arcal`, `arcal แอป`, `arcal ai` | Exact |
| Category (Thai) | `แอปนับแคล`, `นับแคลอรี่`, `แอปนับแคลอรี่`, `คุมอาหาร`, `ลดน้ำหนัก แอป` | Phrase |
| Category (Eng) | `calorie counter app`, `AI food tracker`, `calorie tracker` | Phrase |
| Feature intent | `สแกนอาหาร AI`, `ถ่ายรูปอาหาร นับแคล`, `AR scan food` | Broad (modified) |
| Competitor | `myfitnesspal ไทย`, `lose it ภาษาไทย`, `yazio` | Phrase |

**เวียดนาม — Keywords กลุ่มหลัก:**

| กลุ่ม | Keywords | Match Type |
|-------|----------|------------|
| Brand intent | `arcal`, `arcal app` | Exact |
| Category (Viet) | `app đếm calo`, `đếm calories`, `theo dõi dinh dưỡng`, `giảm cân app` | Phrase |
| Category (Eng) | `calorie counter app`, `food tracker Vietnam` | Phrase |
| Feature intent | `quét thức ăn AI`, `chụp ảnh đếm calo` | Broad (modified) |

**Negative keywords (ใส่ทั้ง 2 ตลาด):**
- `free calorie calculator` (คนหาเครื่องคิดเลขแคล ไม่ใช่แอป)
- `calorie food list` (หาตาราง ไม่ใช่แอป)
- `recipe`, `cooking` (ไม่ใช่ intent โหลดแอปนับแคล)

### 3.3 Ad Copy — ตัวอย่าง Search Ads (Responsive Search Ads)

**แคมเปญไทย:**

Headlines (15 ชิ้น — Google จะ mix & match):
```
ArCal — นับแคลด้วย AI
ถ่ายรูปอาหาร รู้แคลใน 10 วิ
ไม่ต้อง login เปิดใช้ได้ทันที
AR สแกนอาหารตัวแรกของโลก
ฟรีโทเค็น เริ่มใช้เลย
แม่นยำระดับวัตถุดิบ
รองรับอาหารไทย 100%
ไม่มี subscription บังคับ
ข้อมูลอยู่ในเครื่อง ปลอดภัย
ดาวน์โหลดฟรีวันนี้
AI วิเคราะห์แคลทุกจาน
ต้มยำคือต้มยำ ไม่ใช่ Tom Yum
เปิดแอป 10 วิ ใช้งานได้เลย
ไม่ถามคำถามยาว ไม่ต้องกรอกอะไร
แอปนับแคลที่ง่ายที่สุด
```

Descriptions (4 ชิ้น):
```
เปิดแอป ArCal แล้วสแกนอาหารด้วย AR หรือถ่ายรูป — AI วิเคราะห์ทุกวัตถุดิบแยกแคลให้ใน 10 วินาที ไม่ต้องสมัครสมาชิก มีโทเค็นฟรีเริ่มทันที
ไม่เหมือนแอปอื่น — ArCal แยกวัตถุดิบย่อยได้ทุกจาน แกงเขียวหวาน? เห็นกะทิ พริกแกง ไก่ แยกชิ้น พร้อมแคลแต่ละตัว
ไม่มี subscription บังคับ ซื้อโทเค็นครั้งเดียวใช้ตลอดชีวิต ข้อมูลทุกอย่างอยู่ในมือถือคุณ ไม่ upload ขึ้น cloud
รองรับ 15 ชาติอาหาร ผัดไทยคือผัดไทย ไม่ใช่ stir-fried noodle — AI เข้าใจวัฒนธรรมอาหารไทยจริงๆ
```

**แคมเปญเวียดนาม:**

Headlines:
```
ArCal — Đếm calo bằng AI
Chụp ảnh, biết calo trong 10s
Không cần đăng nhập
AR quét thức ăn đầu tiên
Token miễn phí để bắt đầu
Chính xác từng nguyên liệu
Hỗ trợ ẩm thực Việt Nam
Không subscription bắt buộc
Dữ liệu trên máy, an toàn
Tải miễn phí ngay hôm nay
Phở là Phở, không phải "noodle"
Mở app 10 giây, dùng ngay
Không câu hỏi dài, không form
App đếm calo dễ nhất
AI phân tích mọi món ăn
```

Descriptions:
```
Mở ArCal và quét AR hoặc chụp ảnh — AI phân tích từng nguyên liệu với calo chính xác trong 10 giây. Không đăng ký, token miễn phí ngay.
Khác app khác — ArCal phân tích nguyên liệu phụ. Bún bò Huế? Thấy bò, giò, sả, ớt — từng thứ với calo riêng.
Không subscription bắt buộc. Mua token 1 lần dùng mãi. Dữ liệu 100% trên điện thoại, không upload lên cloud.
Hỗ trợ 15 nền ẩm thực. Phở là Phở, Bánh mì là Bánh mì — AI hiểu văn hóa ẩm thực Việt Nam thực sự.
```

### 3.4 Landing Page Extensions

ใส่ใน Google Ads:

| Extension | ค่า |
|-----------|-----|
| Sitelink 1 | **Features** → `yoursite.com/#features` |
| Sitelink 2 | **How It Works** → `yoursite.com/#how-it-works` |
| Sitelink 3 | **Pricing** → `yoursite.com/#pricing` |
| Sitelink 4 | **Download** → `yoursite.com/#download` |
| Callout | `No Login Required` / `AR Scan` / `15 Cuisines` / `100% Private` |
| Structured Snippet | Types: `AI Scan, AR Scan, Chat Logging, Photo Analysis, Batch Analysis` |

---

## 4. งบประมาณ & การจัดสรร — คำแนะนำ

### 4.1 เริ่มต้น (เดือนแรก)

| รายการ | งบ/วัน | งบ/เดือน | หมายเหตุ |
|--------|--------|----------|---------|
| UAC — ไทย | ฿500 (~$14) | ฿15,000 | เน้น install |
| UAC — เวียดนาม | 350k VND (~$14) | 10.5M VND | เน้น install |
| Search — ไทย | ฿300 (~$8) | ฿9,000 | จับ high-intent |
| Search — เวียดนาม | 200k VND (~$8) | 6M VND | จับ high-intent |
| **รวมต่อวัน** | **~$44** | **~$1,320/เดือน** | |

### 4.2 ค่า CPI คาดการณ์

| ตลาด | CPI (Android) คาดการณ์ | CPI (iOS) คาดการณ์ |
|------|----------------------|-------------------|
| ไทย | ฿15–35 ($0.40–1.00) | ฿30–60 ($0.85–1.70) |
| เวียดนาม | 5,000–15,000 VND ($0.20–0.60) | 10,000–25,000 VND ($0.40–1.00) |

**หมายเหตุ:** เวียดนาม CPI ถูกกว่าไทยมาก แต่ purchasing power ก็ต่ำกว่า — ต้องดู ROAS ไม่ใช่แค่ CPI

### 4.3 เมื่อเห็นตัวเลขแล้ว — ปรับยังไง

- **CPI สูงกว่าคาด:** ปรับ creative / ลอง headline ใหม่ / เพิ่ม negative keywords
- **Install เยอะแต่ไม่ scan:** ปัญหาอยู่ที่ onboarding ในแอป ไม่ใช่ ads
- **Search ได้ install ถูกกว่า UAC:** เพิ่มงบ Search, ลด UAC
- **ภายใน 2 สัปดาห์ Google ยัง learning:** อย่าเพิ่งเปลี่ยนอะไร — ให้ algorithm เรียนรู้

---

## 5. Creative Production Brief — ทำตามนี้ทีละชิ้น

> **หลักการ:** รูป/วิดีโอสำหรับ Google Ads ต้อง **โชว์แอปจริง** ไม่ใช่กราฟิกพร้อมข้อความ
> Google ลด reach ถ้ารูปมี text เกิน 20% ของพื้นที่ภาพ — ดังนั้น text บนรูปต้องน้อยมาก (โลโก้เล็กๆ + คำ 2–3 คำเท่านั้น)
> ข้อความขายทั้งหมดไปอยู่ใน headline / description ที่ตั้งใน Google Ads platform แทน

---

### 5.1 รูปภาพ — ต้องทำทั้งหมด 10 ชิ้น

Google Ads ต้องการ 3 สัดส่วน ต่อ 1 ชิ้น creative:

| สัดส่วน | ขนาด (px) | ใช้ที่ไหน |
|---------|----------|----------|
| 1.91:1 (Landscape) | **1200 × 628** | Display ads, YouTube thumbnail |
| 1:1 (Square) | **1200 × 1200** | Feed ads, Discovery |
| 4:5 (Portrait) | **1080 × 1350** | Mobile feed, Stories placement |

**ทุกชิ้นต้องทำครบ 3 ขนาด** — ใช้ layout เดียวกันแค่ปรับ crop

---

#### ชิ้นที่ 1: "AR Scan จริง" (Money Shot — ชิ้นสำคัญที่สุด)

**ฟีเจอร์ที่ขาย:** AR Scan — จุดขายหลักที่ไม่มีแอปไหนมี

| รายการ | กำหนด |
|--------|-------|
| **ถ่ายอะไร** | เปิดแอป ArCal หน้า AR Scan → เล็งกล้องไปที่จานอาหาร → **screenshot ตอนที่เห็นกรอบเขียว AR bounding box ล้อมรอบอาหาร** พร้อม badge "Food" และ confidence |
| **อาหาร (TH)** | ข้าวผัดกะเพราไข่ดาว หรือ ส้มตำ (จานสีสดใส มีหลายวัตถุดิบ) |
| **อาหาร (VN)** | Phở bò (เฝอเนื้อ) หรือ Bánh mì (บั๋นหมี่) |
| **มุมถ่าย** | เอียง ~30° จากด้านบน ให้เห็นทั้งจานและหน้าจอมือถือ (ใช้มือถืออีกเครื่องถ่าย หรือ screenshot แล้ว mockup ลงกรอบมือถือ) |
| **พื้นหลัง** | โต๊ะไม้ หรือโต๊ะสีอ่อน (ไม่รก ไม่มีของอื่น) |
| **text overlay** | มุมล่างขวา: โลโก้ ArCal เล็กๆ ขนาดไม่เกิน 10% ของภาพ — **ไม่ต้องเขียนอะไรอื่น** |
| **แต่งเพิ่ม** | ไม่ต้อง — screenshot จริงดีที่สุด ปรับ brightness/contrast เล็กน้อยถ้ามืด |
| **จำนวน** | 2 ชิ้น (อาหารไทย 1 + อาหารเวียดนาม 1) × 3 ขนาด = **6 ไฟล์** |

---

#### ชิ้นที่ 2: "ผลลัพธ์ AI — วัตถุดิบแยกชิ้น"

**ฟีเจอร์ที่ขาย:** Sub-ingredient breakdown — เห็นทุกวัตถุดิบแยก kcal

| รายการ | กำหนด |
|--------|-------|
| **ถ่ายอะไร** | Screenshot หน้าผลวิเคราะห์อาหาร ที่เห็น: ชื่ออาหาร + แคลรวม + macro (P/C/F) + **รายการวัตถุดิบย่อย** (Ingredients Editable) แสดงอย่างน้อย 3–4 รายการ |
| **อาหาร (TH)** | แกงเขียวหวาน หรือ ต้มยำกุ้ง — เพราะมีวัตถุดิบย่อยเยอะ ดูน่าสนใจ (กะทิ, พริกแกง, ไก่, มะเขือ...) |
| **อาหาร (VN)** | Bún bò Huế — มีเนื้อ, giò, สะระแหน่, ตะไคร้ แยกชัด |
| **มุมถ่าย** | Screenshot ตรงๆ จากแอป (ไม่ต้อง mockup มือถือ — ใช้ screenshot เต็มจอ) |
| **text overlay** | มุมล่างขวา: โลโก้ ArCal เล็กๆ เท่านั้น |
| **แต่งเพิ่ม** | ไม่ต้อง |
| **จำนวน** | 2 ชิ้น (TH food 1 + VN food 1) × 3 ขนาด = **6 ไฟล์** |

---

#### ชิ้นที่ 3: "เปิดมาใช้ได้เลย — Zero Setup"

**ฟีเจอร์ที่ขาย:** ไม่ต้อง login / ไม่มี onboarding quiz / เปิดปุ๊บใช้ปั๊บ

| รายการ | กำหนด |
|--------|-------|
| **ถ่ายอะไร** | Screenshot หน้า Dashboard หลักของแอป ที่เห็นว่า**มีอาหารอยู่แล้ว** (ถ่ายรูปจริงลงไปก่อน 3–5 มื้อ) ให้เห็นว่าแอปพร้อมใช้ มี food grid สวยงาม |
| **สิ่งที่ต้องเห็น** | แถบ Energy token ด้านบน + food cards พร้อมรูปและ kcal + ปุ่ม Gallery / Chat ด้านล่าง |
| **text overlay** | มุมบนซ้าย: ข้อความ **"No login"** ตัวเล็ก (font ≤ 24pt, สีขาวบนพื้นเข้ม) + โลโก้ ArCal มุมล่างขวา — **รวม text ไม่เกิน 15% ของภาพ** |
| **แต่งเพิ่ม** | ไม่ต้อง |
| **จำนวน** | 1 ชิ้น × 3 ขนาด = **3 ไฟล์** |

---

#### ชิ้นที่ 4: "15 Cuisines — เข้าใจอาหารท้องถิ่น"

**ฟีเจอร์ที่ขาย:** Select Your Cuisine — AI เข้าใจว่าผัดกะเพราคืออะไร ไม่ใช่ basil stir fry

| รายการ | กำหนด |
|--------|-------|
| **ถ่ายอะไร** | Screenshot หน้า "Select Your Cuisine" ที่เห็นธงชาติ + ชื่ออาหารหลายชาติ |
| **Version TH** | Screenshot ขณะที่ **Thai** ถูกเลือก (highlight สีเขียว) |
| **Version VN** | Screenshot ขณะที่ **Vietnamese** ถูกเลือก |
| **text overlay** | โลโก้ ArCal มุมล่างขวาเท่านั้น |
| **แต่งเพิ่ม** | ไม่ต้อง |
| **จำนวน** | 2 ชิ้น (TH select 1 + VN select 1) × 3 ขนาด = **6 ไฟล์** |

---

#### ชิ้นที่ 5: "Streak & Free Tokens"

**ฟีเจอร์ที่ขาย:** มี token ฟรีให้เริ่ม + streak system ให้ token เพิ่ม

| รายการ | กำหนด |
|--------|-------|
| **ถ่ายอะไร** | Screenshot หน้า Streak / Challenge ที่เห็น: Streak day count + Daily Challenge "Use Energy (+1)" Claimed! + Weekly challenges |
| **สิ่งที่ต้องเห็น** | badge "Claimed!" สีเขียว + Energy count ด้านบน (ยิ่งเลข Energy เยอะยิ่งดี ให้รู้สึกว่าได้ฟรีเยอะ) |
| **text overlay** | โลโก้ ArCal มุมล่างขวาเท่านั้น |
| **แต่งเพิ่ม** | ไม่ต้อง |
| **จำนวน** | 1 ชิ้น × 3 ขนาด = **3 ไฟล์** |

---

#### ชิ้นที่ 6: "Before → After" (Landscape only — สำหรับ Display)

**ฟีเจอร์ที่ขาย:** AR scan ทำให้เห็นสิ่งที่ตาเปล่าไม่เห็น

| รายการ | กำหนด |
|--------|-------|
| **Layout** | ภาพแบ่งครึ่ง — **ซ้าย:** ถ่ายจานอาหารธรรมดาด้วยกล้องปกติ / **ขวา:** จานเดียวกันผ่านหน้าจอ ArCal ที่มี AR overlay แสดง kcal |
| **อาหาร** | ผัดไทย (TH) / Phở (VN) — จานสีสด มีองค์ประกอบเยอะ |
| **text overlay** | เส้นแบ่งกลาง เขียน **→** หรือลูกศรเล็กๆ / โลโก้ ArCal มุมล่างขวา |
| **แต่งเพิ่ม** | ต้องทำกราฟิกเล็กน้อย — วางรูป 2 ภาพเทียบกัน (ใช้ Canva, Figma, หรือ PowerPoint ก็ได้) |
| **ขนาด** | 1200 × 628 เท่านั้น (landscape only — ชิ้นนี้ไม่ต้องทำ square/portrait) |
| **จำนวน** | 2 ชิ้น (TH 1 + VN 1) = **2 ไฟล์** |

---

#### สรุปรวมรูปทั้งหมด

| ชิ้น | ชื่อ | จำนวนไฟล์ |
|------|------|----------|
| 1 | AR Scan จริง (TH + VN) | 6 |
| 2 | ผลลัพธ์ AI วัตถุดิบ (TH + VN) | 6 |
| 3 | Zero Setup Dashboard | 3 |
| 4 | 15 Cuisines (TH + VN) | 6 |
| 5 | Streak & Free Tokens | 3 |
| 6 | Before → After (TH + VN) | 2 |
| **รวม** | | **26 ไฟล์** |

**วิธีจัดการ:** ถ่าย/screenshot **10 ภาพต้นฉบับ** (ชิ้นละ 1–2 ภาพ) แล้ว export ออกเป็น 3 ขนาด = ได้ 26 ไฟล์ ใช้เวลาทำประมาณ **2–3 ชั่วโมง**

**เครื่องมือที่ใช้:**
- Screenshot: มือถือจริงที่ลงแอป ArCal
- Mockup มือถือ (ถ้าต้องการ): [mockuphone.com](https://mockuphone.com) ฟรี
- Resize + crop: Canva (ฟรี) หรือ Figma
- ใส่โลโก้: วาง `arcal_logo.png` ขนาดเล็กมุมล่างขวา opacity 80–90%

---

### 5.2 วิดีโอ — ต้องทำ 4 คลิป

Google UAC ให้ผลดีกว่ารูปนิ่ง 2–3 เท่าเมื่อมีวิดีโอ ทำเองได้ไม่ต้องจ้าง — ใช้ screen recording + มือถือถ่ายอาหาร

#### วิดีโอ A: "AR Scan Flow" — 15 วินาที (ชิ้นสำคัญที่สุด)

**ขนาด:** Portrait **1080 × 1920** (9:16) — สำหรับ mobile feed + Shorts

| วินาที | สิ่งที่เห็นบนจอ | เสียง |
|--------|----------------|-------|
| 0–1 | เปิดแอป → เห็น Dashboard ทันที (ไม่มีหน้า login) | เงียบ หรือ upbeat music เบาๆ |
| 1–3 | กดปุ่ม AR Scan → กล้อง AR เปิด | — |
| 3–7 | เล็งกล้องไปที่ **จานอาหารไทย** (ผัดกะเพรา / ส้มตำ) → เห็นกรอบเขียว AR bounding box ค่อยๆ ล้อมอาหาร + badge "Food" + confidence % | — |
| 7–8 | กดถ่าย / confirm | — |
| 8–11 | หน้าผลลัพธ์ปรากฏ: ชื่ออาหาร + **kcal ตัวใหญ่** + P/C/F + วัตถุดิบย่อย 3–4 ตัว (scroll ช้าๆ ให้เห็น) | — |
| 11–13 | ค้างหน้าผลลัพธ์ให้อ่าน 2 วินาที | — |
| 13–15 | **End card:** พื้นหลังสีเขียวมิ้นท์ + โลโก้ ArCal ตรงกลาง + ข้อความ "Download Free" + ไอคอน Play Store/App Store | — |

**ถ่ายยังไง:**
1. เปิด screen recording ของมือถือ (iOS: Control Center > Screen Recording / Android: Quick Settings > Screen Record)
2. เตรียมจานอาหารไหนก็ได้ที่มีสีสด + หลายวัตถุดิบ วางบนโต๊ะ
3. เปิดแอป ArCal แล้วทำตาม flow ด้านบน
4. ตัด + ใส่ end card ด้วย CapCut (ฟรี) หรือ iMovie

**ทำ 2 เวอร์ชัน:**
- **Version TH:** ใช้อาหารไทย (ผัดกะเพรา, ส้มตำ, ต้มยำ — เลือก 1)
- **Version VN:** ใช้อาหารเวียดนาม (Phở, Bún bò, Cơm tấm — เลือก 1)

---

#### วิดีโอ B: "Chat Logging" — 10 วินาที

**ขนาด:** Portrait **1080 × 1920** (9:16)

| วินาที | สิ่งที่เห็นบนจอ |
|--------|----------------|
| 0–2 | เปิดแอป → กดปุ่ม Chat |
| 2–5 | พิมพ์ข้อความ 1 บรรทัด: **"เช้ากินข้าวต้ม กลางวันข้าวมันไก่ เย็นส้มตำ"** (TH) หรือ **"Sáng ăn phở, trưa cơm tấm, tối bún bò"** (VN) → กด send |
| 5–8 | AI ตอบกลับ: แสดงผลวิเคราะห์ทุกมื้อ พร้อม kcal + macro ทีเดียว |
| 8–10 | **End card:** โลโก้ ArCal + "Download Free" |

**ถ่ายยังไง:** Screen recording → พิมพ์ช้าๆ ให้คนอ่านทัน → ตัดต่อเร่งเวลารอ AI ตอบ

---

#### วิดีโอ C: "Gallery Batch Scan" — 10 วินาที

**ขนาด:** Portrait **1080 × 1920** (9:16)

| วินาที | สิ่งที่เห็นบนจอ |
|--------|----------------|
| 0–2 | เปิดแอป → กดปุ่ม Gallery |
| 2–4 | เลือกรูปอาหาร 4–6 รูปจาก gallery (กดเลือกเร็วๆ ให้ดูง่าย) |
| 4–5 | กด "Analyze" หรือ pull to refresh |
| 5–8 | ผลลัพธ์: Dashboard แสดงทุกมื้อพร้อม kcal + รูป — **ทั้งวันวิเคราะห์ครบใน 2 คลิก** |
| 8–10 | **End card:** โลโก้ ArCal + "Download Free" |

---

#### วิดีโอ D: "Landscape Version" — 15 วินาที (สำหรับ YouTube)

**ขนาด:** Landscape **1920 × 1080** (16:9)

| รายการ | กำหนด |
|--------|-------|
| **เนื้อหา** | เหมือนวิดีโอ A (AR Scan Flow) แต่ถ่ายแบบ landscape — ใช้มือถือเครื่อง 2 ถ่ายมือถือเครื่อง 1 ที่กำลังสแกน AR อาหารบนโต๊ะ |
| **มุมถ่าย** | เอียง 45° จากด้านบน ให้เห็น: จานอาหารจริง + มือถือเปิดแอป + หน้าจอ AR scan |
| **สิ่งที่ต้องเห็น** | จานอาหารจริง (สีสดใส) + หน้าจอมือถือแสดง AR bounding box |
| **End card** | เหมือนวิดีโอ A |

**ทำเวอร์ชันเดียว** ใช้ได้ทั้ง TH + VN (เพราะ visual เป็นหลัก ไม่มีข้อความภาษาใดภาษาหนึ่ง)

---

#### สรุปรวมวิดีโอทั้งหมด

| คลิป | ชื่อ | ความยาว | ขนาด | เวอร์ชัน | รวมไฟล์ |
|------|------|---------|------|---------|--------|
| A | AR Scan Flow | 15 วิ | 9:16 Portrait | TH + VN | 2 |
| B | Chat Logging | 10 วิ | 9:16 Portrait | TH + VN | 2 |
| C | Gallery Batch | 10 วิ | 9:16 Portrait | 1 (universal) | 1 |
| D | AR Scan Landscape | 15 วิ | 16:9 Landscape | 1 (universal) | 1 |
| **รวม** | | | | | **6 ไฟล์** |

**End card ทุกคลิป** (ทำ template 1 ชิ้น ใช้ซ้ำ):
- พื้นหลัง: สีเขียวมิ้นท์ `#f0fdf4`
- กลางจอ: โลโก้ ArCal (ใช้ `arcal_logo.png`)
- ใต้โลโก้: ข้อความ **"Download Free"** สีเขียวเข้ม `#166534`
- ด้านล่าง: ไอคอน Google Play + App Store เรียงกัน

**เครื่องมือตัดต่อ:**
- CapCut (ฟรี, มือถือ) — ดีที่สุดสำหรับงานนี้
- หรือ iMovie (iOS) / Google Photos editor (Android)
- ไม่ต้องใส่เพลง (Google Ads มักเล่นแบบ mute) แต่ถ้าจะใส่ ใช้เพลงฟรีจาก YouTube Audio Library

**อัปโหลดวิดีโอ:**
1. อัปขึ้น **YouTube** (ตั้งเป็น Unlisted)
2. ใส่ลิงก์ YouTube ในขั้นตอนสร้าง UAC campaign → Add Video Asset
3. Google จะ auto-crop ให้เข้ากับ placement ต่างๆ

---

### 5.3 ลำดับความสำคัญ — ทำอะไรก่อน

ถ้ามีเวลาจำกัด ให้ทำตามลำดับนี้:

| Priority | ชิ้น | ทำไม |
|----------|------|------|
| **1 (ต้องทำ)** | วิดีโอ A: AR Scan Flow (TH + VN) | วิดีโอ = reach สูงสุดใน UAC + AR เป็น unique differentiator |
| **2 (ต้องทำ)** | รูปชิ้น 1: AR Scan จริง (TH + VN) | Money shot — ภาพที่สื่อ "แอปนี้ต่าง" ทันทีที่เห็น |
| **3 (ต้องทำ)** | รูปชิ้น 2: ผลลัพธ์ AI วัตถุดิบ | แสดง value ที่ได้หลัง scan — ปิด objection "แล้วแม่นไหม?" |
| **4 (ควรทำ)** | รูปชิ้น 3: Zero Setup Dashboard | ตอบ objection "ต้อง login ไหม?" |
| **5 (ควรทำ)** | วิดีโอ B: Chat Logging | โชว์อีก use case — คนไม่อยากถ่ายรูปก็พิมพ์ได้ |
| **6 (เสริม)** | รูปชิ้น 4–6 + วิดีโอ C–D | เพิ่ม variety ให้ Google test |

**Minimum Viable Ad Set:** ทำแค่ priority 1–3 (2 วิดีโอ + 4 รูป × 3 ขนาด = 14 ไฟล์) ก็เปิด campaign ได้แล้ว — ใช้เวลาทำ **1–2 ชั่วโมง**

---

## 6. เทคนิคสำคัญ — มุมนักการตลาด

### 6.1 ข้อผิดพลาดที่พบบ่อย

| ผิดพลาด | ทำไมเสียเงินเปล่า | ทำแทน |
|---------|-------------------|-------|
| รวม TH + VN ในแคมเปญเดียว | Google จะเทงบไปประเทศที่ CPI ถูกกว่า → VN กิน budget TH | **แยกแคมเปญ** ต่อประเทศ |
| ไม่ใส่ negative keywords | คนค้นหา "สูตรอาหาร" / "recipe" คลิกมาเสียเงินแต่ไม่โหลด | ใส่ negative list ตั้งแต่วันแรก |
| เปลี่ยน bid ทุกวัน | Algorithm reset ต้องเรียนรู้ใหม่ | รอ **7–14 วัน** ก่อนปรับ |
| ไม่มี conversion tracking | ไม่รู้ว่า install มาจาก ad ไหน optimize ไม่ได้ | ติด **Firebase + event tracking** ก่อนยิง |
| Creative เดียวสำหรับทุกตลาด | อาหารไทย = ไม่สื่อกับคนเวียดนาม | ทำ creative **แยกภาษา + อาหาร** ต่อตลาด |

### 6.2 A/B Testing Roadmap

| สัปดาห์ | ทดสอบ | Metric |
|--------|-------|--------|
| 1–2 | Headline variations (5 ชุด) | CTR (Click-through rate) |
| 3–4 | Image variations (3 ชุด) | CVR (Conversion rate → install) |
| 5–6 | Bid strategy: CPI vs CPA (first_scan) | CPA |
| 7–8 | Landing page vs direct-to-store | Install rate |

### 6.3 จุดขายที่ควรเน้นต่อตลาด

**ไทย — Pain points:**
- แอปนับแคลส่วนใหญ่เป็นภาษาอังกฤษ ไม่เข้าใจอาหารไทย
- "ผัดกะเพรา" ไม่ใช่ "basil stir fry" — คนไทยรู้สึกว่าผลลัพธ์ไม่แม่น
- ไม่อยากสมัครสมาชิก / ให้อีเมล / ตอบคำถาม 20 ข้อก่อนใช้งาน
- **ชู:** "เข้าใจอาหารไทย", "ไม่ต้อง login", "AR สแกนอาหาร"

**เวียดนาม — Pain points:**
- ตลาด health/fitness กำลังโตเร็วมาก (urbanization + fitness trend)
- แอปส่วนใหญ่ไม่รู้จัก phở, bánh mì, bún bò — ใส่เป็น "noodle soup", "sandwich"
- คนเวียดนามระวังเรื่อง privacy + data เหมือนกัน
- **ชู:** "Phở là Phở", "không đăng nhập", "AI chính xác"

### 6.4 Seasonal Timing (ช่วงเวลาที่ CPI ถูก + demand สูง)

| ช่วง | เหตุผล | ทำอะไร |
|------|-------|-------|
| มกราคม | New Year resolution ลดน้ำหนัก | เพิ่มงบ 2x |
| มีนาคม–เมษายน | ก่อนสงกรานต์/หน้าร้อน ไทยอยากผอม | เพิ่มงบ |
| กันยายน | Back to routine หลังวันหยุด | ปานกลาง |
| พฤศจิกายน–ธันวาคม | ก่อน new year — คนเริ่มตั้งเป้าปีหน้า | เพิ่มงบ |
| Tết (ม.ค.–ก.พ.) | เวียดนาม — หลังกินเยอะช่วงเทศกาล | เพิ่มงบ VN |

---

## 7. วัดผล — KPI ที่ต้องดู

| KPI | เป้าหมาย | ดูที่ไหน |
|-----|---------|---------|
| **CPI** (Cost per Install) | <฿30 (TH) / <10k VND (VN) | Google Ads |
| **CTR** (Click-through rate) | >2% (Search), >0.5% (Display) | Google Ads |
| **Day 1 Retention** | >30% | Firebase Analytics |
| **First Scan Rate** | >50% ของ install | Firebase custom event |
| **ROAS** (Return on Ad Spend) | >1.5x ภายใน 30 วัน | Firebase + Revenue tracking |

---

## 8. Checklist ก่อนเปิด Google Ads

- [ ] **Firebase** ติดตั้งแล้ว + ลิงก์กับ Google Ads account
- [ ] **Conversion events** ตั้งค่าแล้ว (`first_open`, `first_scan`, `energy_purchase`)
- [ ] **Play Store listing** อัปเดตชื่อ/สกรีนเป็น ArCal แล้ว
- [ ] **App Store listing** พร้อมแล้ว (ArCal อยู่บน App Store)
- [ ] **Landing page** deploy แล้ว + ลิงก์ Play/App Store ถูกต้อง
- [ ] **Google tag** บนเว็บ — ตั้ง `NEXT_PUBLIC_GA_MEASUREMENT_ID` และ/หรือ `NEXT_PUBLIC_GOOGLE_ADS_TAG_ID` (`AW-`) ใน `website/.env.local` แล้ว deploy (ดู section 9.6)
- [ ] **Conversion คลิกสโตร์บนเว็บ** (ถ้าใช้) — สร้างเป้าหมายการแปลงแยก Play / App Store แล้วใส่ `NEXT_PUBLIC_GOOGLE_ADS_CONV_*` ใน `.env.local` + deploy (ดู section 9.7)
- [ ] **Ad creative** เตรียมแล้วอย่างน้อย: 5 headlines + 4 descriptions + 3 images ต่อตลาด
- [ ] **Negative keywords** ใส่แล้ว
- [ ] **Budget** ตั้งค่าแยกต่อประเทศ
- [ ] **Payment method** ในGods Ads account พร้อม (บัตรเครดิต/debit)

---

## 9. Landing Page Optimization สำหรับ Ads

Landing page ที่สร้างมากับเอกสารนี้ออกแบบเพื่อ Google Ads โดยเฉพาะ:

| องค์ประกอบ | ทำไมถึงสำคัญ |
|-----------|-------------|
| **Store buttons เหนือ fold** | คนจากโฆษณาพร้อมโหลด — อย่าให้ต้อง scroll ไกล |
| **Store buttons 3 จุด** | Hero, หลัง How it works, ท้ายหน้า — จับทุกช่วง scroll |
| **USP ชัด 3 ข้อใน Hero** | Free tokens / No login / 10-sec setup — ตอบ objection ทันที |
| **Social proof strip** | 10 sec, 95%, 15 cuisines, 0 login — ตัวเลขสร้างความเชื่อมั่น |
| **Comparison table** | คนเปรียบเทียบกับแอปอื่น — ตารางช่วยตัดสินใจ |
| **ไม่มี video** | Video ทำให้โหลดช้า ลด conversion สำหรับ 3G/4G ใน SEA |

### สิ่งที่ควรทำเพิ่มบน Landing Page ในอนาคต:

- [ ] เพิ่ม `?utm_source=google&utm_campaign=xxx` tracking ใน store URLs
- [ ] ทำเวอร์ชันภาษาไทย (`/th`) และเวียดนาม (`/vi`) — Google Ads ส่ง traffic ไปหน้าภาษาที่ตรงได้ ลด bounce rate มหาศาล
- [ ] เพิ่ม user review / testimonial section เมื่อมี real reviews
- [ ] A/B test Hero headline — ทดลอง 2–3 variation

---

## 9.5 Store Links (ใช้ตรวจสอบก่อนยิงโฆษณา)

- **Google Play (Android)**: `https://play.google.com/store/apps/details?id=com.tanabun.miro`
- **App Store (iOS)**: `https://apps.apple.com/us/app/arcal-ai-calorie-counter/id6759806302`

---

## 9.6 Google tag บน Landing (ทาง C — Search/Display เข้าเว็บ)

แผนในเอกสารนี้รวม **Search + Display → Landing page** ดังนั้นเว็บต้องมี **Google tag (gtag.js) + GA4** เพื่อให้ Google Ads วัดผลคลิก/พฤติกรรมบนเว็บได้ และลด warning แบบ “missing Google tag” ในบัญชีที่มี website conversion

### ขั้นตอน (ทำครั้งเดียว)

1. เปิด **Google Analytics** (property เดียวกับ Firebase เช่น `miro-d6856`)
2. **Admin** → **Data streams** → เลือก **Web** stream ของเว็บ (เช่น `arcal web` / URL `https://miro-d6856.web.app/miro/` หรือโดเมนจริง)
3. คัดลอก **Measurement ID** รูปแบบ `G-XXXXXXXXXX`
4. ในโฟลเดอร์ `website/` สร้างไฟล์ **`.env.local`** (ไม่ commit — อยู่ใน `.gitignore` แล้ว):
   ```bash
   cp .env.example .env.local
   ```
5. แก้ไฟล์ `.env.local` ให้มีบรรทัด (ใส่ทั้งสองถ้ามีทั้ง GA4 และ Google Ads tag):
   ```bash
   NEXT_PUBLIC_GA_MEASUREMENT_ID=G-XXXXXXXXXX
   NEXT_PUBLIC_GOOGLE_ADS_TAG_ID=AW-XXXXXXXXXX
   ```
   - **`G-...`** = Measurement ID จาก GA4 → Web stream  
   - **`AW-...`** = Google Ads tag จากหน้า “Install Google tag” ใน Google Ads (ต้องตรงกับที่ระบบแสดง ไม่งั้น “Test connection” จะไม่ผ่าน)
6. Build + deploy:
   ```bash
   cd website && ./deploy.sh
   ```

### ตรวจว่าติดแล้ว

- เปิดเว็บ → DevTools → **Network** → ค้นหา `gtag/js` หรือ `collect` จาก `google-analytics.com`
- ใน GA4 → **Reports** → **Realtime** → เปิดหน้าเว็บแล้วควรเห็น active user

### Google Ads

- หลัง tag ทำงาน ให้กลับไปที่ **Goals → Conversions** แล้วให้สถานะ website conversion / diagnostics อัปเดต (อาจใช้เวลาไม่กี่ชั่วโมง)

---

## 9.7 Conversion บนเว็บ: คลิกไป Play Store / App Store (แนะนำสำหรับโฆษณาที่ส่งเข้า Landing)

เมื่อ traffic มาที่เว็บแล้วคลิกปุ่มดาวน์โหลด ถ้าต้องการให้ **Google Ads นับเป็น conversion** (ไม่ใช่แค่เห็นใน GA4) ให้ทำแบบนี้:

### ขั้นตอนใน Google Ads

1. ไปที่ **เป้าหมาย** → **การแปลง** → **สร้างการแปลง**
2. เลือกประเภท **เว็บไซต์** — สร้าง **แยก 2 action** เช่น  
   - **คลิก Google Play**  
   - **คลิก App Store**
3. หลังสร้างแต่ละ action ให้คัดลอกค่า **`send_to`** รูปแบบ  
   `AW-18017791527/xxxxxxxx`  
   (เลข `AW-` ต้องตรงกับบัญชี/tag เดียวกับ `NEXT_PUBLIC_GOOGLE_ADS_TAG_ID` — ส่วนหลัง `/` คือ **ป้ายกำกับการแปลง** ไม่ซ้ำกันระหว่าง Play กับ iOS)

### ขั้นตอนในโปรเจกต์เว็บ (`website/`)

ใส่ใน **`.env.local`** และใน **environment ของ hosting ตอน build** (ค่า `NEXT_PUBLIC_*` ถูกฝังตอน build):

```bash
NEXT_PUBLIC_GOOGLE_ADS_TAG_ID=AW-18017791527
NEXT_PUBLIC_GOOGLE_ADS_CONV_PLAY_STORE=AW-18017791527/เลเบลจาก_Play_action
NEXT_PUBLIC_GOOGLE_ADS_CONV_APP_STORE=AW-18017791527/เลเบลจาก_iOS_action
```

- Snippet HTML ที่ Google ให้มา (`gtag('config', 'AW-...')`) = **แค่โหลด tag** — การนับ conversion ต้องมี **`gtag('event', 'conversion', { send_to: '...' })`** ซึ่งโค้ดใน repo ยิงให้แล้วเมื่อมี env ข้างบน
- ปุ่มสโตร์บนหน้าแรกและลิงก์ในหน้า Support ใช้คอมโพเนนต์ที่เรียก tracking นี้ (ดู `website/src/lib/gtagStore.ts`, `StoreButtons.tsx`, `StoreOutboundLink.tsx`)

### ทางเลือก: วัดผ่าน GA4 อย่างเดียว

- ไม่ใส่ `NEXT_PUBLIC_GOOGLE_ADS_CONV_*` ก็ได้ — ระบบยังยิง event **`store_outbound_click`** (พารามิเตอร์ `store`, `link_url`) ไปยัง GA4 ถ้ามี `NEXT_PUBLIC_GA_MEASUREMENT_ID`
- จากนั้นไปตั้ง **Key event** ใน GA4 แล้ว **ลิงก์ GA4 กับ Google Ads** เพื่อใช้เป็น conversion ในแคมเปญได้ (ไม่ต้องมี label แยกใน `.env`)

### สิ่งที่ต้องทำหลังแก้ `.env.local`

1. **Build + deploy ใหม่** (`cd website && ./deploy.sh` หรือ pipeline ของคุณ) — ค่า `NEXT_PUBLIC_*` ไม่อัปเดตถ้าไม่ build ใหม่  
2. ทดสอบคลิกปุ่ม Play / App Store แล้วดูใน **Google Ads → การแปลง** หรือ **Tag Assistant** / Network ว่ามี request conversion

---

*เอกสารนี้เป็นแนวทางเริ่มต้น — ปรับตาม data จริงหลังยิง 2 สัปดาห์แรก*
