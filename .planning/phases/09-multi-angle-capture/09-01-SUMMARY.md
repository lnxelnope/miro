# Phase 09 Plan 01: Multi-angle capture controller Summary

## One-liner

Logic layer สำหรับ multi-angle capture ที่ใช้เซนเซอร์มุมกล้องและ detection state เพื่อ auto/manual capture ครบ 3 มุมอย่างเสถียร

## What was implemented

- สร้าง `AngleZone` enum และ `AngleCaptureResult` model พร้อม helper `fromDegrees` สำหรับ map มุมองศาเป็น zone
- สร้าง `DeviceAngleSensor` สำหรับอ่าน accelerometer, คำนวณมุมกล้อง 0–90° แบบ smooth และ classify เป็น `AngleZone` พร้อมเช็คความเสถียรของมุม
- สร้าง `MultiAngleCaptureController` เป็น state machine สำหรับ flow multi-angle capture (top → diagonal → side) รวม auto-capture, manual fallback และ reset เมื่อกล่องอาหารหาย

## Key files

- `lib/features/arscan/domain/models/angle_zone.dart`
- `lib/features/arscan/application/device_angle_sensor.dart`
- `lib/features/arscan/application/multi_angle_capture_controller.dart`
- `test/features/arscan/domain/angle_zone_test.dart`

## Behavior details

- `AngleZone.fromDegrees` map มุมองศาเป็น zone ตามช่วงที่กำหนดในแผน พร้อม clamp ค่าอยู่ในช่วง 0–90°
- `DeviceAngleSensor`:
  - subscribe `accelerometerEvents` จาก `sensors_plus`
  - คำนวณ pitch แล้วแปลงเป็นมุมกล้อง (0° = มองลง, 90° = มองตรงหน้า)
  - ใช้ low-pass filter (0.8/0.2) เพื่อให้มุมลื่น ไม่สั่น
  - expose `currentAngle` และ `currentZone` เป็น `ValueNotifier` และให้ `isStableInZone` ตรวจว่ามุมอยู่ใน zone เดิมครบเวลาที่ต้องการ
- `MultiAngleCaptureController`:
  - expose state ตามแผน: `capturedCount`, `currentTargetZone`, `currentDeviceZone`, `currentAngle`, `lastCaptureResult`, `isCapturing`, `capturedImages` และ flag `isComplete`
  - ใช้ sequence มุม `top → diagonal → side` พร้อม target zone ที่อัปเดตอัตโนมัติหลัง capture แต่ละครั้ง
  - auto-capture เมื่อ:
    - `ArScanCameraStreamController.detectionState == ArScanState.readyForCapture`
    - มุมกล้องอยู่ใน `currentTargetZone` และ `DeviceAngleSensor.isStableInZone` ครบอย่างน้อย ~0.7 วินาที
  - ขั้นตอน capture:
    - เรียก `cameraStreamController.stopStream()` (ซึ่งภายในใช้ `stopImageStream()`)
    - ถ่ายรูปด้วย `CameraController.takePicture()`
    - บันทึกไฟล์ไปยัง temp dir (`getTemporaryDirectory()/arscan_{timestamp}_{zone}.jpg`)
    - สร้าง `AngleCaptureResult` แล้ว upsert เข้า `capturedImages` และอัปเดต notifiers
    - เรียก `cameraStreamController.startStream()` เพื่อกลับมา stream ต่อ
  - manual shutter ผ่าน `captureManual()`:
    - ใช้มุมปัจจุบันของอุปกรณ์ (`currentDeviceZone` หรือ map จาก `currentAngle`) ในการตัดสิน zone
    - ถ้า zone เดิมเคยถูกถ่ายแล้ว → replace รูปเดิมใน `capturedImages`
    - ถ้าเป็น zone ใหม่ → เพิ่ม entry และอัปเดต `capturedCount`
  - เมื่อ `capturedImages` ครบ 3 zone → `isComplete = true` และ `currentTargetZone` ถูกตั้งเป็น `null` (Phase 10 สามารถ listen เพื่อรู้ว่าครบแล้ว)
  - reset progress เมื่อ detection state เป็น `searching` ต่อเนื่อง >= 1 วินาที:
    - ลบไฟล์รูปทั้งหมดแบบ best-effort
    - reset `capturedImages`, `capturedCount`, `lastCaptureResult`, `isComplete`
    - ตั้ง `currentTargetZone` กลับไปเป็น `AngleZone.top`

## Verification notes

- ไม่สามารถรัน `flutter test` ได้ใน environment นี้เนื่องจากไม่มีคำสั่ง `flutter` บน PATH แต่ได้สร้าง unit test สำหรับ `AngleZone.fromDegrees` เพื่อให้ทีมสามารถรันในเครื่อง dev ได้
- Flow การหยุด/ถ่าย/เริ่ม stream ยึดตามข้อจำกัดของ Flutter camera plugin: ใช้ `ArScanCameraStreamController.stopStream()` ก่อน `takePicture()` และเรียก `startStream()` กลับหลังถ่าย

## Deviations from plan

- เพิ่ม notifier `isComplete` เพื่อให้ phase 10 ตรวจสอบสถานะ complete ได้สะดวกขึ้นนอกเหนือจากการดู `capturedCount` เพียงอย่างเดียว
- auto-capture ใช้ periodic timer check (100ms) แทนการผูก logic ไว้กับ callback ของ stream โดยตรง เพื่อแยก concern และลด coupling กับ detection pipeline

## Self-Check: PASSED

- ไฟล์ model, sensor, controller และ test ถูกสร้างตาม path ที่ระบุและ git แสดง commit ล่าสุดสำหรับแผน 09-01 ครบทั้ง 3 รายการ

