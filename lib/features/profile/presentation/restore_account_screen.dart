import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_service.dart';
import '../../../core/services/recovery_key_service.dart';
import '../../../core/services/data_sync_service.dart';
import '../../../core/services/energy_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
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
      setState(() => _error = L10n.of(context)!.restoreEmptyKey);
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
          _error = L10n.of(context)!.restoreFailedGeneric;
          _isLoading = false;
        });
        return;
      }

      // Restore balance
      final balance = (data['balance'] as num?)?.toInt() ?? 0;
      final energyService = EnergyService(DatabaseService.db);
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
    final l10n = L10n.of(context)!;
    if (error.contains('not found') || error.contains('Invalid')) {
      return l10n.restoreInvalidKey;
    }
    if (error.contains('expired')) {
      return l10n.restoreExpiredKey;
    }
    if (error.contains('same device')) {
      return l10n.restoreSameDevice;
    }
    if (error.contains('network') || error.contains('internet')) {
      return l10n.restoreNoInternet;
    }
    return l10n.restoreErrorGeneric(error);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context)!.restoreAccountTitle),
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
        Text(
          L10n.of(context)!.restoreFromRecoveryKey,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          L10n.of(context)!.restoreEnterKey,
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
            hintText: 'ARCAL-XXXX-XXXX',
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
                : Text(
                    L10n.of(context)!.restoreButton,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            L10n.of(context)!.restoreKeyLocation,
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
        Text(
          L10n.of(context)!.restoreSuccess,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        _buildResultRow(
            Icons.bolt, '${_result!['balance']} Energy', AppColors.warning),
        const SizedBox(height: 12),
        _buildResultRow(Icons.restaurant_menu,
            L10n.of(context)!.restoreFoodEntries(_result!['entries'] as int), AppColors.health),
        const SizedBox(height: 12),
        _buildResultRow(Icons.menu_book,
            '${_result!['meals']} My Meals', AppColors.primary),
        if (_result!['profileRestored'] == true) ...[
          const SizedBox(height: 12),
          _buildResultRow(Icons.person_outline,
              L10n.of(context)!.restoreProfileRecovered, AppColors.info),
        ],
        if ((_result!['miroId'] as String).isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildResultRow(
              Icons.badge, 'ArCal ID: ${_result!['miroId']}', AppColors.premium),
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
            child: Text(L10n.of(context)!.restoreStartUsing,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
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
