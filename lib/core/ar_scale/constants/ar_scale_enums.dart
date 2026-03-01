import 'package:flutter/material.dart';

/// Confidence tier ที่ตัดสินว่าจะใช้ calibration หรือไม่
enum CalibrationTier {
  high,   // ≥ 85% → ใช้เต็มระบบ
  medium, // 65-84% → ใช้แต่มี disclaimer
  low,    // < 65% → ไม่ใช้ ส่งไปธรรมดา
  none,   // ไม่พบวัตถุอ้างอิง
}

extension CalibrationTierExtension on CalibrationTier {
  String get displayName {
    switch (this) {
      case CalibrationTier.high:
        return 'Calibrated';
      case CalibrationTier.medium:
        return 'Estimated';
      case CalibrationTier.low:
        return 'Low Confidence';
      case CalibrationTier.none:
        return 'No Reference';
    }
  }

  IconData get icon {
    switch (this) {
      case CalibrationTier.high:
        return Icons.straighten_rounded;
      case CalibrationTier.medium:
        return Icons.straighten_rounded;
      case CalibrationTier.low:
        return Icons.help_outline_rounded;
      case CalibrationTier.none:
        return Icons.info_outline_rounded;
    }
  }

  Color get color {
    switch (this) {
      case CalibrationTier.high:
        return const Color(0xFF22C55E); // green-500
      case CalibrationTier.medium:
        return const Color(0xFFF59E0B); // amber-500
      case CalibrationTier.low:
        return const Color(0xFFEF4444); // red-500
      case CalibrationTier.none:
        return const Color(0xFF9CA3AF); // gray-400
    }
  }

  Color get backgroundColor {
    switch (this) {
      case CalibrationTier.high:
        return const Color(0xFFDCFCE7); // green-100
      case CalibrationTier.medium:
        return const Color(0xFFFEF3C7); // amber-100
      case CalibrationTier.low:
        return const Color(0xFFFEE2E2); // red-100
      case CalibrationTier.none:
        return const Color(0xFFF3F4F6); // gray-100
    }
  }

  bool get shouldUseCalibration =>
      this == CalibrationTier.high || this == CalibrationTier.medium;
}

/// ประเภทวัตถุอ้างอิงที่ระบบรองรับ
enum ReferenceObjectType {
  creditCard,
  diningFork,
  saladFork,
  tablespoon,
  teaspoon,
  diningKnife,
  chopsticks,
  coin10Baht,
  coin5Baht,
  coin1Baht,
  smartphoneStandard,
  hand,
}

extension ReferenceObjectTypeExtension on ReferenceObjectType {
  String get displayName {
    switch (this) {
      case ReferenceObjectType.creditCard:
        return 'Credit Card';
      case ReferenceObjectType.diningFork:
        return 'Dining Fork';
      case ReferenceObjectType.saladFork:
        return 'Salad Fork';
      case ReferenceObjectType.tablespoon:
        return 'Tablespoon';
      case ReferenceObjectType.teaspoon:
        return 'Teaspoon';
      case ReferenceObjectType.diningKnife:
        return 'Dining Knife';
      case ReferenceObjectType.chopsticks:
        return 'Chopsticks';
      case ReferenceObjectType.coin10Baht:
        return '10 Baht Coin';
      case ReferenceObjectType.coin5Baht:
        return '5 Baht Coin';
      case ReferenceObjectType.coin1Baht:
        return '1 Baht Coin';
      case ReferenceObjectType.smartphoneStandard:
        return 'Smartphone';
      case ReferenceObjectType.hand:
        return 'Hand';
    }
  }

  IconData get icon {
    switch (this) {
      case ReferenceObjectType.creditCard:
        return Icons.credit_card_rounded;
      case ReferenceObjectType.diningFork:
      case ReferenceObjectType.saladFork:
        return Icons.restaurant_rounded;
      case ReferenceObjectType.tablespoon:
      case ReferenceObjectType.teaspoon:
        return Icons.soup_kitchen_rounded;
      case ReferenceObjectType.diningKnife:
        return Icons.content_cut_rounded;
      case ReferenceObjectType.chopsticks:
        return Icons.set_meal_rounded;
      case ReferenceObjectType.coin10Baht:
      case ReferenceObjectType.coin5Baht:
      case ReferenceObjectType.coin1Baht:
        return Icons.monetization_on_rounded;
      case ReferenceObjectType.smartphoneStandard:
        return Icons.smartphone_rounded;
      case ReferenceObjectType.hand:
        return Icons.back_hand_rounded;
    }
  }

  /// ML Kit labels ที่จะ match กับ object type นี้
  /// COCO custom model (EfficientDet-Lite0) returns specific labels เช่น "fork", "knife", "spoon"
  /// Base model fallback returns generic labels เช่น "Home good"
  List<String> get mlKitLabels {
    switch (this) {
      case ReferenceObjectType.creditCard:
        return ['Credit card', 'Card', 'ID card', 'Home good'];
      case ReferenceObjectType.diningFork:
      case ReferenceObjectType.saladFork:
        return ['fork', 'Fork', 'Cutlery', 'Tableware', 'Home good'];
      case ReferenceObjectType.tablespoon:
      case ReferenceObjectType.teaspoon:
        return ['spoon', 'Spoon', 'Cutlery', 'Tableware', 'Home good'];
      case ReferenceObjectType.diningKnife:
        return ['knife', 'Knife', 'Cutlery', 'Tableware', 'Home good'];
      case ReferenceObjectType.chopsticks:
        return ['Chopsticks', 'Cutlery', 'Home good'];
      case ReferenceObjectType.coin10Baht:
      case ReferenceObjectType.coin5Baht:
      case ReferenceObjectType.coin1Baht:
        return ['Coin', 'Money', 'Home good'];
      case ReferenceObjectType.smartphoneStandard:
        return ['cell phone', 'Phone', 'Smartphone', 'Mobile phone', 'Home good'];
      case ReferenceObjectType.hand:
        return ['person', 'Hand', 'Person'];
    }
  }
}
