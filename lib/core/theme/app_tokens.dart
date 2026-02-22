import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// SPACING — ใช้แทน EdgeInsets ที่ใส่ตัวเลขตรงๆ
// ═══════════════════════════════════════════════════════════════
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 40;

  // Shortcut EdgeInsets ที่ใช้บ่อย
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

// ═══════════════════════════════════════════════════════════════
// RADIUS — ใช้แทน BorderRadius.circular(ตัวเลข)
// ═══════════════════════════════════════════════════════════════
class AppRadius {
  AppRadius._();

  static const double smValue = 8;
  static const double mdValue = 12;
  static const double lgValue = 16;
  static const double xlValue = 20;
  static const double xxlValue = 24;
  static const double pillValue = 999;

  static final BorderRadius sm = BorderRadius.circular(smValue);
  static final BorderRadius md = BorderRadius.circular(mdValue);
  static final BorderRadius lg = BorderRadius.circular(lgValue);
  static final BorderRadius xl = BorderRadius.circular(xlValue);
  static final BorderRadius xxl = BorderRadius.circular(xxlValue);
  static final BorderRadius pill = BorderRadius.circular(pillValue);

  // สำหรับ bottom sheet (โค้งแค่ด้านบน)
  static final BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(xlValue),
  );
}

// ═══════════════════════════════════════════════════════════════
// ELEVATION — ค่า elevation มาตรฐาน
// ═══════════════════════════════════════════════════════════════
class AppElevation {
  AppElevation._();

  static const double none = 0;
  static const double sm = 1;
  static const double md = 2;
  static const double lg = 4;
  static const double xl = 8;
}

// ═══════════════════════════════════════════════════════════════
// DURATIONS — animation durations
// ═══════════════════════════════════════════════════════════════
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration verySlow = Duration(milliseconds: 600);
}

// ═══════════════════════════════════════════════════════════════
// SIZES — ขนาดมาตรฐานสำหรับ component ต่างๆ
// ═══════════════════════════════════════════════════════════════
class AppSizes {
  AppSizes._();

  // Button heights
  static const double buttonSmall = 36;
  static const double buttonMedium = 48;
  static const double buttonLarge = 56;

  // Icon sizes
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;

  // Drag handle
  static const double dragHandleWidth = 40;
  static const double dragHandleHeight = 4;
}
