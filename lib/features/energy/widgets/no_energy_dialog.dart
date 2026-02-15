import 'package:flutter/material.dart';
import '../presentation/energy_store_screen.dart';

/// Dialog แสดงเมื่อ Energy หมด
class NoEnergyDialog extends StatelessWidget {
  const NoEnergyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Text('⚡', style: TextStyle(fontSize: 32)),
          SizedBox(width: 12),
          Text('Energy หมดแล้ว'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'คุณต้องใช้ 1 Energy เพื่อวิเคราะห์อาหารด้วย AI',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            '💡 คุณยังสามารถบันทึกอาหารแบบธรรมดา (ไม่ใช้ AI) ได้ฟรี',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ไว้ทีหลัง'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EnergyStoreScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('ซื้อ Energy', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
  
  /// แสดง Dialog
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const NoEnergyDialog(),
    );
  }
}
