import 'package:flutter/material.dart';
import 'package:miro_hybrid/core/services/energy_service.dart';
import 'package:miro_hybrid/features/energy/presentation/energy_store_screen.dart';

/// Badge แสดง Energy ที่เหลือ (ติด AppBar)
class EnergyBadge extends StatefulWidget {
  final EnergyService? energyService;
  
  const EnergyBadge({super.key, this.energyService});

  @override
  State<EnergyBadge> createState() => _EnergyBadgeState();
}

class _EnergyBadgeState extends State<EnergyBadge> {
  int _balance = 0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    if (widget.energyService != null) {
      final balance = await widget.energyService!.getBalance();
      if (mounted) {
        setState(() => _balance = balance);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          color: _balance < 10 
              ? Colors.red.withOpacity(0.1) 
              : Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _balance < 10 ? Colors.red : Colors.green,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚡', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              '$_balance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _balance < 10 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
