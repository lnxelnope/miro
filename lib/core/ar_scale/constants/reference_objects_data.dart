import '../constants/ar_scale_enums.dart';
import '../models/reference_object.dart';

/// ฐานข้อมูลขนาดจริง (ซม.) ของวัตถุอ้างอิงมาตรฐาน
/// ที่มา: ISO 7810 (credit card), ขนาดช้อนส้อมมาตรฐาน, เหรียญกษาปณ์ไทย
class ReferenceObjectsData {
  ReferenceObjectsData._();

  static const Map<ReferenceObjectType, ReferenceObjectSpec> specs = {
    // ──── บัตร ────
    ReferenceObjectType.creditCard: ReferenceObjectSpec(
      type: ReferenceObjectType.creditCard,
      lengthCm: 8.56,
      widthCm: 5.398,
      description: 'ISO/IEC 7810 ID-1 standard (credit card, debit card, ID card)',
    ),

    // ──── ช้อนส้อม ────
    ReferenceObjectType.diningFork: ReferenceObjectSpec(
      type: ReferenceObjectType.diningFork,
      lengthCm: 19.5,
      widthCm: 2.5,
      description: 'Standard dining fork (table fork)',
    ),
    ReferenceObjectType.saladFork: ReferenceObjectSpec(
      type: ReferenceObjectType.saladFork,
      lengthCm: 15.5,
      widthCm: 2.3,
      description: 'Salad fork / dessert fork',
    ),
    ReferenceObjectType.tablespoon: ReferenceObjectSpec(
      type: ReferenceObjectType.tablespoon,
      lengthCm: 17.0,
      widthCm: 4.0,
      description: 'Standard tablespoon',
    ),
    ReferenceObjectType.teaspoon: ReferenceObjectSpec(
      type: ReferenceObjectType.teaspoon,
      lengthCm: 13.0,
      widthCm: 3.0,
      description: 'Standard teaspoon',
    ),
    ReferenceObjectType.diningKnife: ReferenceObjectSpec(
      type: ReferenceObjectType.diningKnife,
      lengthCm: 22.0,
      widthCm: 2.0,
      description: 'Standard dining knife (table knife)',
    ),
    ReferenceObjectType.chopsticks: ReferenceObjectSpec(
      type: ReferenceObjectType.chopsticks,
      lengthCm: 23.0,
      widthCm: 0.7,
      description: 'Standard chopsticks',
    ),

    // ──── เหรียญไทย ────
    ReferenceObjectType.coin10Baht: ReferenceObjectSpec(
      type: ReferenceObjectType.coin10Baht,
      lengthCm: 2.6,
      widthCm: 2.6,
      description: 'Thai 10 Baht coin (diameter 26mm)',
    ),
    ReferenceObjectType.coin5Baht: ReferenceObjectSpec(
      type: ReferenceObjectType.coin5Baht,
      lengthCm: 2.4,
      widthCm: 2.4,
      description: 'Thai 5 Baht coin (diameter 24mm)',
    ),
    ReferenceObjectType.coin1Baht: ReferenceObjectSpec(
      type: ReferenceObjectType.coin1Baht,
      lengthCm: 2.0,
      widthCm: 2.0,
      description: 'Thai 1 Baht coin (diameter 20mm)',
    ),

    // ──── อื่นๆ ────
    ReferenceObjectType.smartphoneStandard: ReferenceObjectSpec(
      type: ReferenceObjectType.smartphoneStandard,
      lengthCm: 15.0,
      widthCm: 7.2,
      description: 'Average smartphone (~6.1" display)',
    ),
    ReferenceObjectType.hand: ReferenceObjectSpec(
      type: ReferenceObjectType.hand,
      lengthCm: 18.5,
      widthCm: 8.5,
      description: 'Average adult hand (wrist to middle finger tip)',
    ),
  };

  /// ดึง spec ของวัตถุอ้างอิง (return null ถ้าไม่เจอ)
  static ReferenceObjectSpec? getSpec(ReferenceObjectType type) => specs[type];

  /// ดึงความยาว (ซม.) ของวัตถุอ้างอิง
  static double getLengthCm(ReferenceObjectType type) =>
      specs[type]?.lengthCm ?? 0;

  /// ดึงความกว้าง (ซม.) ของวัตถุอ้างอิง
  static double getWidthCm(ReferenceObjectType type) =>
      specs[type]?.widthCm ?? 0;

  /// Confidence thresholds
  static const double highConfidenceThreshold = 0.85;
  static const double mediumConfidenceThreshold = 0.65;

  /// Max time between frames for ML Kit processing (ms)
  static const int frameProcessingIntervalMs = 200;

  /// ขนาดจานมาตรฐาน (ซม.) สำหรับ fallback
  static const double standardPlateDiameterCm = 26.0;
  static const double standardBowlDiameterCm = 16.0;

  /// ความลึกเฉลี่ยของจาน/ชาม (ซม.) สำหรับประมาณปริมาตร
  static const double averagePlateDepthCm = 2.5;
  static const double averageBowlDepthCm = 7.0;
}
