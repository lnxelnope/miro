# Junior Tasks — AR Scale Ruler System

> **สำหรับ:** Junior Developer  
> **ประเภท:** สร้างไฟล์ใหม่ + แก้ไฟล์เดิมตาม spec  
> **ความยาก:** ง่าย, มี step-by-step ทุกขั้น, copy-paste ได้  
> **อัปเดตล่าสุด:** 1 มี.ค. 2026

---

## 📊 สถานะ

```
งาน Junior ทั้งหมดถูกสร้างไว้แล้วโดย Senior
Junior ต้องตรวจสอบ + ทำงานที่เหลือตาม checklist ด้านล่าง
```

### สิ่งที่ Senior สร้างไว้แล้ว ✅

| ไฟล์ | สถานะ |
|------|--------|
| `lib/core/ar_scale/constants/ar_scale_enums.dart` | ✅ สร้างแล้ว |
| `lib/core/ar_scale/constants/reference_objects_data.dart` | ✅ สร้างแล้ว |
| `lib/core/ar_scale/models/bounding_box_data.dart` | ✅ สร้างแล้ว |
| `lib/core/ar_scale/models/reference_object.dart` | ✅ สร้างแล้ว |
| `lib/core/ar_scale/models/calibration_result.dart` | ✅ สร้างแล้ว |
| `lib/core/ar_scale/widgets/calibration_badge.dart` | ✅ สร้างแล้ว |
| `lib/core/ar_scale/widgets/reference_guide_tip.dart` | ✅ สร้างแล้ว |
| `lib/core/ar_scale/widgets/ar_ruler_overlay.dart` | ✅ สร้างแล้ว |
| `lib/core/ar_scale/widgets/reference_object_indicator.dart` | ✅ สร้างแล้ว |
| `lib/core/ar_scale/services/scale_calibration_service.dart` | ✅ Shell (TODO สำหรับ Senior) |
| `lib/core/ar_scale/services/reference_detector_service.dart` | ✅ Shell (TODO สำหรับ Senior) |
| `lib/core/ar_scale/services/camera_frame_processor.dart` | ✅ Shell (TODO สำหรับ Senior) |
| `FoodAnalysisResult` ใน `gemini_service.dart` | ✅ เพิ่ม fields แล้ว |
| `FoodEntry` ใน `food_entry.dart` | ✅ เพิ่ม fields แล้ว |
| `pubspec.yaml` | ✅ เพิ่ม `google_mlkit_object_detection` แล้ว |

---

## 🔧 งานที่ Junior ต้องทำ

### J1. Regenerate Isar Schema (สำคัญมาก!)

เนื่องจากเพิ่ม fields ใหม่ใน `FoodEntry` ต้อง regenerate Isar:

```bash
# ที่ root ของโปรเจกต์
dart run build_runner build --delete-conflicting-outputs
```

**ตรวจสอบ:** ไฟล์ `food_entry.g.dart` ต้องถูก regenerate

---

### J2. เพิ่ม CalibrationBadge ใน food_timeline_card.dart

**ไฟล์:** `lib/features/health/widgets/food_timeline_card.dart`

**ตำแหน่ง:** หลัง food name (ต่อจาก Text ที่แสดงชื่ออาหาร)

**เพิ่ม import:**
```dart
import 'package:miro_hybrid/core/ar_scale/widgets/calibration_badge.dart';
import 'package:miro_hybrid/core/ar_scale/constants/ar_scale_enums.dart';
```

**เพิ่ม widget:** หลัง food name text
```dart
// ถ้า entry มี calibration → แสดง badge
if (entry.isCalibrated) ...[
  const SizedBox(width: 4),
  CalibrationBadge(
    tier: entry.referenceConfidence != null && entry.referenceConfidence! >= 0.85
        ? CalibrationTier.high
        : CalibrationTier.medium,
    plateDiameterCm: entry.plateDiameterCm,
    compact: true,
  ),
],
```

---

### J3. เพิ่ม ReferenceGuideTip ใน image_analysis_preview_screen.dart

**ไฟล์:** `lib/features/health/presentation/image_analysis_preview_screen.dart`

**ตำแหน่ง:** ใต้รูป preview (หลัง Image widget)

**เพิ่ม import:**
```dart
import 'package:miro_hybrid/core/ar_scale/widgets/reference_guide_tip.dart';
```

**เพิ่ม widget:** ใต้รูป preview
```dart
// แสดง tip ให้วางช้อนข้างจาน
if (_currentImageFile != null) ...[
  const SizedBox(height: 8),
  const ReferenceGuideTip(compact: true),
],
```

---

### J4. เพิ่ม CameraReferenceGuideTip ใน camera_screen.dart

**ไฟล์:** `lib/features/camera/presentation/camera_screen.dart`

**ตำแหน่ง:** ใน Stack, ระหว่าง Top Bar กับ Bottom Controls

**เพิ่ม import:**
```dart
import 'package:miro_hybrid/core/ar_scale/widgets/reference_guide_tip.dart';
```

**เพิ่ม widget:** ใน Stack ก่อน Bottom Controls
```dart
// AR Scale tip
Positioned(
  bottom: 140,
  left: 0,
  right: 0,
  child: Center(
    child: CameraReferenceGuideTip(),
  ),
),
```

---

### J5. เพิ่ม CalibrationBadge ใน gemini_analysis_sheet.dart

**ไฟล์:** `lib/features/health/widgets/gemini_analysis_sheet.dart`

**ตำแหน่ง:** หาที่แสดง food name → เพิ่ม badge ข้างๆ

**เพิ่ม import:**
```dart
import 'package:miro_hybrid/core/ar_scale/widgets/calibration_badge.dart';
import 'package:miro_hybrid/core/ar_scale/constants/ar_scale_enums.dart';
```

**เพิ่ม widget:** ข้าง food name
```dart
// แสดง calibration badge ถ้า AI ตรวจจับ reference object ได้
if (result.isCalibrated) ...[
  const SizedBox(width: 6),
  CalibrationBadge(
    tier: (result.referenceConfidence ?? 0) >= 0.85
        ? CalibrationTier.high
        : CalibrationTier.medium,
    plateDiameterCm: result.plateDiameterCm,
  ),
],
```

---

### J6. เพิ่ม Calibration fields ใน applyResultToEntry

**ไฟล์:** หาฟังก์ชันที่ apply `FoodAnalysisResult` ลง `FoodEntry`  
(อาจอยู่ใน `health_provider.dart` หรือ `batch_analysis_helper.dart`)

**หา pattern นี้:** จะมีจุดที่ set ค่า entry จาก result เช่น:
```dart
entry.calories = result.nutrition.calories;
entry.protein = result.nutrition.protein;
// ... etc
```

**เพิ่มต่อท้าย:**
```dart
// AR Scale calibration data
entry.referenceObjectUsed = result.referenceObjectUsed;
entry.referenceConfidence = result.referenceConfidence;
entry.plateDiameterCm = result.plateDiameterCm;
entry.estimatedVolumeMl = result.estimatedVolumeMl;
entry.isCalibrated = result.isCalibrated;
```

---

### J7. Export barrel file

**สร้างไฟล์ใหม่:** `lib/core/ar_scale/ar_scale.dart`

```dart
// AR Scale Ruler System — Barrel Export
export 'constants/ar_scale_enums.dart';
export 'constants/reference_objects_data.dart';
export 'models/bounding_box_data.dart';
export 'models/reference_object.dart';
export 'models/calibration_result.dart';
export 'widgets/calibration_badge.dart';
export 'widgets/reference_guide_tip.dart';
export 'widgets/ar_ruler_overlay.dart';
export 'widgets/reference_object_indicator.dart';
export 'services/scale_calibration_service.dart';
export 'services/reference_detector_service.dart';
export 'services/camera_frame_processor.dart';
```

---

## ✅ Checklist

เสร็จแล้ว check ✅ ได้เลย:

- [ ] J1: `dart run build_runner build` สำหรับ Isar schema
- [ ] J2: เพิ่ม `CalibrationBadge` ใน `food_timeline_card.dart`
- [ ] J3: เพิ่ม `ReferenceGuideTip` ใน `image_analysis_preview_screen.dart`
- [ ] J4: เพิ่ม `CameraReferenceGuideTip` ใน `camera_screen.dart`
- [ ] J5: เพิ่ม `CalibrationBadge` ใน `gemini_analysis_sheet.dart`
- [ ] J6: เพิ่ม calibration fields ใน `applyResultToEntry`
- [ ] J7: สร้าง barrel export file
- [ ] Build test: `flutter analyze` ต้องไม่มี error ใหม่
- [ ] Run: app ต้องเปิดได้ปกติ (calibration ยังไม่ทำงาน แค่มี UI เตรียมไว้)

---

## ⚠️ สิ่งที่ Junior ห้ามทำ (Senior จะทำเอง)

1. ❌ **ห้ามแก้ไข** service files ที่มี `TODO: [SENIOR]`
2. ❌ **ห้ามแก้** Gemini prompts ใน `gemini_service.dart`
3. ❌ **ห้ามเพิ่ม** `startImageStream` ใน `camera_screen.dart`
4. ❌ **ห้ามแก้** `batch_analysis_helper.dart` logic
5. ❌ **ห้ามสร้าง** Riverpod providers ใน `ar_scale/providers/`

---

## 📝 หมายเหตุ

- ไฟล์ทุกตัวที่ Senior สร้างไว้ **compile ได้** แต่ service จะ return null/empty เพราะยังไม่ implement logic
- Widget ทุกตัว **แสดงผลได้** แค่ยังไม่มี data จริง (แสดง empty/placeholder)
- หลัง Junior ทำ J1-J7 เสร็จ → แจ้ง Senior มาตรวจ + implement logic
