import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider สำหรับจัดการ locale ของแอป
/// null = ใช้ภาษาของระบบ
/// Locale('th') = บังคับไทย
/// Locale('en') = บังคับอังกฤษ
final localeProvider = StateProvider<Locale?>((ref) => null);
