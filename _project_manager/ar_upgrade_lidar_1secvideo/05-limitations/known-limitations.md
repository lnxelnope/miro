# Known Limitations & Mitigation Strategies

**File:** `05-limitations/known-limitations.md`  
**Last Updated:** March 11, 2026

---

## Overview

This document outlines known limitations of the AR scanning system and provides practical mitigation strategies for each challenge. Understanding these limits is crucial for setting realistic user expectations and building appropriate error handling.

---

## 1. Food Types with Reduced Accuracy

### Severity Classification Matrix

| Category | Challenge | Expected Error Range | Recommendation Level |
|----------|-----------|---------------------|---------------------|
| **Leafy Greens** (salad, lettuce) | Thin, transparent leaves; air gaps | ±40-60% | ⚠️ Show warning |
| **Clear Liquids** (water, broth, vinegar) | Refractive surfaces confuse depth sensors | ±30-50% | ⚠️ Show warning |
| **Stacked Foods** (pancake stack, burger layers) | Hidden layers not visible in scan | ±20-30% undercount | ℹ️ Suggest side view |
| **Dehydrated Items** (crackers, chips, nuts) | Air gaps between pieces inflate volume | ±15-25% overcount | ℹ️ Apply density correction |
| **Melted/Spread Foods** (melted cheese, peanut butter) | Irregular surfaces difficult to segment | ±25-35% error | ℹ️ Manual adjustment recommended |
| **Powdered/Substances** (flour, sugar, rice grains) | Individual particles hard to distinguish | ±30-40% error | ⚠️ Show warning |
| **Beverages in Container** (coffee in mug, juice in bottle) | Container walls interfere with depth reading | ±20-30% error | ℹ️ Suggest pouring into cup |

### Detailed Analysis by Category

#### Leafy Greens & Salads

**Problem:** Individual leaves are thin and often transparent, causing:
- Depth sensors struggle to detect edges
- Light passes through leaves, reducing contrast
- Air gaps between leaves inflate volume estimate

**Example Scenario:**
```dart
// User scans a bowl of mixed greens salad
Expected weight: 85g (packed)
AR Estimate: 120g (+41% error) - includes air gaps
Actual edible portion: ~60g (-30% from expected)
```

**Mitigation Strategies:**

1. **Pre-scan Guidance:**
   ```dart
   class LeafyFoodWarning extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return Container(
         padding: EdgeInsets.all(12),
         margin: EdgeInsets.only(bottom: 8),
         decoration: BoxDecoration(
           color: Colors.orange.withOpacity(0.1),
           borderRadius: BorderRadius.circular(8),
           border: Border.all(color: Colors.orange, width: 1),
         ),
         child: Row(
           children: [
             Icon(Icons.info_outline, color: Colors.orange),
             SizedBox(width: 8),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text('สลัดอาจวัดไม่แม่นยำ', 
                        style: TextStyle(fontWeight: FontWeight.bold)),
                   Text('(Leafy foods may have lower accuracy)'),
                   SizedBox(height: 4),
                   Text('แนะนำชั่งน้ำหนักสำหรับความแม่นยำสูงสุด', 
                        style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                 ],
               ),
             ),
           ],
         ),
       );
     }
   }
   ```

2. **Post-scan Adjustment UI:**
   ```dart
   class LeafyFoodAdjustmentSlider extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return Column(
         children: [
           Slider(
             value: _adjustmentFactor,
             min: 0.3,
             max: 1.0, // Can reduce estimate significantly for leafy foods
             divisions: 7,
             onChanged: (value) {
               setState(() => _adjustmentFactor = value);
             },
           ),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text('ลด 70%'), // For very loose salads
               Text('ปรับตามความแน่น'),
               Text('ไม่ปรับ'),
             ],
           ),
         ],
       );
     }
   }
   ```

3. **Density Correction Factor:**
   ```dart
   class LeafyFoodDensityCorrector {
     
     double calculateCorrectionFactor({
       required String foodType,
       required List<FrameAnalysis> frames,
     }) {
       
       // Analyze leaf transparency and gap ratio
       final gapRatio = _calculateAirGapRatio(frames);
       final avgLeafThickness = _estimateLeafThickness(frames);
       
       // Higher gaps = more air = need larger reduction
       if (gapRatio > 0.6) return 0.4; // Very loose salad
       if (gapRatio > 0.4) return 0.6; // Typical packed salad
       if (gapRatio > 0.2) return 0.8; // Dense greens
       
       return 1.0; // Minimal adjustment needed
     }
     
     double _calculateAirGapRatio(List<FrameAnalysis> frames) {
       // Count pixels with depth discontinuity vs continuous surface
       final totalPixels = frames.fold(0, (sum, frame) => sum + frame.pixelCount);
       final gapPixels = frames.fold(0, (sum, frame) => 
         sum + _countDepthDiscontinuities(frame.depthMap));
       
       return gapPixels / totalPixels;
     }
   }
   ```

#### Clear Liquids & Transparent Containers

**Problem:** Light refraction through liquid and container walls creates:
- False depth edges at liquid-air interface
- Distorted surface detection
- Container thickness counted as part of food volume

**Example Scenario:**
```dart
// User scans water in glass
Expected volume: 250ml
AR Estimate: 310ml (+24% - includes glass wall thickness)
```

**Mitigation Strategies:**

1. **Container Detection & Exclusion:**
   ```dart
   class ContainerDetector {
     
     bool detectTransparentContainer(CameraFrame frame) {
       // Look for characteristic refraction patterns
       final edgeMap = _detectEdges(frame);
       
       // Transparent containers show:
       // 1. Curved edges with light bending
       // 2. Depth discontinuity at container rim
       // 3. Background visible through sides (low opacity)
       
       final hasCurvedEdges = _hasConsistentCurve(edgeMap, radiusThreshold: 50);
       final hasRimDiscontinuity = _detectRimEdge(frame);
       final isTransparent = _measureOpacity(frame) < 0.3;
       
       return hasCurvedEdges && hasRimDiscontinuity && isTransparent;
     }
     
     // If container detected, prompt user to remove from frame
     Widget buildContainerWarning() {
       return Center(
         child: Column(
           children: [
             Icon(Icons.info_outline, color: Colors.blue),
             Text('ตรวจพบภาชนะ - ลอกออกจากภาพเพื่อผลลัพธ์แม่นยำ'),
             Text('(Detected container - remove for better accuracy)'),
           ],
         ),
       );
     }
   }
   ```

2. **Recommended Alternative:**
   ```dart
   class LiquidMeasurementGuide {
     
     Widget buildAlternativeMethod() {
       return Card(
         child: Padding(
           padding: EdgeInsets.all(16),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text('คำแนะนำสำหรับของเหลว:', 
                    style: TextStyle(fontWeight: FontWeight.bold)),
               SizedBox(height: 8),
               _buildStep('ใช้ช้อนตวงหรือถ้วยตวง', 'Use measuring cup/spoon'),
               _buildStep('เทลงภาชนะที่มีหน่วยวัด', 'Pour into marked container'),
               _buildStep('บันทึกปริมาณที่อ่านได้', 'Record measured volume'),
             ],
           ),
         ),
       );
     }
     
     Widget _buildStep(String thai, String english) {
       return Padding(
         padding: EdgeInsets.only(bottom: 4),
         child: Row(
           children: [
             Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
             SizedBox(width: 8),
             Expanded(child: Text(thai)),
             SizedBox(width: 8),
             Opacity(opacity: 0.7, child: Text(english, style: TextStyle(fontSize: 12))),
           ],
         ),
       );
     }
   }
   ```

#### Stacked Foods & Layered Items

**Problem:** Top layer obscures lower layers from camera view:
- Cannot see height of entire stack
- Side angle required but often not captured
- Individual layers difficult to segment

**Mitigation Strategies:**

1. **Side View Prompt:**
   ```dart
   class StackedFoodGuide {
     
     Widget build() {
       return Container(
         margin: EdgeInsets.all(16),
         padding: EdgeInsets.all(12),
         decoration: BoxDecoration(
           color: Colors.blue.withOpacity(0.1),
           borderRadius: BorderRadius.circular(8),
         ),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Row(
               children: [
                 Icon(Icons.photo_camera_rounded, color: Colors.blue),
                 Text('แนะนำให้ถ่ายด้านข้าง', 
                      style: TextStyle(fontWeight: FontWeight.bold)),
               ],
             ),
             SizedBox(height: 8),
             Text('สำหรับอาหารที่เป็นชั้น เช่น แพนเค้ก เบอร์เกอร์'),
             Text('(For layered foods like pancakes, burgers)'),
             SizedBox(height: 4),
             Text('หมุนกล้องเพื่อให้เห็นความสูงทั้งหมด', 
                  style: TextStyle(fontSize: 12)),
           ],
         ),
       );
     }
   }
   ```

2. **Post-scan Layer Estimation:**
   ```dart
   class LayeredFoodEstimator {
     
     int estimateTotalHeight({
       required double visibleTopLayerHeight,
       required String foodType,
     }) {
       
       // Apply typical layer count based on food type
       final typicalLayers = _getTypicalLayerCount(foodType);
       
       // Estimate hidden layers as 70% of visible (conservative)
       final estimatedHiddenHeight = visibleTopLayerHeight * 0.7 * (typicalLayers - 1);
       
       return (visibleTopLayerHeight + estimatedHiddenHeight).round();
     }
     
     int _getTypicalLayerCount(String foodType) {
       switch (foodType.toLowerCase()) {
         case 'pancake': return 3;    // Typical stack height
         case 'burger': return 4;     // Bun, patty, cheese, bun
         case 'sandwich': return 2;   // Usually just two slices
         default: return 2;           // Conservative default
       }
     }
   }
   ```

---

## 2. Environmental Challenges

### Lighting Conditions Analysis & Guidance

```dart
class LightingAnalyzer {
  
  enum Quality { excellent, good, poor, veryPoor }
  
  final double averageBrightness; // 0-255
  final double contrastRatio;     // Ratio between brightest/darkest areas
  final double motionBlurScore;   // 0.0 (none) to 1.0 (severe)
  
  Quality get quality {
    if (averageBrightness < 60 || motionBlurScore > 0.5) {
      return Quality.veryPoor; // Cannot reliably detect features
    } else if (averageBrightness < 120) {
      return Quality.poor; // May miss details, but usable
    } else if (contrastRatio > 3.0 && averageBrightness < 200) {
      return Quality.good; // Adequate for most foods
    } else {
      return Quality.excellent; // Ideal conditions
    }
  }
  
  String getGuidanceMessage() {
    switch (quality) {
      case Quality.veryPoor:
        return 'ไม่เพียงพอสำหรับสแกน - เปิดไฟหรือย้ายที่ได้';
      
      case Quality.poor:
        return 'เพิ่มแสงสว่างเพื่อผลลัพธ์ที่ดีขึ้น';
      
      case Quality.good:
        return 'แสงสว่างเพียงพอ';
      
      case Quality.excellent:
        return 'สภาพแสงเหมาะสม';
    }
  }

  // Real-time lighting guide overlay
  Widget buildLightingGuide() {
    switch (quality) {
      case Quality.veryPoor:
        return Container(
          padding: EdgeInsets.all(16),
          color: Colors.red.withOpacity(0.8),
          child: Column(
            children: [
              Icon(Icons.wb_sunny_off_rounded, color: Colors.white, size: 48),
              Text('ไม่เพียงพอสำหรับสแกน', 
                   style: TextStyle(color: Colors.white, fontSize: 16)),
              Text('(Not enough light)', style: TextStyle(color: Colors.white70)),
            ],
          ),
        );
      
      case Quality.poor:
        return Container(
          padding: EdgeInsets.all(16),
          color: Colors.orange.withOpacity(0.8),
          child: Column(
            children: [
              Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 48),
              Text('เพิ่มแสงสว่าง', 
                   style: TextStyle(color: Colors.white, fontSize: 16)),
              Text('(Add more light)', style: TextStyle(color: Colors.white70)),
            ],
          ),
        );
      
      case Quality.good:
        return Container(
          padding: EdgeInsets.all(8),
          color: Colors.green.withOpacity(0.8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              Text('แสงสว่างเพียงพอ', style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      
      default: // excellent
        return Container(); // No guidance needed
    }
  }
}
```

### Reflection & Specular Highlight Issues

**Problem:** Shiny surfaces (glazed desserts, oily foods, metallic containers) create:
- Overexposed regions that confuse depth sensors
- False edges from light reflections
- Inconsistent depth readings across scan

**Detection Algorithm:**
```dart
class ReflectionDetector {
  
  bool detectsProblematicReflections(CameraFrame frame) {
    // Find overexposed pixels (>250 brightness)
    final highlightRegions = _findOverexposedRegions(frame);
    
    if (highlightRegions.isEmpty) return false;
    
    // Calculate total area of highlights
    final totalHighlightPixels = 
        highlightRegions.fold(0, (sum, region) => sum + region.pixelCount);
    
    // If >10% of frame is overexposed, likely problematic reflection
    if (totalHighlightPixels > frame.totalPixels * 0.1) {
      return true;
    }
    
    // Also check for specular patterns (concentric bright rings)
    final hasSpecularPattern = _detectSpecularRings(frame);
    if (hasSpecularPattern) return true;
    
    return false;
  }

  Widget buildReflectionMitigationGuide() {
    return Column(
      children: [
        Icon(Icons.adjust, color: Colors.amber),
        Text('อาหารมีผิวสะท้อนแสง'),
        Text('(Food has reflective surface)'),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTip('เปลี่ยนมุมกล้อง', 'Change angle'),
            _buildTip('ลดแสงจ้า', 'Reduce glare'),
            _buildTip('หมุนช้าๆ', 'Rotate slowly'),
          ],
        ),
      ],
    );
  }

  Widget _buildTip(String thai, String english) {
    return Column(
      children: [
        Icon(Icons.lightbulb_outline, size: 24),
        Text(thai, style: TextStyle(fontSize: 12)),
        Text(english, 
             style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}
```

---

## 3. Scale Ambiguity & Reference Object Mode

### When Depth Data is Unavailable

**Problem:** Without LiDAR or reliable ARKit/ARCore depth data, the system cannot determine absolute scale:
- Cannot distinguish between small object close to camera vs large object far away
- Volume estimates are relative, not absolute

**Solution: Reference Object Mode (Phase 2 Enhancement)**

```dart
class ReferenceObjectScaler {
  
  // Standard reference objects with known dimensions
  enum ReferenceType {
    standardPlate(26.0),      // Diameter in cm
    dinnerPlate(28.0),        // Larger plate
    coffeeCup(9.5),           // Height in cm
    smartphone,               // Use user's phone as reference
    creditCard(8.56),         // Standard width in cm
  }

  final ReferenceType _referenceType;
  
  double estimateScale({
    required DetectedObject detectedReference,
    required ReferenceType type,
  }) {
    
    final knownDimension = _getReferenceKnownSize(type);
    final measuredInPixels = detectedReference.measurementsInFrame;
    
    // Scale factor: cm per pixel
    return knownDimension / measuredInPixels;
  }

  Widget buildSetupGuide() {
    return Scaffold(
      body: Stack(
        children: [
          // Camera preview
          CameraPreview(),
          
          // Overlay guide for reference object placement
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('วางจานมาตรฐานข้างอาหาร', 
                     style: TextStyle(color: Colors.white, fontSize: 18)),
                Text('(Place standard plate next to food)', 
                     style: TextStyle(color: Colors.grey[300])),
                SizedBox(height: 20),
                
                // Visual guide showing expected size
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 4),
                      borderRadius: BorderRadius.circular(15)
                    ),
                  ),
                ),
                
                SizedBox(height: 12),
                Text('จานมาตรฐาน ≈ 26 ซม.', 
                     style: TextStyle(color: Colors.yellow[700], fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Post-scan scale adjustment using detected reference object
  double applyReferenceScale({
    required ReferenceType referenceType,
    required DetectedObject referenceInFrame,
    required double estimatedVolumeWithoutReference,
  }) {
    
    final knownSize = _getReferenceKnownSize(referenceType);
    final scaleFactor = knownSize / referenceInFrame.pixelMeasurement;
    
    // Volume scales cubically with linear dimension
    return estimatedVolumeWithoutReference * (scaleFactor * scaleFactor * scaleFactor);
  }

  double _getReferenceKnownSize(ReferenceType type) {
    switch (type) {
      case ReferenceType.standardPlate: return 26.0;
      case ReferenceType.dinnerPlate: return 28.0;
      case ReferenceType.coffeeCup: return 9.5;
      case ReferenceType.smartphone: 
        // Use detected phone dimensions from previous scans or user input
        return 14.76; // iPhone 15 Pro width in cm
      case ReferenceType.creditCard: return 8.56;
    }
  }
}
```

---

## 4. User Expectation Management

### Confidence Display Strategy

```dart
class ConfidenceDisplay {
  
  static Widget build(FoodScanResult result) {
    final confidence = result.scanQuality.confidence;
    
    return Column(
      children: [
        // Primary calorie display with confidence indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${result.totalCalories.toInt()}', 
                 style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Text('kcal', style: TextStyle(fontSize: 20)),
          ],
        ),
        
        SizedBox(height: 12),
        
        // Confidence badge with color coding
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getConfidenceColor(confidence).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getConfidenceColor(confidence)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getConfidenceIcon(confidence), 
                   color: _getConfidenceColor(confidence), size: 16),
              SizedBox(width: 8),
              Text(_getConfidenceText(confidence)),
            ],
          ),
        ),
        
        // Detailed issues and recommendations if confidence low
        if (confidence < 0.7) ...[
          Divider(height: 24),
          
          _buildIssuesSection(result.scanQuality.issues),
          SizedBox(height: 8),
          
          _buildRecommendationsSection(result.scanQuality.recommendations),
        ],
      ],
    );
  }

  static Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  static Icon _getConfidenceIcon(double confidence) {
    if (confidence >= 0.8) return Icon(Icons.check_circle_outline);
    if (confidence >= 0.6) return Icon(Icons.info_outline);
    return Icon(Icons.error_outline);
  }

  static String _getConfidenceText(double confidence) {
    if (confidence >= 0.8) return 'ความมั่นใจสูง'; // High confidence
    if (confidence >= 0.6) return 'ความมั่นใจปานกลาง'; // Medium confidence
    return 'ความมั่นใจต่ำ - แนะนำตรวจสอบด้วยตนเอง'; // Low confidence
  }

  static Widget _buildIssuesSection(List<String> issues) {
    if (issues.isEmpty) return Container();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ปัญหาที่ตรวจพบ:', style: TextStyle(fontWeight: FontWeight.bold)),
        ...issues.map((issue) => Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(child: Text(issue)),
            ],
          ),
        )),
      ],
    );
  }

  static Widget _buildRecommendationsSection(List<String> recommendations) {
    if (recommendations.isEmpty) return Container();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('คำแนะนำ:', style: TextStyle(fontWeight: FontWeight.bold)),
        ...recommendations.map((rec) => Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 16, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(child: Text(rec)),
            ],
          ),
        )),
      ],
    );
  }
}
```

### Onboarding & Education Strategy

```dart
class ScanningEducation {
  
  // First-time user education flow
  Widget buildOnboardingFlow() {
    return PageView(
      children: [
        _buildIntroSlide(),
        _buildHowToScanSlide(),
        _buildAccuracyExpectationsSlide(),
        _buildManualAdjustmentSlide(),
      ],
    );
  }

  Widget _buildIntroSlide() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.camera_alt_rounded, size: 80, color: Colors.blue),
          SizedBox(height: 24),
          Text('สแกนอาหารด้วย AR', 
               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text('ระบบจะวิเคราะห์ขนาดและคำนวณแคลอรี่จากภาพ', 
               textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildHowToScanSlide() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.rotate_left_rounded, size: 80, color: Colors.blue),
          SizedBox(height: 24),
          Text('วิธีใช้งาน', style: TextStyle(fontSize: 24)),
          SizedBox(height: 16),
          
          _buildStep('1. กดปุ่ม "สแกนด้วย AR"', 'Tap "Scan with AR"'),
          _buildStep('2. หมุนกล้องรอบอาหารเป็นเวลา 1 วินาที', 'Rotate around food for 1 second'),
          _buildStep('3. รอสистวิเคราะห์และแสดงผลลัพธ์', 'Wait for analysis and results'),
        ],
      ),
    );
  }

  Widget _buildAccuracyExpectationsSlide() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.info_outline_rounded, size: 80, color: Colors.blue),
          SizedBox(height: 24),
          Text('ความแม่นยำ', style: TextStyle(fontSize: 24)),
          SizedBox(height: 16),
          
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ระบบให้ค่าประมาณเท่านั้น', 
                     style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• ความแม่นยำ ±20-30% สำหรับอาหารทั่วไป'),
                Text('• อาจไม่แม่นยำสำหรับสลัดหรือของเหลวใส'),
                Text('• แนะนำใช้ชั่งน้ำหนักสำหรับความละเอียดสูง'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualAdjustmentSlide() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.edit_rounded, size: 80, color: Colors.blue),
          SizedBox(height: 24),
          Text('ปรับแต่งผลลัพธ์', style: TextStyle(fontSize: 24)),
          SizedBox(height: 16),
          
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('สามารถปรับค่าประมาณได้', 
                     style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• ใช้ sliders ปรับตามความเข้าใจ'),
                Text('• บันทึกข้อมูลจริงสำหรับเรียนรู้'),
                Text('• ระบบจะเรียนรู้จาก feedback ของคุณ'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String thai, String english) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Text(_buildStepNumber(), style: TextStyle(color: Colors.white))),
              ),
              SizedBox(width: 12),
              Expanded(child: Text(thai, style: TextStyle(fontSize: 16))),
            ],
          ),
          Text(english, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  String _buildStepNumber() {
    // Should be passed as parameter in real implementation
    return '1';
  }
}
```

---

## Summary

Key mitigation strategies implemented:
- ✅ **Pre-scan warnings** for known problem food types
- ✅ **Real-time guidance** based on lighting and detection quality
- ✅ **Post-scan adjustment tools** for manual refinement
- ✅ **Clear confidence indicators** with actionable recommendations
- ✅ **Educational onboarding** to set realistic expectations

**Next Steps:** Implement comprehensive testing strategy (`../06-testing/testing-strategy.md`) to validate accuracy across all food categories and environmental conditions.
