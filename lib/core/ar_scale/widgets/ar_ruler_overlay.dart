import 'package:flutter/material.dart';
import '../models/detected_object_label.dart';
import '../../widgets/food_entry_image.dart';

/// Widget wrapper — delegates to [BoundingBoxPainter] for consistent styling.
class ArLabelOverlay extends StatelessWidget {
  final List<DetectedObjectLabel> labels;
  final Size imageSize;
  final Widget child;
  final double? pixelPerCm;

  const ArLabelOverlay({
    super.key,
    required this.labels,
    required this.imageSize,
    required this.child,
    this.pixelPerCm,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (labels.isNotEmpty &&
            imageSize.width > 0 &&
            imageSize.height > 0)
          Positioned.fill(
            child: CustomPaint(
              painter: BoundingBoxPainter(
                labels: labels,
                imageWidth: imageSize.width,
                imageHeight: imageSize.height,
                boxFit: BoxFit.contain,
              ),
            ),
          ),
      ],
    );
  }
}
