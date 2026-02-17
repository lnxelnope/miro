import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subscription_provider.dart';
import '../../../core/theme/app_colors.dart';

/// Subscriber Badge Widget
/// 
/// Shows a premium badge for active subscribers
class SubscriberBadge extends ConsumerWidget {
  const SubscriberBadge({
    super.key,
    this.size = BadgeSize.medium,
    this.showText = true,
  });

  final BadgeSize size;
  final bool showText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSubscription = ref.watch(hasActiveSubscriptionProvider);

    if (!hasSubscription) {
      return const SizedBox.shrink();
    }

    final double iconSize;
    final double fontSize;
    final EdgeInsets padding;

    switch (size) {
      case BadgeSize.small:
        iconSize = 16;
        fontSize = 10;
        padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
        break;
      case BadgeSize.medium:
        iconSize = 20;
        fontSize = 12;
        padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
        break;
      case BadgeSize.large:
        iconSize = 24;
        fontSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.energy_savings_leaf,
            size: iconSize,
            color: Colors.white,
          ),
          if (showText) ...[
            SizedBox(width: iconSize * 0.3),
            Text(
              'PRO',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Badge Size Options
enum BadgeSize {
  small,
  medium,
  large,
}

/// Inline Subscriber Badge (for use in text)
class InlineSubscriberBadge extends ConsumerWidget {
  const InlineSubscriberBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSubscription = ref.watch(hasActiveSubscriptionProvider);

    if (!hasSubscription) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
