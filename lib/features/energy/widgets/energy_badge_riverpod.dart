import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/features/energy/presentation/energy_store_screen.dart';
import 'package:miro_hybrid/features/energy/providers/energy_provider.dart';

/// Energy Badge — Clean minimal pill design
class EnergyBadgeRiverpod extends ConsumerWidget {
  const EnergyBadgeRiverpod({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final energyAsync = ref.watch(energyBalanceProvider);

    return energyAsync.when(
      data: (balance) => _buildBadge(context, balance),
      loading: () => _buildShimmer(context),
      error: (error, stack) => _buildBadge(context, 0, isError: true),
    );
  }

  Widget _buildBadge(BuildContext context, int balance,
      {bool isError = false}) {
    // Color based on balance level
    Color accentColor;
    if (isError) {
      accentColor = Colors.grey;
    } else if (balance < 10) {
      accentColor = const Color(0xFFEF4444); // Red
    } else if (balance < 30) {
      accentColor = const Color(0xFFF59E0B); // Amber
    } else if (balance < 100) {
      accentColor = const Color(0xFF10B981); // Emerald
    } else {
      accentColor = const Color(0xFF06B6D4); // Cyan
    }

    final displayText = isError
        ? '–'
        : balance >= 1000
            ? '${(balance / 1000).toStringAsFixed(1)}K'
            : balance.toString();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const EnergyStoreScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, size: 18, color: accentColor),
            const SizedBox(width: 3),
            Text(
              displayText,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: accentColor,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 3),
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
