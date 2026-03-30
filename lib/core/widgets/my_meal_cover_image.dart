import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../database/model_extensions.dart';

/// รูปปกเมนู — โฟลเดอร์ก่อน; ถ้าไม่มีและ [allowNetworkThumbnail] ค่อยโหลด [MyMeal.thumbnailUrl]
class MyMealCoverImage extends StatelessWidget {
  const MyMealCoverImage({
    super.key,
    required this.meal,
    this.height = 120,
    this.width = double.infinity,
    this.borderRadius,
    this.allowNetworkThumbnail = false,
    this.fit = BoxFit.cover,
  });

  final MyMeal meal;
  final double height;
  final double width;
  final BorderRadius? borderRadius;
  final bool allowNetworkThumbnail;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final r = borderRadius ?? BorderRadius.circular(12);

    if (meal.hasMealLocalImage) {
      return ClipRRect(
        borderRadius: r,
        child: Image.file(
          File(meal.imagePath!),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _placeholder(context, r),
        ),
      );
    }

    if (allowNetworkThumbnail && meal.hasMealThumbnailUrl) {
      return ClipRRect(
        borderRadius: r,
        child: CachedNetworkImage(
          imageUrl: meal.thumbnailUrl!.trim(),
          width: width == double.infinity ? null : width,
          height: height,
          fit: fit,
          memCacheWidth: 400,
          placeholder: (_, __) => SizedBox(
            height: height,
            width: width == double.infinity ? double.infinity : width,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (_, __, ___) => _placeholder(context, r),
        ),
      );
    }

    return _placeholder(context, r);
  }

  Widget _placeholder(BuildContext context, BorderRadius r) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: r,
      child: Container(
        width: width,
        height: height,
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.grey.withValues(alpha: 0.12),
        alignment: Alignment.center,
        child: Icon(
          Icons.restaurant_rounded,
          size: height >= 100 ? 48 : 24,
          color: isDark ? Colors.white24 : Colors.grey,
        ),
      ),
    );
  }
}
