# 🔧 Quick Fix: Android Setup Issues

## ปัญหาที่พบ:
1. ✅ Android SDK ติดตั้งแล้ว (version 36.1.0)
2. ❌ cmdline-tools component is missing
3. ❌ Android license status unknown

---

## วิธีแก้ (เลือก 1 วิธี):

### วิธีที่ 1: ใช้ Android Studio (ง่ายที่สุด)

1. เปิด **Android Studio**
2. ไปที่ **Tools** → **SDK Manager**
3. ไปที่แท็บ **SDK Tools**
4. ✅ เช็ค **"Android SDK Command-line Tools (latest)"**
5. กด **Apply** → รอให้ติดตั้งเสร็จ
6. รัน: `flutter doctor --android-licenses` (กด `y` ทุกคำถาม)
7. รัน: `flutter doctor` (ควรเห็น ✅ แล้ว)

---

### วิธีที่ 2: Download cmdline-tools โดยตรง

1. Download: https://developer.android.com/studio#command-line-tools-only
2. Extract ไปที่: `%LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest`
3. รัน: `flutter doctor --android-licenses`
4. รัน: `flutter doctor`

---

## หลังจากแก้แล้ว:

รัน:
```
flutter build apk --debug
```

ควรจะ Build ได้แล้ว! 🎉
