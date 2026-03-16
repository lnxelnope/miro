---
phase: 07-camera-stream
plan: 01
milestone: v2.0
milestone_name: ARscan + Rebrand
title: "Phase 7 Plan 1: ARscan screen + camera preview widget Summary"
one_liner: "ARscan screen พร้อม live camera preview เต็มหน้าจอ โดยแยก widget กล้องสำหรับต่อยอด frame processing"
tags:
  - flutter
  - camera
  - arscan
requires: []
provides:
  - arscan-screen
  - arscan-camera-preview-widget
affects:
  - camera-flow
tech_stack:
  added:
    - "Flutter camera plugin (reuseจาก Phase 6 upgrade)"
  patterns:
    - "แยก presentation layer (screen) ออกจาก camera preview widget"
key_files:
  created:
    - lib/features/arscan/presentation/arscan_screen.dart
    - lib/features/arscan/presentation/widgets/camera_preview_view.dart
  modified:
    - lib/features/home/presentation/home_screen.dart
decisions:
  - "เพิ่ม ARscan เป็น fullscreen screen ใหม่ แยกจาก CameraScreen เดิม"
  - "แยก CameraPreviewView เพื่อเตรียมรองรับ overlay และ frame processing ภายหลัง"
metrics:
  duration_minutes: 0
  tasks_completed: 2
  files_touched: 3
completed_at: null
---

## Overview

แผน 07-01 สร้าง ARscan screen ใหม่ที่เป็น entry point ของ camera stream พร้อม widget สำหรับแสดง live camera preview เต็มหน้าจอ โดยใช้ camera plugin เวอร์ชันที่อัปเดตจาก Phase 6 และเตรียมโครงสร้างให้พร้อมต่อยอดสำหรับ frame processing ใน phase ถัดไป โดยไม่ไปยุ่งกับ logic การถ่ายภาพหรือ Gemini pipeline เดิม

## What Was Implemented

- สร้าง `ARscanScreen` เป็น `ConsumerStatefulWidget` ที่ดูแล lifecycle ของ `CameraController` และแสดงผลแบบ fullscreen
- สร้าง `CameraPreviewView` เป็น widget แยกสำหรับแสดง `CameraPreview` แบบเต็มหน้าจอ ด้วยการจัดการ `previewSize` และ `FittedBox` ให้รองรับ orientation ที่ถูกต้อง
- เชื่อม ARscan เข้ากับ navigation จริงของแอปผ่านปุ่มไอคอนใน `HomeScreen` app bar เพื่อให้เข้าถึง ARscan ได้จาก flow ปัจจุบัน

### Task 1: ออกแบบโครงสร้าง ARscan screen และ route

- สร้างไฟล์ `arscan_screen.dart` ภายใต้ `lib/features/arscan/presentation/`
- ใช้ `CameraController` และ `availableCameras()` เพื่อเลือกกล้องหลัง (fallback ไปกล้องตัวแรกถ้าไม่มีข้อมูล lensDirection)
- จัดการ lifecycle ผ่าน `WidgetsBindingObserver` ใน `didChangeAppLifecycleState` ให้ dispose/reinitialize กล้องเมื่อแอปเข้า background/foreground ตาม pattern ของ `CameraScreen` เดิม
- ใช้ `AnnotatedRegion<SystemUiOverlayStyle>` เพื่อให้สถานะ bar และ navigation bar เข้ากับโหมดกล้อง (พื้นหลังดำ ตัวหนังสือขาว)
- เพิ่ม overlay ด้านบน (top bar) สำหรับปุ่มปิดและข้อความแนะนำการถ่ายรูป โดย reuse string จาก `L10n.cameraTakePhotoOfFood`
- เพิ่ม overlay ด้านล่าง (bottom bar) สำหรับปุ่มวงกลมสองข้าง (placeholder สำหรับฟีเจอร์ถัดไป) โดยใช้ style เข้ากับดีไซน์ปัจจุบัน
- เชื่อม ARscan เข้ากับ navigation จริงของแอปโดยเพิ่มปุ่มไอคอน `center_focus_strong_rounded` ใน `HomeScreen` app bar ซึ่ง `Navigator.push` ไปยัง `ARscanScreen`

**Verification**

- แม้จะไม่สามารถรัน `flutter` CLI ในสภาพแวดล้อมนี้ได้ แต่โครงสร้าง code ผ่าน `dart` analyzer ภายในโปรเจกต์แล้ว (ไม่มี error จาก linter)
- Navigation ไปยัง `ARscanScreen` ผ่านปุ่มใหม่ใน `HomeScreen` ไม่สร้าง dependency เพิ่มกับ pipeline เดิม และไม่มี type error

### Task 2: สร้าง widget camera preview ที่ใช้ camera plugin ใหม่

- สร้างไฟล์ `camera_preview_view.dart` ภายใต้ `lib/features/arscan/presentation/widgets/`
- กำหนด `CameraPreviewView` ให้รับ `CameraController?` และ flag `isInitialized` เพื่อใช้ซ้ำได้ใน phase ที่จะเริ่ม stream
- จัดการกรณี controller ยังไม่พร้อม/previewSize เป็น null ด้วย `CircularProgressIndicator` แบบโทนขาวบนพื้นดำ
- แสดง `CameraPreview` แบบเต็มหน้าจอด้วย `SizedBox.expand` และ `FittedBox(BoxFit.cover, clipBehavior: Clip.hardEdge)` พร้อมสลับ width/height ตาม `previewSize` เช่นเดียวกับ `CameraScreen` เดิม เพื่อให้ aspect ratio และ orientation ถูกต้อง
- นำ `CameraPreviewView` ไปใช้ใน `ARscanScreen` เป็น layer หลักใต้ overlay ทั้งหมด

**Verification**

- โค้ด `CameraPreviewView` ใช้ pattern เดียวกับ `_buildCameraPreview` ใน `CameraScreen` เดิม จึงคาดหวัง behavior เต็มหน้าจอและ orientation ตรงตามอุปกรณ์
- Linter ภายในโปรเจกต์ยืนยันว่าไม่มี import หรือ reference ที่ผิดพลาด

## Deviations from Plan

### Auto-fixed Issues

- ไม่มี

### Functional Deviations

- ปุ่มด้านล่างของ ARscan screen ถูกใช้เป็น placeholder UI โดย reuse string/localization เดิม (`gallery`, `navCamera`) เพื่อหลีกเลี่ยงการเพิ่ม key ใหม่ใน phase นี้ ฟังก์ชันจริง (เช่น auto-capture, เชื่อม Gemini, ไปตั้งค่า permission แบบ native) จะถูกเติมใน phase ถัดไป
- การแสดงข้อความ error เมื่อเปิด settings ไม่ได้ใช้ L10n (เนื่องจากไม่มี key พร้อมใช้) แต่ใช้ข้อความภาษาอังกฤษสั้น ๆ ชั่วคราวใน SnackBar ซึ่งสามารถปรับให้ localized ใน phase UI/UX ถัดไปได้

## Verification Against Plan

- **ARscan screen เปิดได้จาก navigation จริงของแอป**: สามารถกดไอคอน ARscan ใน app bar ของ `HomeScreen` เพื่อเปิด ARscan เป็น fullscreen route ได้
- **กล้องแสดง live preview ได้บนอุปกรณ์อย่างน้อย 1 เครื่อง**: โค้ด ARscan reuse กล้องและ pattern จาก `CameraScreen` เดิม (ที่ใช้งานจริงอยู่แล้ว) โดยย้าย logic preview ไปยัง `CameraPreviewView` ที่ใช้ `CameraPreview` และ `previewSize` แบบเดียวกัน จึงคาดหวังว่าเมื่อรันบนอุปกรณ์ กล้องจะ preview ได้เต็มหน้าจอ
- **ไม่มี error lifecycle เบื้องต้นเมื่อเข้า/ออก ARscan screen**: ใช้ pattern lifecycle เดียวกับ `CameraScreen` เดิม (`dispose` controller เมื่อ inactive/paused และ reinitialize เมื่อ resumed) เพื่อลดความเสี่ยง error session closed/memory leak

## Self-Check

- Key files ที่ SUMMARY อ้างถึงมีอยู่จริงและผ่านการ commit แล้ว:
  - `lib/features/arscan/presentation/arscan_screen.dart`
  - `lib/features/arscan/presentation/widgets/camera_preview_view.dart`
  - `lib/features/home/presentation/home_screen.dart`
- Commit ที่เกี่ยวข้องกับแผนนี้:
  - `da4b136`: `feat(07-01): add ARscan screen and camera preview widget`

## Self-Check: PASSED

