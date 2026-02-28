# MIRO — Play Store Launch Plan

> **MIRO** = **M**y **I**ntake **R**ecord **O**racle
> AI-powered calorie tracker — snap, type, or chat to log your food.

---

## Brand Identity

| Item | Value |
|------|-------|
| ชื่อแอป | **MIRO — Intake Oracle** |
| Package ID | `com.tanabun.miro` |
| Product ID (IAP) | `miro_cal_pro` |
| Category | Health & Fitness |
| ราคา Pro | $9.99 (one-time, non-consumable) |
| Free Tier | 3 AI analyses / day + unlimited manual logging |

### Slogan (เสนอ 4 แบบ)

| # | Slogan | จุดเด่น |
|---|--------|---------|
| 1 | **"Snap. Log. Know."** | สั้น จำง่าย สื่อครบ 3 actions |
| 2 | **"AI calorie tracking that learns from you"** | เน้น AI + ยิ่งใช้ยิ่งฉลาด |
| 3 | **"จดแคลให้ง่าย ด้วย AI ที่เข้าใจคุณ"** | Thai localized listing |
| 4 | **"Your food diary, powered by AI"** | คลาสสิค เรียบง่าย |

---

## Play Store Listing

### Short Description (80 chars max)

```
AI calorie tracker — snap food photos or just type. Free, private, offline.
```

### Full Description

```
MIRO — the simplest AI-powered calorie tracker.

Snap a photo of your food and let AI calculate calories, protein, carbs,
and fat instantly. Or just type what you ate — Miro figures out the rest.

━━━━━━━━━━━━━━━━━━━━━
KEY FEATURES
━━━━━━━━━━━━━━━━━━━━━

📸 SNAP & ANALYZE
Take a photo of any meal. AI identifies ingredients, estimates portions,
and calculates full nutrition breakdown. Edit ingredients before saving
for accuracy.

⌨️ TYPE & LOG
Just type "fried rice 1 plate" — AI finds the calories, macros, and
ingredients for you. The fastest way to log food.

💬 CHAT WITH AI
Tell Miro what you ate in natural language. It understands and logs
everything automatically.

📚 YOUR DATABASE GROWS WITH YOU
The more you use Miro, the smarter it gets. Your personal food database
builds from YOUR eating habits. Custom meals and ingredients are saved
locally.

🔒 PRIVACY FIRST
All data stored locally on your device. No cloud, no server, no account
required. Your food diary stays yours.

🔑 BRING YOUR OWN AI KEY
Use your own free Gemini API key. No middleman, no hidden costs.
Gemini 2.0 Flash free tier is more than enough for daily use.

━━━━━━━━━━━━━━━━━━━━━
FREE WITH OPTIONAL PRO
━━━━━━━━━━━━━━━━━━━━━

✅ FREE:
• 3 AI food analyses per day
• Unlimited manual food logging
• Full nutrition dashboard (kcal, protein, carbs, fat)
• Personal meals & ingredients database
• Chat with AI assistant

⭐ PRO ($9.99 one-time purchase):
• Unlimited AI food analyses
• No daily limits — ever

Built for people who want to track what they eat without the hassle.
```

### Play Store Graphics ที่ต้องทำ

| Asset | ขนาด | สถานะ |
|-------|-------|--------|
| App Icon | 512x512 | ✅ มีแล้ว (`assets/icon/logo.png`) |
| Feature Graphic | 1024x500 | ❌ ต้องสร้าง (Canva/Figma) |
| Screenshots (Phone) | min 4 รูป, แนะนำ 8 | ❌ ต้อง capture |

#### Screenshots ที่ควรมี (เรียงตามลำดับ)

1. หน้า Dashboard + สรุป kcal ของวัน
2. ถ่ายรูปอาหาร → ผลวิเคราะห์ AI (จุดขายหลัก)
3. หน้า Chat กับ AI — พิมพ์แล้วบันทึกให้
4. หน้า Diet log / Timeline
5. หน้าแก้ไขวัตถุดิบก่อนบันทึก
6. หน้า My Meals (เมนูของฉัน)
7. หน้า Nutrition breakdown (macro details)
8. Pro upgrade prompt

---

## สิ่งที่ต้องทำใน Code

### Priority: HIGH (ต้องทำก่อน publish)

#### 1. Privacy Policy (in-app)
- **สร้างไฟล์**: `lib/features/profile/presentation/privacy_policy_screen.dart`
- เนื้อหาภาษาอังกฤษ (Global audience)
- ครอบคลุม:
  - ข้อมูลที่เก็บ: health data (calories, food entries), user profile (age, weight, height, gender)
  - วิธีเก็บ: **local only** (Isar DB บนเครื่อง), ไม่ส่งไป server
  - Gemini API: ผู้ใช้ใช้ key ของตัวเอง, รูปอาหาร + text ถูกส่งไป Google Gemini API เพื่อวิเคราะห์
  - Camera/Storage: ใช้เพื่อถ่ายรูปอาหาร + scan gallery เท่านั้น
  - In-App Purchase: จัดการโดย Google Play
  - API Key: เก็บใน Secure Storage, ไม่ส่งไปที่อื่นนอกจาก Google AI
  - ไม่มี analytics, ไม่มี ads, ไม่เก็บ PII บน server
- **อัพเดท Profile screen** ให้กดแล้วไปหน้า in-app แทน external URL

#### 2. Terms of Service (in-app)
- **สร้างไฟล์**: `lib/features/profile/presentation/terms_screen.dart`
- เนื้อหาครอบคลุม:
  - ข้อมูลโภชนาการเป็น **การประมาณ** ไม่ใช่คำแนะนำทางการแพทย์
  - ผู้ใช้รับผิดชอบ Gemini API key ของตัวเอง
  - Free tier จำกัด 3 AI calls/day, Pro ไม่จำกัด
  - การซื้อ Pro เป็น non-consumable (ซื้อครั้งเดียว)
  - สงวนสิทธิ์เปลี่ยนแปลงราคา/ฟีเจอร์
  - Disclaimer: ไม่รับผิดชอบความเสียหายจากการใช้ข้อมูลโภชนาการ

#### 3. แก้บั๊ก URL Launcher (ลิงก์ Gemini API ไม่เปิด browser)

**ปัญหา**: `canLaunchUrl()` บน Android 11+ ต้องการ `<queries>` ใน AndroidManifest.xml

**แก้ 2 จุด**:

**(A)** `android/app/src/main/AndroidManifest.xml` — เพิ่ม:
```xml
<queries>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="https" />
    </intent>
</queries>
```

**(B)** `lib/features/profile/presentation/api_key_screen.dart` — แก้ `_openUrl()`:
```dart
Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถเปิดลิงก์ได้: $url')),
      );
    }
  }
}
```

#### 4. ปิด Dev Mode
- **ไฟล์**: `lib/core/services/usage_limiter.dart` บรรทัด 10
- เปลี่ยน `_forceProDuringDev = true` → `false`

#### 5. อัพเดท Profile Screen
- **ไฟล์**: `lib/features/profile/presentation/profile_screen.dart`
- Privacy Policy: เปลี่ยนจาก `_openUrl(external)` → `Navigator.push(PrivacyPolicyScreen)`
- Terms of Service: เปลี่ยนจาก `_openUrl(external)` → `Navigator.push(TermsScreen)`

---

### Priority: MEDIUM (ควรทำ แต่ไม่ block launch)

#### 6. GitHub Pages สำหรับ Legal URL
- Google Play Console **บังคับ** Privacy Policy URL ภายนอก
- ทางออกง่ายที่สุด: สร้าง GitHub repo → host HTML ง่ายๆ 2 หน้า
- URL pattern: `https://<username>.github.io/miro-legal/privacy-policy`
- เนื้อหาเหมือน in-app ทุกประการ

---

### Priority: LOW (ทำทีหลัง v1.1+)

#### 7. Database Backup/Restore
- Export Isar DB → `.miro` file → share ผ่าน `share_plus`
- Import: เลือกไฟล์ → copy ทับ Isar DB → restart
- Profile screen มี placeholder อยู่แล้ว (commented out บรรทัด 157-168)

---

## Google Play Console Setup (Manual — นอก code)

| ขั้นตอน | รายละเอียด |
|---------|------------|
| 1. Developer Account | สร้าง Google Play Developer Account ($25 one-time) |
| 2. Create App | ชื่อ "MIRO — Intake Oracle", category Health & Fitness |
| 3. Store Listing | กรอก description + upload screenshots + feature graphic |
| 4. Content Rating | ทำแบบสอบถาม IARC (ไม่มี content ที่ไม่เหมาะสม) |
| 5. Data Safety | ประกาศว่าเก็บ health data แบบ **local only**, ไม่ share กับ third party |
| 6. Privacy Policy URL | ใส่ GitHub Pages URL |
| 7. In-App Products | สร้าง `miro_cal_pro` ราคา $9.99, type: non-consumable |
| 8. Target Audience | ทุกอายุ (13+) |
| 9. Testing Track | Internal → Closed → Open → Production |
| 10. Review | Google review ใช้เวลา 1-7 วัน |

---

## Production Build Checklist

- [ ] `_forceProDuringDev = false`
- [ ] `pubspec.yaml` version ถูกต้อง (`1.0.0+1`)
- [ ] `key.properties` มีค่าถูกต้อง (keyAlias, keyPassword, storeFile, storePassword)
- [ ] `proguard-rules.pro` มี rules สำหรับ Isar, Google ML Kit
- [ ] `.gitignore` มี `.env`, `key.properties`, `*.jks`, `*.keystore`
- [ ] `AndroidManifest.xml` มี `<queries>` สำหรับ url_launcher
- [ ] Privacy Policy screen ทำเสร็จ
- [ ] Terms of Service screen ทำเสร็จ
- [ ] Profile screen เชื่อมกับ legal screens
- [ ] Test In-App Purchase ใน sandbox
- [ ] Test URL launcher เปิด Google AI Studio ได้
- [ ] Screenshots จาก device จริง
- [ ] Feature Graphic ออกแบบเสร็จ
- [ ] Build release APK/AAB: `flutter build appbundle --release`
- [ ] ทดสอบ release build บนเครื่องจริง

---

## จุดขายที่ต้องเน้นในการตลาด

| จุดขาย | ทำไมสำคัญ |
|--------|----------|
| **ถ่ายรูป → รู้แคล** | ง่ายที่สุดในตลาด ไม่ต้องค้นหาเอง |
| **แก้วัตถุดิบได้** | ต่างจากคู่แข่งที่ lock ผลวิเคราะห์ |
| **ยิ่งใช้ ยิ่งฉลาด** | DB โตจากการใช้งานจริง |
| **Privacy First** | ไม่เก็บบน cloud — ต่างจาก MyFitnessPal, Cronometer |
| **ใช้ AI key ตัวเอง** | โปร่งใส ไม่มี hidden cost |
| **ฟรีก็ใช้ได้** | 3 ครั้ง/วัน + manual logging ไม่จำกัด |
| **Gemini 2.0 Flash ฟรี** | ใช้ปกติไม่ต้องจ่ายค่า API เลย |
| **ไม่ต้อง login** | เปิดใช้ได้เลย ไม่ต้องสร้าง account |
