import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/services/consent_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/constants/cuisine_options.dart';
import 'package:drift/drift.dart' hide JsonKey, Column;
import '../../../core/database/app_database.dart';
import '../../../core/database/database_service.dart';
import '../../../core/database/model_extensions.dart';
import '../../../core/utils/logger.dart';
import '../../../core/ai/gemini_service.dart';
import '../../scanner/services/gallery_service.dart';
import '../providers/profile_provider.dart';
import '../providers/locale_provider.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../onboarding/presentation/tutorial_food_analysis_screen.dart';
import '../../legal/presentation/disclaimer_screen.dart';
import 'health_goals_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';
import '../../home/widgets/feature_tour.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/data_sync_service.dart';
import '../../chat/services/greeting_service.dart';
import '../../../features/energy/providers/gamification_provider.dart';
import '../../subscription/presentation/subscription_screen.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../../subscription/models/subscription_status.dart';
import '../../referral/presentation/referral_screen.dart';
import '../../energy/presentation/tier_benefits_screen.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/services/health_sync_service.dart';
import '../../../core/services/recovery_key_service.dart';
import '../../../core/services/device_id_service.dart';
import '../../../core/services/promo_code_service.dart';
import '../../energy/providers/energy_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'restore_account_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Collapsible sections state (default all collapsed except healthGoals)
  bool _healthGoalsExpanded = true;
  bool _languageExpanded = false;
  bool _cuisineExpanded = false;
  bool _unitSystemExpanded = false;
  bool _photoScanExpanded = false;
  bool _accountExpanded = false;
  bool _healthSyncExpanded = false;
  bool _dataExpanded = false;
  bool _aboutExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          L10n.of(context)!.profileAndSettings,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ref.watch(profileNotifierProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(
                child: Text(L10n.of(context)!.errorOccurred(e.toString()))),
            data: (profile) => SingleChildScrollView(
              padding: AppSpacing.paddingXl,
              child: Column(
                children: [
                  // Modern Avatar Section
                  _buildModernAvatarSection(context, profile.name ?? 'User'),
                  const SizedBox(height: AppSpacing.xxl),

                  // ──────────────────────────────────────────────
                  // Health Goals (expanded by default)
                  // ──────────────────────────────────────────────
                  _buildCollapsibleSection(
                    title: L10n.of(context)!.healthGoalsSection,
                    icon: Icons.track_changes_rounded,
                    isExpanded: _healthGoalsExpanded,
                    onToggle: () => setState(
                        () => _healthGoalsExpanded = !_healthGoalsExpanded),
                    child: _buildModernSettingCard(
                      context: context,
                      title: L10n.of(context)!.dailyGoals,
                      subtitle:
                          '${profile.calorieGoal.toInt()} kcal • P ${profile.proteinGoal.toInt()}g • C ${profile.carbGoal.toInt()}g • F ${profile.fatGoal.toInt()}g',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HealthGoalsScreen()),
                      ),
                    ),
                  ),

                  // ──────────────────────────────────────────────
                  // Language Settings (collapsed by default)
                  // ──────────────────────────────────────────────
                  _buildCollapsibleSection(
                    title: L10n.of(context)!.languageSection,
                    icon: Icons.language_rounded,
                    isExpanded: _languageExpanded,
                    onToggle: () =>
                        setState(() => _languageExpanded = !_languageExpanded),
                    child: _buildLanguageCard(context),
                  ),

                  // ──────────────────────────────────────────────
                  // Cuisine Preference (collapsed by default)
                  // ──────────────────────────────────────────────
                  _buildCollapsibleSection(
                    title: L10n.of(context)!.cuisinePreferenceSection,
                    icon: Icons.restaurant_rounded,
                    iconColor: AppColors.warning,
                    isExpanded: _cuisineExpanded,
                    onToggle: () =>
                        setState(() => _cuisineExpanded = !_cuisineExpanded),
                    child: _buildCuisinePreferenceCard(context, profile),
                  ),

                  // ──────────────────────────────────────────────
                  // Unit System (collapsed by default)
                  // ──────────────────────────────────────────────
                  _buildCollapsibleSection(
                    title: L10n.of(context)!.unitSystemSection,
                    icon: Icons.straighten_rounded,
                    iconColor: AppColors.info,
                    isExpanded: _unitSystemExpanded,
                    onToggle: () => setState(
                        () => _unitSystemExpanded = !_unitSystemExpanded),
                    child: _buildUnitSystemCard(context, profile),
                  ),

                  // ──────────────────────────────────────────────
                  // Gallery Scan Settings (collapsed by default)
                  // ──────────────────────────────────────────────
                  _buildCollapsibleSection(
                    title: L10n.of(context)!.photoScanSection,
                    icon: Icons.photo_camera_rounded,
                    isExpanded: _photoScanExpanded,
                    onToggle: () => setState(
                        () => _photoScanExpanded = !_photoScanExpanded),
                    child: _ScanSettingsCard(),
                  ),

                  // ──────────────────────────────────────────────
                  // Account (collapsed by default)
                  // ──────────────────────────────────────────────
                  _buildCollapsibleSection(
                    title: L10n.of(context)!.accountSection,
                    icon: Icons.person_outline_rounded,
                    isExpanded: _accountExpanded,
                    onToggle: () =>
                        setState(() => _accountExpanded = !_accountExpanded),
                    child: Column(
                      children: [
                        Consumer(
                          builder: (context, ref, _) {
                            final gamification =
                                ref.watch(gamificationProvider);
                            return _buildModernSettingCard(
                              context: context,
                              title: L10n.of(context)!.miroId,
                              subtitle: gamification.miroId.isEmpty
                                  ? L10n.of(context)!.loading
                                  : gamification.miroId,
                              leading: Container(
                                padding: AppSpacing.paddingSm,
                                decoration: BoxDecoration(
                                  color: AppColors.premiumLight,
                                  borderRadius: AppRadius.md,
                                ),
                                child: const Icon(Icons.badge_outlined,
                                    color: AppColors.premium, size: 20),
                              ),
                              showArrow: false,
                              trailing: gamification.miroId.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.copy, size: 18),
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(
                                              text: gamification.miroId),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                L10n.of(context)!.miroIdCopied),
                                            duration:
                                                const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    )
                                  : null,
                            );
                          },
                        ),
                        _RecoveryKeyCard(),
                        const _PromoCodeSection(),
                        _buildModernSettingCard(
                          context: context,
                          title: L10n.of(context)!.inviteFriends,
                          subtitle: L10n.of(context)!.inviteFriendsSubtitle,
                          leading: Container(
                            padding: AppSpacing.paddingSm,
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: AppRadius.md,
                            ),
                            child: const Icon(Icons.people_outline,
                                color: AppColors.success, size: 20),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReferralScreen(),
                            ),
                          ),
                        ),
                        Consumer(
                          builder: (context, ref, _) {
                            final subState = ref.watch(subscriptionProvider);
                            final sub = subState.subscription;
                            final isActive = sub.isActive;

                            return _buildSubscriptionSection(
                              context: context,
                              sub: sub,
                              isActive: isActive,
                              isLoading: subState.isLoading,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // ──────────────────────────────────────────────
                  // Health Sync (collapsed by default)
                  // ──────────────────────────────────────────────
                  _buildCollapsibleSection(
                    title: L10n.of(context)!.healthSyncSection,
                    icon: Icons.favorite_rounded,
                    iconColor: AppColors.error,
                    isExpanded: _healthSyncExpanded,
                    onToggle: () => setState(
                        () => _healthSyncExpanded = !_healthSyncExpanded),
                    child: Column(
                      children: [
                        _HealthSyncToggle(profile: profile),
                        // BMR ย้ายไปอยู่กับ TDEE ใน Health Goals แล้ว
                      ],
                    ),
                  ),

                  // ──────────────────────────────────────────────
                  // Data (collapsed by default)
                  // ──────────────────────────────────────────────
                  _buildCollapsibleSection(
                    title: L10n.of(context)!.dataSection,
                    icon: Icons.storage_rounded,
                    iconColor: AppColors.info,
                    isExpanded: _dataExpanded,
                    onToggle: () =>
                        setState(() => _dataExpanded = !_dataExpanded),
                    child: Column(
                      children: [
                        const _AutoSyncStatusCard(),
                        _buildModernSettingCard(
                          context: context,
                          title: L10n.of(context)!.backupData,
                          subtitle: L10n.of(context)!.backupExportSubtitle,
                          leading: Container(
                            padding: AppSpacing.paddingSm,
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.1),
                              borderRadius: AppRadius.md,
                            ),
                            child: const Icon(Icons.ios_share_rounded,
                                color: AppColors.info, size: 20),
                          ),
                          onTap: () => _handleBackup(context),
                        ),
                        _buildModernSettingCard(
                          context: context,
                          title: L10n.of(context)!.restoreFromBackup,
                          subtitle: L10n.of(context)!.restoreFromBackupSubtitle,
                          leading: Container(
                            padding: AppSpacing.paddingSm,
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: AppRadius.md,
                            ),
                            child: const Icon(Icons.restore,
                                color: AppColors.success, size: 20),
                          ),
                          onTap: () => _handleRestore(context),
                        ),
                        _buildModernSettingCard(
                          context: context,
                          title: L10n.of(context)!.recoveryKeyRestoreTitle,
                          subtitle: L10n.of(context)!.recoveryKeyRestoreSubtitle,
                          leading: Container(
                            padding: AppSpacing.paddingSm,
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: AppRadius.md,
                            ),
                            child: const Icon(Icons.key_rounded,
                                color: AppColors.warning, size: 20),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RestoreAccountScreen(),
                            ),
                          ),
                        ),
                        _buildModernSettingCard(
                          context: context,
                          title: L10n.of(context)!.restorePurchase,
                          subtitle: L10n.of(context)!.restorePurchaseSubtitle,
                          leading: Container(
                            padding: AppSpacing.paddingSm,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: AppRadius.md,
                            ),
                            child: const Icon(Icons.shopping_bag_outlined,
                                color: AppColors.primary, size: 20),
                          ),
                          onTap: () => _handleRestorePurchase(context),
                        ),
                        const _AnalyticsConsentToggle(),
                        const _FoodResearchConsentToggle(),
                        _buildModernSettingCard(
                          context: context,
                          title: L10n.of(context)!.clearAllData,
                          textColor: AppColors.error,
                          leading: Container(
                            padding: AppSpacing.paddingSm,
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: AppRadius.md,
                            ),
                            child: const Icon(Icons.delete_forever,
                                color: AppColors.error, size: 20),
                          ),
                          onTap: () => _confirmClearAllData(context),
                        ),
                        _buildModernSettingCard(
                          context: context,
                          title: L10n.of(context)!.deleteAccount,
                          subtitle: L10n.of(context)!.deleteAccountSubtitle,
                          textColor: AppColors.error,
                          leading: Container(
                            padding: AppSpacing.paddingSm,
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: AppRadius.md,
                            ),
                            child: const Icon(Icons.person_off_rounded,
                                color: AppColors.error, size: 20),
                          ),
                          onTap: () => _confirmDeleteAccount(context),
                        ),
                      ],
                    ),
                  ),

                  // ──────────────────────────────────────────────
                  // About (collapsed by default)
                  // ──────────────────────────────────────────────
                  _buildCollapsibleSection(
                    title: L10n.of(context)!.aboutSection,
                    icon: Icons.info_outline_rounded,
                    iconColor: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    isExpanded: _aboutExpanded,
                    onToggle: () =>
                        setState(() => _aboutExpanded = !_aboutExpanded),
                    child: Column(
                      children: [
                        _buildModernSettingCard(
                          context: context,
                          title: L10n.of(context)!.version,
                          subtitle: '2.0.0',
                          showArrow: false,
                        ),
                        _buildModernSettingCard(
                          context: context,
                          title: L10n.of(context)!.privacyPolicy,
                          leading: Container(
                            padding: AppSpacing.paddingSm,
                            decoration: BoxDecoration(
                              color: AppColors.premiumLight,
                              borderRadius: AppRadius.md,
                            ),
                            child: const Icon(Icons.privacy_tip_outlined,
                                color: AppColors.premium, size: 20),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PrivacyPolicyScreen()),
                          ),
                        ),
                        _buildModernSettingCard(
                          context: context,
                          title: L10n.of(context)!.termsOfService,
                          leading: Container(
                            padding: AppSpacing.paddingSm,
                            decoration: BoxDecoration(
                              color: AppColors.ai.withValues(alpha: 0.1),
                              borderRadius: AppRadius.md,
                            ),
                            child: const Icon(Icons.description_outlined,
                                color: AppColors.ai, size: 20),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TermsScreen()),
                          ),
                        ),
                        _buildModernSettingCard(
                          context: context,
                          title: L10n.of(context)!.healthDisclaimer,
                          subtitle: L10n.of(context)!.importantLegalInformation,
                          leading: Container(
                            padding: AppSpacing.paddingSm,
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: AppRadius.md,
                            ),
                            child: const Icon(Icons.warning_amber,
                                color: AppColors.warning, size: 20),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DisclaimerScreen()),
                          ),
                        ),
                        _buildModernSettingCard(
                          context: context,
                          title: L10n.of(context)!.showTutorialAgain,
                          subtitle: L10n.of(context)!.viewFeatureTour,
                          leading: Container(
                            padding: AppSpacing.paddingSm,
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: AppRadius.md,
                            ),
                            child: const Icon(Icons.lightbulb_outline,
                                color: AppColors.warning, size: 20),
                          ),
                          onTap: () => _showTutorialAgain(),
                        ),
                        _buildModernSettingCard(
                          context: context,
                          title: L10n.of(context)!.foodAnalysisTutorial,
                          subtitle:
                              L10n.of(context)!.foodAnalysisTutorialSubtitle,
                          leading: Container(
                            padding: AppSpacing.paddingSm,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primaryLight.withValues(alpha: 0.1),
                              borderRadius: AppRadius.md,
                            ),
                            child: const Icon(Icons.school,
                                color: AppColors.primary, size: 20),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TutorialFoodAnalysisScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxxxl),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildModernAvatarSection(BuildContext context, String name) {
    return Consumer(
      builder: (context, ref, _) {
        final gamification = ref.watch(gamificationProvider);
        final subState = ref.watch(subscriptionProvider);
        final isSubscribed = subState.subscription.isActive;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.health],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(
                  gamification.tierIcon,
                  size: 50,
                  color: gamification.tierColor,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Subscriber Badge (if subscriber)
            if (isSubscribed) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.premium, AppColors.premiumDark],
                  ),
                  borderRadius: AppRadius.xl,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.premium.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.diamond_rounded,
                        size: 16, color: Colors.white),
                    const SizedBox(width: AppSpacing.sm - 2),
                    Text(
                      L10n.of(context)!.subscriptionEnergyPass,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm - 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm - 2,
                          vertical: AppSpacing.xxs),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: AppRadius.sm,
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            // Tier Badge (Clickable)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TierBenefitsScreen(),
                  ),
                );
              },
              borderRadius: AppRadius.xl,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: gamification.tierColor.withValues(alpha: 0.15),
                  borderRadius: AppRadius.xl,
                  border: Border.all(
                    color: gamification.tierColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      gamification.tierIcon,
                      size: 20,
                      color: gamification.tierColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${gamification.tierName} Tier',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: gamification.tierColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '• ${gamification.currentStreak} day streak',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: gamification.tierColor.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Collapsible Section Widget — simple elegance style
  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
    Color? iconColor,
  }) {
    final color = iconColor ?? AppColors.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: AppRadius.md,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onToggle,
            borderRadius: AppRadius.md,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md + 2,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: AppRadius.md,
                border: Border.all(
                  color: isExpanded
                      ? color.withValues(alpha: 0.3)
                      : isDark
                          ? AppColors.dividerDark
                          : AppColors.divider,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: isDark ? Colors.white38 : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: child,
          ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  /// Legacy section title builder (kept for future use)
  // ignore: unused_element
  Widget _buildModernSectionTitle(String title) {
    // Helper method to extract icon and label from emoji-prefixed title
    IconData? icon;
    String label;

    if (title.startsWith('🎯')) {
      icon = AppIcons.target;
      label = title.substring(2).trim();
    } else if (title.startsWith('🤖')) {
      icon = AppIcons.ai;
      label = title.substring(2).trim();
    } else if (title.startsWith('🍽️')) {
      icon = AppIcons.meal;
      label = title.substring(3).trim();
    } else if (title.startsWith('📸')) {
      icon = AppIcons.camera;
      label = title.substring(2).trim();
    } else if (title.startsWith('🌐')) {
      icon = Icons.language;
      label = title.substring(2).trim();
    } else if (title.startsWith('💾')) {
      icon = AppIcons.save;
      label = title.substring(2).trim();
    } else if (title.startsWith('ℹ️')) {
      icon = AppIcons.info;
      label = title.substring(2).trim();
    } else {
      label = title;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: icon != null
          ? AppIcons.iconWithLabel(
              icon,
              label,
              iconColor: AppIcons.infoColor,
              iconSize: 20,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )
          : Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
    );
  }

  Widget _buildModernSettingCard({
    required BuildContext context,
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
    bool showArrow = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: AppRadius.lg,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lg,
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Row(
              children: [
                if (leading != null) ...[
                  leading,
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing
                else if (showArrow)
                  Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.white38 : AppColors.textTertiary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionSection({
    required BuildContext context,
    required dynamic sub,
    required bool isActive,
    required bool isLoading,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isActive) {
      final expiryText = sub.expiryDate != null
          ? '${sub.expiryDate!.day}/${sub.expiryDate!.month}/${sub.expiryDate!.year}'
          : '';
      final startText = sub.startDate != null
          ? '${sub.startDate!.day}/${sub.startDate!.month}/${sub.startDate!.year}'
          : '';

      String statusLabel;
      Color statusColor;
      if (sub.status == SubscriptionStatus.gracePeriod) {
        statusLabel = 'GRACE PERIOD';
        statusColor = AppColors.warning;
      } else {
        statusLabel = 'ACTIVE';
        statusColor = AppColors.premium;
      }

      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md - 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.premium.withValues(alpha: 0.05),
              AppColors.premiumDark.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.lg,
          border: Border.all(
            color: AppColors.premium.withValues(alpha: 0.2),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
            ),
            borderRadius: AppRadius.lg,
            child: Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: AppSpacing.paddingSm,
                        decoration: BoxDecoration(
                          color: AppColors.premium.withValues(alpha: 0.15),
                          borderRadius: AppRadius.md,
                        ),
                        child: const Icon(
                          Icons.diamond,
                          color: AppColors.premium,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          L10n.of(context)!.subscriptionEnergyPass,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: AppRadius.sm,
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: AppSpacing.paddingMd,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceVariantDark.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.7),
                      borderRadius: AppRadius.md,
                    ),
                    child: Column(
                      children: [
                        _buildSubscriptionInfoRow(
                          L10n.of(context)!.plan,
                          L10n.of(context)!.monthly,
                          Icons.calendar_month,
                        ),
                        if (startText.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildSubscriptionInfoRow(
                            L10n.of(context)!.started,
                            startText,
                            Icons.play_circle_outline,
                          ),
                        ],
                        if (expiryText.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildSubscriptionInfoRow(
                            sub.autoRenewing
                                ? L10n.of(context)!.renews
                                : L10n.of(context)!.expires,
                            expiryText,
                            sub.autoRenewing
                                ? Icons.autorenew
                                : Icons.event_busy,
                          ),
                        ],
                        const SizedBox(height: 8),
                        _buildSubscriptionInfoRow(
                          L10n.of(context)!.autoRenew,
                          sub.autoRenewing
                              ? L10n.of(context)!.on
                              : L10n.of(context)!.off,
                          Icons.repeat,
                          valueColor: sub.autoRenewing
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: isDark ? Colors.white38 : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        L10n.of(context)!.tapToManageSubscription,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isDark ? Colors.white38 : AppColors.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right,
                        color: isDark ? Colors.white38 : AppColors.textTertiary,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return _buildModernSettingCard(
      context: context,
      title: L10n.of(context)!.subscriptionEnergyPass,
      subtitle: isLoading
          ? L10n.of(context)!.loading
          : L10n.of(context)!.unlimitedAiDoubleRewards,
      leading: Container(
        padding: AppSpacing.paddingSm,
        decoration: BoxDecoration(
          color: AppColors.premiumLight,
          borderRadius: AppRadius.md,
        ),
        child: const Icon(
          Icons.diamond,
          color: AppColors.premium,
          size: 20,
        ),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
      ),
    );
  }

  Widget _buildSubscriptionInfoRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.premium.withValues(alpha: 0.6)),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ??
                (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildCuisinePreferenceCard(BuildContext context, profile) {
    return _buildSettingCard(
      context: context,
      title: L10n.of(context)!.preferredCuisine,
      subtitle: CuisineOptions.getLabel(profile.cuisinePreference),
      leading: Text(
        CuisineOptions.getFlag(profile.cuisinePreference),
        style: const TextStyle(fontSize: 20),
      ),
      onTap: () => _showCuisineDialog(context, profile),
    );
  }

  Widget _buildUnitSystemCard(BuildContext context, profile) {
    final isImperial = profile.unitSystem == 'imperial';
    return _buildSettingCard(
      context: context,
      title: L10n.of(context)!.unitSystemPreference,
      subtitle: isImperial
          ? '${L10n.of(context)!.unitSystemImperial} (${L10n.of(context)!.unitSystemImperialDesc})'
          : '${L10n.of(context)!.unitSystemMetric} (${L10n.of(context)!.unitSystemMetricDesc})',
      leading: Icon(
        isImperial ? Icons.square_foot_rounded : Icons.straighten_rounded,
        size: 24,
        color: AppColors.info,
      ),
      onTap: () => _showUnitSystemDialog(context, profile),
    );
  }

  Future<void> _showUnitSystemDialog(BuildContext context, profile) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10n.of(context)!.unitSystemPreference),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildUnitSystemOption(
              ctx: ctx,
              profile: profile,
              key: 'metric',
              label: L10n.of(context)!.unitSystemMetric,
              desc: L10n.of(context)!.unitSystemMetricDesc,
              icon: Icons.straighten_rounded,
              isSelected: profile.unitSystem != 'imperial',
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildUnitSystemOption(
              ctx: ctx,
              profile: profile,
              key: 'imperial',
              label: L10n.of(context)!.unitSystemImperial,
              desc: L10n.of(context)!.unitSystemImperialDesc,
              icon: Icons.square_foot_rounded,
              isSelected: profile.unitSystem == 'imperial',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitSystemOption({
    required BuildContext ctx,
    required dynamic profile,
    required String key,
    required String label,
    required String desc,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        profile.unitSystem = key;
        ref.read(profileNotifierProvider.notifier).updateProfile(profile);
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L10n.of(context)!.unitSystemChangedTo(label))),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isDark ? Colors.grey.shade600 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: isSelected ? AppColors.primary : Colors.grey),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primary : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }

  static const _supportedLanguages = [
    {'code': 'en', 'flag': '🇺🇸'},
    {'code': 'th', 'flag': '🇹🇭'},
    {'code': 'vi', 'flag': '🇻🇳'},
    {'code': 'id', 'flag': '🇮🇩'},
    {'code': 'zh', 'flag': '🇨🇳'},
    {'code': 'ja', 'flag': '🇯🇵'},
    {'code': 'ko', 'flag': '🇰🇷'},
    {'code': 'es', 'flag': '🇪🇸'},
    {'code': 'fr', 'flag': '🇫🇷'},
    {'code': 'de', 'flag': '🇩🇪'},
    {'code': 'pt', 'flag': '🇵🇹'},
    {'code': 'hi', 'flag': '🇮🇳'},
  ];

  String _getLanguageLabel(BuildContext context, String code) {
    switch (code) {
      case 'en':
        return L10n.of(context)!.english;
      case 'th':
        return L10n.of(context)!.thai;
      case 'vi':
        return L10n.of(context)!.vietnamese;
      case 'id':
        return L10n.of(context)!.indonesian;
      case 'zh':
        return L10n.of(context)!.chinese;
      case 'ja':
        return L10n.of(context)!.japanese;
      case 'ko':
        return L10n.of(context)!.korean;
      case 'es':
        return L10n.of(context)!.spanish;
      case 'fr':
        return L10n.of(context)!.french;
      case 'de':
        return L10n.of(context)!.german;
      case 'pt':
        return L10n.of(context)!.portuguese;
      case 'hi':
        return L10n.of(context)!.hindi;
      default:
        return code;
    }
  }

  String _getLanguageSublabel(BuildContext context, String code) {
    switch (code) {
      case 'en':
        return L10n.of(context)!.englishSublabel;
      case 'th':
        return L10n.of(context)!.thaiSublabel;
      case 'vi':
        return L10n.of(context)!.vietnameseSublabel;
      case 'id':
        return L10n.of(context)!.indonesianSublabel;
      case 'zh':
        return L10n.of(context)!.chineseSublabel;
      case 'ja':
        return L10n.of(context)!.japaneseSublabel;
      case 'ko':
        return L10n.of(context)!.koreanSublabel;
      case 'es':
        return L10n.of(context)!.spanishSublabel;
      case 'fr':
        return L10n.of(context)!.frenchSublabel;
      case 'de':
        return L10n.of(context)!.germanSublabel;
      case 'pt':
        return L10n.of(context)!.portugueseSublabel;
      case 'hi':
        return L10n.of(context)!.hindiSublabel;
      default:
        return code;
    }
  }

  String _getLanguageFlag(String? code) {
    for (final lang in _supportedLanguages) {
      if (lang['code'] == code) return lang['flag']!;
    }
    return '🌐';
  }

  Widget _buildLanguageCard(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);

    final String languageLabel;
    final String languageFlag;

    if (currentLocale != null) {
      languageLabel = _getLanguageLabel(context, currentLocale.languageCode);
      languageFlag = _getLanguageFlag(currentLocale.languageCode);
    } else {
      languageLabel = L10n.of(context)!.systemDefault;
      languageFlag = '🌐';
    }

    return _buildModernSettingCard(
      context: context,
      title: L10n.of(context)!.languageTitle,
      subtitle: languageLabel,
      leading: Container(
        padding: AppSpacing.paddingSm,
        decoration: BoxDecoration(
          color: AppColors.info.withValues(alpha: 0.1),
          borderRadius: AppRadius.md,
        ),
        child: Text(
          languageFlag,
          style: const TextStyle(fontSize: 20),
        ),
      ),
      onTap: () => _showLanguageDialog(context),
    );
  }

  Future<void> _showCuisineDialog(BuildContext context, profile) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10n.of(context)!.selectYourCuisine),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CuisineOptions.options.map((option) {
                final isSelected = profile.cuisinePreference == option['key'];
                return ChoiceChip(
                  avatar: Text(option['flag']!,
                      style: const TextStyle(fontSize: 16)),
                  label: Text(option['label']!),
                  selected: isSelected,
                  onSelected: (selected) async {
                    if (selected) {
                      profile.cuisinePreference = option['key']!;
                      await ref
                          .read(profileNotifierProvider.notifier)
                          .updateProfile(profile);
                      // Sync cuisine preference to AI analysis
                      GeminiService.setCuisinePreference(option['key']!);
                      if (ctx.mounted) Navigator.pop(ctx);
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(L10n.of(context)!.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguageDialog(BuildContext context) async {
    final currentLocale = ref.read(localeProvider);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10n.of(context)!.selectLanguage),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption(
                  context: ctx,
                  flag: '🌐',
                  label: L10n.of(context)!.systemDefault,
                  sublabel: L10n.of(context)!.systemDefaultSublabel,
                  isSelected: currentLocale == null,
                  onTap: () async {
                    ref.read(localeProvider.notifier).state = null;
                    GeminiService.setUserLanguage('en');
                    await _saveLocaleToProfile(null);
                    if (!mounted || !ctx.mounted) return;
                    Navigator.pop(ctx);
                    if (!mounted) return;
                    _showLanguageChangedSnackbar(
                        L10n.of(context)!.systemDefault);
                  },
                ),
                const SizedBox(height: 8),
                ..._supportedLanguages.map((lang) {
                  final code = lang['code']!;
                  final flag = lang['flag']!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildLanguageOption(
                      context: ctx,
                      flag: flag,
                      label: _getLanguageLabel(context, code),
                      sublabel: _getLanguageSublabel(context, code),
                      isSelected: currentLocale?.languageCode == code,
                      onTap: () async {
                        ref.read(localeProvider.notifier).state = Locale(code);
                        GeminiService.setUserLanguage(code);
                        await _saveLocaleToProfile(code);
                        if (!mounted || !ctx.mounted) return;
                        Navigator.pop(ctx);
                        if (!mounted) return;
                        _showLanguageChangedSnackbar(
                            _getLanguageLabel(context, code));
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(L10n.of(context)!.closeBilingual),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String flag,
    required String label,
    required String sublabel,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.md,
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : isDark
                    ? AppColors.dividerDark.withValues(alpha: 0.4)
                    : AppColors.divider.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.white38 : AppColors.textTertiary),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Flag
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// เก็บ locale ทั้งในโปรไฟล์และ SharedPreferences — ต้องตรงกับ [main.dart] `_initApp`
  /// ที่โหลด `selected_locale` ตอนเปิดแอป มิฉะนั้นหลังรีสตาร์ทจะกลับไปภาษาตอนเลือกครั้งแรก
  Future<void> _saveLocaleToProfile(String? localeCode) async {
    final prefs = await SharedPreferences.getInstance();
    if (localeCode == null || localeCode.isEmpty) {
      await prefs.remove('selected_locale');
    } else {
      await prefs.setString('selected_locale', localeCode);
    }

    final profile = ref.read(profileNotifierProvider).valueOrNull;
    if (profile != null) {
      profile.locale = localeCode;
      ref.read(profileNotifierProvider.notifier).updateProfile(profile);
    }
  }

  void _showLanguageChangedSnackbar(String language) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(L10n.of(context)!.languageChangedTo(language)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSettingCard({
    required BuildContext context,
    required String title,
    String? subtitle,
    Color? textColor,
    bool showArrow = true,
    VoidCallback? onTap,
    Widget? leading,
  }) {
    // Delegate to modern version
    return _buildModernSettingCard(
      context: context,
      title: title,
      subtitle: subtitle,
      leading: leading,
      textColor: textColor,
      onTap: onTap,
      showArrow: showArrow,
    );
  }

  // ===== ซ่อนสำหรับ v1.0 =====
  // void _showComingSoon(BuildContext context, String feature) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('$feature - Coming Soon!'),
  //       behavior: SnackBarBehavior.floating,
  //     ),
  //   );
  // }

  // Widget _buildGoogleCalendarCard(BuildContext context) {
  //   final isConnected = GoogleAuthService.isSignedIn;
  //   final userEmail = GoogleAuthService.currentUser?.email;
  //
  //   return Card(
  //     margin: const EdgeInsets.only(bottom: 8),
  //     child: ListTile(
  //       leading: const Icon(Icons.calendar_today, color: AppColors.primary),
  //       title: const Text('Google Calendar'),
  //       subtitle: Text(
  //         isConnected
  //             ? '✅ เชื่อมต่อแล้ว\n${userEmail ?? ""}'
  //             : 'ยังไม่เชื่อมต่อ',
  //         style: const TextStyle(color: AppColors.textSecondary),
  //       ),
  //       trailing: isConnected
  //           ? IconButton(
  //               icon: const Icon(Icons.logout, color: AppColors.error),
  //               onPressed: () => _handleGoogleSignOut(context),
  //               tooltip: 'ออกจากระบบ',
  //             )
  //           : ElevatedButton.icon(
  //               onPressed: () => _handleGoogleSignIn(context),
  //               icon: const Icon(Icons.login, size: 18),
  //               label: const Text('Login'),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: AppColors.primary,
  //                 foregroundColor: Colors.white,
  //               ),
  //             ),
  //     ),
  //   );
  // }
  // ===== จบซ่อน v1.0 =====

  // ===== ซ่อนสำหรับ v1.0 =====
  // Future<void> _handleGoogleSignIn(BuildContext context) async {
  //   try {
  //     final user = await GoogleAuthService.signIn();
  //     if (user != null && context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('✅ เชื่อมต่อ Google Calendar สำเร็จ\n${user.email}'),
  //           backgroundColor: AppColors.success,
  //           behavior: SnackBarBehavior.floating,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('❌ เกิดข้อผิดพลาด: $e'),
  //           backgroundColor: AppColors.error,
  //           behavior: SnackBarBehavior.floating,
  //         ),
  //       );
  //     }
  //   }
  // }

  // Future<void> _handleGoogleSignOut(BuildContext context) async {
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('ออกจากระบบ Google?'),
  //       content: const Text('คุณจะไม่สามารถ sync กับ Google Calendar ได้'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: const Text('ยกเลิก'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           child: const Text(
  //             'ออกจากระบบ',
  //             style: TextStyle(color: AppColors.error),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   if (confirmed == true) {
  //     await GoogleAuthService.signOut();
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('✅ ออกจากระบบ Google แล้ว'),
  //           behavior: SnackBarBehavior.floating,
  //         ),
  //       );
  //     }
  //   }
  // }
  // ===== จบซ่อน v1.0 =====

  Future<void> _confirmClearAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.error),
            const SizedBox(width: 8),
            Text(L10n.of(context)!.clearAllDataTitle),
          ],
        ),
        content: Text(L10n.of(context)!.clearAllDataContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(L10n.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(L10n.of(context)!.deleteAll,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // 1. Clear Drift DB
        await DatabaseService.db.transaction(() async {
          await DatabaseService.db.delete(DatabaseService.db.foodEntries).go();
          await DatabaseService.db.delete(DatabaseService.db.myMeals).go();
          await DatabaseService.db.delete(DatabaseService.db.ingredients).go();
          await DatabaseService.db.delete(DatabaseService.db.userProfiles).go();
          await DatabaseService.db.delete(DatabaseService.db.chatMessages).go();
          await DatabaseService.db.delete(DatabaseService.db.chatSessions).go();
        });

        // 2. Clear SharedPreferences (dismissed_offers, welcome_claimed, balance cache, etc.)
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // 3. Clear FlutterSecureStorage (device_id cache, welcome flag, balance)
        const storage = FlutterSecureStorage();
        await storage.deleteAll();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(L10n.of(context)!.allDataClearedSuccess),
                duration: const Duration(seconds: 2)),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            (_) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(L10n.of(context)!.errorOccurred(e.toString())),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 2)),
          );
        }
      }
    }
  }

  /// Show feature tour again
  Future<void> _showTutorialAgain() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L10n.of(context)!.showTutorialDialogTitle),
        content: Text(L10n.of(context)!.showTutorialDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(L10n.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(L10n.of(context)!.showTutorialButton),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    // Reset tutorial flag
    await FeatureTour.resetTour();

    // Show success message
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(L10n.of(context)!.tutorialResetMessage),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ============================================================
  // BACKUP & RESTORE HANDLERS
  // ============================================================

  /// Handle Backup Flow
  Future<void> _handleBackup(BuildContext context) async {
    // แสดง Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final backupFiles = await BackupService.createBackup();

      // ปิด Loading
      if (context.mounted) Navigator.pop(context);

      // แสดง Bottom Sheet ถามว่าจะบันทึกหรือแชร์
      if (!context.mounted) return;
      final choice = await _showBackupChoiceSheet(context);

      if (choice == null || !context.mounted) return;

      if (choice == 'save' || choice == 'share') {
        await BackupService.shareBackupFiles(
          backupFiles.dataFile,
          backupFiles.energyFile,
        );
        // Track last backup date for greeting reminders
        await GreetingService.setLastBackupDate(DateTime.now());
      }
    } catch (e) {
      // ปิด Loading (ถ้ายังอยู่)
      if (context.mounted) Navigator.pop(context);

      // แสดง Error
      if (context.mounted) {
        _showErrorDialog(
          context,
          L10n.of(context)!.backupFailed,
          '${L10n.of(context)!.backupFailed}: ${e.toString()}',
        );
      }
    }
  }

  /// Bottom Sheet ให้เลือกว่าจะบันทึกหรือแชร์
  Future<String?> _showBackupChoiceSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSizes.dragHandleWidth,
                height: AppSizes.dragHandleHeight,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: AppRadius.pill,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  L10n.of(context)!.backupCreated,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  L10n.of(context)!.backupChooseDestination,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textTertiary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.md - 2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.info.withValues(alpha: 0.2)
                        : AppColors.info.withValues(alpha: 0.1),
                    borderRadius: AppRadius.md,
                  ),
                  child: Icon(Icons.save_alt_rounded,
                      color: isDark
                          ? AppColors.info.withValues(alpha: 0.7)
                          : AppColors.info,
                      size: 24),
                ),
                title: Text(
                  L10n.of(context)!.backupSaveToDevice,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(L10n.of(context)!.backupSaveToDeviceDesc),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(ctx, 'save'),
              ),
              const Divider(indent: 24, endIndent: 24),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.md - 2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: AppRadius.md,
                  ),
                  child: Icon(Icons.share_rounded,
                      color: isDark
                          ? AppColors.success.withValues(alpha: 0.7)
                          : AppColors.success,
                      size: 24),
                ),
                title: Text(
                  L10n.of(context)!.backupShareToOther,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(L10n.of(context)!.backupShareToOtherDesc),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(ctx, 'share'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle Delete Account (local + cloud)
  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.error),
            const SizedBox(width: 8),
            Text(L10n.of(context)!.deleteAccountTitle),
          ],
        ),
        content: Text(L10n.of(context)!.deleteAccountContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(L10n.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(L10n.of(context)!.deleteAccountConfirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(L10n.of(context)!.deleteAccountDeleting)),
          ],
        ),
      ),
    );

    try {
      final deviceId = await DeviceIdService.getDeviceId();

      // 1. Delete cloud data
      final userDoc = FirebaseFirestore.instance.collection('users').doc(deviceId);
      final energyDoc = FirebaseFirestore.instance.collection('energy').doc(deviceId);

      await Future.wait([
        userDoc.delete(),
        energyDoc.delete(),
      ]);

      // 2. Clear local data (same as clearAllData)
      await DatabaseService.db.transaction(() async {
        await DatabaseService.db.delete(DatabaseService.db.foodEntries).go();
        await DatabaseService.db.delete(DatabaseService.db.myMeals).go();
        await DatabaseService.db.delete(DatabaseService.db.ingredients).go();
        await DatabaseService.db.delete(DatabaseService.db.userProfiles).go();
        await DatabaseService.db.delete(DatabaseService.db.chatMessages).go();
        await DatabaseService.db.delete(DatabaseService.db.chatSessions).go();
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      const secureStorage = FlutterSecureStorage();
      await secureStorage.deleteAll();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.deleteAccountSuccess),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.deleteAccountFailed),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Handle Restore Purchase (IAP)
  Future<void> _handleRestorePurchase(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(L10n.of(context)!.restorePurchaseRestoring)),
          ],
        ),
      ),
    );

    try {
      final service = ref.read(subscriptionServiceProvider);
      await service.restorePurchases();

      await Future.delayed(const Duration(seconds: 3));

      if (!context.mounted) return;
      Navigator.pop(context);

      final subState = ref.read(subscriptionProvider);
      if (subState.subscription.isActive) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.restorePurchaseSuccess),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.restorePurchaseNotFound),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.restorePurchaseFailed),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Handle Restore Flow
  Future<void> _handleRestore(BuildContext context) async {
    try {
      // 1. เลือกไฟล์
      final file = await BackupService.pickBackupFile();

      if (file == null) {
        // ผู้ใช้ยกเลิก
        return;
      }

      // 2. Validate ไฟล์
      BackupInfo? info;
      try {
        info = await BackupService.validateBackupFile(file);
      } catch (e) {
        if (context.mounted) {
          _showErrorDialog(
            context,
            L10n.of(context)!.invalidBackupFile,
            '${L10n.of(context)!.invalidBackupFile}\n\n${e.toString()}',
          );
        }
        return;
      }

      if (info == null) return;

      // 2b. ถ้าเป็น energy file — แจ้งให้เลือก data file แทน
      if (info.fileType == BackupFileType.energy) {
        if (context.mounted) {
          _showErrorDialog(
            context,
            L10n.of(context)!.invalidBackupFile,
            L10n.of(context)!.restoreSelectDataFile,
          );
        }
        return;
      }

      // 3. แสดง Preview + Confirmation
      if (context.mounted) {
        final confirmed = await _showRestoreConfirmationDialog(context, info);

        if (confirmed != true) return;
      }

      // 4. แสดง Loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // 5. Restore
      final result = await BackupService.restoreFromBackup(file);

      // 6. ปิด Loading
      if (context.mounted) Navigator.pop(context);

      // 7. แสดงผลลัพธ์
      if (context.mounted) {
        if (result.success) {
          _showRestoreSuccessDialog(context, result);
        } else {
          _showErrorDialog(
            context,
            L10n.of(context)!.restoreFailed,
            result.errorMessage ?? L10n.of(context)!.error,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(
          context,
          L10n.of(context)!.error,
          '${L10n.of(context)!.restoreFailed}: ${e.toString()}',
        );
      }
    }
  }

  // ============================================================
  // DIALOGS
  // ============================================================

  /// Confirmation Dialog ก่อน Restore
  Future<bool?> _showRestoreConfirmationDialog(
    BuildContext context,
    BackupInfo info,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L10n.of(context)!.restoreBackup),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.premium.withValues(alpha: 0.1),
                  borderRadius: AppRadius.sm,
                ),
                child: const Text(
                  '📦 Full Backup',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.premium,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildInfoRow('${L10n.of(context)!.backupFrom} ',
                  info.deviceInfo ?? L10n.of(context)!.error),
              _buildInfoRow(
                '${L10n.of(context)!.date} ',
                _formatDate(info.createdAt),
              ),
              _buildInfoRow(
                  '${L10n.of(context)!.energy} ', '${info.energyBalance}'),
              _buildInfoRow('${L10n.of(context)!.foodEntries} ',
                  '${info.foodEntryCount}'),
              _buildInfoRow(
                  '${L10n.of(context)!.myMeals} ', '${info.myMealCount}'),
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: AppSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.warning),
                  borderRadius: AppRadius.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning,
                            color: AppColors.warning, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          L10n.of(context)!.restoreImportant,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      L10n.of(context)!
                          .restoreImportantNotes('${info.energyBalance}'),
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(L10n.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: Text(L10n.of(context)!.restore),
          ),
        ],
      ),
    );
  }

  /// Success Dialog หลัง Restore
  void _showRestoreSuccessDialog(
    BuildContext context,
    BackupRestoreResult result,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 28),
            const SizedBox(width: 12),
            Text(L10n.of(context)!.restoreComplete),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L10n.of(context)!.restoreCompleteContent,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildInfoRow('${L10n.of(context)!.newEnergyBalance} ',
                '${result.newEnergyBalance}'),
            _buildInfoRow('${L10n.of(context)!.foodEntriesImported} ',
                '${result.foodEntriesImported}'),
            _buildInfoRow(
                '${L10n.of(context)!.myMeals} ', '${result.myMealsImported}'),
            if (result.foodEntriesImported == 0 && result.fileType == BackupFileType.data) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: AppSpacing.paddingSm,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: AppRadius.sm,
                ),
                child: Text(
                  L10n.of(context)!.restoreZeroEntriesHint,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                const Icon(AppIcons.success,
                    size: 16, color: AppIcons.successColor),
                const SizedBox(width: 4),
                Text(
                  L10n.of(context)!.appWillRefresh,
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(L10n.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  /// Error Dialog
  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: AppColors.error, size: 28),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPER WIDGETS
  // ============================================================

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ============================================
// SCAN SETTINGS CARD
// ============================================

class _ScanSettingsCard extends StatefulWidget {
  @override
  State<_ScanSettingsCard> createState() => _ScanSettingsCardState();
}

class _ScanSettingsCardState extends State<_ScanSettingsCard> {
  int _scanImageLimit = 500;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final galleryService = GalleryService();
    _scanImageLimit = await galleryService.getScanLimit();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? AppColors.surfaceDark : null,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined,
                color: AppColors.primary),
            title: Text(L10n.of(context)!.imagesPerDay),
            subtitle: Text(
                L10n.of(context)!.scanUpToImagesPerDay('$_scanImageLimit')),
            trailing: Icon(Icons.chevron_right,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary),
            onTap: _showScanLimitDialog,
          ),
          Divider(height: 1, color: isDark ? AppColors.dividerDark : null),
          ListTile(
            leading: const Icon(Icons.refresh, color: AppColors.warning),
            title: Text(L10n.of(context)!.resetScanHistory),
            subtitle: Text(L10n.of(context)!.resetScanHistorySubtitle),
            onTap: _resetScanHistory,
          ),
        ],
      ),
    );
  }

  void _showScanLimitDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L10n.of(context)!.imagesPerDayDialog),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              L10n.of(context)!.maxImagesPerDayDescription,
              style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : AppColors.textTertiary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [100, 250, 500, 1000, 2000, 5000].map((limit) {
                return ChoiceChip(
                  label: Text('$limit'),
                  selected: _scanImageLimit == limit,
                  onSelected: (selected) async {
                    if (selected) {
                      final galleryService = GalleryService();
                      await galleryService.setScanLimit(limit);
                      setState(() => _scanImageLimit = limit);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      _showMessage(L10n.of(context)!.scanLimitSetTo('$limit'));
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(L10n.of(context)!.close),
          ),
        ],
      ),
    );
  }

  Future<void> _resetScanHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L10n.of(context)!.resetScanHistoryDialog),
        content: Text(L10n.of(context)!.resetScanHistoryContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(L10n.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: Text(L10n.of(context)!.reset),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // ลบ food entries ที่มาจาก gallery scan (hard delete)
        final scanEntries = await (DatabaseService.db.select(DatabaseService.db.foodEntries)
            ..where((tbl) => tbl.source.equalsValue(DataSource.galleryScanned)))
            .get();

        // ลบ entries ที่ถูก analyze แล้ว (source เปลี่ยนเป็น aiAnalyzed) แต่มี imagePath (มาจาก gallery)
        final analyzedFromGallery = await (DatabaseService.db.select(DatabaseService.db.foodEntries)
            ..where((tbl) => tbl.source.equalsValue(DataSource.aiAnalyzed) & tbl.imagePath.isNotNull() & tbl.imagePath.length.isBiggerThanValue(0)))
            .get();

        final allEntries = [...scanEntries, ...analyzedFromGallery];
        final ids = allEntries.map((e) => e.id).toSet().toList();

        await DatabaseService.db.transaction(() async {
          for (final id in ids) {
            await (DatabaseService.db.delete(DatabaseService.db.foodEntries)..where((tbl) => tbl.id.equals(id))).go();
          }
        });

        // Reset retro scan flag เพื่อให้สแกนรูปเก่าได้อีกครั้ง
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('retro_scan_completed');

        AppLogger.info(
            'Deleted ${ids.length} scan entries (gallery+analyzed) & reset retro scan flag');

        if (!mounted) return;
        _showMessage(L10n.of(context)!.resetComplete('${ids.length}'));
      } catch (e) {
        AppLogger.error('Error resetting scan history', e);
        if (!mounted) return;
        _showMessage(L10n.of(context)!.errorOccurred(e.toString()));
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Auto Sync Status Card
/// Shows last cloud sync date and unsynced entry count.
class _AutoSyncStatusCard extends ConsumerStatefulWidget {
  const _AutoSyncStatusCard();

  @override
  ConsumerState<_AutoSyncStatusCard> createState() =>
      _AutoSyncStatusCardState();
}

class _AutoSyncStatusCardState extends ConsumerState<_AutoSyncStatusCard> {
  String? _lastSyncDate;
  int _unsyncedCount = 0;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadSyncStatus();
  }

  Future<void> _loadSyncStatus() async {
    final lastSync = await DataSyncService.getLastAutoSyncDate();
    final unsynced = await DataSyncService.getUnsyncedCount();
    if (mounted) {
      setState(() {
        _lastSyncDate = lastSync;
        _unsyncedCount = unsynced;
      });
    }
  }

  Future<void> _syncNow() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      await DataSyncService.syncNow();
      await GreetingService.setLastBackupDate(DateTime.now());
      await _loadSyncStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.cloudSyncSuccess),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.cloudSyncFailed(e.toString())),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final synced = _unsyncedCount == 0;
    final statusColor = synced ? AppColors.success : AppColors.warning;
    final statusText = synced
        ? l10n.cloudSyncSynced
        : l10n.cloudSyncPending(_unsyncedCount);
    final dateText = _lastSyncDate != null
        ? l10n.cloudSyncLastDate(_lastSyncDate!)
        : l10n.cloudSyncNever;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: AppRadius.lg,
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: AppSpacing.paddingSm,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.md,
            ),
            child: Icon(
              synced ? Icons.cloud_done_rounded : Icons.cloud_upload_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.cloudSync,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$statusText • $dateText',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.cloudSyncAutoDescription,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white38 : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (!synced)
            GestureDetector(
              onTap: _isSyncing ? null : _syncNow,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.sm,
                ),
                child: _isSyncing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        l10n.cloudSyncNow,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Analytics Consent Toggle Widget
/// Allows users to opt-in/opt-out of analytics data collection
class _AnalyticsConsentToggle extends ConsumerStatefulWidget {
  const _AnalyticsConsentToggle();

  @override
  ConsumerState<_AnalyticsConsentToggle> createState() =>
      _AnalyticsConsentToggleState();
}

class _AnalyticsConsentToggleState
    extends ConsumerState<_AnalyticsConsentToggle> {
  bool _isLoading = true;
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadConsentStatus();
  }

  Future<void> _loadConsentStatus() async {
    final hasConsent = await ConsentService.hasConsent();
    if (mounted) {
      setState(() {
        _isEnabled = hasConsent;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleConsent(bool value) async {
    setState(() => _isLoading = true);

    if (value) {
      await ConsentService.grantConsent();
      await AnalyticsService.setAnalyticsEnabled(true);
    } else {
      await ConsentService.revokeConsent();
      await AnalyticsService.setAnalyticsEnabled(false);
    }

    if (mounted) {
      setState(() {
        _isEnabled = value;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? L10n.of(context)!.analyticsEnabled
                : L10n.of(context)!.analyticsDisabled,
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.md,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        leading: Container(
          padding: AppSpacing.paddingSm,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.info.withValues(alpha: 0.2)
                : AppColors.info.withValues(alpha: 0.1),
            borderRadius: AppRadius.md,
          ),
          child: Icon(
            Icons.analytics_outlined,
            color:
                isDark ? AppColors.info.withValues(alpha: 0.7) : AppColors.info,
            size: 20,
          ),
        ),
        title: Text(
          L10n.of(context)!.analyticsDataCollection,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          _isEnabled
              ? L10n.of(context)!.enabledSubtitle
              : L10n.of(context)!.disabledSubtitle,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textTertiary : AppColors.textSecondary,
          ),
        ),
        trailing: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Switch(
                value: _isEnabled,
                onChanged: _toggleConsent,
              ),
      ),
    );
  }
}

/// Health Sync toggle — connects to Apple Health / Google Health Connect.
/// Requests Read + Write permissions on first toggle ON.
class _HealthSyncToggle extends ConsumerStatefulWidget {
  final UserProfile profile;
  const _HealthSyncToggle({required this.profile});

  @override
  ConsumerState<_HealthSyncToggle> createState() => _HealthSyncToggleState();
}

class _HealthSyncToggleState extends ConsumerState<_HealthSyncToggle> {
  bool _isLoading = false;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.profile.isHealthConnectConnected;
  }

  Future<void> _toggle(bool value) async {
    if (value) {
      await _enableHealthSync();
    } else {
      await _disableHealthSync();
    }
  }

  Future<void> _enableHealthSync() async {
    setState(() => _isLoading = true);

    final available = await HealthSyncService.isAvailable();
    if (!available) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.healthSyncNotAvailable),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final hasPerms = await HealthSyncService.hasPermissions();
    bool granted = hasPerms;

    if (!hasPerms) {
      granted = await HealthSyncService.requestPermissions();
    }

    if (!granted) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showPermissionDeniedDialog();
      }
      return;
    }

    widget.profile.isHealthConnectConnected = true;
    await ref
        .read(profileNotifierProvider.notifier)
        .updateProfile(widget.profile);

    if (mounted) {
      setState(() {
        _isEnabled = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.healthSyncEnabledBmrHint),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _disableHealthSync() async {
    setState(() => _isLoading = true);

    widget.profile.isHealthConnectConnected = false;
    await ref
        .read(profileNotifierProvider.notifier)
        .updateProfile(widget.profile);

    if (mounted) {
      setState(() {
        _isEnabled = false;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.healthSyncDisabled),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10n.of(context)!.healthSyncPermissionDeniedTitle),
        content: Text(L10n.of(context)!.healthSyncPermissionDeniedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(L10n.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              HealthSyncService.openDeviceSettings();
            },
            child: Text(L10n.of(context)!.healthSyncGoToSettings),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.md,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        leading: Container(
          padding: AppSpacing.paddingSm,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: AppRadius.md,
          ),
          child: Icon(
            Icons.favorite_rounded,
            color: isDark
                ? AppColors.error.withValues(alpha: 0.7)
                : AppColors.error,
            size: 20,
          ),
        ),
        title: Text(
          L10n.of(context)!.healthSyncTitle,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          _isEnabled
              ? L10n.of(context)!.healthSyncSubtitleOn
              : L10n.of(context)!.healthSyncSubtitleOff,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textTertiary : AppColors.textSecondary,
          ),
        ),
        trailing: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Switch(
                value: _isEnabled,
                onChanged: _toggle,
              ),
      ),
    );
  }
}

/// Recovery Key card — shows/hides the key for account recovery on new devices.
class _RecoveryKeyCard extends StatefulWidget {
  @override
  State<_RecoveryKeyCard> createState() => _RecoveryKeyCardState();
}

class _RecoveryKeyCardState extends State<_RecoveryKeyCard> {
  String? _recoveryKey;
  bool _isRevealed = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final key = await RecoveryKeyService.getRecoveryKey();
    if (key == null || key.isEmpty) {
      final generated = await RecoveryKeyService.generateRecoveryKey();
      if (mounted) setState(() { _recoveryKey = generated; _isLoading = false; });
    } else {
      if (mounted) setState(() { _recoveryKey = key; _isLoading = false; });
    }
  }

  Future<void> _regenerate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 12),
            Flexible(child: Text(L10n.of(context)!.recoveryKeyRegenerateConfirm)),
          ],
        ),
        content: Text(
          L10n.of(context)!.recoveryKeyRegenerateWarning,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(L10n.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(L10n.of(context)!.recoveryKeyRegenerate),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    final newKey = await RecoveryKeyService.regenerateRecoveryKey();
    if (mounted) {
      setState(() {
        _recoveryKey = newKey;
        _isRevealed = true;
        _isLoading = false;
      });
      if (newKey != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L10n.of(context)!.recoveryKeyRegenerated)),
        );
      }
    }
  }

  String get _maskedKey {
    if (_recoveryKey == null) return '●●●●-●●●●-●●●●';
    return 'ARCAL-●●●●-●●●●';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.key_rounded,
                      color: AppColors.warning, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recovery Key',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        L10n.of(context)!.recoveryKeyDescription,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Regenerate button
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  tooltip: L10n.of(context)!.recoveryKeyRegenerateTooltip,
                  onPressed: _isLoading ? null : _regenerate,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Key display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _isLoading
                        ? Text(L10n.of(context)!.recoveryKeyLoading,
                            style: const TextStyle(color: Colors.grey))
                        : Text(
                            _isRevealed ? (_recoveryKey ?? '-') : _maskedKey,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: _isRevealed
                                  ? AppColors.warning
                                  : (isDark ? Colors.white54 : Colors.black38),
                            ),
                          ),
                  ),
                  // Reveal / Hide toggle
                  IconButton(
                    icon: Icon(
                      _isRevealed
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 20,
                    ),
                    onPressed: _isLoading
                        ? null
                        : () => setState(() => _isRevealed = !_isRevealed),
                    tooltip: _isRevealed ? L10n.of(context)!.recoveryKeyHide : L10n.of(context)!.recoveryKeyShow,
                  ),
                  // Copy button
                  if (_isRevealed && _recoveryKey != null)
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _recoveryKey!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(L10n.of(context)!.recoveryKeyCopied),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      tooltip: L10n.of(context)!.recoveryKeyCopyTooltip,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              L10n.of(context)!.recoveryKeyWarning,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Food Research Consent Toggle
/// Users opt-in to allow food photos to be analyzed for food environment research.
/// Photos with consent are flagged as "researchable" and may include
/// bounding box labels for food, beverages, and dining context.
class _FoodResearchConsentToggle extends ConsumerStatefulWidget {
  const _FoodResearchConsentToggle();

  @override
  ConsumerState<_FoodResearchConsentToggle> createState() =>
      _FoodResearchConsentToggleState();
}

class _FoodResearchConsentToggleState
    extends ConsumerState<_FoodResearchConsentToggle> {
  bool _isLoading = true;
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final profile = await (DatabaseService.db.select(DatabaseService.db.userProfiles)
          ..where((tbl) => tbl.id.equals(1)))
          .getSingleOrNull();
      if (mounted) {
        setState(() {
          _isEnabled = profile?.foodResearchConsent ?? false;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggle(bool value) async {
    if (value) {
      final confirmed = await _showConsentDialog();
      if (confirmed != true) return;
    }

    setState(() => _isLoading = true);

    try {
      final profile = await (DatabaseService.db.select(DatabaseService.db.userProfiles)
          ..where((tbl) => tbl.id.equals(1)))
          .getSingleOrNull();
      if (profile != null) {
        profile.foodResearchConsent = value;
        profile.foodResearchConsentAt = value ? DateTime.now() : null;
        profile.updatedAt = DateTime.now();
        await DatabaseService.db.into(DatabaseService.db.userProfiles).insertOnConflictUpdate(profile);
      }

      if (mounted) {
        setState(() {
          _isEnabled = value;
          _isLoading = false;
        });

        final l10n = L10n.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value
                ? l10n.foodResearchThanks
                : l10n.foodResearchDisabled),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showConsentDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = L10n.of(ctx)!;
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.science_outlined, color: AppColors.premium),
              const SizedBox(width: 12),
              Expanded(
                child: Text(l10n.foodResearchDialogTitle,
                    style: const TextStyle(fontSize: 17)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.foodResearchDialogDescription,
                  style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 16),
              Text(l10n.foodResearchWhatWeAnalyze,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 6),
              Text('✅ ${l10n.foodResearchAnalyze1}', style: const TextStyle(fontSize: 13)),
              Text('✅ ${l10n.foodResearchAnalyze2}', style: const TextStyle(fontSize: 13)),
              Text('✅ ${l10n.foodResearchAnalyze3}', style: const TextStyle(fontSize: 13)),
              Text('✅ ${l10n.foodResearchAnalyze4}', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              Text(l10n.foodResearchWhatWeSkip,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 6),
              Text('❌ ${l10n.foodResearchSkip1}', style: const TextStyle(fontSize: 13)),
              Text('❌ ${l10n.foodResearchSkip2}', style: const TextStyle(fontSize: 13)),
              Text('❌ ${l10n.foodResearchSkip3}', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              Text(l10n.foodResearchPrivacyNote,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.foodResearchDecline),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.premium,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.foodResearchAccept),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.md,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        leading: Container(
          padding: AppSpacing.paddingSm,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.premium.withValues(alpha: 0.2)
                : AppColors.premium.withValues(alpha: 0.1),
            borderRadius: AppRadius.md,
          ),
          child: Icon(
            Icons.science_outlined,
            color: isDark
                ? AppColors.premium.withValues(alpha: 0.7)
                : AppColors.premium,
            size: 20,
          ),
        ),
        title: Text(
          L10n.of(context)!.foodResearch,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          _isEnabled
              ? L10n.of(context)!.foodResearchSubtitleOn
              : L10n.of(context)!.foodResearchSubtitleOff,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textTertiary : AppColors.textSecondary,
          ),
        ),
        trailing: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Switch(
                value: _isEnabled,
                onChanged: _toggle,
              ),
      ),
    );
  }
}

class _PromoCodeSection extends ConsumerStatefulWidget {
  const _PromoCodeSection();

  @override
  ConsumerState<_PromoCodeSection> createState() => _PromoCodeSectionState();
}

class _PromoCodeSectionState extends ConsumerState<_PromoCodeSection> {
  final _controller = TextEditingController();
  bool _isRedeeming = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _messageForError(String key) {
    final l10n = L10n.of(context)!;
    switch (key) {
      case 'invalid_code':
        return l10n.redeemErrorInvalid;
      case 'expired':
        return l10n.redeemErrorExpired;
      case 'max_reached':
        return l10n.redeemErrorMaxReached;
      case 'per_user_limit':
        return l10n.redeemErrorAlreadyUsed;
      case 'user_not_found':
      case 'invalid_reward':
      case 'server_error':
        return l10n.redeemErrorGeneric;
      default:
        return l10n.redeemErrorGeneric;
    }
  }

  Future<void> _redeem() async {
    final code = _controller.text.trim();
    if (code.isEmpty) return;

    setState(() => _isRedeeming = true);
    try {
      await PromoCodeService.redeemCode(code);
      if (!mounted) return;
      await ref.read(energyServiceProvider).syncBalanceWithServer();
      ref.invalidate(currentEnergyProvider);
      await ref.read(gamificationProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            L10n.of(context)!.redeemSuccess,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
        ),
      );
      _controller.clear();
    } on PromoRedeemException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _messageForError(e.errorKey),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            L10n.of(context)!.redeemErrorGeneric,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isRedeeming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.promoCodeTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: l10n.promoCodeHint,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _redeem(),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _isRedeeming ? null : _redeem,
                child: _isRedeeming
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.redeemButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// BMR setting — ย้ายไปอยู่กับ TDEE ใน Health Goals แล้ว
