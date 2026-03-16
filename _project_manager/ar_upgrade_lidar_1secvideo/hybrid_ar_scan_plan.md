# AR Scan Upgrade Plan: Hybrid LiDAR + 1-Second Video Scanning

**Project:** Miro - Food Calorie Scanner  
**Date:** March 11, 2026  
**Status:** Planning Phase

---

## Executive Summary

This document outlines an upgrade to Miro's food scanning feature that combines **Local AI detection**, **AR visual feedback**, and **Gemini multimodal analysis** into a seamless "1-Second Scan" experience. The hybrid approach ensures high accuracy on LiDAR devices while maintaining usability on all smartphones.

### Key Innovation: Hybrid Depth System

Instead of requiring LiDAR-only devices, this system adapts to available hardware:
- **LiDAR Devices (iPhone Pro):** Real depth data + mesh metadata
- **Standard Devices:** ARKit/ARCore depth estimation + parallax analysis from 3 frames

---

## 1. UI/UX Design: The "1-Second Scan" Flow

### 1.1 Action Button Redesign

**Current State:**  
Button labeled "ถ่ายรูป" (Take Photo) - single static capture

**New Design:**  
Button labeled **"สแกนด้วย AR"** (Scan with AR) with visual enhancement:
- Icon: Circular arrow animation indicating rotation
- Color: Brand primary color with subtle pulse animation when active
- Microcopy: "วนรอบอาหาร 1 วินาที" (Rotate around food for 1 second)

### 1.2 User Guidance System

**On Activation:**
```
┌─────────────────────────────────────────┐
│  🎯 สแกนอาหารแบบ AR                    │
│                                         │
│  วางอาหารในวงกลม                         │
│  หมุนกล้องช้าๆ รอบอาหาร                 │
│  (ใช้เวลาประมาณ 1 วินาที)                │
│                                         │
│  [← →] แสดงตัวอย่าง                      │
└─────────────────────────────────────────┘
```

**Visual Elements:**
- **Guiding Circle:** Semi-transparent ring overlay (diameter: ~30cm at typical distance)
- **Rotation Arrow:** Curved arrow indicating clockwise rotation direction
- **Progress Indicator:** Circular progress bar that fills over 1 second
- **Speed Guide:** Subtle animation showing optimal rotation speed

### 1.3 Real-Time Visual Feedback

**During Scanning (Local AI Processing):**

```dart
// Conceptual visualization layer
Overlay:
  - Bounding Box (faded wireframe)
    • Green outline when food detected
    • Red outline when tracking lost
    • Dashed line during initial detection
  
  - Mesh Preview (if LiDAR available)
    • Semi-transparent surface overlay
    • Updates in real-time at 30fps
    
  - Depth Heatmap (optional)
    • Blue = close, Red = far
    • Helps user maintain consistent distance
```

**Feedback States:**

| State | Visual Cue | User Action Required |
|-------|-----------|---------------------|
| **Ready** | Solid circle, green | Start rotating |
| **Tracking** | Circle pulses, bounding box visible | Continue rotation |
| **Lost** | Circle turns red, shake animation | Slow down, reposition |
| **Complete** | Checkmark, haptic feedback | Scan processing... |

---

## 2. Frame Management Strategy

### 2.1 Capture Specifications

**Video Recording Parameters:**
```swift
// iOS Camera Configuration
sessionPreset = .high // Maximum quality
frameRate = 30 fps   // Balanced for performance
duration = 1.0 second (exactly)
resolution = 1920x1080 (preserved for analysis)
```

**Storage Strategy:**
- Buffer in memory during capture (no disk write needed)
- Extract key frames before processing
- Discard raw video after frame selection to save bandwidth

### 2.2 Smart Frame Selection Algorithm

**Selection Criteria:**
1. **Frame 1 (t=0s):** Initial detection - establishes baseline
2. **Frame 15 (t=0.5s):** Mid-point - optimal lighting typically
3. **Frame 30 (t=1.0s):** Final position - completes rotation

**Quality Validation:**
```dart
class FrameSelector {
  List<int> selectFrames(List<CameraFrame> frames) {
    // Filter out low-quality frames
    final validFrames = frames.where((frame) => 
      frame.brightness > MIN_BRIGHTNESS &&
      frame.motionBlur < MAX_BLUR &&
      frame.foodCoverage > MIN_COVERAGE
    ).toList();
    
    // Select best 3 frames spaced evenly
    if (validFrames.length >= 3) {
      return [
        validFrames[0],                    // First high-quality
        validFrames[validFrames.length ~/ 2], // Middle
        validFrames.last                   // Last high-quality
      ];
    }
    
    // Fallback: use any available frames
    return validFrames.take(3).toList();
  }
}
```

### 2.3 Preprocessing Pipeline

**Step-by-Step Processing:**

1. **Object Detection (Local AI):**
   ```dart
   // Run ML Kit image labeling on each frame
   final labeler = GoogleMLKit.imageLabeling;
   final labels = await labeler.processImage(image);
   
   // Identify food bounding box
   final foodBox = labels.firstWhere(
     (label) => label.confidence > 0.7 && 
                [ 'Food', 'Fruit', 'Vegetable', 'Dish' ].contains(label.label)
   );
   ```

2. **Bounding Box Refinement:**
   ```dart
   // Combine detections across 3 frames for robust box
   final refinedBox = calculateConsensusBoundingBox([
     frame1.detection,
     frame2.detection,
     frame3.detection
   ]);
   ```

3. **Cropping & Normalization:**
   ```dart
   // Crop to food region + 10% padding
   final croppedImage = image.cropWithPadding(
     box: refinedBox,
     paddingPercent: 10
   );
   
   // Resize to optimal dimensions for Gemini
   final normalizedImage = croppedImage.resizeTo(1024x1024);
   ```

**File Size Reduction:**
- Original frame: ~2MB (1080p JPEG)
- After crop: ~300KB average
- 3 frames total: ~900KB vs 6MB raw video

---

## 3. Hybrid Depth System Architecture

### 3.1 Hardware Detection & Routing

```swift
class DepthSystemRouter {
  enum DepthType {
    lidar,      // iPhone Pro with LiDAR scanner
    arkit,      // iOS ARKit depth API
    arcore,     // Android ARCore depth API
    monocular   // Fallback: no depth sensor
  }
  
  static Future<DepthType> detectHardware() async {
    if (await ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)) {
      return DepthType.lidar;
    } else if (ARKitSupport.isSupported && ARCoreSupport.isSupported) {
      // Check device capabilities
      if (Platform.isIOS) {
        return DepthType.arkit;
      } else if (Platform.isAndroid) {
        return DepthType.arcore;
      }
    }
    return DepthType.monocular;
  }
}
```

### 3.2 LiDAR Mode Implementation

**For iPhone Pro Devices:**

```swift
class LIDARDepthProvider: NSObject, ARSCNViewDelegate {
    
    func captureDepthData(sceneView: ARSCNView) -> DepthMetadata {
        // Extract actual depth from LiDAR sensor
        let depthMap = sceneView.renderer?.depthData
        
        // Get mesh geometry if available
        guard let mesh = sceneView.scene.rootNode.childEntities.first?.mesh else {
            return emptyDepthMetadata
        }
        
        // Calculate volume from triangulated mesh
        let volume = calculateMeshVolume(mesh)
        
        // Extract device information for scaling reference
        let deviceInfo = DeviceInfo(
            model: UIDevice.current.model,
            hasLiDAR: true,
            scannerGeneration: getLiDGARGeneration() // 1st gen, 2nd gen, etc.
        )
        
        return DepthMetadata(
            depthMap: depthMap,
            mesh: mesh,
            volume: volume,
            deviceInfo: deviceInfo,
            timestamp: Date(),
            confidence: calculateDepthConfidence(depthMap)
        )
    }
}

// Device recognition for scaling reference
func getLiDGARGeneration() -> Int {
    if #available(iOS 17.0, *) {
        return 4 // iPhone 15 Pro series
    } else if #available(iOS 16.0, *) {
        return 3 // iPhone 14 Pro series
    } else if #available(iOS 15.0, *) {
        return 2 // iPhone 13 Pro series
    } else {
        return 1 // iPhone 12 Pro (first with LiDAR)
    }
}
```

**Metadata Structure Sent to Gemini:**
```json
{
  "deviceInfo": {
    "model": "iPhone 15 Pro",
    "hasLiDAR": true,
    "scannerGeneration": 4,
    "depthAccuracy": "±2mm"
  },
  "scanMetadata": {
    "frameCount": 30,
    "captureDurationMs": 1000,
    "lensType": "wide",
    "flashUsed": false
  },
  "depthData": {
    "type": "lidar_point_cloud",
    "pointCount": 250000,
    "averageConfidence": 0.94,
    "meshVolumeCm3": 450.5,
    "boundingBox": {
      "width": 18.2,
      "height": 12.5,
      "depth": 8.3,
      "units": "cm"
    }
  },
  "frames": [ /* base64 encoded cropped frames */ ]
}
```

### 3.3 ARKit/ARCore Depth Estimation Mode

**For Standard iOS Devices:**

```swift
class ARKitDepthEstimator {
    
    func estimateDepthFromFrames(frames: [ARFrame]) -> EstimatedDepthData {
        // Use ARKit's built-in depth API
        guard let depthData = frames.first?.depthData else {
            return fallbackMonocularAnalysis
        }
        
        // Create depth point cloud from multiple frames
        var pointCloud: [Vector3] = []
        for frame in frames {
            if let points = frame.depthPoints() {
                pointCloud.append(contentsOf: points)
            }
        }
        
        // Apply temporal smoothing
        let smoothedCloud = applyTemporalSmoothing(pointCloud, alpha: 0.7)
        
        return EstimatedDepthData(
            pointCloud: smoothedCloud,
            estimatedVolume: calculatePointcloudVolume(smoothedCloud),
            confidence: estimateConfidenceFromQuality(frame.qualityMetrics)
        )
    }
}
```

**Parallax-Based 3D Reconstruction:**

When depth API unavailable or low quality, use **structure from motion**:

```dart
class ParallaxReconstructor {
  
  Vector3 reconstructFoodGeometry({
    required List<Image> frames,
    required List<Pose> cameraPoses
  }) {
    // Extract feature points across all 3 frames
    final features1 = extractFeatures(frames[0]);
    final features2 = extractFeatures(frames[1]);
    final features3 = extractFeatures(frames[2]);
    
    // Match features between consecutive frames
    final matches12 = matchFeatures(features1, features2);
    final matches23 = matchFeatures(features2, features3);
    
    // Triangulate 3D points from matched pairs
    final triangulatedPoints = [
      for (var match in matches12) 
        triangulatePoint(match.p1, match.p2, cameraPoses[0], cameraPoses[1]),
      for (var match in matches23)
        triangulatePoint(match.p1, match.p2, cameraPoses[1], cameraPoses[2])
    ];
    
    // RANSAC to remove outliers
    final cleanPoints = ransacOutlierRemoval(triangulatedPoints);
    
    // Reconstruct surface mesh
    return reconstructMesh(cleanPoints);
  }
}

// Camera pose tracking using visual odometry
class VisualOdometry {
  
  Pose estimateCameraPose(Image previousFrame, Image currentFrame) {
    // Track feature flow between frames
    final opticalFlow = computeOpticalFlow(previousFrame, currentFrame);
    
    // Estimate rotation and translation from motion vectors
    final rotation = estimateRotation(opticalFlow);
    final translation = estimateTranslation(opticalFlow, baselineDistance: 0.02); // ~2cm movement
    
    return Pose(rotation: rotation, translation: translation);
  }
}
```

**Metadata for Parallax Mode:**
```json
{
  "deviceInfo": {
    "model": "iPhone 14",
    "hasLiDAR": false,
    "depthMethod": "arkit_depth_api"
  },
  "parallaxData": {
    "frameBaselineCM": [1.8, 2.1], // distance between frames 1-2 and 2-3
    "featurePointsDetected": 847,
    "triangulatedPoints": 623,
    "reconstructionConfidence": 0.78,
    "estimatedScaleFromReference": true // if reference object used
  }
}
```

### 3.4 Reference Object Scaling (Future Enhancement)

**Concept:** Provide known-size reference for better scale estimation

```dart
class ReferenceObjectScaler {
  
  double estimateScale({
    required String referenceType, // 'plate', 'cup', 'phone'
    required List<DetectedObject> sceneObjects
  }) {
    final reference = sceneObjects.firstWhere(
      (obj) => obj.type == referenceType,
      orElse: () => DetectedObject.unknown
    );
    
    switch (referenceType) {
      case 'standard_plate':
        return 26.0 / reference.diameterPixels; // Standard plate = 26cm
      case 'coffee_cup':
        return 9.5 / reference.heightPixels;     // Standard cup = 9.5cm tall
      case 'iphone_15_pro':
        return 147.6 / reference.widthPixels;    // iPhone 15 Pro width in mm
      default:
        return null; // Cannot estimate scale
    }
  }
}

// UI Prompt for Reference Object Mode
class ReferenceObjectGuide {
  
  Widget buildGuide() {
    return Column(
      children: [
        Text('วางจานมาตรฐานข้างอาหารเพื่อช่วยคำนวณขนาด'),
        Text('(Place standard plate next to food)'),
        SizedBox(height: 20),
        // Visual guide showing plate size reference
        AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(130) // Standard plate ratio
            ),
          )
        )
      ]
    );
  }
}
```

---

## 4. Gemini Multimodal API Integration

### 4.1 Prompt Engineering for Food Analysis

**System Prompt:**
```
You are a nutritionist and computer vision expert specialized in food volume estimation from multiple camera angles. You analyze 3 images of food taken during a 1-second scan, using parallax and depth data to estimate volume in milliliters (ml) and calculate calories based on detected food type.

Your output must be valid JSON following the schema below. Never include explanations outside the JSON structure.
```

**User Prompt Template:**
```markdown
Analyze this 3-frame food scan and provide volume and calorie estimates.

**Scan Metadata:**
{scanMetadata}

**Device Information:**
{deviceInfo}

**Depth Data (if available):**
{depthData}

**Images:**
[Frame 1: Initial view of food]
[Frame 2: Mid-rotation view]
[Frame 3: Final rotation position]

**Instructions:**
1. Identify the primary food item(s) in all frames
2. Use parallax between frames to estimate 3D volume
3. If depth data is available, use it to refine volume calculation
4. Consider typical density for identified food types
5. Account for common variations (e.g., cooked vs raw, packed vs loose)

**Output Format:**
Return ONLY valid JSON in this structure:
{
  "foodItems": [
    {
      "name": "string",
      "confidence": number (0-1),
      "category": "solid|liquid|mixed|leafy",
      "estimatedWeightGrams": number,
      "volumeMl": number,
      "calories": number,
      "nutritionalInfo": {
        "protein_g": number,
        "carbs_g": number,
        "fat_g": number,
        "fiber_g": number
      },
      "uncertaintyFactors": ["string explaining why estimate may be uncertain"]
    }
  ],
  "totalCalories": number,
  "scanQuality": {
    "confidence": number (0-1),
    "issues": ["list of any quality issues detected"],
    "recommendations": ["suggestions for better scan next time"]
  },
  "metadata": {
    "processingTimeMs": number,
    "modelVersion": "gemini-2.0-flash-food-v1"
  }
}
```

### 4.2 API Implementation

```dart
class GeminiFoodAnalyzer {
  
  final GoogleGenerativeAI _ai;
  
  Future<FoodScanResult> analyzeScan({
    required List<String> encodedFrames, // base64 JPEGs
    required ScanMetadata metadata,
    required DeviceInfo deviceInfo,
    required DepthData? depthData,
  }) async {
    
    // Build prompt with all context
    final prompt = _buildAnalysisPrompt(
      frames: encodedFrames,
      metadata: metadata,
      deviceInfo: deviceInfo,
      depthData: depthData
    );
    
    // Configure multimodal request
    final content = [
      Content.multi([
        for (var i = 0; i < encodedFrames.length; i++)
          Part.base64(
            encodedFrames[i],
            mimeType: 'image/jpeg'
          ).copyWith(
            inlineData: InlineData(
              mimeType: 'image/jpeg',
              data: encodedFrames[i]
            )
          ),
        Part.text(prompt)
      ])
    ];
    
    final request = GenerativeContentBlob(
      content: content,
      mimeType: 'application/json'
    );
    
    // Execute analysis
    final response = await _ai.model.generateContent(request);
    
    // Parse JSON result
    try {
      final jsonStr = _extractJsonFromResponse(response.text!);
      return FoodScanResult.fromJson(json.decode(jsonStr));
    } catch (e) {
      throw GeminiParseError('Failed to parse Gemini response: $e');
    }
  }
}

// Helper to extract JSON from potential markdown formatting
String _extractJsonFromResponse(String text) {
  // Remove code blocks if present
  final cleaned = text.replaceAllMapped(
    RegExp(r'```(?:json)?\n?(.*?)\n?```', multiLine: true, caseSensitive: true),
    (match) => match.group(1)!
  );
  
  return cleaned.trim();
}
```

### 4.3 Error Handling & Fallbacks

**Scenario-Based Responses:**

| Issue | Detection Method | Gemini Prompt Adjustment |
|-------|-----------------|-------------------------|
| **Low confidence food detection** | All frames <0.6 confidence | Add "Food may not be clearly visible" warning in prompt |
| **Motion blur detected** | Edge sharpness analysis | Request to focus on clearer regions |
| **Multiple food items** | Bounding boxes overlap | Ask for primary item identification |
| **Scale ambiguity** | No depth data + no reference object | Add "Use standard plate as size reference next time" suggestion |

**Fallback Strategy:**

```dart
class AnalysisFallbackHandler {
  
  Future<FoodScanResult> handleLowConfidence(
    FoodScanResult initialResult,
    List<String> originalFrames
  ) async {
    
    // If confidence < 0.5, try enhanced analysis
    if (initialResult.scanQuality.confidence < 0.5) {
      final enhancedPrompt = '''
      This scan has low confidence. Please:
      - Focus on the most visible regions across all frames
      - Consider partial visibility of food items
      - Provide a range estimate if uncertain
      - List specific visual ambiguities
      
      Try your best to provide reasonable estimates based on available information.
      ''';
      
      final retryResult = await _retryWithPrompt(enhancedPrompt);
      
      if (retryResult.scanQuality.confidence > initialResult.scanQuality.confidence) {
        return retryResult;
      }
    }
    
    // Return best available result with caution flags
    return initialResult.copyWith(
      warnings: ['Low confidence scan - manual verification recommended']
    );
  }
}
```

---

## 5. Known Limitations & Mitigation Strategies

### 5.1 Food Types with Reduced Accuracy

| Category | Challenge | Accuracy Impact | Recommended Mitigation |
|----------|-----------|-----------------|----------------------|
| **Leafy Greens** (salad) | Thin, transparent leaves | ±40-60% error | Show warning: "สลัดอาจวัดไม่แม่นยำ - แนะนำชั่งน้ำหนัก" |
| **Clear Liquids** (water, broth) | Refractive surfaces confuse depth sensors | ±30-50% error | Use reference object mode; manual entry preferred |
| **Stacked Foods** (pancake stack) | Hidden layers not visible in scan | ±20-30% undercount | Prompt user to show side view for height estimation |
| **Dehydrated Items** (crackers, chips) | Air gaps between pieces inflate volume | ±15-25% overcount | Apply density correction factor based on food type |
| **Melted/Spread Foods** (melted cheese) | Irregular surfaces difficult to segment | ±25-35% error | Suggest manual adjustment after scan |

### 5.2 Environmental Challenges

**Lighting Conditions:**

```dart
enum LightingQuality { excellent, good, poor, veryPoor }

class LightingAnalyzer {
  
  LightingQuality assessLighting(CameraFrame frame) {
    final histogram = analyzeBrightnessHistogram(frame);
    
    if (histogram.meanBrightness > 180 && histogram.standardDeviation < 30) {
      return LightingQuality.excellent; // Bright, even lighting
    } else if (histogram.meanBrightness > 120 && histogram.standardDeviation < 60) {
      return LightingQuality.good; // Adequate lighting
    } else if (histogram.meanBrightness > 60) {
      return LightingQuality.poor; // Dim or high contrast
    } else {
      return LightingQuality.veryPoor; // Too dark for reliable scan
    }
  }
}

// On-screen guidance based on lighting
class LightingGuideOverlay {
  
  Widget build() {
    final quality = _lightingAnalyzer.assessLighting(currentFrame);
    
    switch (quality) {
      case LightingQuality.excellent:
        return Container(); // No guidance needed
      
      case LightingQuality.good:
        return Text('แสงสว่างเพียงพอ', style: TextStyle(color: Colors.green));
      
      case LightingQuality.poor:
        return Column(
          children: [
            Icon(Icons.wb_sunny_outlined, color: Colors.orange),
            Text('เพิ่มแสงสว่างเพื่อผลลัพธ์ที่ดีขึ้น'),
            Text('(Add more light for better results)')
          ]
        );
      
      case LightingQuality.veryPoor:
        return Column(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            Text('ไม่เพียงพอสำหรับสแกน - เปิดไฟหรือย้ายที่ได้'),
            Text('(Not enough light - turn on lights or move)')
          ]
        );
    }
  }
}
```

**Reflection & Transparent Surfaces:**

```dart
class ReflectionDetector {
  
  bool detectsProblematicReflections(CameraFrame frame) {
    // Check for specular highlights (overexposed spots)
    final highlightRegions = findOverexposedRegions(frame, threshold: 250);
    
    if (highlightRegion.length > 5 && 
        highlightRegion.fold(0, (sum, region) => sum + region.area) > frame.width * frame.height * 0.1) {
      return true; // Too many reflections detected
    }
    
    return false;
  }
}

// Guidance for reflective foods (cheese, glazed desserts)
class ReflectionMitigationGuide {
  
  Widget build() {
    return Column(
      children: [
        Icon(Icons.adjust, color: Colors.amber),
        Text('อาหารมีผิวสะท้อนแสง'),
        Text('(Food has reflective surface)'),
        SizedBox(height: 8),
        Text('เปลี่ยนมุมกล้องเพื่อลดการสะท้อน', textAlign: TextAlign.center),
        Text('(Try different angle to reduce glare)')
      ]
    );
  }
}
```

### 5.3 Future Enhancement: Reference Object Mode

**Phase 2 Implementation Plan:**

1. **Pre-scan Guidance:**
   ```dart
   class ReferenceObjectScanner {
     
     Widget buildSetupScreen() {
       return Scaffold(
         body: Stack(
           children: [
             CameraPreview(),
             
             // Overlay guide for reference object placement
             Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Text('วางจานมาตรฐานข้างอาหาร'),
                   Text('(Place standard plate next to food)'),
                   
                   // Visual guide showing expected size
                   AspectRatio(
                     aspectRatio: 1.0,
                     child: Container(
                       decoration: BoxDecoration(
                         border: Border.all(color: Colors.white, width: 3),
                         borderRadius: BorderRadius.circular(15)
                       ),
                     )
                   ),
                   
                   Text('จานมาตรฐาน ≈ 26 ซม.'),
                   Text('(Standard plate ≈ 26cm diameter)'),
                 ]
               )
             )
           ]
         )
       );
     }
   }
   ```

2. **Post-scan Scale Adjustment:**
   ```dart
   class PostScanScaler {
     
     double applyReferenceScale({
       required String referenceType,
       required DetectedObject referenceInFrame,
       required double estimatedVolumeWithoutReference
     }) {
       final knownSize = _getReferenceKnownSize(referenceType); // e.g., 26.0 for plate
       
       final scaleFactor = knownSize / referenceInFrame.measuredInPixels;
       
       return estimatedVolumeWithoutReference * (scaleFactor * scaleFactor); // Volume scales cubically
     }
   }
   ```

---

## 6. Performance Optimization

### 6.1 Token Budget Management

**Gemini API Cost Considerations:**

| Component | Approximate Tokens | Cost Estimate (USD) |
|-----------|-------------------|---------------------|
| System prompt | ~300 | $0.0003 |
| Per frame image (1024x1024 JPEG) | ~800 each × 3 = 2,400 | $0.0024 |
| Metadata JSON | ~500 | $0.0005 |
| **Total per scan** | ~3,200 tokens | **~$0.0032** |

**Optimization Strategies:**

1. **Image Compression:**
   ```dart
   final compressed = await image.compress(quality: 75); // JPEG quality 75%
   final encoded = base64Encode(compressed);
   
   // Verify visual quality preserved after compression
   assert(psnr(original, compressed) > 30.0); // PSNR > 30dB acceptable
   ```

2. **Smart Frame Selection:**
   - Only send frames where food is clearly visible
   - Skip frames with motion blur or poor lighting
   - Can reduce to 2 frames if quality high: ~2,400 tokens total

3. **Prompt Optimization:**
   - Use concise prompt templates
   - Remove unnecessary context when not needed
   - Cache frequently-used system prompts

### 6.2 Local Processing Pipeline

**Optimized Flutter Implementation:**

```dart
class ScanPipeline {
  
  Future<FoodScanResult> runScan() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Step 1: Capture video buffer (0-50ms)
      final frameBuffer = await _captureVideoBuffer(durationMs: 1000);
      
      // Step 2: Parallel processing (50-150ms)
      final results = await Future.wait([
        _selectKeyFrames(frameBuffer),       // Frame selection
        _detectObjectsParallel(frameBuffer), // Object detection on all frames
        _assessLighting(frameBuffer),        // Lighting analysis
      ]);
      
      // Step 3: Preprocessing (150-200ms)
      final processedFrames = await _prepareFramesForGemini(
        results.frames, 
        results.detections
      );
      
      // Step 4: API call with timeout (200-3000ms)
      final result = await _geminiAnalyzer.analyzeScan(
        frames: processedFrames.encodedFrames,
        metadata: processedFrames.metadata,
        options: GenerateContentOptions(timeout: Duration(seconds: 5))
      ).timeout(
        Duration(seconds: 5),
        onTimeout: () => throw ScanTimeoutException()
      );
      
      stopwatch.stop();
      _logScanMetrics(stopwatch.elapsedMilliseconds, result);
      
      return result;
      
    } catch (e) {
      _handleScanError(e);
      rethrow;
    }
  }
  
  int get totalProcessingTime => _stopwatchElapsed;
}

// Performance targets:
// - Total scan time: < 5 seconds
// - Pre-processing: < 300ms
// - API call: < 5000ms (with retry)
// - UI feedback: real-time during each phase
```

---

## 7. User Experience Considerations

### 7.1 Error States & Recovery

| State | Trigger | User Message (Thai/English) | Recovery Action |
|-------|---------|----------------------------|-----------------|
| **Too Dark** | Lighting quality < poor | "ไม่เพียงพอสำหรับสแกน - เปิดไฟหรือย้ายที่ได้ / Not enough light" | Turn on lights, move to brighter location |
| **Motion Blur** | Frame blur score > threshold | "กล้องสั่น - ถือให้มั่นคงขึ้น / Camera shaking" | Hold phone steadier, brace against surface |
| **Tracking Lost** | Food leaves bounding box | "อาหารหายไปจากจอ / Food out of view" | Slow rotation, keep food centered |
| **Reflection Issue** | Specular highlights detected | "ผิวสะท้อนแสง - ลองเปลี่ยนมุม / Reflective surface" | Change angle to reduce glare |
| **Scale Ambiguous** | No depth data + no reference | "ไม่ทราบขนาด - วางวัตถุล่วงหน้า / Unknown scale" | Place known object (phone, plate) in frame |

### 7.2 Confidence Indicators

**Post-Scan Display:**

```dart
class ScanResultDisplay {
  
  Widget build(FoodScanResult result) {
    return Column(
      children: [
        // Primary result with confidence score
        Text('${result.totalCalories} kcal', style: TextStyle(fontSize: 48)),
        
        // Confidence indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getConfidenceIcon(result.scanQuality.confidence),
              color: _getConfidenceColor(result.scanQuality.confidence)
            ),
            Text(_getConfidenceText(result.scanQuality.confidence)),
          ]
        ),
        
        // Issues and recommendations if confidence low
        if (result.scanQuality.confidence < 0.7) ...[
          Divider(),
          _buildIssuesSection(result),
          _buildRecommendationsSection(result),
        ],
        
        // Manual adjustment controls
        _buildManualAdjustmentSlider(result),
      ]
    );
  }
  
  Widget _buildManualAdjustmentSlider(FoodScanResult result) {
    return Column(
      children: [
        Text('ปรับค่าประมาณ (Adjust estimate)'),
        Slider(
          value: _adjustmentFactor,
          min: 0.5,
          max: 1.5,
          divisions: 10,
          label: '${(_adjustmentFactor * 100).round()}%',
          onChanged: (value) {
            setState(() => _adjustmentFactor = value);
            _updateCalories(result.totalCalories * value);
          },
        ),
      ]
    );
  }
}

// Confidence color coding
Color _getConfidenceColor(double confidence) {
  if (confidence >= 0.8) return Colors.green;
  if (confidence >= 0.6) return Colors.orange;
  return Colors.red;
}

String _getConfidenceText(double confidence) {
  if (confidence >= 0.8) return 'ความมั่นใจสูง / High confidence';
  if (confidence >= 0.6) return 'ความมั่นใจปานกลาง / Medium confidence';
  return 'ความมั่นใจต่ำ - แนะนำตรวจสอบ / Low confidence - verify manually';
}
```

---

## 8. Implementation Phases

### Phase 1: Core Framework (Weeks 1-3)

**Deliverables:**
- [ ] Basic AR camera view with bounding box overlay
- [ ] Frame capture and selection logic
- [ ] Local AI food detection integration
- [ ] Simple cropping pipeline

**Success Criteria:**
- Can capture 3 frames in < 1 second
- Object detection works on all supported devices
- Bounding boxes displayed in real-time during scan

### Phase 2: Depth System Integration (Weeks 4-6)

**Deliverables:**
- [ ] LiDAR depth data extraction for iPhone Pro
- [ ] ARKit/ARCore fallback implementation
- [ ] Device detection and routing logic
- [ ] Metadata generation for API

**Success Criteria:**
- LiDAR volume estimates within ±25% of actual weight (test with known objects)
- Standard devices produce usable depth estimates
- Automatic device type detection works reliably

### Phase 3: Gemini Integration (Weeks 7-9)

**Deliverables:**
- [ ] Prompt engineering and testing
- [ ] API integration with error handling
- [ ] JSON parsing and validation
- [ ] Fallback strategies for low-confidence scans

**Success Criteria:**
- Food type identification accuracy >80% on test dataset
- Volume estimates within ±30% of actual (validated against scale)
- API calls complete in < 5 seconds with 95th percentile

### Phase 4: UX Polish & Testing (Weeks 10-12)

**Deliverables:**
- [ ] Complete UI/UX flow from activation to result display
- [ ] Error handling and recovery guides
- [ ] Performance optimization for all devices
- [ ] Comprehensive testing across food types

**Success Criteria:**
- User task completion rate >90% in usability tests
- Average scan time < 3 seconds (including API call)
- User satisfaction score >4.0/5.0

---

## 9. Testing Strategy

### 9.1 Unit Tests

```dart
// Frame selection algorithm test
void testFrameSelector() {
  final frames = generateTestFrames(qualityVariation: true);
  final selector = FrameSelector();
  
  final selected = selector.selectFrames(frames);
  
  expect(selected.length, equals(3));
  expect(selected[0].timestamp, closeTo(0.0, 0.1)); // ~frame 1
  expect(selected[1].timestamp, closeTo(0.5, 0.1)); // ~frame 15
  expect(selected[2].timestamp, closeTo(1.0, 0.1)); // ~frame 30
  
  // Verify low-quality frames filtered out
  for (var frame in selected) {
    expect(frame.brightness, greaterThan(MIN_BRIGHTNESS));
    expect(frame.motionBlur, lessThan(MAX_BLUR));
  }
}

// Depth calculation test with known volumes
void testLidarVolumeCalculation() {
  final testObjects = [
    {'name': 'sphere', 'volumeCm3': 52.36}, // r=2.5cm sphere
    {'name': 'cube', 'volumeCm3': 1000.0},  // 10x10x10 cm cube
    {'name': 'cylinder', 'volumeCm3': 78.54} // r=2, h=10cm
  ];
  
  for (var obj in testObjects) {
    final mesh = generateTestMesh(obj['name']);
    final calculatedVolume = calculateMeshVolume(mesh);
    
    expect(
      calculatedVolume, 
      closeTo(obj['volumeCm3'], 5.0), // ±5cm³ tolerance
      reason: 'Failed for ${obj['name']}'
    );
  }
}
```

### 9.2 Integration Tests

**Test Matrix:**

| Test Category | Devices to Test | Expected Outcome |
|--------------|-----------------|------------------|
| **LiDAR Accuracy** | iPhone 12 Pro, 13 Pro, 14 Pro, 15 Pro | Volume estimates ±20% of actual weight |
| **ARKit Fallback** | iPhone SE (2nd gen), iPhone XR, iPhone 11 | Volume estimates ±35% of actual weight |
| **ARCore Fallback** | Samsung Galaxy S21, Pixel 6, OnePlus 9 | Volume estimates ±40% of actual weight |
| **Edge Cases** | All devices with: dark food, reflective surfaces, transparent containers | Graceful degradation with appropriate warnings |

### 9.3 User Acceptance Testing

**Participant Criteria:**
- 20+ participants across device types (LiDAR and non-LiDAR)
- Diverse food preferences to test various categories
- Mix of tech-savvy and casual users

**Success Metrics:**
- Time to complete scan: < 15 seconds average
- First-time success rate: >80%
- Confidence in result: >3.5/5.0 average rating
- Willingness to use again: >70% would recommend

---

## 10. Risk Assessment & Mitigation

### Technical Risks

| Risk | Probability | Impact | Mitigation Strategy |
|------|------------|--------|---------------------|
| **LiDAR hardware variance** | Medium | High | Test across all iPhone Pro models; build adaptive calibration |
| **Gemini API latency** | Medium | Medium | Implement timeout with cached fallback results |
| **Low accuracy on certain foods** | High | Medium | Clear UI warnings; manual adjustment tools |
| **Battery drain during scan** | Low | Medium | Optimize camera session; limit to 1-second capture only |

### Business Risks

| Risk | Probability | Impact | Mitigation Strategy |
|------|------------|--------|---------------------|
| **Users expect perfect accuracy** | High | High | Set realistic expectations in onboarding; position as "estimate" |
| **Competitors with better solutions** | Medium | Medium | Focus on UX speed and ease-of-use as differentiators |
| **API cost scaling issues** | Low | Medium | Implement token budgeting; cache results for common foods |

---

## 11. Success Metrics & KPIs

### Technical KPIs

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| Scan completion rate | >90% | Track scans started vs completed |
| Average scan time | <3 seconds | Time from button press to result display |
| API success rate | >95% | Successful Gemini calls / total attempts |
| Crash-free sessions | >99.5% | Firebase Crashlytics data |

### User Experience KPIs

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| Task completion time | <20 seconds | Usability testing observation |
| First-time success rate | >80% | New user scan attempts |
| Result confidence rating | >3.5/5.0 | In-app survey post-scan |
| Manual adjustment usage | <40% of scans | Track slider adjustments after scan |

### Business KPIs

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| Feature adoption rate | >25% of active users | Daily scans / DAU |
| Retention lift | +5% for feature users | Compare 30-day retention vs non-users |
| Support tickets related to accuracy | <2% of total scans | Tag support inquiries by category |

---

## 12. Conclusion & Recommendations

### Key Takeaways

1. **Hybrid approach is feasible:** Combining LiDAR precision with ARKit/ARCore fallback enables broad device coverage while maintaining good accuracy on supported devices.

2. **1-second scan is achievable:** With optimized frame selection and parallel processing, the entire scanning flow can complete in under 3 seconds including API call.

3. **Realistic expectations are critical:** Users must understand this provides estimates, not precise measurements. UI should emphasize confidence levels and offer manual adjustment tools.

4. **Local AI + Cloud AI synergy:** Using local detection for bounding boxes reduces token costs while leveraging Gemini's multimodal capabilities for complex analysis.

### Recommended Next Steps

1. **Start with Phase 1 (Core Framework):** Build basic scanning capability to validate technical feasibility before investing in depth systems.

2. **Conduct rapid prototyping:** Test frame selection algorithms and depth estimation on actual food samples to establish baseline accuracy expectations.

3. **Iterative user testing:** Validate UX flow early with clickable prototypes to refine guidance cues and error states before full implementation.

4. **Monitor API costs carefully:** Implement token budgeting from day one; consider caching strategies for common food types.

### Final Recommendation

**Proceed with Phase 1-2 development**, focusing on:
- Building robust core scanning framework
- Establishing baseline accuracy metrics across device types
- Creating clear user communication about estimation limitations

This phased approach minimizes risk while delivering measurable value to users who have LiDAR devices, and provides a foundation for continuous improvement based on real-world usage data.

---

## Appendix A: Glossary

| Term | Definition |
|------|------------|
| **LiDAR** | Light Detection and Ranging - time-of-flight depth sensor in iPhone Pro models |
| **ARKit Depth API** | iOS framework for estimating scene depth using stereo vision and motion tracking |
| **ARCore Depth API** | Android equivalent to ARKit for depth estimation on supported devices |
| **Parallax Analysis** | 3D reconstruction technique using multiple camera viewpoints to estimate depth |
| **Bounding Box** | Rectangular region containing detected object in image coordinates |
| **Token Budget** | Maximum number of tokens sent to Gemini API per request to control costs |

## Appendix B: References

1. Apple Developer Documentation - ARKit: https://developer.apple.com/documentation/arkit
2. Google ML Kit Image Labeling: https://developers.google.com/ml-kit/image-labeling
3. Gemini API Documentation: https://ai.google.dev/gemini-api/docs
4. IEEE "AR-Based Food Volume Estimation" (2023)

---

*Document Version: 1.0*  
*Last Updated: March 11, 2026*  
*Status: Ready for Phase 1 Planning*
