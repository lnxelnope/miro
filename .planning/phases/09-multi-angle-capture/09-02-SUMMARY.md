# Phase 09 Plan 02: Multi-angle capture overlay & feedback Summary

## One-liner

UI overlay สำหรับ multi-angle capture: arc gauge แสดงมุมกล้อง, progress dots 0/3→3/3, capture confirmation พร้อม haptic/เสียง/animation feedback, และ manual shutter button

## What was implemented

- สร้าง `AngleGaugeWidget` — CustomPainter arc indicator แสดงมุมปัจจุบัน + target zone highlight พร้อมข้อความแนะนำทิศ (Tilt down/up/Hold steady)
- สร้าง `MultiAngleCaptureOverlay` — widget รวมที่ประกอบ gauge, progress dots (T/D/S), capture confirmation text (fade in/out), และ manual shutter button
- เพิ่ม haptic feedback (`HapticFeedback.lightImpact`) + เสียง (`SystemSound.play(click)`) + scale animation (1.0→1.3→1.0) เมื่อ capture สำเร็จ
- ประกอบ `MultiAngleCaptureOverlay` เข้า ARscan screen Stack layer ระหว่าง bounding box overlay กับ settings overlay
- สร้าง `DeviceAngleSensor` และ `MultiAngleCaptureController` ใน `_ARscanScreenState.initState` พร้อม dispose ครบ lifecycle
- เพิ่ม i18n strings (EN/TH) สำหรับ angle names, progress format, capture confirmation message

## Key files

- `lib/features/arscan/presentation/widgets/angle_gauge_widget.dart` (NEW)
- `lib/features/arscan/presentation/widgets/multi_angle_capture_overlay.dart` (NEW)
- `lib/features/arscan/presentation/arscan_screen.dart` (MODIFIED — added controller init + overlay widget)
- `lib/l10n/app_en.arb` (MODIFIED — added 6 new keys)
- `lib/l10n/app_th.arb` (MODIFIED — added 6 new keys)

## Behavior details

- **AngleGaugeWidget**: แสดง half-arc (180°) ที่ top-center ของจอ, background arc สีเทา, target zone highlight (เหลืองเมื่อยังไม่ตรง, เขียวเมื่อตรง), indicator dot ขาว/เขียวตามสถานะ
- **Progress dots**: 3 วงกลม (T=Top, D=Diagonal, S=Side) แสดงทางขวาของจอ — captured=เขียว+check, target=เหลือง+pulse, pending=เทา
- **Capture confirmation**: ข้อความ "Top angle captured (1/3)" ใน badge เขียว fade in/stay 1.5s/fade out ตำแหน่ง bottom-center เหนือ safe area
- **Manual shutter**: ปุ่มกลม 56px สีขาวโปร่ง + camera icon, disabled เมื่อ isCapturing, ซ่อนเมื่อ isComplete
- **Feedback**: ทุก capture → haptic light + system click sound + dot scale animation 300ms

## Verification notes

- ไม่สามารถรัน `flutter test` ใน environment นี้ แต่ linter ผ่านทุกไฟล์
- overlay ใช้ `IgnorePointer` โดย implicit — เฉพาะ manual shutter ที่รับ GestureDetector tap, ส่วน gauge/progress เป็น non-interactive
- ValueListenableBuilder ซ้อนกันหลายชั้นเพื่อ listen state แต่ละตัวจาก controller อย่างแยกส่วน

## Deviations from plan

- ไม่ได้ใช้ pulse animation แยกสำหรับ target dot (ใช้ AnimatedContainer + สี highlight แทน เพราะ single TickerProvider มี dot scale animation อยู่แล้ว)
- direction text ใช้ภาษาอังกฤษ ("Tilt down"/"Hold steady"/"Tilt up") เนื่องจากเป็น overlay บนกล้อง ข้อความสั้นเข้าใจง่ายทั้งสอง locale

## Self-Check: PASSED

- ไฟล์ใหม่ 2 ไฟล์ + ไฟล์แก้ไข 3 ไฟล์ตรงตาม plan
- linter errors = 0
- i18n keys ครบ EN/TH
- ARscan screen Stack: CameraPreview → BoundingBox → MultiAngleCaptureOverlay → TopBar → BottomBar → Settings overlay
