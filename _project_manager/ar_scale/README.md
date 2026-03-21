# AR Scale Ruler System

ระบบวัดขนาดอาหารจากวัตถุอ้างอิง (ช้อน, ส้อม, บัตรเครดิต)

## วิธีทำงาน

1. **Local AI** (ML Kit) ตรวจจับวัตถุอ้างอิง + ให้ bounding box ที่แม่นยำ
2. **Calibration Engine** คำนวณ pixel-to-cm ratio
3. **AR Overlay** วาดกรอบ + ไม้บรรทัดดิจิทัลบนรูป
4. **Gemini** ใช้ข้อมูล calibration ปรับ serving_grams ให้แม่นขึ้น

## Confidence Threshold

| Tier | Confidence | พฤติกรรม |
|------|-----------|---------|
| High | ≥ 85% | ใช้ calibration เต็มระบบ + overlay สีเขียว |
| Medium | 65-84% | ใช้ calibration + disclaimer + overlay สีเหลือง |
| Low | < 65% | ไม่ใช้ calibration, ส่ง Gemini ปกติ |
| None | ไม่พบ | ส่ง Gemini ปกติ + แสดง tip วางช้อน |

## Folder Structure

```
lib/core/ar_scale/
├── ar_scale.dart              # Barrel export
├── constants/
│   ├── ar_scale_enums.dart    # CalibrationTier, ReferenceObjectType
│   └── reference_objects_data.dart  # ขนาดจริง (ซม.) ของวัตถุ
├── models/
│   ├── bounding_box_data.dart # Bounding box model
│   ├── reference_object.dart  # Detected object + spec
│   └── calibration_result.dart # Calibration result
├── widgets/
│   ├── ar_ruler_overlay.dart  # CustomPainter overlay
│   ├── calibration_badge.dart # Status badge
│   ├── reference_guide_tip.dart # User tip widget
│   └── reference_object_indicator.dart # Live indicator
├── services/
│   ├── scale_calibration_service.dart  # [SENIOR] Calibration math
│   ├── reference_detector_service.dart # [SENIOR] ML Kit integration
│   └── camera_frame_processor.dart     # [SENIOR] Real-time processing
└── providers/
    └── (ว่าง — Senior จะสร้างภายหลัง)
```

## Implementation Order

1. **Junior ทำก่อน:** ดู `JUNIOR_TASKS.md`
2. **Senior ทำหลัง:** ดู `SENIOR_TASKS.md`
