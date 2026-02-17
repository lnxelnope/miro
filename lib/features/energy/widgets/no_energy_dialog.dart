import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/services/energy_service.dart';
import '../../../core/database/database_service.dart';
import '../../energy/providers/energy_provider.dart';
import '../presentation/energy_store_screen.dart';
import 'welcome_offer_unlocked_dialog.dart';

/// Dialog shown when Energy runs out
/// 
/// **New Feature:** First time empty → Grant 50 Energy bonus + unlock Welcome Offer (40% OFF - 24h)
class NoEnergyDialog extends ConsumerStatefulWidget {
  const NoEnergyDialog({super.key});

  @override
  ConsumerState<NoEnergyDialog> createState() => _NoEnergyDialogState();
  
  /// Show Dialog
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const NoEnergyDialog(),
    );
  }
}

class _NoEnergyDialogState extends ConsumerState<NoEnergyDialog> {
  bool _isChecking = true;
  bool _receivedBonus = false;

  @override
  void initState() {
    super.initState();
    _checkFirstTimeBonus();
  }

  Future<void> _checkFirstTimeBonus() async {
    final energyService = EnergyService(DatabaseService.isar);
    
    // Check if this is the first time Energy ran out
    final receivedBonus = await energyService.checkAndHandleFirstEnergyEmpty();
    
    setState(() {
      _isChecking = false;
      _receivedBonus = receivedBonus;
    });

    if (receivedBonus) {
      // Wait a moment then close this dialog
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        // Refresh energy balance
        ref.invalidate(energyBalanceProvider);
        
        // Close dialog
        Navigator.pop(context);
        
        // Show Welcome Offer Unlocked Dialog
        await WelcomeOfferUnlockedDialog.show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      // Show loading while checking
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppIcons.energyColor),
            const SizedBox(height: 16),
            const Text('Checking...'),
          ],
        ),
      );
    }

    if (_receivedBonus) {
      // Show bonus message
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(AppIcons.celebration, size: 32, color: Colors.purple),
            const SizedBox(width: 12),
            const Text('🎉 Special Bonus!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You received:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(AppIcons.energy, size: 24, color: AppIcons.energyColor),
                const SizedBox(width: 8),
                const Text(
                  '50 Energy FREE!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(AppIcons.discount, size: 24, color: Colors.orange),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '40% OFF Energy (24h)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Normal case (not first time) - show original dialog
    // Normal case (not first time) - show original dialog
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(AppIcons.energy, size: 32, color: AppIcons.energyColor),
          const SizedBox(width: 12),
          const Text('Out of Energy'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You need 1 Energy to analyze food with AI',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(AppIcons.tips, size: 16, color: AppIcons.tipsColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You can still log food manually (without AI) for free',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Later'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EnergyStoreScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Buy Energy', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
