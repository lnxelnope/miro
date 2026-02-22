import 'package:flutter/material.dart';

abstract class AppSpacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 14.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
  static const double xxxxl = 64.0;

  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
}

abstract class AppSizes {
  static const double dragHandleWidth = 40.0;
  static const double dragHandleHeight = 4.0;
}

abstract class AppRadius {
  static final BorderRadius sm = BorderRadius.circular(6.0);
  static final BorderRadius md = BorderRadius.circular(10.0);
  static final BorderRadius lg = BorderRadius.circular(16.0);
  static final BorderRadius xl = BorderRadius.circular(24.0);
  static final BorderRadius pill = BorderRadius.circular(100.0);
}
