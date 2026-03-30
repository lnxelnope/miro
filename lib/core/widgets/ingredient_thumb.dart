import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:miro_hybrid/core/theme/app_colors.dart';
import 'package:miro_hybrid/core/theme/app_tokens.dart';
import 'package:miro_hybrid/l10n/app_localizations.dart';

/// Small optional thumbnail for an ingredient row; [SizedBox.shrink] when no path.
class IngredientThumb extends StatelessWidget {
  final String? imagePath;
  final double size;
  final VoidCallback? onTap;

  const IngredientThumb({
    super.key,
    required this.imagePath,
    this.size = 28,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    if (path == null || path.isEmpty) return const SizedBox.shrink();

    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dividerDark
        : AppColors.divider;

    final child = ClipRRect(
      borderRadius: AppRadius.sm,
      child: Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.sm,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.sm,
              border: Border.all(color: borderColor.withValues(alpha: 0.4)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Full-screen preview with optional normalized bbox overlay (`x,y,w,h` in 0–1).
  static void showFullScreen(
    BuildContext context,
    String imagePath, {
    String? arBoundingBox,
  }) {
    final l10n = L10n.of(context)!;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (ctx) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.close),
              tooltip: l10n.close,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: _FullScreenIngredientImage(
                path: imagePath,
                arBoundingBox: arBoundingBox,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FullScreenIngredientImage extends StatelessWidget {
  final String path;
  final String? arBoundingBox;

  const _FullScreenIngredientImage({
    required this.path,
    this.arBoundingBox,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final box = _parseNormalizedBox(arBoundingBox);
        return Stack(
          alignment: Alignment.center,
          children: [
            Image.file(
              File(path),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.broken_image_outlined,
                color: AppColors.textTertiary,
                size: 48,
              ),
            ),
            if (box != null)
              Positioned.fill(
                child: CustomPaint(
                  painter: _NormalizedBboxPainter(box),
                ),
              ),
          ],
        );
      },
    );
  }
}

Rect? _parseNormalizedBox(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  try {
    final m = jsonDecode(raw);
    if (m is! Map<String, dynamic>) return null;
    final x = (m['x'] as num?)?.toDouble();
    final y = (m['y'] as num?)?.toDouble();
    final w = (m['w'] as num?)?.toDouble();
    final h = (m['h'] as num?)?.toDouble();
    if (x == null || y == null || w == null || h == null) return null;
    return Rect.fromLTWH(x, y, w, h);
  } catch (_) {
    return null;
  }
}

class _NormalizedBboxPainter extends CustomPainter {
  final Rect normalized;

  _NormalizedBboxPainter(this.normalized);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      normalized.left * size.width,
      normalized.top * size.height,
      normalized.width * size.width,
      normalized.height * size.height,
    );
    final stroke = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final fill = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
    canvas.drawRRect(rrect, fill);
    canvas.drawRRect(rrect, stroke);
  }

  @override
  bool shouldRepaint(covariant _NormalizedBboxPainter oldDelegate) =>
      oldDelegate.normalized != normalized;
}
