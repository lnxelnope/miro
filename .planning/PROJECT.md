# ArCal - AI Calorie Counter

## What This Is

ArCal (formerly Miro) is an offline-first AI calorie and nutrition tracking mobile app built with Flutter. Users log food intake via camera, gallery, barcode scanning, chat, or manual entry. The app uses local ML Kit for food detection and Gemini API for detailed nutritional analysis. It supports gamification (energy tokens), subscription/IAP, health platform integration (HealthKit/Health Connect), and multi-language (EN/TH/VI).

## Core Value

ผู้ใช้สามารถบันทึกแคลอรี่และสารอาหารได้อย่างแม่นยำและสะดวกที่สุด โดยใช้ AI ช่วยวิเคราะห์จากภาพถ่ายอาหาร

## Requirements

### Validated

<!-- Shipped and confirmed valuable (v1.0 - v1.2.2) -->

- ✓ Food entry tracking with calories and macronutrients — v1.0
- ✓ Camera capture for food analysis — v1.0
- ✓ Gallery image picker for food analysis — v1.0
- ✓ Gemini API integration for AI nutritional analysis — v1.0
- ✓ ML Kit local AI (image labeling, text recognition, barcode) — v1.0
- ✓ Barcode scanner for packaged food — v1.0
- ✓ My Meals (saved meal templates) — v1.0
- ✓ Ingredients database — v1.0
- ✓ Chat-based food logging — v1.0
- ✓ Retro scan (gallery auto-scan past 7 days) — v1.0
- ✓ User profile with TDEE/goal setting — v1.0
- ✓ Health timeline view — v1.0
- ✓ Multi-language support (EN/TH/VI) — v1.0
- ✓ Offline-first with Isar database — v1.0
- ✓ Energy gamification system — v1.1
- ✓ In-app purchase / subscription — v1.1
- ✓ Firebase Analytics — v1.2
- ✓ Health Connect / HealthKit integration — v1.2
- ✓ In-app review prompt — v1.2
- ✓ Google Ads integration — v1.2

### Active

<!-- Current scope: Milestone v2.0 -->

- [ ] Rename app display name to "ArCal - AI Calorie Counter"
- [ ] ARscan: Video-based food detection with real-time bounding boxes (local AI)
- [ ] ARscan: Auto-capture 3 optimal angles for portion estimation
- [ ] ARscan: On-screen guidance for camera positioning
- [ ] ARscan: Auto-send captured images for AI analysis (zero-tap flow)
- [ ] ARscan: Reset tracking when camera moves away from target food
- [ ] ARscan: Prominent button placement in navigation

### Out of Scope

- Real-time cloud streaming — Local AI only for bounding box, cloud API only for final analysis
- 3D food reconstruction — Too complex, multi-angle 2D analysis is sufficient
- Package name change — Existing installs must not break

## Context

- **Tech stack:** Flutter 3.x, Riverpod, Isar, ML Kit, Gemini API, Firebase
- **Current version:** 1.2.2+51 (published on App Store / Play Store)
- **Camera flow:** CameraScreen → ImageAnalysisPreviewScreen → Gemini analysis
- **ML Kit usage:** VisionProcessor for image labeling (food detection), text recognition, barcode scanning
- **App naming:** Android label "MIRO", iOS "Miro Hybrid", package "miro_hybrid"
- **Reason for rename:** "Miro" conflicts with a major established product (Miro whiteboard)

## Constraints

- **Package name**: Must remain `miro_hybrid` — changing would break existing installs and store listings
- **Offline-first**: Core food tracking must work without internet
- **Local AI for bounding box**: Real-time detection must use on-device ML (ML Kit or TFLite), not cloud API
- **Flutter**: Must stay within Flutter ecosystem
- **Gemini API**: Final nutritional analysis uses Gemini (user BYOK model)

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Rename to ArCal | Avoid trademark conflict with Miro (whiteboard app) | — Pending |
| ARscan replaces basic camera | Multi-angle capture improves portion estimation accuracy | — Pending |
| Local AI for real-time detection | Cloud API too slow for real-time bounding box overlay | — Pending |
| 3 angles for portion estimation | Research suggests multi-view improves volume estimation | — Pending |

---
*Last updated: 2026-03-16 after milestone v2.0 initialization*
