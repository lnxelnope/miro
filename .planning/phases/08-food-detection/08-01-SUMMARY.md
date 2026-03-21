---
phase: 08-food-detection
plan: 01
subsystem: arscan-detection
tags: [mlkit, object-detection, camera-stream]
provides:
  - ArScanDetection data model for ARscan pipeline
  - On-device ML Kit ObjectDetector service for camera frames
  - Camera stream controller integration exposing detection state and primary box
affects: [07-camera-stream, 09-multi-angle-capture, 10-review-pipeline]
tech-stack:
  added: [google_mlkit_object_detection]
  patterns: [on-device-ml, value-notifier-state, throttled-detection]
key-files:
  created:
    - lib/features/arscan/domain/models/ar_scan_detection.dart
    - lib/features/arscan/application/arscan_detection_service.dart
  modified:
    - lib/features/arscan/application/camera_stream_controller.dart
key-decisions:
  - "ใช้ ML Kit base ObjectDetector (DetectionMode.stream) แบบ on-device เท่านั้นสำหรับ v2.0"
  - "ให้ controller ดูแล stableFrameCount ของ primary box แทนที่จะซ้อน logic ใน service"
duration: TBD
completed: 2026-03-16
---

# Phase 8: Food Detection — Plan 01 Summary

**เพิ่ม detection layer สำหรับ ARscan ด้วย ML Kit ObjectDetector บน camera stream พร้อม state machine พื้นฐานสำหรับ UI ถัดไป**

## Performance
- **Duration:** TBD
- **Tasks:** 4 completed
- **Files modified:** 3

## Accomplishments
- สร้าง `ArScanDetection` data model พร้อมฟิลด์ตาม spec และ enum `ArScanState` สำหรับสถานะ ARscan
- เพิ่ม `ArScanDetectionService` ที่ใช้ ML Kit ObjectDetector (stream mode) ประมวลผล `CameraImage` → `List<ArScanDetection>` แบบ on-device พร้อม throttle ~250ms
- เชื่อม `ArScanCameraStreamController` กับ detection service และ expose `ValueNotifier<ArScanState>` + `ValueNotifier<ArScanDetection?>` สำหรับ primary box พร้อม logic stableFrameCount

## Task Commits
1. **Task 1: สร้าง ArScanDetection data model** - `9b33852`
2. **Task 2–3: food class mapping + ArScanDetectionService** - `6775da7`
3. **Task 4: เชื่อม detection service เข้ากับ camera_stream_controller** - `480edd6`

## Files Created/Modified
- `lib/features/arscan/domain/models/ar_scan_detection.dart` - data class `ArScanDetection` และ enum `ArScanState` สำหรับผลลัพธ์ detection และ state ของ ARscan
- `lib/features/arscan/application/arscan_detection_service.dart` - service ที่ wrap ML Kit `ObjectDetector` (DetectionMode.stream) สำหรับ `CameraImage` พร้อม food label mapping, primary box selection, และ throttle
- `lib/features/arscan/application/camera_stream_controller.dart` - เพิ่มการเรียกใช้ `ArScanDetectionService` ใน image stream และ expose detection state/primary detection ผ่าน `ValueNotifier`

## Decisions & Deviations
- ใช้ ML Kit base model (`ObjectDetectorOptions`) แบบ on-device เท่านั้นตาม roadmap (ไม่มี cloud call)
- ให้ controller เป็นผู้จัดการ `stableFrameCount` ของ primary detection โดยอาศัย `trackingId` เดิมต่อเนื่อง ≥ 5 เฟรม → map เป็น `ArScanState.readyForCapture`
- การทดสอบอยู่ในระดับ dev-log/behavior (ยังไม่เพิ่ม unit test แยกสำหรับ service ในแผนนี้)

## Next Phase Readiness
- UI overlay (Plan 08-02) สามารถ subscribe `detectionState` และ `primaryDetection` จาก `ArScanCameraStreamController` ได้ทันทีเพื่อนำไปวาด bounding box
- Phase 9 (multi-angle capture) สามารถใช้ `ArScanDetection` model เดียวกันสำหรับ state/primary box ข้ามมุมกล้อง และต่อยอดจาก normalizedRect (0–1) เพื่อ mapping กับ preview

