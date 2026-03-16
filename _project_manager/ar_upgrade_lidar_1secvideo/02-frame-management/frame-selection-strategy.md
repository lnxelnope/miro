# Frame Selection Strategy & Preprocessing Pipeline

**File:** `02-frame-management/frame-selection-strategy.md`  
**Last Updated:** March 11, 2026

---

## Overview

Optimize the scanning process by capturing only essential frames and preprocessing them for efficient Gemini analysis. This reduces token costs while maintaining accuracy.

---

## 1. Capture Specifications

### Camera Configuration

```dart
class CameraConfiguration {
  
  static final SessionPreset preset = SessionPreset.high; // Maximum quality
  
  static const int frameRate = 30; // Balanced for performance
  
  static const Duration duration = Duration(milliseconds: 1000); // Exactly 1 second
  
  static const Size resolution = Size(1920, 1080); // Preserve full HD
}

// Implementation using camera package
Future<void> initializeScanCamera() async {
  final cameras = await availableCameras();
  
  for (var camera in cameras) {
    if (camera.lensDirection == LensDirection.back) {
      try {
        await cameraDevice.open(camera);
        
        await cameraDevice.setConfiguration(CameraConfiguration(
          sessionPreset: CameraConfiguration.preset,
          videoFormatProfile: VideoFormatProfile.h264,
          maxResolution: camera.maxSupportedVideoResolution,
          videoOrientation: VideoOrientation.videoPortrait,
          audioMode: AudioMode.defaultAudio,
        ));
        
        await cameraDevice.startPreview();
      } catch (e) {
        debugPrint('Failed to initialize scan camera: $e');
      }
    }
  }
}
```

### Buffer Strategy

**Memory-Only Buffering:**
```dart
class FrameBuffer {
  final List<CameraFrame> _frames = [];
  
  void addFrame(CameraFrame frame) {
    if (_frames.length < 30) { // Max 30 frames (1 second at 30fps)
      _frames.add(frame);
    }
  }
  
  List<CameraFrame> get allFrames => List.unmodifiable(_frames);
  
  void clear() {
    _frames.clear();
  }
}

// Usage during scan
Future<void> startScan(FrameBuffer buffer) async {
  final cameraStream = cameraDevice.captureStream();
  
  await for (var frame in cameraStream.take(30)) {
    buffer.addFrame(frame);
  }
  
  // No disk write needed - process directly from memory
}
```

---

## 2. Smart Frame Selection Algorithm

### Quality-Based Filtering

```dart
class CameraFrame {
  final int index; // 0-29
  final double timestamp; // seconds into scan
  final ImageData image;
  final Brightness brightness;
  final double motionBlurScore; // 0.0 (clear) to 1.0 (blurry)
  final double foodCoverageRatio; // Food pixels / total pixels
  
  bool get isValid => 
    brightness.min > 50 && // Minimum brightness threshold
    motionBlurScore < 0.3 && // Acceptable blur level
    foodCoverageRatio > 0.05; // At least 5% food visible
}

class FrameSelector {
  
  List<int> selectFrames(List<CameraFrame> frames) {
    // Step 1: Filter out low-quality frames
    final validFrames = frames.where((frame) => frame.isValid).toList();
    
    if (validFrames.isEmpty) {
      debugPrint('No valid frames detected, using all frames');
      return [0, 15, 29].take(validFrames.length).toList(); // Fallback
    }
    
    // Step 2: Select best frame from each third of scan
    final firstThird = validFrames.take(validFrames.length ~/ 3).toList();
    final secondThird = validFrames.skip(validFrames.length ~/ 3)
                                  .take(validFrames.length ~/ 3);
    final lastThird = validFrames.skip(validFrames.length * 2 ~/ 3);
    
    // Pick best quality frame from each third
    final selectedIndices = [
      _bestFrameIndex(firstThird),
      _bestFrameIndex(secondThird.toList()),
      _bestFrameIndex(lastThird),
    ];
    
    return selectedIndices;
  }
  
  int _bestFrameIndex(Iterable<CameraFrame> frames) {
    final frameList = frames.toList();
    if (frameList.isEmpty) return -1;
    
    // Score based on combination of factors
    return frameList.indexWhere((frame) => 
      frame.brightness * 0.3 + // Brightness matters moderately
      (1.0 - frame.motionBlurScore) * 0.4 + // Sharpness important
      frame.foodCoverageRatio * 0.3 // Food visibility key
    ).toDouble() > 0 ? frameList.first.index : frameList.last.index;
  }
}
```

### Selection Criteria Weights

| Factor | Weight | Description |
|--------|--------|-------------|
| **Brightness** | 30% | Proper lighting for clear detection |
| **Motion Blur** | 40% | Sharp edges critical for depth estimation |
| **Food Coverage** | 30% | Enough food visible in frame |

---

## 3. Preprocessing Pipeline

### Step-by-Step Processing Flow

```dart
class ScanPreprocessor {
  
  Future<ProcessedFrames> preprocess({
    required List<CameraFrame> selectedFrames,
    required List<DetectionResult> detectionResults,
  }) async {
    
    // Step 1: Run object detection on each frame (parallel)
    final detections = await Future.wait(
      selectedFrames.map((frame) => _detectObject(frame))
    );
    
    // Step 2: Calculate consensus bounding box
    final refinedBox = _calculateConsensusBoundingBox(detections);
    
    // Step 3: Crop and normalize each frame
    final processedImages = await Future.wait(
      selectedFrames.asMap().entries.map((entry) async {
        return await _cropAndNormalize(
          entry.value,
          refinedBox,
          index: entry.key
        );
      })
    );
    
    // Step 4: Validate and prepare for API
    final validated = _validateProcessedFrames(processedImages);
    
    return ProcessedFrames(
      frames: validated,
      boundingBox: refinedBox,
      processingTimeMs: DateTime.now().millisecondsSinceEpoch - startTime,
    );
  }
  
  Future<DetectionResult> _detectObject(CameraFrame frame) async {
    // Use ML Kit for local object detection
    final imageLabeler = GoogleMLKit.imageLabeling;
    
    final labels = await imageLabeler.processImage(
      InputImage.fromBytes(
        frame.bytes,
        InputImageMetadata(
          size: frame.size,
          rotation: R90, // Adjust based on device orientation
          format: ImageFormat.nv21,
          planeData: [],
        )
      )
    );
    
    // Filter for food-related labels with high confidence
    final foodLabels = labels.where((label) => 
      label.confidence > 0.7 && 
      [ 'Food', 'Fruit', 'Vegetable', 'Dish', 'Beverage' ].any(
        (foodType) => label.label.contains(foodType)
      )
    );
    
    return DetectionResult(
      frameIndex: frame.index,
      labels: foodLabels,
      boundingBox: _extractBoundingBox(labels.first), // Most confident
      confidence: foodLabels.first.confidence,
    );
  }
  
  BoundingBox _calculateConsensusBoundingBox(List<DetectionResult> detections) {
    if (detections.isEmpty || detections.every((d) => d.boundingBox == null)) {
      return BoundingBox.centerCrop(); // Fallback to center crop
    }
    
    // Combine bounding boxes using intersection-over-union
    final validBoxes = detections.where((d) => d.boundingBox != null);
    
    if (validBoxes.length < 2) {
      return validBoxes.first.boundingBox!; // Only one detection, use it
    }
    
    // Calculate average bounding box
    double minX = validBoxes.map((b) => b.boundingBox!.left).reduce(min);
    double minY = validBoxes.map((b) => b.boundingBox!.top).reduce(min);
    double maxX = validBoxes.map((b) => b.boundingBox!.right).reduce(max);
    double maxY = validBoxes.map((b) => b.boundingBox!.bottom).reduce(max);
    
    // Expand box by 10% for padding
    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;
    final width = (maxX - minX) * 1.1;
    final height = (maxY - minY) * 1.1;
    
    return BoundingBox(
      left: centerX - width / 2,
      top: centerY - height / 2,
      right: centerX + width / 2,
      bottom: centerY + height / 2,
    );
  }
  
  Future<ProcessedImage> _cropAndNormalize(
    CameraFrame frame,
    BoundingBox box, {
    required int index,
  }) async {
    
    // Crop to bounding box with padding
    final cropped = await imageProcessor.crop(
      frame.image,
      box: box,
      paddingPercent: 10,
    );
    
    // Resize to optimal dimensions for Gemini (keeps aspect ratio)
    final resized = await imageProcessor.resize(
      cropped,
      maxWidth: 1024,
      maxHeight: 1024,
      maintainAspectRatio: true,
    );
    
    // Compress for API transmission
    final compressed = await imageProcessor.compress(
      resized,
      quality: 75, // JPEG quality (balance between size and quality)
    );
    
    return ProcessedImage(
      index: index,
      base64Data: base64Encode(compressed),
      originalWidth: frame.size.width,
      originalHeight: frame.size.height,
      croppedWidth: resized.width,
      croppedHeight: resized.height,
      fileBytes: compressed.length,
    );
  }
}

// Result structure after preprocessing
class ProcessedFrames {
  final List<ProcessedImage> frames;
  final BoundingBox boundingBox;
  final int processingTimeMs;
  
  ProcessedFrames({
    required this.frames,
    required this.boundingBox,
    required this.processingTimeMs,
  });
}

class ProcessedImage {
  final int index; // 0, 1, or 2
  final String base64Data;
  final int originalWidth, originalHeight;
  final int croppedWidth, croppedHeight;
  final int fileBytes; // Compressed size in bytes
  
  double get compressionRatio => 
    ((originalWidth * originalHeight) / fileBytes).toDouble();
}

class BoundingBox {
  final double left, top, right, bottom;
  
  BoundingBox({required this.left, required this.top, 
              required this.right, required this.bottom});
  
  static BoundingBox centerCrop() {
    return BoundingBox(left: 0.3, top: 0.3, right: 0.7, bottom: 0.7);
  }
  
  double get width => right - left;
  double get height => bottom - top;
}
```

---

## 4. File Size Optimization

### Compression Strategy Comparison

| Method | Quality | Avg File Size | PSNR (vs original) | Recommendation |
|--------|---------|---------------|-------------------|----------------|
| **Original JPEG** | 100% | ~2MB/frame | ∞ | ❌ Too large for API |
| **Quality 90%** | High | ~800KB/frame | 42dB | ⚠️ Still expensive |
| **Quality 75%** | Good | ~300KB/frame | 36dB | ✅ Best balance |
| **Quality 60%** | Medium | ~150KB/frame | 32dB | ⚡ Use if token budget tight |

### Implementation with Quality Control

```dart
Future<List<int>> compressImage(Image image, int quality) async {
  // Validate quality doesn't drop below acceptable threshold
  assert(quality >= 60 && quality <= 100);
  
  final compressed = await ImageCompressor.compress(
    image,
    format: CompressionFormat.jpeg,
    quality: quality,
  );
  
  // Verify compression ratio is reasonable
  final originalSize = image.height * image.width * 3; // RGB bytes
  final compressedSize = compressed.length;
  final ratio = originalSize / compressedSize;
  
  if (ratio < 5) {
    debugPrint('Low compression ratio: $ratio, may indicate already-compressed image');
  }
  
  return compressed;
}

// Quality adjustment based on lighting conditions
int getOptimalQuality(LightingConditions lighting) {
  switch (lighting.quality) {
    case LightingQuality.excellent:
      return 85; // Can afford higher quality in good light
    
    case LightingQuality.good:
      return 75; // Standard quality
    
    case LightingQuality.poor:
      return 60; // Lower quality OK since original was poor anyway
    
    default:
      return 75; // Fallback to standard
  }
}
```

---

## 5. Bounding Box Refinement

### Multi-Frame Consensus Algorithm

```dart
class BoundingBoxRefiner {
  
  BoundingBox refine(List<DetectionResult> detections) {
    if (detections.isEmpty) return BoundingBox.centerCrop();
    
    // Collect all bounding boxes with confidence scores
    final validDetections = detections.where((d) => 
      d.boundingBox != null && d.confidence > 0.5
    ).toList();
    
    if (validDetections.length < 2) {
      // Not enough detections, use highest confidence single box
      return detections.fold<BoundingBox?>(null, (best, current) {
        if (current.boundingBox == null || best == null) return current.boundingBox;
        return current.confidence > best.confidence ? current.boundingBox : best;
      });
    }
    
    // Weighted average based on confidence scores
    double totalWeight = 0;
    final weightedBox = validDetections.fold<BoundingBox?>(null, (acc, det) {
      if (det.boundingBox == null) return acc;
      
      totalWeight += det.confidence;
      
      if (acc == null) {
        return BoundingBox(
          left: det.boundingBox!.left * det.confidence,
          top: det.boundingBox!.top * det.confidence,
          right: det.boundingBox!.right * det.confidence,
          bottom: det.boundingBox!.bottom * det.confidence,
        );
      } else {
        return BoundingBox(
          left: acc.left + det.boundingBox!.left * det.confidence,
          top: acc.top + det.boundingBox!.top * det.confidence,
          right: acc.right + det.boundingBox!.right * det.confidence,
          bottom: acc.bottom + det.boundingBox!.bottom * det.confidence,
        );
      }
    });
    
    // Normalize by total weight
    if (weightedBox != null && totalWeight > 0) {
      return BoundingBox(
        left: weightedBox.left / totalWeight,
        top: weightedBox.top / totalWeight,
        right: weightedBox.right / totalWeight,
        bottom: weightedBox.bottom / totalWeight,
      );
    }
    
    return BoundingBox.centerCrop();
  }
}

// IOU (Intersection over Union) for box merging
double calculateIoU(BoundingBox box1, BoundingBox box2) {
  // Calculate intersection area
  final double x1 = max(box1.left, box2.left);
  final double y1 = max(box1.top, box2.top);
  final double x2 = min(box1.right, box2.right);
  final double y2 = min(box1.bottom, box2.bottom);
  
  final double intersectionWidth = max(0.0, x2 - x1);
  final double intersectionHeight = max(0.0, y2 - y1);
  
  if (intersectionWidth == 0 || intersectionHeight == 0) return 0;
  
  final double intersectionArea = intersectionWidth * intersectionHeight;
  
  // Calculate union area
  final double box1Area = box1.width * box1.height;
  final double box2Area = box2.width * box2.height;
  
  final double unionArea = box1Area + box2Area - intersectionArea;
  
  return intersectionArea / unionArea;
}

// Merge overlapping boxes before averaging
List<BoundingBox> mergeOverlappingBoxes(List<DetectionResult> detections) {
  final List<BoundingBox> boxes = [];
  final List<double> confidences = [];
  
  for (var det in detections) {
    if (det.boundingBox == null || det.confidence < 0.5) continue;
    
    bool merged = false;
    for (int i = 0; i < boxes.length && !merged; i++) {
      if (calculateIoU(boxes[i], det.boundingBox!) > 0.3) { // 30% overlap threshold
        // Merge boxes by averaging
        final mergedBox = BoundingBox(
          left: (boxes[i].left + det.boundingBox!.left) / 2,
          top: (boxes[i].top + det.boundingBox!.top) / 2,
          right: (boxes[i].right + det.boundingBox!.right) / 2,
          bottom: (boxes[i].bottom + det.boundingBox!.bottom) / 2,
        );
        
        // Average confidences
        final avgConfidence = (boxes[i] as dynamic).confidence * 0.5 + 
                             det.confidence * 0.5;
        
        boxes[i] = mergedBox;
        confidences[i] = avgConfidence;
        merged = true;
      }
    }
    
    if (!merged) {
      boxes.add(det.boundingBox!);
      confidences.add(det.confidence);
    }
  }
  
  return boxes;
}
```

---

## 6. Metadata Generation for API

### Complete Preprocessing Output

```dart
class ScanMetadataGenerator {
  
  Map<String, dynamic> generateMetadata({
    required List<ProcessedImage> processedFrames,
    required BoundingBox finalBoundingBox,
    required DeviceHardware hardwareInfo,
    required LightingConditions lighting,
    required Duration totalProcessingTime,
  }) {
    
    return {
      'scanMetadata': {
        'frameCount': processedFrames.length,
        'captureDurationMs': 1000, // Fixed at 1 second
        'lensType': hardwareInfo.lensType ?? 'wide',
        'flashUsed': false,
        'lightingQuality': lighting.quality.name,
        'processingTimeMs': totalProcessingTime.inMilliseconds,
      },
      
      'deviceInfo': {
        'model': hardwareInfo.deviceModel,
        'hasLiDAR': hardwareInfo.hasLiDAR,
        'osVersion': hardwareInfo.osVersion,
        'appVersion': '1.0.0',
      },
      
      'boundingBox': {
        'x': finalBoundingBox.left,
        'y': finalBoundingBox.top,
        'width': finalBoundingBox.width,
        'height': finalBoundingBox.height,
        'confidence': _calculateBoundingBoxConfidence(processedFrames),
      },
      
      'frameMetadata': processedFrames.map((frame) => {
        'index': frame.index,
        'timestampOffsetMs': frame.index * 33, // ~33ms between frames at 30fps
        'originalDimensions': '${frame.originalWidth}x${frame.originalHeight}',
        'croppedDimensions': '${frame.croppedWidth}x${frame.croppedHeight}',
        'fileSizeBytes': frame.fileBytes,
        'compressionRatio': frame.compressionRatio.toStringAsFixed(2),
      }).toList(),
      
      'qualityMetrics': {
        'averageBrightness': lighting.averageBrightness,
        'motionBlurDetected': lighting.motionBlurScore > 0.3,
        'reflectionDetected': lighting.reflectionScore > 0.5,
      }
    };
  }
  
  double _calculateBoundingBoxConfidence(List<ProcessedImage> frames) {
    // Confidence based on:
    // - Number of frames with valid food detection
    // - Consistency across frames (low IoU variance)
    
    final consistentFrames = frames.where((f) => f.croppedWidth > 100).length;
    final consistencyRatio = consistentFrames / frames.length;
    
    return consistencyRatio;
  }
}

class DeviceHardware {
  final String deviceModel;
  final bool hasLiDAR;
  final String lensType;
  final String osVersion;
  
  DeviceHardware({
    required this.deviceModel,
    required this.hasLiDAR,
    required this.lensType,
    required this.osVersion,
  });
}

class LightingConditions {
  final double averageBrightness; // 0-255
  final double motionBlurScore; // 0.0 (none) to 1.0 (severe)
  final double reflectionScore; // 0.0 (none) to 1.0 (severe)
  
  LightingQuality get quality {
    if (averageBrightness < 60 || motionBlurScore > 0.5) {
      return LightingQuality.poor;
    } else if (averageBrightness < 120) {
      return LightingQuality.fair;
    } else {
      return LightingQuality.good;
    }
  }
}

enum LightingQuality { excellent, good, fair, poor }
```

---

## Summary

This preprocessing pipeline:
- ✅ Captures exactly 30 frames in 1 second at 30fps
- ✅ Selects optimal 3 frames based on quality metrics
- ✅ Uses local AI (ML Kit) for bounding box detection
- ✅ Combines multiple detections into consensus box
- ✅ Compresses images to optimize token usage (~900KB total vs 6MB raw)
- ✅ Generates comprehensive metadata for Gemini API

**Next Steps:** Integrate with Hybrid Depth System (`../03-hybrid-depth/hybrid-depth-system.md`) for complete scanning pipeline.
