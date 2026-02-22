import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/services/consent_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/constants/cuisine_options.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/logger.dart';
import '../../../core/ai/gemini_service.dart';
import '../../health/models/food_entry.dart';
import '../../scanner/services/gallery_service.dart';
import '../providers/profile_provider.dart';
import '../providers/locale_provider.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../onboarding/presentation/tutorial_food_analysis_screen.dart';
import '../../legal/presentation/disclaimer_screen.dart';
import '../../chat/models/chat_ai_mode.dart';
import '../../chat/providers/chat_provider.dart';
import 'health_goals_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';
import '../../home/widgets/feature_tour.dart';
import '../../../core/services/backup_service.dart';
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

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Collapsible sections state (default all collapsed except healthGoals)
  bool _healthGoalsExpanded = true;
  bool _languageExpanded = false;
  bool _aiChatExpanded = false;
  bool _cuisineExpanded = false;
  bool _photoScanExpanded = false;
  bool _accountExpanded = false;
  bool _dataExpanded = false;
  bool _aboutExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            error: (e, st) => Center(child: Text(L10n.of(context)!.errorOccurred(e.toString()))),
            data: (profile) => SingleChildScrollView(
              padding: AppSpacing.paddingXl,
              child: Column(
                children: [
                  // Modern Avatar Section
                  _buildModernAvatarSection(context, profile.name ?? 'User'),
                  SizedBox(height: AppSpacing.xxl),

                  // ──────────────────────────────────────────────
                  // Health Goals (expanded by default)
                  // ──────────────────────────────────────────────
                  _buildCollapsibleSection(
                    title: L10n.of(context)!.healthGoalsSection,
                    icon: Icons.track_changes_rounded,
                    isExpanded: _healthGoalsExpanded,
                    onToggle: () => setState(() => _healthGoalsExpanded = !_healthGoalsExpanded),
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
                    onToggle: () => setState(() => _languageExpanded = !_languageExpanded),
                    child: _buildLanguageCard(context),
                  ),

                  // ──────────────────────────────────────────────
                  // AI Chat Mode (collapsed by default)
                  // ──────────────────────────────────────────────
                  _buildCollapsibleSection(
                    title: L10n.of(context)!.chatAiModeSection,
                    icon: Icons.auto_awesome_rounded,
                    iconColor: AppColors.ai,
                    isExpanded: _aiChatExpanded,
                    onToggle: () => setState(() => _aiChatExpanded = !_aiChatExpanded),
                    child: _buildAiModeSettingCard(context),
                  ),

                  // ──────────────────────────────────────────────
                  // Cuisine Preference (collapsed by default)
                  // ──────────────────────────────────────────────
                  _buildCollapsibleSection(
                    title: L10n.of(context)!.cuisinePreferenceSection,
                    icon: Icons.restaurant_rounded,
                    iconColor: AppColors.warning,
                    isExpanded: _cuisineExpanded,
                    onToggle: () => setState(() => _cuisineExpanded = !_cuisineExpanded),
                    child: _buildCuisinePreferenceCard(context, profile),
                  ),

                  // ──────────────────────────────────────────────
                  // Gallery Scan Settings (collapsed by default)
                  // ──────────────────────────────────────────────
                  _buildCollapsibleSection(
                    title: L10n.of(context)!.photoScanSection,
                    icon: Icons.photo_camera_rounded,
                    isExpanded: _photoScanExpanded,
                    onToggle: () => setState(() => _photoScanExpanded = !_photoScanExpanded),
                    child: _ScanSettingsCard(),
                  ),

                  // ──────────────────────────────────────────────
                  // Account (collapsed by default)
                  // ──────────────────────────────────────────────
                  _buildCollapsibleSection(
                    title: L10n.of(context)!.accountSection,
                    icon: Icons.person_outline_rounded,
                    isExpanded: _accountExpanded,
                    onToggle: () => setState(() => _accountExpanded = !_accountExpanded),
                    child: Column(
                      children: [
                        Consumer(
                          builder: (context, ref, _) {
                            final gamification = ref.watch(gamificationProvider);
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
                                child: Icon(Icons.badge_outlined,
                                    color: AppColors.premium, size: 20),
                              ),
                              showArrow: false,
                              trailing: gamification.miroId.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.copy, size: 18),
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(text: gamification.miroId),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(L10n.of(context)!.miroIdCopied),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    )
                                  : null,
                            );
                          },
                        ),
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
                            child: Icon(Icons.people_outline,
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
                  // Data (collapsed by default)
                  // ──────────────────────────────────────────────
                  _buildCollapsibleSection(
                    title: L10n.of(context)!.dataSection,
                    icon: Icons.storage_rounded,
                    iconColor: AppColors.info,
                    isExpanded: _dataExpanded,
                    onToggle: () => setState(() => _dataExpanded = !_dataExpanded),
                    child: Column(
                      children: [
                        _buildModernSettingCard(
                          context: context,
                          title: L10n.of(context)!.backupData,
                          subtitle: L10n.of(context)!.backupDataSubtitle,
                          leading: Container(
                            padding: AppSpacing.paddingSm,
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.1),
                              borderRadius: AppRadius.md,
                            ),
                            child: Icon(Icons.backup,
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
                            child: Icon(Icons.restore,
                                color: AppColors.success, size: 20),
                          ),
                          onTap: () => _handleRestore(context),
                        ),
                        const _AnalyticsConsentToggle(),
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
                            child: Icon(Icons.delete_forever,
                                color: AppColors.error, size: 20),
                          ),
                          onTap: () => _confirmClearAllData(context),
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
                    iconColor: AppColors.textSecondary,
                    isExpanded: _aboutExpanded,
                    onToggle: () => setState(() => _aboutExpanded = !_aboutExpanded),
                    child: Column(
                      children: [
                        _buildModernSettingCard(
                          context: context,
                          title: L10n.of(context)!.version,
                          subtitle: '1.1.14',
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
                            child: Icon(Icons.privacy_tip_outlined,
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
                            child: Icon(Icons.description_outlined,
                                color: AppColors.ai, size: 20),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TermsScreen()),
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
                            child: Icon(Icons.warning_amber,
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
                            child: Icon(Icons.lightbulb_outline,
                                color: AppColors.warning, size: 20),
                          ),
                          onTap: () => _showTutorialAgain(),
                        ),
                        _buildModernSettingCard(
                          context: context,
                          title: L10n.of(context)!.foodAnalysisTutorial,
                          subtitle: L10n.of(context)!.foodAnalysisTutorialSubtitle,
                          leading: Container(
                            padding: AppSpacing.paddingSm,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withValues(alpha: 0.1),
                              borderRadius: AppRadius.md,
                            ),
                            child: Icon(Icons.school,
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

                  SizedBox(height: AppSpacing.xxxxl),
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
              padding: EdgeInsets.all(AppSpacing.xs),
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
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            // Subscriber Badge (if subscriber)
            if (isSubscribed) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                    const Icon(Icons.diamond_rounded, size: 16, color: Colors.white),
                    SizedBox(width: AppSpacing.sm - 2),
                    Text(
                      L10n.of(context)!.subscriptionEnergyPass,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm - 2),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm - 2, vertical: AppSpacing.xxs),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        color: AppColors.textSecondary,
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
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md + 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.md,
                border: Border.all(
                  color: isExpanded
                      ? color.withValues(alpha: 0.3)
                      : AppColors.divider,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: color),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
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
                      color: AppColors.textTertiary,
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
            padding: EdgeInsets.only(top: AppSpacing.md),
            child: child,
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        SizedBox(height: AppSpacing.md),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
                  borderRadius: AppRadius.lg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                            color: AppColors.textSecondary,
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
                    color: AppColors.textTertiary,
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
        margin: EdgeInsets.only(bottom: AppSpacing.md - 2),
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
                  SizedBox(height: AppSpacing.md),
                  Container(
                    padding: AppSpacing.paddingMd,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
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
                            sub.autoRenewing ? L10n.of(context)!.renews : L10n.of(context)!.expires,
                            expiryText,
                            sub.autoRenewing
                                ? Icons.autorenew
                                : Icons.event_busy,
                          ),
                        ],
                        const SizedBox(height: 8),
                        _buildSubscriptionInfoRow(
                          L10n.of(context)!.autoRenew,
                          sub.autoRenewing ? L10n.of(context)!.on : L10n.of(context)!.off,
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
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        L10n.of(context)!.tapToManageSubscription,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.textTertiary,
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
        child: Icon(
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
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.premium.withValues(alpha: 0.6)),
        SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
                            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAiModeSettingCard(BuildContext context) {
    final currentMode = ref.watch(chatAiModeProvider);
    final isMiroAi = currentMode == ChatAiMode.miroAi;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L10n.of(context)!.selectAiPowersChat,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            // Miro AI option
            _buildAiModeOption(
              context: context,
              icon: Icons.auto_awesome,
              color: AppColors.ai,
              title: L10n.of(context)!.miroAi,
              subtitle: L10n.of(context)!.miroAiSubtitle,
              cost: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(AppIcons.energy, size: 12, color: AppIcons.energyColor),
                  Text('2 + ', style: const TextStyle(fontSize: 12)),
                  const Icon(AppIcons.energy, size: 12, color: AppIcons.energyColor),
                  Text('/item', style: const TextStyle(fontSize: 12)),
                ],
              ),
              isSelected: isMiroAi,
              onTap: () {
                ref.read(chatAiModeProvider.notifier).state = ChatAiMode.miroAi;
              },
            ),
            const SizedBox(height: 8),
            // Local AI option
            _buildAiModeOption(
              context: context,
              icon: Icons.psychology,
              color: AppColors.success,
              title: L10n.of(context)!.localAi,
              subtitle: L10n.of(context)!.localAiSubtitle,
              cost: Text(L10n.of(context)!.free, style: const TextStyle(fontSize: 12)),
              isSelected: !isMiroAi,
              onTap: () {
                ref.read(chatAiModeProvider.notifier).state = ChatAiMode.local;
              },
            ),
          ],
        ),
      ),
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
      case 'en': return L10n.of(context)!.english;
      case 'th': return L10n.of(context)!.thai;
      case 'vi': return L10n.of(context)!.vietnamese;
      case 'id': return L10n.of(context)!.indonesian;
      case 'zh': return L10n.of(context)!.chinese;
      case 'ja': return L10n.of(context)!.japanese;
      case 'ko': return L10n.of(context)!.korean;
      case 'es': return L10n.of(context)!.spanish;
      case 'fr': return L10n.of(context)!.french;
      case 'de': return L10n.of(context)!.german;
      case 'pt': return L10n.of(context)!.portuguese;
      case 'hi': return L10n.of(context)!.hindi;
      default: return code;
    }
  }

  String _getLanguageSublabel(BuildContext context, String code) {
    switch (code) {
      case 'en': return L10n.of(context)!.englishSublabel;
      case 'th': return L10n.of(context)!.thaiSublabel;
      case 'vi': return L10n.of(context)!.vietnameseSublabel;
      case 'id': return L10n.of(context)!.indonesianSublabel;
      case 'zh': return L10n.of(context)!.chineseSublabel;
      case 'ja': return L10n.of(context)!.japaneseSublabel;
      case 'ko': return L10n.of(context)!.koreanSublabel;
      case 'es': return L10n.of(context)!.spanishSublabel;
      case 'fr': return L10n.of(context)!.frenchSublabel;
      case 'de': return L10n.of(context)!.germanSublabel;
      case 'pt': return L10n.of(context)!.portugueseSublabel;
      case 'hi': return L10n.of(context)!.hindiSublabel;
      default: return code;
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
                  onTap: () {
                    ref.read(localeProvider.notifier).state = null;
                    Navigator.pop(ctx);
                    _showLanguageChangedSnackbar(L10n.of(context)!.systemDefault);
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
                      onTap: () {
                        ref.read(localeProvider.notifier).state = Locale(code);
                        Navigator.pop(ctx);
                        _showLanguageChangedSnackbar(_getLanguageLabel(context, code));
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
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.md,
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
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
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
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
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
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

  void _showLanguageChangedSnackbar(String language) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(L10n.of(context)!.languageChangedTo(language)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildAiModeOption({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Widget cost,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.md,
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.4)
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
                  color: isSelected ? color : AppColors.textTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Icon
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm - 2, vertical: AppSpacing.xxs),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: AppRadius.md,
                        ),
                        child: DefaultTextStyle(
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                          child: cost,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
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
        content: Text(
          '${L10n.of(context)!.clearAllDataContent}\n\n'
          'รวมถึง: Isar DB, SharedPreferences, SecureStorage\n'
          '(เหมือน install ใหม่ — ใช้คู่กับ Factory Reset ใน Admin Panel)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(L10n.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child:
                Text(L10n.of(context)!.deleteAll, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // 1. Clear Isar DB
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.foodEntries.clear();
          await DatabaseService.myMeals.clear();
          await DatabaseService.ingredients.clear();
          await DatabaseService.userProfiles.clear();
          await DatabaseService.chatMessages.clear();
          await DatabaseService.chatSessions.clear();
        });

        // 2. Clear SharedPreferences (dismissed_offers, welcome_claimed, balance cache, etc.)
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // 3. Clear FlutterSecureStorage (device_id cache, welcome flag, balance)
        const storage = FlutterSecureStorage();
        await storage.deleteAll();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(L10n.of(context)!.allDataClearedSuccess), duration: const Duration(seconds: 2)),
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
            SnackBar(content: Text(L10n.of(context)!.errorOccurred(e.toString())), backgroundColor: AppColors.error, duration: const Duration(seconds: 2)),
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
                margin: EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: AppRadius.pill,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
                    color: isDark ? AppColors.textTertiary : AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Container(
                  padding: EdgeInsets.all(AppSpacing.md - 2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.info.withValues(alpha: 0.2) : AppColors.info.withValues(alpha: 0.1),
                    borderRadius: AppRadius.md,
                  ),
                  child: Icon(Icons.save_alt_rounded,
                      color: isDark ? AppColors.info.withValues(alpha: 0.7) : AppColors.info,
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
                  padding: EdgeInsets.all(AppSpacing.md - 2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.success.withValues(alpha: 0.2) : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: AppRadius.md,
                  ),
                  child: Icon(Icons.share_rounded,
                      color: isDark ? AppColors.success.withValues(alpha: 0.7) : AppColors.success,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              SizedBox(height: AppSpacing.md),

              _buildInfoRow(
                  '${L10n.of(context)!.backupFrom} ', info.deviceInfo ?? L10n.of(context)!.error),
              _buildInfoRow(
                '${L10n.of(context)!.date} ',
                _formatDate(info.createdAt),
              ),
              _buildInfoRow('${L10n.of(context)!.energy} ', '${info.energyBalance}'),
              _buildInfoRow('${L10n.of(context)!.foodEntries} ', '${info.foodEntryCount}'),
              _buildInfoRow('${L10n.of(context)!.myMeals} ', '${info.myMealCount}'),

              SizedBox(height: AppSpacing.lg),
              const Divider(),
              SizedBox(height: AppSpacing.lg),

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
                        const Icon(Icons.warning, color: AppColors.warning, size: 20),
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
                      L10n.of(context)!.restoreImportantNotes('${info.energyBalance}'),
                      style: TextStyle(
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
            SizedBox(height: AppSpacing.lg),
            _buildInfoRow('${L10n.of(context)!.newEnergyBalance} ', '${result.newEnergyBalance}'),
            _buildInfoRow(
                '${L10n.of(context)!.foodEntriesImported} ', '${result.foodEntriesImported}'),
            _buildInfoRow('${L10n.of(context)!.myMeals} ', '${result.myMealsImported}'),
            SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                const Icon(AppIcons.success, size: 16, color: AppIcons.successColor),
                const SizedBox(width: 4),
                Text(
                  L10n.of(context)!.appWillRefresh,
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined,
                color: AppColors.primary),
            title: Text(L10n.of(context)!.imagesPerDay),
            subtitle: Text(L10n.of(context)!.scanUpToImagesPerDay('$_scanImageLimit')),
            trailing:
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: _showScanLimitDialog,
          ),
          const Divider(height: 1),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L10n.of(context)!.imagesPerDayDialog),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              L10n.of(context)!.maxImagesPerDayDescription,
              style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
            ),
            SizedBox(height: AppSpacing.lg),
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
        final scanEntries = await DatabaseService.foodEntries
            .filter()
            .sourceEqualTo(DataSource.galleryScanned)
            .findAll();

        // ลบ entries ที่ถูก analyze แล้ว (source เปลี่ยนเป็น aiAnalyzed) แต่มี imagePath (มาจาก gallery)
        final analyzedFromGallery = await DatabaseService.foodEntries
            .filter()
            .sourceEqualTo(DataSource.aiAnalyzed)
            .imagePathIsNotNull()
            .imagePathIsNotEmpty()
            .findAll();

        final allEntries = [...scanEntries, ...analyzedFromGallery];
        final ids = allEntries.map((e) => e.id).toSet().toList();

        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.foodEntries.deleteAll(ids);
        });

        // Reset retro scan flag เพื่อให้สแกนรูปเก่าได้อีกครั้ง
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('retro_scan_completed');

        AppLogger.info('Deleted ${ids.length} scan entries (gallery+analyzed) & reset retro scan flag');

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
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        leading: Container(
          padding: AppSpacing.paddingSm,
          decoration: BoxDecoration(
            color: isDark ? AppColors.info.withValues(alpha: 0.2) : AppColors.info.withValues(alpha: 0.1),
            borderRadius: AppRadius.md,
          ),
          child: Icon(
            Icons.analytics_outlined,
            color: isDark ? AppColors.info.withValues(alpha: 0.7) : AppColors.info,
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

