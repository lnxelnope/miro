import 'package:flutter/material.dart';

/// Brand strip (logo + store badges) on share card exports.
///
/// Asset is a wide banner (e.g. 1024×400). Using a square box made the layout
/// tall while the painted logo stayed small; this sizes the box to the asset
/// aspect ratio so the strip stays lean.
class ShareCardBrandBadge extends StatelessWidget {
  const ShareCardBrandBadge({super.key, required this.layoutScale});

  final double layoutScale;

  /// Matches `logo_with_store.png` pixel ratio (width / height).
  static const double assetAspectWidthOverHeight = 1024 / 400;

  /// Bar height on card (× [layoutScale]); width follows [assetAspectWidthOverHeight].
  static const double barHeightFactor = 34;

  @override
  Widget build(BuildContext context) {
    final s = layoutScale;
    final h = barHeightFactor * s;
    final w = h * assetAspectWidthOverHeight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6 * s),
      child: Image.asset(
        'assets/icon/logo_with_store.png',
        width: w,
        height: h,
        fit: BoxFit.contain,
      ),
    );
  }
}
