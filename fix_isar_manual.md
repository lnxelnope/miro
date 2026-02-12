# 🔧 Fix Isar Namespace - Manual Steps

## ปัญหา:
Isar build.gradle ไม่มี namespace ซึ่งจำเป็นสำหรับ Android Gradle Plugin 8+

## วิธีแก้:

### Step 1: เปิดไฟล์
เปิดไฟล์นี้ใน Notepad หรือ VS Code:
```
%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\isar_flutter_libs-3.1.0+1\android\build.gradle
```

### Step 2: หา `android {`
ควรจะเห็นประมาณนี้:
```gradle
android {
    compileSdkVersion ...
```

### Step 3: เพิ่ม namespace
แก้เป็น:
```gradle
android {
    namespace = "dev.isar.isar_flutter_libs"
    compileSdkVersion ...
```

**สำคัญ:** ต้องเป็นบรรทัดใหม่จริงๆ ไม่ใช่ `\n` หรือตัวอักษรพิเศษ

### Step 4: Save แล้วลอง Build อีกครั้ง
