import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../domain/models/angle_zone.dart';

/// Wrapper สำหรับอ่านมุมกล้องจาก accelerometer แล้ว map เป็น AngleZone
class DeviceAngleSensor {
  DeviceAngleSensor({
    double smoothingFactor = 0.2,
  }) : _smoothingFactor = smoothingFactor {
    _subscription = accelerometerEvents.listen(_onEvent);
  }

  final double _smoothingFactor;

  StreamSubscription<AccelerometerEvent>? _subscription;
  double _smoothedAngle = 0;

  /// มุมกล้องปัจจุบัน (0-90 องศา)
  final ValueNotifier<double> currentAngle = ValueNotifier<double>(0);

  /// Zone ปัจจุบันของมุมกล้อง
  final ValueNotifier<AngleZone> currentZone =
      ValueNotifier<AngleZone>(AngleZone.outOfRange);

  AngleZone _lastStableZone = AngleZone.outOfRange;
  DateTime? _zoneEnteredAt;

  void _onEvent(AccelerometerEvent event) {
    final x = event.x;
    final y = event.y;
    final z = event.z;

    // pitch = มุมระหว่างแนวตั้งกับกล้อง (0° = มองลงตรง, 90° = มองตรงหน้า)
    final pitch =
        math.atan2(y, math.sqrt(x * x + z * z)) * (180 / math.pi);
    final rawAngle = (90 - pitch.abs()).clamp(0.0, 90.0);

    _smoothedAngle = _smoothedAngle * (1 - _smoothingFactor) +
        rawAngle * _smoothingFactor;

    final angle = _smoothedAngle.clamp(0.0, 90.0);
    currentAngle.value = angle;

    final zone = AngleZoneHelper.fromDegrees(angle);

    if (zone != currentZone.value) {
      currentZone.value = zone;
      _lastStableZone = zone;
      _zoneEnteredAt = DateTime.now();
    } else {
      _lastStableZone = zone;
      _zoneEnteredAt ??= DateTime.now();
    }
  }

  /// ตรวจว่ามุมอยู่ใน zone ที่กำหนดนานพอหรือยัง
  bool isStableInZone(AngleZone zone, Duration requiredDuration) {
    if (_lastStableZone != zone) return false;
    final enteredAt = _zoneEnteredAt;
    if (enteredAt == null) return false;
    return DateTime.now().difference(enteredAt) >= requiredDuration;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    currentAngle.dispose();
    currentZone.dispose();
  }
}

