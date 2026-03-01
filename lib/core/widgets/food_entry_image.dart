import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../features/health/models/food_entry.dart';

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

/// Full-screen image viewer with fallback support.
/// Guards against missing local files on restored devices.
class FoodEntryFullScreenImage extends StatelessWidget {
  final FoodEntry entry;

  const FoodEntryFullScreenImage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.black,
        child: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: _buildImage(),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (entry.hasLocalImage) {
      return Image.file(
        File(entry.imagePath!),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildNetworkOrError(),
      );
    }
    return _buildNetworkOrError();
  }

  Widget _buildNetworkOrError() {
    if (entry.hasThumbnailUrl) {
      return CachedNetworkImage(
        imageUrl: entry.thumbnailUrl!,
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

/// Shows full-screen image if viewable, otherwise shows a snackbar message.
void showFoodEntryImage(BuildContext context, FoodEntry entry) {
  if (!entry.hasAnyImage) return;

  if (entry.hasLocalImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodEntryFullScreenImage(entry: entry),
        fullscreenDialog: true,
      ),
    );
  } else if (entry.hasThumbnailUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodEntryFullScreenImage(entry: entry),
        fullscreenDialog: true,
      ),
    );
  }
}
