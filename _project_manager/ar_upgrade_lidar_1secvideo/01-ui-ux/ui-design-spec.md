# AR Scan UI/UX Design: The "1-Second Scan" Flow

**File:** `01-ui-ux/ui-design-spec.md`  
**Last Updated:** March 11, 2026

---

## Overview

Transform the scanning experience from static photo capture to dynamic AR-guided rotation for better volume estimation.

---

## 1. Action Button Redesign

### Current State
- Button: "ถ่ายรูป" (Take Photo)
- Behavior: Single static capture
- Feedback: Minimal

### New Design: "สแกนด้วย AR"

**Button Appearance:**
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
  decoration: BoxDecoration(
    gradient: LinearGradient(colors: [brandPrimary, brandSecondary]),
    borderRadius: BorderRadius.circular(50),
    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]
  ),
  child: Row(
    children: [
      Icon(Icons.camera_alt_rounded), // Animated rotation icon
      Text('สแกนด้วย AR', style: TextStyle(fontSize: 16)),
    ],
  ),
)
```

**Microcopy Options:**
- **Default:** "สแกนด้วย AR" / "Scan with AR"
- **Hover/Long press:** "วนรอบอาหาร 1 วินาที" / "Rotate around food for 1 second"

---

## 2. User Guidance System (On Activation)

### Initial Screen Layout

```dart
Scaffold(
  body: Stack(
    children: [
      // Camera preview background
      CameraPreview(),
      
      // Overlay guidance UI
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main instruction card
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12)
            ),
            child: Column(
              children: [
                Icon(Icons.photo_camera_rounded, size: 32, color: Colors.white),
                SizedBox(height: 8),
                Text('🎯 สแกนอาหารแบบ AR', 
                     style: TextStyle(color: Colors.white, fontSize: 18)),
                SizedBox(height: 4),
                Text('วางอาหารในวงกลม', 
                     style: TextStyle(color: Colors.grey[300])),
                Text('หมุนกล้องช้าๆ รอบอาหาร', 
                     style: TextStyle(color: Colors.grey[300])),
                Text('(ใช้เวลาประมาณ 1 วินาที)', 
                     style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          // Visual guide overlay (see next section)
        ],
      ),
    ],
  ),
)
```

---

## 3. Guiding Circle & Rotation Arrow

### Visual Elements

**Guiding Circle:**
- **Purpose:** Show optimal food positioning area
- **Size:** ~30cm diameter at typical distance (15-20 inches)
- **Appearance:** Semi-transparent white ring, 4px width
- **Positioning:** Centered on screen initially

**Rotation Arrow:**
- **Direction:** Clockwise (standard for most users)
- **Animation:** Pulsing arrow that rotates to show direction
- **Color:** White with subtle glow effect

### Implementation Code

```dart
class GuidingCircle extends StatefulWidget {
  @override
  _GuidingCircleState createState() => _GuidingCircleState();
}

class _GuidingCircleState extends State<GuidingCircle> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );
    
    _rotationAnimation = Tween<double>(begin: 0, end: 360).animate(
      _controller
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _startScan(),
      child: Center(
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: CirclePainter(
                opacity: _pulseAnimation.value,
                rotationAngle: _rotationAnimation.value,
              ),
              size: Size(300, 300),
            );
          },
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double opacity;
  final double rotationAngle;
  
  CirclePainter({required this.opacity, required this.rotationAngle});
  
  @override
  void paint(Canvas canvas, Size size) {
    // Main guiding circle
    final mainCircle = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    // Rotation arrow indicator
    final arrowPaint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    // Draw circle with rotation
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotationAngle * pi / 180);
    
    canvas.drawCircle(Offset.zero, 140, mainCircle);
    
    // Draw arrow at top (indicating rotation direction)
    canvas.save();
    canvas.translate(0, -135);
    _drawArrow(canvas, arrowPaint);
    canvas.restore();
    
    canvas.restore();
  }
  
  void _drawArrow(Canvas canvas, Paint paint) {
    final path = Path()
      ..moveTo(-8, 0)
      ..lineTo(8, 0)
      ..lineTo(6, -4)
      ..close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

---

## 4. Progress Indicator

### Circular Progress Bar During Scan

```dart
class ScanProgressIndicator extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  
  @override
  _ScanProgressIndicatorState createState() => _ScanProgressIndicatorState();
}

class _ScanProgressIndicatorState extends State<ScanProgressIndicator> {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: widget.progress,
            strokeWidth: 4,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          if (widget.progress < 1.0)
            Text(
              '${(widget.progress * 3).round()}', // Show "3", "2", or "1"
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Icon(Icons.check, color: Colors.green, size: 28),
        ],
      ),
    );
  }
}

// Usage during scan
class ScanOverlay extends StatelessWidget {
  final double scanProgress;
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Center(
        child: ScanProgressIndicator(progress: scanProgress),
      ),
    );
  }
}
```

**Animation States:**
- **0.0 - 0.3:** Initial rotation (countdown "3")
- **0.3 - 0.7:** Middle rotation (countdown "2")  
- **0.7 - 1.0:** Final rotation (countdown "1")
- **1.0:** Complete (checkmark)

---

## 5. Real-Time Visual Feedback

### Bounding Box Overlay (Local AI Processing)

```dart
class BoundingBoxOverlay extends StatelessWidget {
  final Rect foodBoundingBox;
  final bool isTracking;
  
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: BoxPainter(
          box: foodBoundingBox,
          color: isTracking ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}

class BoxPainter extends CustomPainter {
  final Rect box;
  final Color color;
  
  BoxPainter({required this.box, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    // Draw rounded rectangle
    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      box,
      Radius.circular(8),
    ));
    
    canvas.drawPath(path, borderPaint);
    
    // Corner markers
    final cornerPaint = Paint()..color = color;
    final cornerSize = 12.0;
    
    // Top-left
    canvas.drawLine(
      Offset(box.left, box.top),
      Offset(box.left + cornerSize, box.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(box.left, box.top),
      Offset(box.left, box.top + cornerSize),
      cornerPaint,
    );
    
    // Top-right
    canvas.drawLine(
      Offset(box.right - cornerSize, box.top),
      Offset(box.right, box.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(box.right, box.top),
      Offset(box.right, box.top + cornerSize),
      cornerPaint,
    );
    
    // Bottom-left and bottom-right... (similar pattern)
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Wireframe mode when tracking unstable
class WireframePainter extends CustomPainter {
  final Rect box;
  
  WireframePainter({required this.box});
  
  @override
  void paint(Canvas canvas, Size size) {
    final dashedPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    
    // Create dashed effect
    pathEffect = DashPathEffect();
    
    canvas.drawRect(box, dashedPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

### Depth Heatmap (Optional - LiDAR Only)

```dart
class DepthHeatmapOverlay extends StatelessWidget {
  final Map<Vector2d, double> depthValues; // x, y -> distance in cm
  
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: HeatmapPainter(depthValues),
        size: Size.infinite,
      ),
    );
  }
}

class HeatmapPainter extends CustomPainter {
  final Map<Vector2d, double> depthValues;
  
  static Color distanceToColor(double distance) {
    // Blue (close) to Red (far) gradient
    if (distance < 10) return Colors.blue.withOpacity(0.3);
    if (distance < 15) return Colors.cyan.withOpacity(0.3);
    if (distance < 20) return Colors.green.withOpacity(0.3);
    if (distance < 25) return Colors.yellow.withOpacity(0.3);
    return Colors.red.withOpacity(0.3);
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    for (var entry in depthValues.entries) {
      final x = entry.key.x;
      final y = entry.key.y;
      final distance = entry.value;
      
      final paint = Paint()
        ..color = distanceToColor(distance);
      
      canvas.drawCircle(Offset(x * size.width, y * size.height), 2, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

---

## 6. Feedback States & Transitions

### State Machine for Scan Feedback

```dart
enum ScanFeedbackState {
  ready,      // Awaiting user interaction
  tracking,   // Successfully detecting food
  lost,       // Lost track of food
  complete,   // Scan finished successfully
  error,      // Error occurred
}

class ScanFeedbackController extends ChangeNotifier {
  ScanFeedbackState _state = ScanFeedbackState.ready;
  
  ScanFeedbackState get state => _state;
  
  void setState(ScanFeedbackState newState) {
    _state = newState;
    notifyListeners();
    
    // Haptic feedback based on state
    switch (newState) {
      case ScanFeedbackState.tracking:
        HapticManager.lightHaptic();
        break;
      case ScanFeedbackState.lost:
        HapticManager.mediumHaptic();
        break;
      case ScanFeedbackState.complete:
        HapticManager.successHaptic();
        break;
      default:
        break;
    }
  }
}

// UI responsive to state changes
class StateResponsiveOverlay extends StatelessWidget {
  final ScanFeedbackController controller;
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ScanFeedbackState>(
      stream: controller.stream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        
        switch (state) {
          case ScanFeedbackState.ready:
            return ReadyGuide();
          
          case ScanFeedbackState.tracking:
            return TrackingGuide();
          
          case ScanFeedbackState.lost:
            return LostFoodGuide();
          
          case ScanFeedbackState.complete:
            return SuccessIndicator();
          
          default:
            return Container();
        }
      },
    );
  }
}

class ReadyGuide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.photo_camera_rounded, size: 48, color: Colors.white),
          SizedBox(height: 16),
          Text('แตะเพื่อเริ่มสแกน', style: TextStyle(color: Colors.white)),
          Text('(Tap to start scanning)', style: TextStyle(
            color: Colors.grey[300], fontSize: 12
          ))
        ],
      ),
    );
  }
}

class TrackingGuide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.check_circle_outline_rounded, 
               size: 48, color: Colors.green),
          SizedBox(height: 16),
          Text('กำลังสแกน...', style: TextStyle(color: Colors.white)),
          Text('(Scanning...)', style: TextStyle(
            color: Colors.grey[300], fontSize: 12
          ))
        ],
      ),
    );
  }
}

class LostFoodGuide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.warning_amber_rounded, 
               size: 48, color: Colors.orange),
          SizedBox(height: 16),
          Text('อาหารหายไปจากจอ', style: TextStyle(color: Colors.white)),
          Text('(Food out of view)', style: TextStyle(
            color: Colors.grey[300], fontSize: 12
          )),
          SizedBox(height: 8),
          Text('หมุนช้าลง - ให้อาหารอยู่ในกรอบ', 
               style: TextStyle(color: Colors.yellow[700], fontSize: 12))
        ],
      ),
    );
  }
}

class SuccessIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_circle_rounded, 
                  size: 64, color: Colors.green),
      ),
    );
  }
}
```

---

## 7. Post-Scan Result Display

### Result Card with Confidence Indicator

```dart
class ScanResultCard extends StatelessWidget {
  final FoodScanResult result;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8)
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary calorie display
          Text('แคลอรี่โดยประมาณ', 
               style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          
          SizedBox(height: 8),
          
          Row(
            children: [
              Text('${result.totalCalories.toInt()}', 
                   style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
              Text(' kcal', style: TextStyle(fontSize: 20)),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Confidence indicator
          Row(
            children: [
              Icon(_getConfidenceIcon(), 
                   color: _getConfidenceColor(), size: 24),
              SizedBox(width: 8),
              Text(_getConfidenceText(), style: TextStyle(fontSize: 16)),
            ],
          ),
          
          // Manual adjustment slider (if confidence low)
          if (result.confidence < 0.7) ...[
            Divider(height: 24),
            
            Text('ปรับค่าประมาณ', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            
            Slider(
              value: _adjustmentFactor,
              min: 0.5,
              max: 1.5,
              divisions: 10,
              onChanged: (value) {
                setState(() => _adjustmentFactor = value);
              },
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ลด 50%', style: TextStyle(color: Colors.grey[600])),
                Text('เพิ่ม 50%', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ],
          
          SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(child: _buildCancelButton()),
              SizedBox(width: 12),
              Expanded(child: _buildSaveButton()),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getConfidenceColor() {
    if (result.confidence >= 0.8) return Colors.green;
    if (result.confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
  
  Icon _getConfidenceIcon() {
    return Icon(
      result.confidence >= 0.8 ? Icons.check_circle : 
      result.confidence >= 0.6 ? Icons.info_outline : 
      Icons.error_outline,
    );
  }
  
  String _getConfidenceText() {
    if (result.confidence >= 0.8) return 'ความมั่นใจสูง';
    if (result.confidence >= 0.6) return 'ความมั่นใจปานกลาง';
    return 'ความมั่นใจต่ำ - แนะนำตรวจสอบ';
  }
}
```

---

## 8. Error States & Recovery Guides

### Comprehensive Error Handling UI

```dart
class ErrorGuideOverlay extends StatelessWidget {
  final ScanErrorType errorType;
  
  @override
  Widget build(BuildContext context) {
    switch (errorType) {
      case ScanErrorType.tooDark:
        return _buildLightingGuide(Colors.orange);
      
      case ScanErrorType.motionBlur:
        return _buildStabilityGuide(Colors.orange);
      
      case ScanErrorType.reflectionIssue:
        return _buildReflectionGuide(Colors.amber);
      
      case ScanErrorType.scaleAmbiguous:
        return _buildReferenceObjectGuide();
      
      default:
        return Container();
    }
  }
  
  Widget _buildLightingGuide(Color iconColor) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.wb_sunny_outlined, 
               size: 48, color: iconColor),
          SizedBox(height: 16),
          Text('เพิ่มแสงสว่างเพื่อผลลัพธ์ที่ดีขึ้น', style: TextStyle(color: Colors.white)),
          Text('(Add more light for better results)', style: TextStyle(
            color: Colors.grey[300], fontSize: 12
          ))
        ],
      ),
    );
  }
  
  Widget _buildStabilityGuide(Color iconColor) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.handyman_rounded, 
               size: 48, color: iconColor),
          SizedBox(height: 16),
          Text('ถือให้มั่นคงขึ้น', style: TextStyle(color: Colors.white)),
          Text('(Hold steadier)', style: TextStyle(
            color: Colors.grey[300], fontSize: 12
          ))
        ],
      ),
    );
  }
  
  Widget _buildReflectionGuide(Color iconColor) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.adjust, 
               size: 48, color: iconColor),
          SizedBox(height: 16),
          Text('เปลี่ยนมุมกล้องเพื่อลดการสะท้อน', style: TextStyle(color: Colors.white)),
          Text('(Try different angle to reduce glare)', style: TextStyle(
            color: Colors.grey[300], fontSize: 12
          ))
        ],
      ),
    );
  }
  
  Widget _buildReferenceObjectGuide() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.ruler_rounded, 
               size: 48, color: Colors.blue),
          SizedBox(height: 16),
          Text('วางวัตถุล่วงหน้าเพื่อช่วยคำนวณขนาด', style: TextStyle(color: Colors.white)),
          Text('(Place reference object like a plate)', style: TextStyle(
            color: Colors.grey[300], fontSize: 12
          ))
        ],
      ),
    );
  }
}

enum ScanErrorType {
  tooDark,
  motionBlur,
  reflectionIssue,
  scaleAmbiguous,
}
```

---

## Summary

This UI/UX design provides:
- ✅ Clear visual guidance for users during scanning
- ✅ Real-time feedback through bounding boxes and progress indicators
- ✅ Error states with actionable recovery guides
- ✅ Post-scan results with confidence indicators and manual adjustment options

**Next Steps:** Implement this UI layer alongside the frame management system (see `../02-frame-management/frame-selection-strategy.md`) for complete scanning flow.
