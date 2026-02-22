# 📤 Build เพื่อขึ้น App Store (แบบสั้น)

**เป้าหมาย**: เอาไฟล์ไป build แล้วส่ง App Store โดยทำน้อยที่สุดบน Mac

---

## ทางเลือกที่ 1: Build บน Cloud (ไม่ต้องใช้ Mac เลย)

ใช้ **Codemagic** หรือ **GitHub Actions** → build IPA ให้อัตโนมัติ

### Codemagic (แนะนำ)
1. Push โค้ดขึ้น [GitHub](https://github.com/lnxelnope/miro)
2. ไปที่ [codemagic.io](https://codemagic.io) → Sign up with GitHub
3. Add app → เลือก repo `lnxelnope/miro` → branch `feature/airbnb-redesign`
4. ตั้งค่า:
   - **iOS code signing**: อัปโหลด certificate + provisioning profile จาก Apple Developer
   - **Environment**: ใส่ `GEMINI_API_KEY` ใน Codemagic
   - **Firebase**: อัปโหลด `GoogleService-Info.plist` เป็น secret
5. กด **Start build** → ได้ไฟล์ `.ipa` มาดาวน์โหลด

**ข้อดี**: ไม่ต้องติดตั้งอะไรบน Mac, build ได้ทุกที่

---

## ทางเลือกที่ 2: Build บน Mac (ขั้นตอนน้อยสุด)

### สิ่งที่ต้องมี
- Mac + Xcode (จาก App Store)
- Apple Developer Account ($99/ปี)
- ไฟล์ `GoogleService-Info.plist` จาก Firebase
- ไฟล์ `.env` มี `GEMINI_API_KEY`

### คำสั่งรวดเดียว (รันจากโฟลเดอร์โปรเจกต์)

```bash
# 1. ติดตั้ง tools (ครั้งเดียว)
brew install flutter cocoapods

# 2. Build
cd /Users/tanabuninkeaw/ai_program/miro
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
cd ios && pod install && cd ..
flutter build ipa
```

### ไฟล์ที่ต้องมีก่อน build
| ไฟล์ | อยู่ที่ |
|------|---------|
| `.env` | root โปรเจกต์ (มี GEMINI_API_KEY) |
| `GoogleService-Info.plist` | `ios/Runner/` |

### หลัง build เสร็จ
- ไฟล์ IPA อยู่ที่: `build/ios/ipa/`
- ใช้ **Transporter** (จาก App Store) หรือ **Xcode** ส่งขึ้น App Store Connect

---

## สรุป

| วิธี | ต้องทำบน Mac | ความยาก |
|-----|-------------|---------|
| **Codemagic** | ไม่ต้อง | ตั้งค่าครั้งแรก |
| **Build บน Mac** | ต้อง | ติดตั้ง Xcode + Flutter |

ถ้าไม่อยากยุ่งกับ Mac → ใช้ **Codemagic**
