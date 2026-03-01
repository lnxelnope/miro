import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/recovery_key_service.dart';
import '../../../core/services/data_sync_service.dart';
import '../../../core/services/energy_service.dart';
import '../../../core/database/database_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../energy/providers/gamification_provider.dart';

/// Screen for restoring an account on a new device using Recovery Key.
/// Accessible from onboarding or settings.
class RestoreAccountScreen extends ConsumerStatefulWidget {
  const RestoreAccountScreen({super.key});

  @override
  ConsumerState<RestoreAccountScreen> createState() =>
      _RestoreAccountScreenState();
}

class _RestoreAccountScreenState extends ConsumerState<RestoreAccountScreen> {
  final _keyController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    final key = _keyController.text.trim().toUpperCase();
    if (key.isEmpty) {
      setState(() => _error = 'กรุณาใส่ Recovery Key');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await RecoveryKeyService.redeemRecoveryKey(key);
      if (data == null) {
        setState(() {
          _error = 'ไม่สามารถกู้คืนได้ กรุณาตรวจสอบ Key';
          _isLoading = false;
        });
        return;
      }

      // Restore balance
      final balance = (data['balance'] as num?)?.toInt() ?? 0;
      final energyService = EnergyService(DatabaseService.isar);
      await energyService.updateFromServerResponse(balance);

      // Restore food entries
      int entriesRestored = 0;
      if (data['entries'] != null) {
        entriesRestored = await DataSyncService.restoreEntries(
          data['entries'] as List<dynamic>,
        );
      }

      // Restore meals
      int mealsRestored = 0;
      if (data['meals'] != null) {
        mealsRestored = await DataSyncService.restoreMeals(
          data['meals'] as List<dynamic>,
        );
      }

      // Restore profile (calorie goal, weight, height, cuisine, etc.)
      bool profileRestored = false;
      if (data['profile'] != null) {
        profileRestored = await DataSyncService.restoreProfile(
          data['profile'] as Map<String, dynamic>,
        );
      }

      // Force re-sync gamification state by invalidating the provider
      ref.invalidate(gamificationProvider);

      setState(() {
        _isLoading = false;
        _result = {
          'balance': balance,
          'entries': entriesRestored,
          'meals': mealsRestored,
          'miroId': data['miroId'] ?? '',
          'profileRestored': profileRestored,
        };
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = _humanizeError(e.toString());
      });
    }
  }

  String _humanizeError(String error) {
    if (error.contains('not found') || error.contains('Invalid')) {
      return 'Recovery Key ไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง';
    }
    if (error.contains('expired')) {
      return 'Recovery Key หมดอายุแล้ว กรุณาสร้างใหม่จากเครื่องเดิม';
    }
    if (error.contains('same device')) {
      return 'ไม่สามารถกู้คืนบนเครื่องเดิมได้';
    }
    if (error.contains('network') || error.contains('internet')) {
      return 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต กรุณาลองใหม่';
    }
    return 'เกิดข้อผิดพลาด: $error';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('กู้คืนบัญชี'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _result != null ? _buildSuccessView() : _buildInputView(isDark),
        ),
      ),
    );
  }

  Widget _buildInputView(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.restore_rounded, size: 48, color: AppColors.primary),
        const SizedBox(height: 16),
        const Text(
          'กู้คืนจาก Recovery Key',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'ใส่ Recovery Key จากเครื่องเดิม\n'
          'เพื่อกู้คืนประวัติการทานและ Energy',
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _keyController,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'MIRO-XXXX-XXXX',
            hintStyle: TextStyle(
              color: isDark ? Colors.white24 : Colors.black26,
              fontFamily: 'monospace',
              letterSpacing: 3,
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 20),
            errorText: _error,
          ),
          enabled: !_isLoading,
          onSubmitted: (_) => _restore(),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _restore,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'กู้คืนบัญชี',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Recovery Key อยู่ใน Settings > Account ของเครื่องเดิม',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_rounded,
            size: 72, color: AppColors.success),
        const SizedBox(height: 20),
        const Text(
          'กู้คืนสำเร็จ!',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        _buildResultRow(
            Icons.bolt, '${_result!['balance']} Energy', AppColors.warning),
        const SizedBox(height: 12),
        _buildResultRow(Icons.restaurant_menu,
            '${_result!['entries']} รายการอาหาร', AppColors.health),
        const SizedBox(height: 12),
        _buildResultRow(Icons.menu_book,
            '${_result!['meals']} My Meals', AppColors.primary),
        if (_result!['profileRestored'] == true) ...[
          const SizedBox(height: 12),
          _buildResultRow(Icons.person_outline,
              'โปรไฟล์ & เป้าหมายกู้คืนแล้ว', AppColors.info),
        ],
        if ((_result!['miroId'] as String).isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildResultRow(
              Icons.badge, 'MiRO ID: ${_result!['miroId']}', AppColors.premium),
        ],
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context)
              ..pop()
              ..pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('เริ่มใช้งาน',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(IconData icon, String text, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
