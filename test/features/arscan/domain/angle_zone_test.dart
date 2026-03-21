import 'package:flutter_test/flutter_test.dart';
import 'package:miro_hybrid/features/arscan/domain/models/angle_zone.dart';

void main() {
  group('AngleZone.fromDegrees', () {
    test('maps 0 degrees to top', () {
      expect(AngleZoneHelper.fromDegrees(0), AngleZone.top);
    });

    test('maps 45 degrees to diagonal', () {
      expect(AngleZoneHelper.fromDegrees(45), AngleZone.diagonal);
    });

    test('maps 70 degrees to side', () {
      expect(AngleZoneHelper.fromDegrees(70), AngleZone.side);
    });

    test('maps out of range degrees to outOfRange', () {
      expect(AngleZoneHelper.fromDegrees(-10), AngleZone.outOfRange);
      expect(AngleZoneHelper.fromDegrees(100), AngleZone.outOfRange);
    });
  });
}

