import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/core/services/energy_service.dart';
import 'package:miro_hybrid/core/theme/app_icons.dart';
import 'package:miro_hybrid/features/energy/presentation/energy_store_screen.dart';
import 'package:miro_hybrid/features/energy/providers/gamification_provider.dart';

/// Badge แสดง Energy ที่เหลือ (ติด AppBar)
class EnergyBadge extends ConsumerWidget {
  final EnergyService? energyService;

  const EnergyBadge({super.key, this.energyService});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final freeAiAvailable = gamification.freeAiAvailable;
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: balance < 10
              ? Colors.red.withOpacity(0.1)
              : Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: balance < 10 ? Colors.red : Colors.green,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.energy, size: 18, color: AppIcons.energyColor),
            const SizedBox(width: 4),
            Text(
              '$balance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: balance < 10 ? Colors.red : Colors.green,
              ),
            ),
            // Phase 5: Subscription badge หรือ Free AI indicator
            if (gamification.isSubscriber) ...[
              const SizedBox(width: 8),
              Icon(
                AppIcons.subscription,
                size: 16,
                color: AppIcons.subscriptionColor,
              ),
            ] else if (freeAiAvailable) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '1 FREE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
