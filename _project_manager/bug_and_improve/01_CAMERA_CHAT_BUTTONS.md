# Implementation Guide #01: Camera & Chat Button Redesign

**Priority:** 🔴 High  
**Estimated Time:** 2-3 hours  
**Difficulty:** Medium

---

## Overview

Redesign the home screen floating action buttons by adding a camera button next to the chat button and reducing both button sizes. The camera button will open a new camera screen with a gallery picker icon.

---

## Files to Modify

### 1. Home Screen
- **File:** `lib/features/home/presentation/home_screen.dart`
- **Current:** Single `MagicButton` (chat button)
- **Change to:** Two floating buttons (chat + camera)

### 2. Magic Button Widget
- **File:** `lib/features/home/widgets/magic_button.dart`
- **Change:** Reduce size from 64.0 to 48.0

### 3. Create New Camera Screen
- **New File:** `lib/features/camera/presentation/camera_screen.dart`

---

## Step-by-Step Implementation

### STEP 1: Reduce Magic Button Size

**File:** `lib/features/home/widgets/magic_button.dart`

**Find this code:**
```dart
SizedBox(
  width: 64.0,
  height: 64.0,
  child: FloatingActionButton(
```

**Replace with:**
```dart
SizedBox(
  width: 48.0,
  height: 48.0,
  child: FloatingActionButton(
```

---

### STEP 2: Create Camera Screen File

**Create:** `lib/features/camera/presentation/camera_screen.dart`

**Full file content:**
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:miro/core/services/image_picker_service.dart';
import 'package:miro/core/theme/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize camera')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile photo = await _cameraController!.takePicture();
      
      // Copy to permanent location
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(appDir.path, fileName);
      await File(photo.path).copy(filePath);

      if (mounted) {
        Navigator.of(context).pop(File(filePath));
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture photo')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final ImagePickerService imagePickerService = ImagePickerService();
      final File? image = await imagePickerService.pickFromGallery();
      
      if (image != null && mounted) {
        Navigator.of(context).pop(image);
      } else if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      debugPrint('Error picking from gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image from gallery')),
        );
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_isInitialized && _cameraController != null)
            SizedBox.expand(
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Top Bar with Close Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(width: 64), // Spacer for alignment
                    
                    // Capture Button (Center)
                    GestureDetector(
                      onTap: _isProcessing ? null : _takePicture,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Gallery Button (Right)
                    IconButton(
                      onPressed: _isProcessing ? null : _pickFromGallery,
                      icon: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Processing Overlay
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
```

---

### STEP 3: Modify Home Screen to Add Camera Button

**File:** `lib/features/home/presentation/home_screen.dart`

**Find this code (around line 180-190):**
```dart
floatingActionButton: MagicButton(
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChatScreen(),
      ),
    );
  },
),
```

**Replace with:**
```dart
floatingActionButton: Padding(
  padding: const EdgeInsets.only(bottom: 16.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      // Camera Button
      SizedBox(
        width: 48.0,
        height: 48.0,
        child: FloatingActionButton(
          heroTag: 'camera_fab',
          onPressed: () async {
            final File? capturedImage = await Navigator.of(context).push<File>(
              MaterialPageRoute(
                builder: (context) => const CameraScreen(),
              ),
            );
            
            if (capturedImage != null && mounted) {
              // TODO: Navigate to Image Analysis Preview Screen (Task #3)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Image captured: ${capturedImage.path}')),
              );
            }
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
        ),
      ),
      const SizedBox(width: 12),
      
      // Chat Button
      MagicButton(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ChatScreen(),
            ),
          );
        },
      ),
    ],
  ),
),
```

**Add import at the top of the file:**
```dart
import 'dart:io';
import 'package:miro/features/camera/presentation/camera_screen.dart';
```

---

### STEP 4: Add Camera Package Dependency

**File:** `pubspec.yaml`

**Find the `dependencies:` section and check if `camera` is already there.**

If NOT, add:
```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.10.5+5  # Add this line
  # ... other dependencies
```

**Run in terminal:**
```bash
flutter pub get
```

---

### STEP 5: Create Camera Feature Folder Structure

**Create these folders:**
```
lib/features/camera/
  ├── presentation/
  │   └── camera_screen.dart (already created in STEP 2)
```

---

## Testing Checklist

After completing all steps, test the following:

- [ ] Home screen shows **two floating buttons** (camera + chat)
- [ ] Both buttons are **48x48 pixels** (smaller than before)
- [ ] Chat button still opens chat screen normally
- [ ] Camera button opens full-screen camera view
- [ ] Camera preview displays correctly
- [ ] Capture button (white circle) takes a photo
- [ ] Gallery button (bottom-right) opens device gallery
- [ ] After capturing/selecting image, screen closes and returns to home
- [ ] Test on both Android and iOS (if available)
- [ ] Test on small screens (width < 360dp)

---

## Troubleshooting

### Issue: Camera permission denied
**Solution:** Ensure permissions are already requested in `home_screen.dart` `initState()` → `_checkAndRequestPermissions()`

### Issue: Camera package not found
**Solution:** Run `flutter pub get` and restart IDE

### Issue: Buttons overlap or look bad
**Solution:** Adjust `padding` and `SizedBox(width)` spacing in the Row widget

### Issue: Build fails with camera package errors
**Solution (Android):** Ensure `minSdkVersion` is at least 21 in `android/app/build.gradle`
**Solution (iOS):** Add camera permission to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to capture food photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select food images</string>
```

---

## Next Steps

After completing this task:
1. Proceed to **Task #03** (Image Analysis Preview Screen) to handle the captured images
2. The camera screen currently returns the image file to home screen
3. Task #03 will create the preview screen where users can edit food name/quantity before AI analysis

---

## Completion Criteria

✅ Task is complete when:
- Two floating buttons appear on home screen (camera + chat)
- Both buttons are 48x48 pixels
- Camera button opens functional camera screen
- Gallery icon in camera screen opens device gallery
- No build errors or warnings
- All tests in the checklist pass
