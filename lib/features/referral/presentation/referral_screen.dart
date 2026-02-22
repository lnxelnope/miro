import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/referral_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_icons.dart';
import '../../energy/providers/gamification_provider.dart';
import '../../../l10n/app_localizations.dart';

class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({super.key});

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen> {
  final _referralCodeController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitReferralCode() async {
    if (_referralCodeController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = L10n.of(context)!.referralPleaseEnterCode;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await ReferralService.submitReferralCode(
        _referralCodeController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _successMessage = result['message'] ?? L10n.of(context)!.referralCodeAccepted;
          _referralCodeController.clear();
        });

        // Refresh gamification state
        ref.read(gamificationProvider.notifier).refresh();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(AppIcons.celebration, size: 18, color: Colors.white),
                SizedBox(width: AppSpacing.sm),
                Text(L10n.of(context)!.referralEnergyBonus(result['bonusEnergy'] as int)),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _copyReferralCode(String miroId) async {
    await Clipboard.setData(ClipboardData(text: miroId));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.referralCodeCopied),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gamification = ref.watch(gamificationProvider);
    final miroId = gamification.miroId;

    return Scaffold(
      appBar: AppBar(
        title: AppIcons.iconWithLabel(
          Icons.people_rounded,
          L10n.of(context)!.referralInviteFriends,
          iconColor: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Your Referral Code Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.lg,
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L10n.of(context)!.referralYourReferralCode,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Container(
                      padding: AppSpacing.paddingLg,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: AppRadius.md,
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              miroId.isEmpty ? L10n.of(context)!.referralLoading : miroId,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: miroId.isEmpty
                                ? null
                                : () => _copyReferralCode(miroId),
                            tooltip: L10n.of(context)!.referralCopy,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      L10n.of(context)!.referralShareCodeDescription,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppSpacing.xxl),

            // Enter Referral Code Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.lg,
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L10n.of(context)!.referralEnterReferralCode,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _referralCodeController,
                      decoration: InputDecoration(
                        hintText: L10n.of(context)!.referralCodeHint,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.md,
                        ),
                        prefixIcon: const Icon(Icons.person_add),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    if (_errorMessage != null) ...[
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (_successMessage != null) ...[
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        _successMessage!,
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReferralCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.md,
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                L10n.of(context)!.referralSubmitCode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppSpacing.xxl),

            // How It Works
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.lg,
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L10n.of(context)!.referralHowItWorks,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStep(
                      '1',
                      L10n.of(context)!.referralStep1Title,
                      L10n.of(context)!.referralStep1Description,
                    ),
                    SizedBox(height: AppSpacing.md),
                    _buildStep(
                      '2',
                      L10n.of(context)!.referralStep2Title,
                      L10n.of(context)!.referralStep2Description,
                    ),
                    SizedBox(height: AppSpacing.md),
                    _buildStep(
                      '3',
                      L10n.of(context)!.referralStep3Title,
                      L10n.of(context)!.referralStep3Description,
                    ),
                    SizedBox(height: AppSpacing.md),
                    _buildStep(
                      '4',
                      L10n.of(context)!.referralStep4Title,
                      L10n.of(context)!.referralStep4Description,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
