---
phase: 08-food-detection
plan: 02
subsystem: arscan-overlay
tags: [mlkit, object-detection, camera-stream, custom-painter, overlay]

# Dependency graph
requires:
  - phase: 08-food-detection
    provides: detection state + primary box from 08-01
provides:
  - Real-time bounding box overlay for ARscan camera preview
  - Coordinate mapping that matches BoxFit.cover across devices
affects: [09-multi-angle-capture, 10-review-pipeline]

# Tech tracking
tech-stack:
  added: []
  patterns: [custom-painter-overlay, value-notifier-ui-binding]

key-files:
  created:
    - lib/features/arscan/presentation/widgets/arscan_bounding_box_overlay.dart
  modified:
    - lib/features/arscan/presentation/arscan_screen.dart

key-decisions:
  - "ใช้ CustomPainter + SizedBox.expand + IgnorePointer สำหรับ overlay เพื่อลด hit test และควบคุม render ชัดเจนบนกล้อง"
  - "ผูก overlay กับ ValueNotifier จาก ArScanCameraStreamController โดยใช้ ValueListenableBuilder ซ้อนสองชั้นแทน Riverpod provider เพื่อให้ latency ต่ำสุด"
  - "คำนวณ mapping จาก normalizedRect → หน้าจอให้สอดคล้องกับ FittedBox(BoxFit.cover) โดยใช้ previewSize จาก CameraController"

patterns-established:
  - "ARscan overlay ใช้ normalized rect (0–1) + previewSize เพื่อแปลงเป็นพิกัดหน้าจอเมื่อกล้องถูกครอบภาพ (cover)"

requirements-completed: [ARSCAN-01]

# Metrics
duration: TBD
completed: 2026-03-16
---

# Phase 8: Food Detection — Plan 02 Summary

**เพิ่ม ARscan bounding box overlay แบบ CustomPainter ที่ผูกกับ detection state และ map พิกัดให้ตรงกับกล้องเมื่อใช้ BoxFit.cover ข้ามหลายอัตราส่วนหน้าจอ**

## Performance

- **Duration:** TBD
- **Started:** 2026-03-16T08:32:08Z
- **Completed:** 2026-03-16T08:32:08Z
- **Tasks:** 3 completed
- **Files modified:** 2

## Accomplishments

- สร้าง `ArScanBoundingBoxOverlay` ที่รับ `ArScanDetection?` และ `ArScanState` แล้ววาดกรอบสีเขียวมุมโค้งพร้อม label เหนือกล่องหลักของอาหารแบบ real-time
- แสดงข้อความสถานะกรณีไม่พบอาหาร (`state == ArScanState.searching`) เป็น banner ขนาดเล็กด้านล่างกลางจอโดยไม่บังเนื้อหากลางหน้าจอ
- ประกอบ overlay เข้า `ARscanScreen` ผ่าน `Stack` ชั้นบนสุด และผูกกับ `detectionState` + `primaryDetection` จาก `ArScanCameraStreamController`
- ปรับ logic mapping จาก `normalizedRect` (0–1) ให้คำนวณ scale/offset ตาม `previewSize` และ BoxFit.cover ทำให้ตำแหน่ง bounding box ตรงกับอาหารจริงบนหลายอัตราส่วนหน้าจอ

## Task Commits

1. **Task 1: สร้าง ArScanBoundingBoxOverlay widget ด้วย CustomPainter** - `1221cca` (feat)
2. **Task 2: ประกอบ overlay เข้ากับ ARscan screen Stack** - `a852719` (feat)
3. **Task 3: ตรวจ coordinate mapping บนหลายอุปกรณ์** - `d7dac5f` (feat)

## Files Created/Modified

- `lib/features/arscan/presentation/widgets/arscan_bounding_box_overlay.dart` - widget + CustomPainter สำหรับวาดกรอบสีเขียว, label และข้อความสถานะเมื่อไม่พบอาหาร โดยรองรับ mapping ตาม BoxFit.cover
- `lib/features/arscan/presentation/arscan_screen.dart` - เพิ่ม overlay ชั้นบนสุดของ Stack และผูกกับ `detectionState` / `primaryDetection` รวมถึงส่งต่อ `previewSize` เพื่อใช้คำนวณพิกัด

## Decisions Made

- ใช้ `IgnorePointer` + `RepaintBoundary` รอบ overlay เพื่อลดผลกระทบต่อ gesture/hit test และช่วยเรื่อง performance time-based repaint
- รักษา interface overlay ให้ผูกตรงกับ `ArScanCameraStreamController` ผ่าน `ValueNotifier` โดยไม่ใช้ provider เพิ่มเติม เพื่อลด overhead และให้โค้ดอ่านง่ายใน Phase 8
- ใช้ `previewSize.height` เป็นความกว้างเชิงภาพ และ `previewSize.width` เป็นความสูง (ตามการหมุนใน `CameraPreviewView`) เพื่อให้ mapping ตรงกับภาพที่ถูกหมุนและ scale ใน FittedBox

## Deviations from Plan

- ข้อความเมื่อไม่พบอาหารใช้ข้อความจากระบบ i18n ที่มีอยู่ (`noDataYet`) แทนการ hardcode `"Food not detect"` โดยตรง เพื่อให้สอดคล้องกับกฎ L10n ของโปรเจกต์ (ไม่มีผลต่อ logic overlay)
- ไม่ได้คัดลอกสีเขียวจาก module scanner โดยตรง แต่ใช้ `Colors.green` ตาม spec ในแผน 08-02 ซึ่งยังคงสอดคล้องกับ photo scan เดิมในเชิงโทนสี

## Issues Encountered

- คำสั่ง `gsd-tools summary` ไม่มีอยู่ใน CLI ปัจจุบัน จึงสร้าง `08-02-SUMMARY.md` ตาม template ด้วยมือแทนการใช้คำสั่งอัตโนมัติ
- Generator `app_localizations.dart` ยังไม่ได้ gen ใหม่ใน workspace นี้ จึงหลีกเลี่ยงการเรียกใช้ key ใหม่ (`arScanFoodNotDetected`) โดยใช้ key ที่มีอยู่แล้วในระบบแทน เพื่อไม่ให้เกิด compile/lint error

## User Setup Required

None - ใช้โค้ดและ dependency ที่มีอยู่แล้วใน Phase 7–8 ไม่มีการตั้งค่า service ภายนอกเพิ่ม

## Next Phase Readiness

- Phase 9 (multi-angle capture) สามารถ reuse overlay และ mapping เดียวกันสำหรับหลายมุมกล้อง โดยส่ง `previewSize` ตามกล้องที่ใช้งาน
- Phase 10 (review & pipeline) สามารถใช้ประสบการณ์ ARscan ที่เห็นกรอบอาหารแบบ real-time เป็น input สำหรับ flow ถ่ายรูปและวิเคราะห์ด้วย Gemini ต่อไป

---
*Phase: 08-food-detection*
*Completed: 2026-03-16*

