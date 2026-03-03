import 'dart:io';

import 'package:miro_hybrid/core/database/model_extensions.dart';
import 'package:miro_hybrid/core/ar_scale/models/detected_object_label.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Shared image widget for FoodEntry with 3-tier fallback:
///   1. Local file (imagePath) — available when on same device
///   2. Thumbnail URL (thumbnailUrl) — available after cloud restore
///   3. Placeholder icon — when no image source exists
class FoodEntryImage extends StatelessWidget {
  final FoodEntry entry;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;

  const FoodEntryImage({
    super.key,
    required this.entry,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(8);

    if (entry.hasLocalImage) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.file(
          File(entry.imagePath!),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildThumbnailOrPlaceholder(radius),
        ),
      );
    }

    return _buildThumbnailOrPlaceholder(radius);
  }

  Widget _buildThumbnailOrPlaceholder(BorderRadius radius) {
    if (entry.hasThumbnailUrl) {
      return ClipRRect(
        borderRadius: radius,
        child: CachedNetworkImage(
          imageUrl: entry.thumbnailUrl!,
          width: width,
          height: height,
          fit: fit,
          placeholder: (_, __) => _defaultPlaceholder(),
          errorWidget: (_, __, ___) => _defaultPlaceholder(),
        ),
      );
    }

    return placeholder ?? _defaultPlaceholder();
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.restaurant_rounded,
        size: width * 0.4,
        color: Colors.grey.withValues(alpha: 0.4),
      ),
    );
  }
}

/// Image with bounding box overlay — for use in detail sheets.
/// Renders with BoxFit.cover + ClipRRect, overlay scales accordingly.
class FoodEntryImageWithOverlay extends StatelessWidget {
  final FoodEntry entry;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const FoodEntryImageWithOverlay({
    super.key,
    required this.entry,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(8);
    final labels = DetectedObjectLabel.decode(entry.arLabelsJson);
    final hasOverlay = labels.isNotEmpty &&
        entry.arImageWidth != null &&
        entry.arImageHeight != null;

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(radius),
            if (hasOverlay)
              CustomPaint(
                painter: BoundingBoxPainter(
                  labels: labels,
                  imageWidth: entry.arImageWidth!,
                  imageHeight: entry.arImageHeight!,
                  boxFit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BorderRadius radius) {
    if (entry.hasLocalImage) {
      return Image.file(
        File(entry.imagePath!),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildThumbnailOrPlaceholder(),
      );
    }
    return _buildThumbnailOrPlaceholder();
  }

  Widget _buildThumbnailOrPlaceholder() {
    if (entry.hasThumbnailUrl) {
      return CachedNetworkImage(
        imageUrl: entry.thumbnailUrl!,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
    return Container(
      color: Colors.grey.withValues(alpha: 0.1),
      child: Icon(
        Icons.restaurant_rounded,
        size: width * 0.4,
        color: Colors.grey.withValues(alpha: 0.4),
      ),
    );
  }
}

/// Full-screen image viewer with bounding box overlay.
class FoodEntryFullScreenImage extends StatefulWidget {
  final FoodEntry entry;

  const FoodEntryFullScreenImage({super.key, required this.entry});

  @override
  State<FoodEntryFullScreenImage> createState() =>
      _FoodEntryFullScreenImageState();
}

class _FoodEntryFullScreenImageState extends State<FoodEntryFullScreenImage> {
  bool _showOverlay = true;

  List<DetectedObjectLabel> get _labels =>
      DetectedObjectLabel.decode(widget.entry.arLabelsJson);

  bool get _hasLabels =>
      _labels.isNotEmpty &&
      widget.entry.arImageWidth != null &&
      widget.entry.arImageHeight != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_hasLabels)
            IconButton(
              icon: Icon(
                _showOverlay ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _showOverlay = !_showOverlay),
              tooltip: 'Toggle detection overlay',
            ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: _hasLabels ? _buildImageWithOverlay() : _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImageWithOverlay() {
    return Stack(
      children: [
        _buildImage(),
        if (_showOverlay)
          Positioned.fill(
            child: CustomPaint(
              painter: BoundingBoxPainter(
                labels: _labels,
                imageWidth: widget.entry.arImageWidth!,
                imageHeight: widget.entry.arImageHeight!,
                boxFit: BoxFit.contain,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImage() {
    if (widget.entry.hasLocalImage) {
      return Image.file(
        File(widget.entry.imagePath!),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildNetworkOrError(),
      );
    }
    return _buildNetworkOrError();
  }

  Widget _buildNetworkOrError() {
    if (widget.entry.hasThumbnailUrl) {
      return CachedNetworkImage(
        imageUrl: widget.entry.thumbnailUrl!,
        fit: BoxFit.contain,
        placeholder: (_, __) => const CircularProgressIndicator(
          color: Colors.white54,
        ),
        errorWidget: (_, __, ___) => _brokenIcon(),
      );
    }
    return _brokenIcon();
  }

  Widget _brokenIcon() {
    return const Icon(
      Icons.broken_image_rounded,
      size: 64,
      color: Colors.white54,
    );
  }
}

/// Paints bounding boxes on top of a food image.
/// Supports both BoxFit.contain (full-screen) and BoxFit.cover (detail sheet).
class BoundingBoxPainter extends CustomPainter {
  final List<DetectedObjectLabel> labels;
  final double imageWidth;
  final double imageHeight;
  final BoxFit boxFit;

  BoundingBoxPainter({
    required this.labels,
    required this.imageWidth,
    required this.imageHeight,
    this.boxFit = BoxFit.contain,
  });

  static const _foodLabels = {'Food', 'Meal', 'Dish', 'Cuisine', 'Baked goods'};

  bool _isFood(String label) =>
      _foodLabels.any((f) => label.toLowerCase().contains(f.toLowerCase()));

  @override
  void paint(Canvas canvas, Size size) {
    if (imageWidth <= 0 || imageHeight <= 0) return;

    final scaleX = size.width / imageWidth;
    final scaleY = size.height / imageHeight;

    late final double scale;
    late final double offsetX;
    late final double offsetY;

    if (boxFit == BoxFit.cover) {
      scale = scaleX > scaleY ? scaleX : scaleY;
      offsetX = (size.width - imageWidth * scale) / 2;
      offsetY = (size.height - imageHeight * scale) / 2;
    } else {
      scale = scaleX < scaleY ? scaleX : scaleY;
      offsetX = (size.width - imageWidth * scale) / 2;
      offsetY = (size.height - imageHeight * scale) / 2;
    }

    for (final label in labels) {
      final isFood = _isFood(label.label);

      final left = offsetX + (label.centerX - label.bboxWidth / 2) * scale;
      final top = offsetY + (label.centerY - label.bboxHeight / 2) * scale;
      final w = label.bboxWidth * scale;
      final h = label.bboxHeight * scale;
      final rect = Rect.fromLTWH(left, top, w, h);

      final confPct = (label.confidence * 100).toStringAsFixed(0);

      if (isFood) {
        final boxPaint = Paint()
          ..color = const Color(0xFF4CAF50)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        final fillPaint = Paint()
          ..color = const Color(0xFF4CAF50).withValues(alpha: 0.08);

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          fillPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          boxPaint,
        );

        _drawLabel(canvas, 'Food $confPct%', rect.left, rect.top - 20,
            const Color(0xFF4CAF50), Colors.white);
      } else {
        final badgePaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          badgePaint,
        );

        _drawLabel(canvas, '${label.label} $confPct%', rect.left, rect.top - 18,
            const Color(0xFF212121), Colors.white);
      }
    }
  }

  void _drawLabel(Canvas canvas, String text, double x, double y,
      Color bgColor, Color textColor) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, textPainter.width + 10, textPainter.height + 4),
      const Radius.circular(3),
    );
    canvas.drawRRect(bgRect, Paint()..color = bgColor.withValues(alpha: 0.9));
    textPainter.paint(canvas, Offset(x + 5, y + 2));
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) =>
      labels != oldDelegate.labels;
}

/// Shows full-screen image if viewable, otherwise shows a snackbar message.
void showFoodEntryImage(BuildContext context, FoodEntry entry) {
  if (!entry.hasAnyImage) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => FoodEntryFullScreenImage(entry: entry),
      fullscreenDialog: true,
    ),
  );
}
