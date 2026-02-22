import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/core/services/energy_service.dart';
import 'package:miro_hybrid/core/theme/app_icons.dart';
import 'package:miro_hybrid/core/theme/app_colors.dart';
import 'package:miro_hybrid/core/theme/app_tokens.dart';
import 'package:miro_hybrid/features/energy/presentation/energy_store_screen.dart';
import 'package:miro_hybrid/features/energy/providers/gamification_provider.dart';

/// Badge แสดง Energy ที่เหลือ (ติด AppBar)
class EnergyBadge extends ConsumerWidget {
  final EnergyService? energyService;

  const EnergyBadge({super.key, this.energyService});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final balance = gamification.balance;

    return GestureDetector(
      onTap: () {
        // เปิด Energy Store
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EnergyStoreScreen()),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: balance < 10
              ? AppColors.error.withValues(alpha: 0.1)
              : AppColors.success.withValues(alpha: 0.1),
          borderRadius: AppRadius.xl,
          border: Border.all(
            color: balance < 10 ? AppColors.error : AppColors.success,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.energy, size: 18, color: AppIcons.energyColor),
            SizedBox(width: AppSpacing.xs),
            Text(
              '$balance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: balance < 10 ? AppColors.error : AppColors.success,
              ),
            ),
            // Phase 5: Subscription badge หรือ Free AI indicator
            if (gamification.isSubscriber) ...[
              SizedBox(width: AppSpacing.sm),
              const Icon(
                AppIcons.subscription,
                size: 16,
                color: AppIcons.subscriptionColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
