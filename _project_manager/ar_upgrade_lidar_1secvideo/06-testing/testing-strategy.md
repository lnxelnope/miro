# Testing Strategy & Quality Assurance

**File:** `06-testing/testing-strategy.md`  
**Last Updated:** March 11, 2026

---

## Overview

This document outlines a comprehensive testing strategy to validate the AR scanning system across different devices, food types, and environmental conditions. Testing ensures accuracy targets are met and identifies areas for improvement.

---

## 1. Unit Tests

### Frame Selection Algorithm Tests

```dart
// test/features/ar_scanner/frame_selector_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:miro/features/ar_scanner/frame_selector.dart';
import 'package:miro/features/ar_scanner/models/camera_frame.dart';

void main() {
  group('FrameSelector', () {
    late FrameSelector selector;
    
    setUp(() {
      selector = FrameSelector();
    });
    
    test('selects exactly 3 frames from 30 available', () {
      final mockFrames = List.generate(30, (index) => CameraFrame(
        index: index,
        timestamp: index / 30.0,
        brightness: 150 + index, // Varying brightness
        motionBlurScore: 0.2,    // Acceptable blur
      ));
      
      final selected = selector.selectFrames(mockFrames);
      
      expect(selected.length, equals(3));
    });
    
    test('filters out low-quality frames', () {
      final poorQualityFrame = CameraFrame(
        index: 5,
        timestamp: 0.17,
        brightness: 20, // Too dark (< 50 threshold)
        motionBlurScore: 0.8, // Excessive blur (> 0.3)
      );
      
      final validFrames = [poorQualityFrame];
      for (var i = 1; i < 30; i++) {
        validFrames.add(CameraFrame(
          index: i,
          timestamp: i / 30.0,
          brightness: 150, // Good lighting
          motionBlurScore: 0.2, // Acceptable blur
        ));
      }
      
      final selected = selector.selectFrames(validFrames);
      
      expect(selected.contains(5), isFalse, 
        reason: 'Poor quality frame should be filtered out');
    });
    
    test('selects one frame from each third of scan', () {
      // Create frames with known qualities in different thirds
      final firstThird = List.generate(10, (i) => CameraFrame(index: i, 
        brightness: 200 + i * 10, motionBlurScore: 0.1)); // Increasing quality
      
      final secondThird = List.generate(10, (i) => CameraFrame(index: 10 + i,
        brightness: 180 + i * 5, motionBlurScore: 0.2));
      
      final thirdThird = List.generate(10, (i) => CameraFrame(index: 20 + i,
        brightness: 160 - i * 5, motionBlurScore: 0.3)); // Decreasing quality
      
      final allFrames = [...firstThird, ...secondThird, ...thirdThird];
      
      final selected = selector.selectFrames(allFrames);
      
      // Verify selection spans across scan duration
      expect(selected.any((index) => index < 10), isTrue, 
        reason: 'Should select from first third');
      expect(selected.any((index) => index >= 10 && index < 20), isTrue,
        reason: 'Should select from second third');
      expect(selected.any((index) => index >= 20), isTrue,
        reason: 'Should select from third third');
    });
    
    test('handles edge case with only valid frames at beginning', () {
      final frames = List.generate(30, (i) {
        if (i < 5) {
          return CameraFrame(index: i, brightness: 200, motionBlurScore: 0.1);
        } else {
          return CameraFrame(index: i, brightness: 30, motionBlurScore: 0.8); // Invalid
        }
      });
      
      final selected = selector.selectFrames(frames);
      
      expect(selected.length, lessThanOrEqualTo(5)); // May select fewer than 3 if not enough valid
      
      for (var index in selected) {
        expect(index < 5, isTrue, 
          reason: 'All selected frames should be from first 5');
      }
    });
    
    test('returns fallback indices when no valid frames', () {
      final allInvalidFrames = List.generate(30, (i) => CameraFrame(
        index: i,
        brightness: 20, // Too dark
        motionBlurScore: 0.9, // Very blurry
      ));
      
      final selected = selector.selectFrames(allInvalidFrames);
      
      expect(selected.length, lessThanOrEqualTo(3));
    });
  });
}

// Mock CameraFrame class for testing
class CameraFrame {
  final int index;
  final double timestamp;
  final double brightness;
  final double motionBlurScore;
  
  const CameraFrame({required this.index, required this.timestamp, 
                     required this.brightness, required this.motionBlurScore});
}
```

### Depth Calculation Tests (LiDAR Mode)

```dart
// test/features/ar_scanner/lidar_depth_calculator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:miro/features/ar_scanner/lidar_depth_calculator.dart';
import 'package:miro/features/ar_scanner/models/mesh.dart';

void main() {
  group('LIDARDepthCalculator', () {
    late LIDARDepthCalculator calculator;
    
    setUp(() {
      calculator = LIDARDepthCalculator();
    });
    
    test('calculates volume of perfect sphere correctly', () {
      // Sphere with radius 2.5cm should have volume ≈ 65.45 cm³
      final sphereMesh = _generateSphereMesh(radius: 2.5, resolution: 100);
      
      final volume = calculator.calculateVolume(sphereMesh);
      
      expect(volume, closeTo(65.45, 3.0), // ±3cm³ tolerance for mesh approximation
        reason: 'Sphere volume calculation should be accurate');
    });
    
    test('calculates volume of perfect cube correctly', () {
      // Cube with side length 10cm should have volume = 1000 cm³
      final cubeMesh = _generateCubeMesh(sideLength: 10.0, resolution: 50);
      
      final volume = calculator.calculateVolume(cubeMesh);
      
      expect(volume, closeTo(1000.0, 25.0), // ±25cm³ tolerance
        reason: 'Cube volume calculation should be accurate');
    });
    
    test('calculates volume of cylinder correctly', () {
      // Cylinder with radius 3cm and height 10cm = π × r² × h ≈ 282.74 cm³
      final cylinderMesh = _generateCylinderMesh(
        radius: 3.0, 
        height: 10.0, 
        resolution: 50
      );
      
      final volume = calculator.calculateVolume(cylinderMesh);
      
      expect(volume, closeTo(282.74, 15.0), // ±15cm³ tolerance
        reason: 'Cylinder volume calculation should be accurate');
    });
    
    test('returns zero for empty mesh', () {
      final emptyMesh = Mesh(vertices: [], triangles: []);
      
      final volume = calculator.calculateVolume(emptyMesh);
      
      expect(volume, equals(0.0));
    });
    
    test('handles degenerate triangles gracefully', () {
      // Create mesh with some zero-area triangles (degenerate)
      final vertices = [
        Vector3(0, 0, 0),
        Vector3(1, 0, 0),
        Vector3(2, 0, 0), // Collinear points - degenerate triangle
        Vector3(0, 1, 0), // Valid point
      ];
      
      final triangles = [0, 1, 2]; // Degenerate
      
      final mesh = Mesh(vertices: vertices, triangles: triangles);
      
      expect(() => calculator.calculateVolume(mesh), returnsNormally,
        reason: 'Should handle degenerate triangles without crashing');
    });
    
    test('bounding box calculation is correct', () {
      final cubeMesh = _generateCubeMesh(sideLength: 10.0, resolution: 50);
      
      final boundingBox = calculator.calculateBoundingBox(cubeMesh);
      
      expect(boundingBox.width, closeTo(10.0, 0.2));
      expect(boundingBox.height, closeTo(10.0, 0.2));
      expect(boundingBox.depth, closeTo(10.0, 0.2));
    });
    
    test('confidence estimation reflects data quality', () {
      // High point density should yield higher confidence
      final highDensityMesh = _generateSphereMesh(radius: 5.0, resolution: 200);
      
      final lowDensityMesh = _generateSphereMesh(radius: 5.0, resolution: 20);
      
      final highConfidence = calculator.estimateConfidence(highDensityMesh);
      final lowConfidence = calculator.estimateConfidence(lowDensityMesh);
      
      expect(highConfidence, greaterThan(lowConfidence),
        reason: 'Higher point density should yield higher confidence');
    });
  });
}

// Helper functions to generate test meshes
class _TestMeshGenerator {
  
  static Mesh _generateSphereMesh({required double radius, required int resolution}) {
    // Simplified sphere mesh generation (actual implementation uses Marching Cubes)
    final vertices = <Vector3>[];
    final triangles = <int>[];
    
    for (var theta = 0; theta <= 180; theta += 180 ~/ resolution) {
      for (var phi = 0; phi < 360; phi += 360 ~/ resolution) {
        final radTheta = theta * pi / 180.0;
        final radPhi = phi * pi / 180.0;
        
        vertices.add(Vector3(
          radius * sin(radTheta) * cos(radPhi),
          radius * sin(radTheta) * sin(radPhi),
          radius * cos(radTheta),
        ));
      }
    }
    
    // Generate triangles (simplified - actual implementation more complex)
    for (var i = 0; i < vertices.length - 3; i += 2) {
      if (i + 2 < vertices.length) {
        triangles.addAll([i, i + 1, i + 2]);
      }
    }
    
    return Mesh(vertices: vertices, triangles: triangles);
  }
  
  static Mesh _generateCubeMesh({required double sideLength, required int resolution}) {
    // Generate cube mesh with specified side length
    final half = sideLength / 2.0;
    
    final vertices = <Vector3>[
      Vector3(-half, -half, -half),
      Vector3(half, -half, -half),
      Vector3(half, half, -half),
      Vector3(-half, half, -half),
      Vector3(-half, -half, half),
      Vector3(half, -half, half),
      Vector3(half, half, half),
      Vector3(-half, half, half),
    ];
    
    final triangles = [0, 1, 2, 0, 2, 3, // Back face
                       4, 5, 6, 4, 6, 7, // Front face
                       0, 1, 5, 0, 5, 4, // Bottom face
                       2, 3, 7, 2, 7, 6, // Top face
                       0, 3, 7, 0, 7, 4, // Left face
                       1, 2, 6, 1, 6, 5, // Right face
                      ];
    
    return Mesh(vertices: vertices, triangles: triangles);
  }
  
  static Mesh _generateCylinderMesh({required double radius, required double height, 
                                     required int resolution}) {
    // Simplified cylinder mesh generation
    final vertices = <Vector3>[];
    final triangles = <int>[];
    
    // Bottom circle
    for (var i = 0; i <= resolution; i++) {
      final angle = i * 2 * pi / resolution;
      vertices.add(Vector3(
        radius * cos(angle),
        -height / 2.0,
        radius * sin(angle),
      ));
    }
    
    // Top circle (offset by resolution + 1)
    for (var i = 0; i <= resolution; i++) {
      final angle = i * 2 * pi / resolution;
      vertices.add(Vector3(
        radius * cos(angle),
        height / 2.0,
        radius * sin(angle),
      ));
    }
    
    // Side triangles and caps (simplified)
    for (var i = 0; i < resolution; i++) {
      triangles.addAll([i, i + 1, resolution + 1 + i]);
      triangles.addAll([i, resolution + 1 + i, resolution + i]);
    }
    
    return Mesh(vertices: vertices, triangles: triangles);
  }
}

class Vector3 {
  final double x, y, z;
  
  const Vector3(this.x, this.y, this.z);
}
```

---

## 2. Integration Tests

### Device-Specific Test Matrix

| Test Category | Devices to Test | Expected Outcome | Pass Criteria |
|--------------|-----------------|------------------|---------------|
| **LiDAR Accuracy** | iPhone 12 Pro, 13 Pro, 14 Pro, 15 Pro | Volume estimates within ±20% of actual weight | ≥8 of 10 test items pass |
| **ARKit Fallback** | iPhone SE (2nd gen), XR, 11 | Volume estimates within ±35% of actual | ≥7 of 10 test items pass |
| **ARCore Fallback** | Samsung S21/S22, Pixel 6/7, OnePlus 9 | Volume estimates within ±40% of actual | ≥6 of 10 test items pass |
| **Monocular Fallback** | Older devices without ARKit/ARCore | Basic volume estimation with warnings | Graceful degradation, no crashes |

### Integration Test Implementation

```dart
// test/features/ar_scanner/device_integration_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:miro/features/ar_scanner/integration_tester.dart';
import 'package:miro/core/models/test_object.dart';

void main() {
  group('Device Integration Tests', () {
    
    // Test with known-volume objects across different devices
    
    testWithDevices('Sphere calibration object', (device) async {
      final sphere = TestObject(
        name: 'Calibration Sphere',
        expectedVolumeCm3: 52.36, // radius=2.5cm
        expectedWeightG: 100.0,   // known density
        shapeType: ShapeType.sphere,
      );
      
      final result = await IntegrationTester.scanObject(
        device: device,
        object: sphere,
        maxScanDuration: Duration(seconds: 3),
      );
      
      final errorPercent = ((result.estimatedVolumeCm3 - sphere.expectedVolumeCm3) 
          / sphere.expectedVolumeCm3 * 100).abs();
      
      expect(errorPercent, lessThan(25.0), // ±25% accuracy target
        reason: 'Sphere scan on ${device.model} should be within 25%');
    }, devices: [
      DeviceType.iPhone12Pro,
      DeviceType.iPhone13Pro,
      DeviceType.iPhone14Pro,
      DeviceType.iPhone15Pro,
      DeviceType.iPhoneSE2,
      DeviceType.samsungS21,
    ]);
    
    testWithDevices('Cube calibration object', (device) async {
      final cube = TestObject(
        name: 'Calibration Cube',
        expectedVolumeCm3: 1000.0, // 10cm side length
        expectedWeightG: 850.0,    // wood density ~0.85g/cm³
        shapeType: ShapeType.cube,
      );
      
      final result = await IntegrationTester.scanObject(
        device: device,
        object: cube,
        maxScanDuration: Duration(seconds: 3),
      );
      
      final errorPercent = ((result.estimatedVolumeCm3 - cube.expectedVolumeCm3) 
          / cube.expectedVolumeCm3 * 100).abs();
      
      expect(errorPercent, lessThan(20.0), // ±20% accuracy target for regular shapes
        reason: 'Cube scan on ${device.model} should be within 20%');
    }, devices: IntegrationTester.supportedDevices);
    
    testWithDevices('Cylinder calibration object', (device) async {
      final cylinder = TestObject(
        name: 'Calibration Cylinder',
        expectedVolumeCm3: 78.54, // r=2cm, h=10cm
        expectedWeightG: 60.0,    // plastic density ~0.9g/cm³
        shapeType: ShapeType.cylinder,
      );
      
      final result = await IntegrationTester.scanObject(
        device: device,
        object: cylinder,
        maxScanDuration: Duration(seconds: 3),
      );
      
      final errorPercent = ((result.estimatedVolumeCm3 - cylinder.expectedVolumeCm3) 
          / cylinder.expectedVolumeCm3 * 100).abs();
      
      expect(errorPercent, lessThan(25.0), // ±25% accuracy target
        reason: 'Cylinder scan on ${device.model} should be within 25%');
    }, devices: IntegrationTester.supportedDevices);
    
    testWithDevices('Food simulation - apple', (device) async {
      final apple = TestObject(
        name: 'Simulated Apple',
        expectedVolumeCm3: 180.0, // Medium apple ~150-200cm³
        expectedWeightG: 180.0,   // density ≈ 1.0g/cm³ (similar to water)
        shapeType: ShapeType.irregularSphere,
      );
      
      final result = await IntegrationTester.scanObject(
        device: device,
        object: apple,
        maxScanDuration: Duration(seconds: 3),
      );
      
      final errorPercent = ((result.estimatedWeightG - apple.expectedWeightG) 
          / apple.expectedWeightG * 100).abs();
      
      expect(errorPercent, lessThan(35.0), // ±35% for food-like objects
        reason: 'Apple scan on ${device.model} should be within 35%');
    }, devices: IntegrationTester.supportedDevices);
    
    testWithDevices('Food simulation - bowl of pasta', (device) async {
      final pastaBowl = TestObject(
        name: 'Simulated Pasta Bowl',
        expectedVolumeCm3: 450.0, // Standard serving ~400-500cm³
        expectedWeightG: 380.0,   // cooked pasta density ~0.85g/cm³
        shapeType: ShapeType.bowlWithContents,
      );
      
      final result = await IntegrationTester.scanObject(
        device: device,
        object: pastaBowl,
        maxScanDuration: Duration(seconds: 3),
      );
      
      final errorPercent = ((result.estimatedWeightG - pastaBowl.expectedWeightG) 
          / pastaBowl.expectedWeightG * 100).abs();
      
      expect(errorPercent, lessThan(45.0), // ±45% for mixed dishes (hardest case)
        reason: 'Pasta bowl scan on ${device.model} should be within 45%');
    }, devices: IntegrationTester.supportedDevices);
    
  });
}

// Helper extension to run tests across multiple device types
extension DeviceTestHelpers on TestWidgetsFlutterBinding {
  
  void testWithDevices(String description, Future<void> Function(DeviceType) fn, 
                       {required List<DeviceType> devices}) async {
    for (var device in devices) {
      test('$description - ${device.model}', () {
        return fn(device);
      });
    }
  }
}

enum DeviceType {
  iPhone12Pro('iPhone 12 Pro', true),
  iPhone13Pro('iPhone 13 Pro', true),
  iPhone14Pro('iPhone 14 Pro', true),
  iPhone15Pro('iPhone 15 Pro', true),
  iPhoneSE2('iPhone SE (2nd gen)', false),
  iPhoneXR('iPhone XR', false),
  iphone11('iPhone 11', false),
  samsungS21('Samsung Galaxy S21', false),
  samsungS22('Samsung Galaxy S22', false),
  pixel6('Google Pixel 6', false),
  pixel7('Google Pixel 7', false);
  
  final String model;
  final bool hasLiDAR;
  
  const DeviceType(this.model, this.hasLiDAR);
}

class TestObject {
  final String name;
  final double expectedVolumeCm3;
  final double expectedWeightG;
  final ShapeType shapeType;
  
  const TestObject({required this.name, required this.expectedVolumeCm3, 
                    required this.expectedWeightG, required this.shapeType});
}

enum ShapeType {
  sphere,
  cube,
  cylinder,
  irregularSphere,
  bowlWithContents,
}
```

---

## 3. User Acceptance Testing (UAT)

### Participant Recruitment Criteria

**Demographics:**
- **20+ participants** total across all device types
- **Device diversity**: 
  - 8 participants with LiDAR devices (iPhone Pro series)
  - 12 participants with standard iOS/Android devices
- **Tech proficiency mix**:
  - 30% tech-savvy users (developers, power users)
  - 50% average users (regular app consumers)
  - 20% less tech-confident users (seniors, non-tech backgrounds)

**Food Preferences:**
- Diverse dietary preferences represented:
  - Vegetarian/vegan participants
  - Meat-eaters
  - International cuisines (Asian, European, Latin American)
- Participants should regularly consume the test food categories

### UAT Test Protocol

```dart
// Documentation for UAT protocol
class UATProtocol {
  
  // Pre-test survey to gather baseline data
  Map<String, dynamic> preTestSurvey() {
    return {
      'participantId': _generateParticipantID(),
      'deviceModel': _getDeviceModel(),
      'hasLiDAR': _checkLiDARSupport(),
      'cookingFrequency': askQuestion(
        question: 'How often do you cook at home?',
        options: ['Daily', 'Several times/week', 'Weekly', 'Rarely'],
      ),
      'nutritionTrackingExperience': askQuestion(
        question: 'Have you used calorie tracking apps before?',
        options: ['Yes, frequently', 'Yes, occasionally', 'No, first time'],
      ),
      'techComfortLevel': askQuestion(
        question: 'How comfortable are you with new technology?',
        options: ['Very comfortable', 'Somewhat comfortable', 'Not very comfortable'],
      ),
    };
  }

  // Task completion measurement
  Map<String, dynamic> measureTaskCompletion({
    required String taskName,
    required DateTime startTime,
    required DateTime endTime,
    required bool completedSuccessfully,
    required List<String> issuesEncountered,
  }) {
    
    final duration = endTime.difference(startTime);
    
    return {
      'taskName': taskName,
      'durationSeconds': duration.inSeconds,
      'successRate': completedSuccessfuly ? 1.0 : 0.0,
      'issuesReported': issuesEncountered,
      'assistedByObserver': false, // or true if help was needed
    };
  }

  // Post-task confidence rating
  double askConfidenceRating({required String taskName}) {
    print('\nHow confident are you in the ${taskName} result?');
    print('Scale: 1-5 (1=Not at all confident, 5=Very confident)\n');
    
    final rating = readUserInput(); // Read from terminal/UI
    
    assert(rating >= 1 && rating <= 5);
    
    return rating.toDouble();
  }

  // Overall satisfaction survey
  Map<String, dynamic> postTestSurvey() {
    return {
      'npsScore': askQuestion(
        question: 'How likely are you to recommend this feature to others?',
        scale: '0-10 (0=Not at all, 10=Extremely likely)',
      ),
      'satisfactionRating': askQuestion(
        question: 'Overall satisfaction with the scanning experience',
        scale: '1-5 stars',
      ),
      'accuracyPerception': askQuestion(
        question: 'How accurate did the calorie estimates seem to you?',
        scale: '1-5 (1=Very inaccurate, 5=Very accurate)',
      ),
      'easeOfUseRating': askQuestion(
        question: 'How easy was it to use the scanning feature?',
        scale: '1-5 (1=Very difficult, 5=Very easy)',
      ),
      'wouldUseAgain': askQuestion(
        question: 'Would you use this feature again in the future?',
        options: ['Definitely yes', 'Probably yes', 'Not sure', 
                 'Probably not', 'Definitely not'],
      ),
      'suggestionsForImprovement': openEndedQuestion(
        question: 'What improvements would make this feature better for you?',
      ),
    };
  }

  // Qualitative feedback collection
  List<String> collectQualitativeFeedback() {
    final themes = <String>[];
    
    print('\nPlease share any additional thoughts about the scanning experience.');
    print('Mention anything that was confusing, frustrating, or particularly helpful.\n');
    
    final participantResponse = readUserInput();
    
    // Code responses into themes (can be done manually or with NLP)
    if (participantResponse.contains(RegExp(r'slow|slowly'))) {
      themes.add('Speed concerns');
    }
    if (participantResponse.contains(RegExp(r'accurate|precise|exact'))) {
      themes.add('Accuracy perceptions');
    }
    if (participantResponse.contains(RegExp(r'confus|unclear|messed'))) {
      themes.add('Confusion points');
    }
    if (participantResponse.contains(RegExp(r'helpful|intuitive|easy'))) {
      themes.add('Positive experiences');
    }
    
    return themes;
  }

  String _generateParticipantID() {
    // Generate unique participant identifier
    return 'PART-${DateTime.now().millisecondsSinceEpoch}';
  }

  String _getDeviceModel() {
    // Detect device model from system info
    return Platform.isIOS ? 
      UIDevice.current.model : 
      Build.MANUFACTURER + ' ' + Build.MODEL;
  }

  bool _checkLiDARSupport() {
    // Check if device has LiDAR sensor
    return DeviceCapabilityDetector.detectHardware().isLidar;
  }
}
```

### UAT Success Metrics

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| **Task completion rate** | >90% | Track scans started vs completed successfully |
| **First-time success rate** | >80% | New users who complete scan without assistance on first attempt |
| **Average task time** | <20 seconds | Time from button press to result display (including API call) |
| **Confidence rating** | >3.5/5.0 | User-reported confidence in results after each scan |
| **NPS score** | >40 | Net Promoter Score from post-test survey |
| **Satisfaction rating** | >4.0/5.0 | Overall satisfaction from 5-point scale |
| **Willingness to recommend** | >70% | Percentage who respond "Definitely yes" or "Probably yes" |

---

## 4. Performance Testing

### Token Budget Validation Tests

```dart
// test/features/ar_scanner/token_budget_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:miro/features/ar_scanner/gemini_analyzer.dart';

void main() {
  group('Token Budget Management', () {
    
    test('compressed frames stay within token budget', () {
      final analyzer = GeminiAnalyzer();
      
      // Simulate typical scan scenario
      final frames = _generateTestFrames(count: 3, qualityLevel: 'medium');
      
      final tokenCount = analyzer.estimateTokenUsage(frames);
      
      expect(tokenCount, lessThan(4000), // Target budget <4000 tokens per scan
        reason: 'Should stay within reasonable token budget for cost control');
    });

    test('low-quality images trigger downscaling', () {
      final analyzer = GeminiAnalyzer();
      
      final lowQualityFrame = _generateTestFrame(qualityLevel: 'low');
      
      final processed = analyzer.preprocessForAPI(lowQualityFrame);
      
      expect(processed.compressedSizeKB, lessThan(200), // Should compress aggressively
        reason: 'Low quality images should be compressed to save tokens');
    });

    test('optimal lighting allows higher quality', () {
      final analyzer = GeminiAnalyzer();
      
      final highQualityFrame = _generateTestFrame(qualityLevel: 'high');
      
      final processed = analyzer.preprocessForAPI(highQualityFrame);
      
      expect(processed.compressedSizeKB, lessThan(500), // Can afford larger files
        reason: 'High quality images can use higher compression ratio');
    });

    test('frame selection reduces tokens when possible', () {
      final analyzer = GeminiAnalyzer();
      
      final allFrames = _generateTestFrames(count: 30, qualityLevel: 'mixed');
      
      final selected = FrameSelector().selectBestFrames(allFrames);
      
      expect(selected.length, lessThanOrEqualTo(3), // Should select max 3 frames
        reason: 'Should limit to optimal number of frames for analysis');
    });

    test('metadata overhead is minimal', () {
      final analyzer = GeminiAnalyzer();
      
      final metadata = ScanMetadata(
        frameCount: 3,
        captureDurationMs: 1000,
        deviceModel: 'iPhone 15 Pro',
        hasLiDAR: true,
        lightingQuality: LightingQuality.good,
      );
      
      final jsonSize = analyzer.serializeMetadata(metadata).length;
      
      expect(jsonSize, lessThan(500), // Metadata should be compact JSON
        reason: 'Metadata should add minimal overhead to token usage');
    });

  });
}

class _TestFrameGenerator {
  
  static List<CapturedFrame> generateTestFrames({required int count, required String qualityLevel}) {
    return List.generate(count, (index) => CapturedFrame(
      index: index,
      timestamp: index / 30.0, // Assuming 30fps
      originalSizeKB: _estimateOriginalSize(qualityLevel),
      estimatedTokenUsage: _estimateTokensForFrame(qualityLevel),
    ));
  }

  static CapturedFrame generateTestFrame({required String qualityLevel}) {
    return CapturedFrame(
      index: 0,
      timestamp: 0.0,
      originalSizeKB: _estimateOriginalSize(qualityLevel),
      estimatedTokenUsage: _estimateTokensForFrame(qualityLevel),
    );
  }

  static int _estimateOriginalSize(String qualityLevel) {
    switch (qualityLevel) {
      case 'high': return 2048; // ~2MB original JPEG
      case 'medium': return 1536; // ~1.5MB
      case 'low': return 1024; // ~1MB
      default: return 1536;
    }
  }

  static int _estimateTokensForFrame(String qualityLevel) {
    switch (qualityLevel) {
      case 'high': return 900; // Higher quality = more tokens
      case 'medium': return 800;
      case 'low': return 700; // Lower quality = fewer tokens
      default: return 800;
    }
  }
}

class CapturedFrame {
  final int index;
  final double timestamp;
  final int originalSizeKB;
  final int estimatedTokenUsage;
  
  const CapturedFrame({required this.index, required this.timestamp, 
                       required this.originalSizeKB, required this.estimatedTokenUsage});
}

enum LightingQuality { excellent, good, fair, poor }
```

### Response Time Benchmarks

| Phase | Target Duration | Measurement Method | Pass Criteria |
|-------|-----------------|-------------------|---------------|
| **Camera initialization** | <100ms | Timestamp from button press to camera ready | ≥95% of scans meet target |
| **Frame capture & selection** | <300ms | Time from camera start to frame buffer complete | ≤300ms average |
| **Local AI processing** | <500ms | ML Kit detection + bounding box refinement | ≤500ms on modern devices |
| **API call (including network)** | <5000ms | Total duration from request send to response received | 95th percentile <5s |
| **Total scan time** | <3 seconds (excluding API) | End-to-end pre-processing time | Average <2.5s |
| **Total with retry** | <8 seconds max | Including one retry attempt if needed | ≤8s in all cases |

---

## 5. Automated Testing Pipeline

### CI/CD Integration Tests

```yaml
# .github/workflows/ar_scanner_tests.yml

name: AR Scanner Test Suite

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  unit-tests:
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run unit tests
        run: flutter test test/features/ar_scanner/
        
  integration-tests:
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run integration tests (simulated devices)
        run: |
          # Use test devices with different capabilities
          flutter test test/features/ar_scanner/device_integration_test.dart \
            --test-randomize-ordering-seed=random
      
  performance-tests:
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
      
      - name: Run performance benchmarks
        run: flutter test test/features/ar_scanner/performance_benchmarks_test.dart
        
  lint-checks:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
      
      - name: Run linter
        run: flutter analyze lib/features/ar_scanner/
      
      - name: Check formatting
        run: dart format --set-exit-if-changed lib/features/ar_scanner/

  gemini-integration-tests:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
      
      - name: Run Gemini API tests (with mock responses)
        run: flutter test test/features/ar_scanner/gemini_mock_tests.dart
          --coverage
        
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3

  security-audit:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Run security scan
        run: |
          flutter pub global activate dart_dependency_audit
          dart pub global run dart_dependency_audit audit
      
      - name: Check for secrets in code
        uses: github/codeql-action/init@v2
        with:
          languages: "flutter"
```

---

## Summary

This comprehensive testing strategy covers:
- ✅ **Unit tests** for core algorithms (frame selection, volume calculation)
- ✅ **Integration tests** across device types with known-volume objects
- ✅ **User acceptance testing** protocol for real-world validation
- ✅ **Performance benchmarks** to ensure acceptable response times
- ✅ **Automated CI/CD pipeline** for continuous quality assurance

**Key Success Criteria:**
- LiDAR devices: ±20% accuracy on standard test objects
- ARKit/ARCore fallback: ±35% accuracy target
- Monocular mode: Graceful degradation with clear warnings
- Total scan time: <3 seconds (excluding API call)
- Token budget: Keep per-scan cost under $0.01

This testing framework ensures the system meets quality standards before deployment and provides data-driven insights for continuous improvement.
