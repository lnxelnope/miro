---
phase: 06-foundation
plan: 02
title: "Dependencies: ML Kit, sensors_plus, camera baseline"
one_liner: "เตรียม dependency ด้านกล้องและ ML Kit สำหรับ ARscan โดยเพิ่ม sensors_plus และยืนยันข้อจำกัด native ที่มีอยู่"
subsystem: "mobile-app"
tags:
  - flutter
  - dependencies
  - android
  - ios
  - arscan
requires:
  - ARSCAN-03
provides:
  - "Dependency baseline สำหรับ ARscan (ML Kit + sensors_plus + camera)"
affects:
  - "Flutter build pipeline"
  - "Android Gradle config"
  - "iOS Pod setup"
tech_stack:
  added:
    - "sensors_plus (Flutter)"
  patterns:
    - "ใช้ ML Kit ตระกูล google_mlkit_* สำหรับงาน ARscan"
    - "รักษา minSdk/compileSdk/iOS platform version ให้สอดคล้องกับ plugin ที่ใช้อยู่"
key_files:
  created: []
  modified:
    - pubspec.yaml
    - android/app/build.gradle.kts
    - ios/Podfile
    - .planning/STATE.md
decisions:
  - "ไม่อัปเดตเวอร์ชัน camera และ ML Kit ใน phase นี้ เพื่อลดความเสี่ยง regression กับฟีเจอร์กล้อง/บาร์โค้ด/แกลเลอรี่ที่ใช้งานอยู่"
  - "ใช้ sensors_plus เป็น dependency หลักสำหรับ sensor integration ใน phase 9"
metrics:
  duration: "N/A (tooling environment ไม่รองรับ flutter commands)"
  completed_at: "2026-03-16"
---

# Phase 6 Plan 2: Dependencies Summary

## Objective

ติดตั้งและปรับ dependency พื้นฐานสำหรับ ARscan (กล้อง, ML Kit object detection, sensors) ให้พร้อมสำหรับ phases ถัดไป โดยไม่ทำให้ฟีเจอร์เดิมพัง และคงความเข้ากันได้กับ Drift database และ plugin อื่น ๆ

## Tasks Executed

### Task 1: ทบทวน dependency ปัจจุบันที่เกี่ยวกับกล้อง/ภาพและ sensors

- ตรวจสอบ `pubspec.yaml` พบว่า:
  - ML Kit ที่ใช้อยู่แล้ว: `google_mlkit_text_recognition`, `google_mlkit_image_labeling`, `google_mlkit_barcode_scanning`, `google_mlkit_object_detection` (ทั้งหมดใช้เวอร์ชัน `any`)
  - กล้องและภาพ: `camera: ^0.10.5+5`, `mobile_scanner: ^7.0.0`, `photo_manager: ^3.6.0`, `image_picker: ^1.0.7`
  - Database: `drift: ^2.24.0`, `drift_sqflite: ^2.0.0`, `sqlite3_flutter_libs: ^0.5.24`
- ตรวจสอบ native config:
  - Android: `compileSdk = 36`, `minSdk = 26`, `targetSdk = 35` ซึ่งรองรับ health plugin และสอดคล้องกับ requirement ของ plugin ส่วนใหญ่
  - iOS: `platform :ios, '15.5'` ใน `Podfile`
- สรุป constraint สำคัญ:
  - ไม่ควรลด `minSdk` หรือ platform version ลง เพราะ health และ plugin ปัจจุบันต้องการระดับนี้
  - การอัปเดต camera/ML Kit ควรทำอย่างระวัง เพราะอาจกระทบฟีเจอร์กล้อง/บาร์โค้ด/แกลเลอรี่
- Verification:
  - ไม่พบ dependency ชนกันหรือซ้ำซ้อนใน `pubspec.yaml` จากการตรวจด้วยสายตา

**สถานะ:** Task 1 ถือว่าเสร็จสมบูรณ์ (การทบทวนและจด constraint เสร็จสิ้นโดยไม่ต้องแก้โค้ด)

### Task 2: เพิ่ม/อัปเดต dependency สำหรับ ML Kit object detection และ sensors

- การเปลี่ยนแปลงที่ทำใน `pubspec.yaml`:
  - เพิ่ม `sensors_plus: any` ในหมวด Vision & Scanning/Local AI เพื่อเตรียมใช้ accelerometer และ sensors อื่น ๆ ใน Phase 9
  - คง `google_mlkit_object_detection: any` ตามเดิม (มีอยู่แล้ว) เพราะโปรเจกต์ได้เลือกใช้ ML Kit object detection อยู่แล้ว และการเปลี่ยนเวอร์ชันโดยไม่มีข้อมูลเพิ่มเติมอาจเพิ่มความเสี่ยง regression
  - รักษา `camera: ^0.10.5+5` เนื่องจากเวอร์ชันนี้รองรับ image stream อยู่แล้ว และใช้งานกับ flow ปัจจุบันได้
- ไม่เปลี่ยนแปลง dependency ที่เกี่ยวข้องกับ Drift (`drift`, `drift_sqflite`, `sqlite3_flutter_libs`) เพื่อหลีกเลี่ยง conflict
- Verification:
  - พยายามรัน `flutter pub get` แต่ล้มเหลวเพราะสิ่งแวดล้อม execution ไม่มีคำสั่ง `flutter`:
    - Error: `command not found: flutter`
  - ในสภาพแวดล้อมจริง จำเป็นต้องรัน:
    - `flutter pub get`

**สถานะ:** Task 2 เสร็จสมบูรณ์ในแง่การแก้ `pubspec.yaml` และมี commit:
- Commit: `d1cd1da` — `feat(06-02): add sensors_plus for ARscan dependencies`

### Task 3: ปรับ native build config สำหรับ Android/iOS ให้รองรับ dependency ใหม่

- ตรวจสอบ `android/app/build.gradle.kts` และ `ios/Podfile` แล้วพบว่า:
  - Android:
    - `compileSdk = 36`, `minSdk = 26`, `targetSdk = 35`, `JavaVersion.VERSION_17` และ `kotlinOptions.jvmTarget = 17`
    - การเพิ่ม `sensors_plus` ไม่ต้องการการเปลี่ยนแปลง minSdk หรือ compileSdk เพิ่มเติม
  - iOS:
    - `platform :ios, '15.5'` เพียงพอสำหรับ plugin ปัจจุบันและ `sensors_plus`
    - ใช้ `flutter_install_all_ios_pods` ตามมาตรฐานของ Flutter
- จากการประเมิน dependency ที่เพิ่ม (เฉพาะ `sensors_plus`) และสถานะ config ปัจจุบัน:
  - ไม่มีความจำเป็นต้องปรับ minSdk/compileSdk หรือ Podfile เพิ่มเติมใน plan นี้
  - การเปลี่ยนแปลงเชิงรุกรบ (เช่น อัปเกรดกล้อง/ML Kit ครั้งใหญ่) ถูกเลื่อนออกไปเพื่อลดความเสี่ยง regression กับฟีเจอร์เดิม
- Verification ที่วางแผนไว้:
  - `flutter build apk --debug`
  - `flutter build ios --simulator`
- ข้อจำกัด tooling:
  - ไม่สามารถรันคำสั่ง build เหล่านี้ในสภาพแวดล้อม execution ของ agent ได้ เนื่องจากไม่มีคำสั่ง `flutter` ให้ใช้งาน

**สถานะ:** Task 3 ถือว่าถูกประเมินและยืนยันว่า config ปัจจุบันรองรับ dependency ใหม่ (`sensors_plus`) โดยไม่ต้องแก้ไฟล์ native เพิ่มเติมใน phase นี้

## Verification Status

ตาม checklist ในแผน:

- [ ] flutter pub get สำเร็จ  
  - ไม่สามารถยืนยันได้ในสภาพแวดล้อมนี้ (ไม่มีคำสั่ง `flutter`); ต้องให้ทีมรันบนเครื่อง dev จริง
- [ ] build Android สำเร็จ (debug หรือ profile)  
  - ยังไม่ได้รันด้วยเหตุผลเดียวกัน
- [ ] build iOS สำเร็จ (simulator หรือ device)  
  - ยังไม่ได้รันด้วยเหตุผลเดียวกัน
- [ ] แอปยังเปิดและใช้งานฟีเจอร์เดิมได้โดยไม่มี crash จาก dependency ใหม่  
  - ต้องทดสอบ manual/QA บนเครื่องจริงหลังรัน build

จากมุมมองของโค้ดและ config:
- Dependency สำหรับ ARscan ถูกตั้งค่าใน `pubspec.yaml` ครบ (มีทั้ง `google_mlkit_object_detection` และ `sensors_plus`)
- Native config ปัจจุบันรองรับ dependency ที่เพิ่ม โดยไม่ต้องอัปเดตเพิ่มเติมใน phase นี้

## Deviations from Plan

### Auto-fixed / Adjusted Scope Issues

1. **[Rule 3 - Blocking issue] เครื่องมือ flutter CLI ไม่พร้อมใช้งานในสภาพแวดล้อม execution**
   - **พบระหว่าง:** Task 2 (verify `flutter pub get`) และ Task 3 (เตรียมคำสั่ง build)
   - **Issue:** เรียก `flutter pub get` แล้วได้ error `command not found: flutter`
   - **การจัดการ:** ถือเป็นข้อจำกัดของ tooling environment ไม่ใช่ bug ของโปรเจกต์ จึง:
     - บันทึกข้อจำกัดไว้ในส่วน Verification Status
     - ระบุขั้นตอนที่ทีมต้องรันเองบนเครื่อง dev จริง

2. **[Scope adjustment] ไม่อัปเกรด camera/ML Kit ใน phase นี้**
   - **เหตุผล:** 
     - โปรเจกต์มี ML Kit และ camera ที่ใช้งานอยู่แล้วกับฟีเจอร์ production
     - การเปลี่ยนเวอร์ชันครั้งใหญ่ของ camera/ML Kit มีโอกาสทำให้ฟีเจอร์กล้อง/บาร์โค้ด/แกลเลอรี่พัง และควรถูกจัดการใน phase ที่เน้น camera stream โดยตรงพร้อมแผนทดสอบเฉพาะ
   - **แนวทาง:** 
     - ยืนยันว่ามี dependency ที่จำเป็น (ML Kit object detection + sensors_plus)
     - เลื่อนการพิจารณา camera upgrade เชิงลึกไปผูกกับ phase ที่เกี่ยวข้องกับ camera stream โดยตรง

## Follow-up / Manual Steps Required

เพื่อให้แผนนี้ถือว่าสมบูรณ์ 100% ตามเกณฑ์ในเอกสาร ควรทำสิ่งต่อไปนี้บนเครื่อง dev จริง:

1. รัน `flutter pub get` และตรวจสอบว่า:
   - ไม่มี dependency conflict
   - การ generate ไฟล์ที่เกี่ยวข้อง (เช่น l10n, drift) ยังทำงานปกติ
2. รัน build:
   - `flutter build apk --debug`
   - `flutter build ios --simulator`
3. ทดสอบ manual:
   - เปิดแอปบน Android/iOS
   - ตรวจสอบฟีเจอร์ต่อไปนี้ว่ายังทำงานปกติ:
     - กล้องถ่ายภาพ + image picker
     - barcode scanning
     - แกลเลอรี่
     - แชทที่ผูกกับ Gemini

## Self-Check

- มีไฟล์ที่อ้างถึงใน summary นี้อยู่จริง:
  - `pubspec.yaml`
  - `android/app/build.gradle.kts`
  - `ios/Podfile`
  - `.planning/STATE.md`
- Commit ที่อ้างถึง:
  - `d1cd1da` พบใน `git log`

**Self-Check: PASSED**

