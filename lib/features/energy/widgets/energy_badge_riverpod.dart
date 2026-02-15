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
      loading: () => _buildBadge(context, 0),
      error: (_, __) => _buildBadge(context, 0),
    );
  }

  Widget _buildBadge(BuildContext context, int balance) {
    // เลือกสีตาม balance
    final Color color;
    final Color bgColor;
    
    if (balance < 10) {
      color = Colors.red;
      bgColor = Colors.red.withOpacity(0.15);
    } else if (balance < 30) {
      color = Colors.orange;
      bgColor = Colors.orange.withOpacity(0.15);
    } else {
      color = Colors.green;
      bgColor = Colors.green.withOpacity(0.15);
    }
    
    // Format ตัวเลข: 1000+ จะแสดงเป็น "1K"
    final String displayText;
    if (balance >= 1000) {
      displayText = '${(balance / 1000).toStringAsFixed(1)}K';
    } else {
      displayText = '$balance';
    }
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EnergyStoreScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '⚡',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 3),
            Text(
              displayText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
