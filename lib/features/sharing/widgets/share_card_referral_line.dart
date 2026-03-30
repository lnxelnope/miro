import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

/// Subtle invite line under the brand logo on share cards (always on).
class ShareCardReferralLine extends StatelessWidget {
  final String referralCode;
  final double layoutScale;
  final CrossAxisAlignment align;

  /// When true, removes extra top gap so the invite line sits tight under the
  /// brand strip (used on all share cards).
  final bool compactBelowLogo;

  const ShareCardReferralLine({
    super.key,
    required this.referralCode,
    required this.layoutScale,
    this.align = CrossAxisAlignment.start,
    this.compactBelowLogo = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final s = layoutScale;
    final code = referralCode.trim();
    final display = code.isEmpty ? '—' : code;

    final shadow = [
      Shadow(blurRadius: 3 * s, color: Colors.black87),
      Shadow(blurRadius: 1 * s, color: Colors.black54),
    ];

    final topGap = compactBelowLogo ? 0.0 : 3 * s;
    final column = Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: topGap),
        Text(
          l10n.shareCardReferralCaption,
          style: TextStyle(
            fontSize: 9 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.78),
            letterSpacing: 0.35,
            height: 1.1,
            shadows: shadow,
          ),
        ),
        SizedBox(height: 1 * s),
        Text(
          display,
          style: TextStyle(
            fontSize: 11 * s,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: 0.96),
            letterSpacing: code.isEmpty ? 0 : 0.6,
            height: 1.15,
            shadows: shadow,
          ),
        ),
      ],
    );

    return column;
  }
}
