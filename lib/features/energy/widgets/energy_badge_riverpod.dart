import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/features/energy/presentation/energy_store_screen.dart';
import 'package:miro_hybrid/features/energy/providers/energy_provider.dart';

/// Energy Badge ที่ใช้ Riverpod (อัพเดทอัตโนมัติ)
class EnergyBadgeRiverpod extends ConsumerWidget {
  const EnergyBadgeRiverpod({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final energyAsync = ref.watch(energyBalanceProvider);
    
    return energyAsync.when(
      data: (balance) => _buildBadge(context, balance),
      loading: () => const SizedBox(
        width: 60,
        height: 32,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, stack) => GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const EnergyStoreScreen(),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('⚡', style: TextStyle(fontSize: 16)),
              SizedBox(width: 4),
              Text('?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, int balance) {
    // Determine background color based on balance
    Color backgroundColor;
    if (balance < 10) {
      backgroundColor = Colors.red.withOpacity(0.1);
    } else if (balance < 30) {
      backgroundColor = Colors.orange.withOpacity(0.1);
    } else {
      backgroundColor = Colors.green.withOpacity(0.1);
    }
    
    // Determine border color
    Color borderColor;
    if (balance < 10) {
      borderColor = Colors.red;
    } else if (balance < 30) {
      borderColor = Colors.orange;
    } else {
      borderColor = Colors.green;
    }
    
    // Format display text
    final displayText = balance >= 1000
        ? '${(balance / 1000).toStringAsFixed(1)}K'
        : balance.toString();
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const EnergyStoreScreen(),
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '⚡',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: borderColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
