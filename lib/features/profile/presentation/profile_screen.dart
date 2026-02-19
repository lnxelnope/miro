import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/services/permission_service.dart';
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

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Profile & Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ref.watch(profileNotifierProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
            data: (profile) => SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Modern Avatar Section
                  _buildModernAvatarSection(context, profile.name ?? 'User'),
                  const SizedBox(height: 28),

                  // Health Goals
                  _buildModernSectionTitle('🎯 Health Goals'),
                  const SizedBox(height: 12),
                  _buildModernSettingCard(
                    context: context,
                    title: 'Daily Goals',
                    subtitle:
                        '${profile.calorieGoal.toInt()} kcal • P ${profile.proteinGoal.toInt()}g • C ${profile.carbGoal.toInt()}g • F ${profile.fatGoal.toInt()}g',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HealthGoalsScreen()),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // AI Chat Mode
                  _buildModernSectionTitle('🤖 Chat AI Mode'),
                  const SizedBox(height: 12),
                  _buildAiModeSettingCard(context),
                  const SizedBox(height: 24),

                  // Cuisine Preference
                  _buildModernSectionTitle('🍽️ Cuisine Preference'),
                  const SizedBox(height: 12),
                  _buildCuisinePreferenceCard(context, profile),
                  const SizedBox(height: 24),

                  // Gallery Scan Settings
                  _buildModernSectionTitle('📸 Photo Scan'),
                  const SizedBox(height: 12),
                  _ScanSettingsCard(),
                  const SizedBox(height: 24),

                  // Account
                  _buildModernSectionTitle('🆔 Account'),
                  const SizedBox(height: 12),
                  Consumer(
                    builder: (context, ref, _) {
                      final gamification = ref.watch(gamificationProvider);
                      return _buildModernSettingCard(
                        context: context,
                        title: 'MiRO ID',
                        subtitle: gamification.miroId.isEmpty
                            ? 'Loading...'
                            : gamification.miroId,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.badge_outlined,
                              color: Colors.purple.shade600, size: 20),
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
                                    const SnackBar(
                                      content: Text('MiRO ID copied!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              )
                            : null,
                      );
                    },
                  ),
                  // Phase 4: Referral
                  _buildModernSettingCard(
                    context: context,
                    title: 'Invite Friends',
                    subtitle: 'Share your referral code and earn rewards!',
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.people_outline,
                          color: Colors.green.shade600, size: 20),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReferralScreen(),
                      ),
                    ),
                  ),
                  // Phase 5: Subscription
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
                  const SizedBox(height: 24),

                  // Data
                  _buildModernSectionTitle('💾 Data'),
                  const SizedBox(height: 12),
                  _buildModernSettingCard(
                    context: context,
                    title: 'Backup Data',
                    subtitle: 'Energy + Food History → save as file',
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.backup,
                          color: Colors.blue.shade600, size: 20),
                    ),
                    onTap: () => _handleBackup(context),
                  ),
                  _buildModernSettingCard(
                    context: context,
                    title: 'Restore from Backup',
                    subtitle: 'Import data from backup file',
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.restore,
                          color: Colors.green.shade600, size: 20),
                    ),
                    onTap: () => _handleRestore(context),
                  ),
                  
                  // ✅ Analytics Consent Toggle
                  const _AnalyticsConsentToggle(),
                  
                  _buildModernSettingCard(
                    context: context,
                    title: 'Clear All Data',
                    textColor: AppColors.error,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.delete_forever,
                          color: Colors.red.shade600, size: 20),
                    ),
                    onTap: () => _confirmClearAllData(context),
                  ),
                  const SizedBox(height: 24),

                  // About
                  _buildModernSectionTitle('ℹ️ About'),
                  const SizedBox(height: 12),
                  _buildModernSettingCard(
                    context: context,
                    title: 'Version',
                    subtitle: '1.0.2',
                    showArrow: false,
                  ),
                  _buildModernSettingCard(
                    context: context,
                    title: 'Privacy Policy',
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.privacy_tip_outlined,
                          color: Colors.purple.shade600, size: 20),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen()),
                    ),
                  ),
                  _buildModernSettingCard(
                    context: context,
                    title: 'Terms of Service',
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.description_outlined,
                          color: Colors.indigo.shade600, size: 20),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TermsScreen()),
                    ),
                  ),
                  _buildModernSettingCard(
                    context: context,
                    title: 'Health Disclaimer',
                    subtitle: 'Important legal information',
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.warning_amber,
                          color: Colors.orange.shade600, size: 20),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DisclaimerScreen()),
                    ),
                  ),
                  _buildModernSettingCard(
                    context: context,
                    title: 'Show Tutorial Again',
                    subtitle: 'View feature tour',
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.lightbulb_outline,
                          color: Colors.amber.shade700, size: 20),
                    ),
                    onTap: () => _showTutorialAgain(),
                  ),
                  _buildModernSettingCard(
                    context: context,
                    title: 'Food Analysis Tutorial',
                    subtitle: 'Learn how to use food analysis features',
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.school,
                          color: Colors.teal.shade600, size: 20),
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
                  const SizedBox(height: 40),
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
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.health],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
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
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            // Subscriber Badge (if subscriber)
            if (isSubscribed) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.diamond_rounded, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    const Text(
                      'Energy Pass',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
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
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: gamification.tierColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: gamification.tierColor.withOpacity(0.3),
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
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: gamification.tierColor.withOpacity(0.6),
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                            color: Colors.grey.shade600,
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
                    color: Colors.grey.shade400,
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
        statusColor = Colors.orange;
      } else {
        statusLabel = 'ACTIVE';
        statusColor = const Color(0xFF7C3AED);
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF7C3AED).withOpacity(0.05),
              const Color(0xFF6D28D9).withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF7C3AED).withOpacity(0.2),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
            ),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.diamond,
                          color: Color(0xFF7C3AED),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Energy Pass',
                          style: TextStyle(
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
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
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
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _buildSubscriptionInfoRow(
                          'Plan',
                          'Monthly',
                          Icons.calendar_month,
                        ),
                        if (startText.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildSubscriptionInfoRow(
                            'Started',
                            startText,
                            Icons.play_circle_outline,
                          ),
                        ],
                        if (expiryText.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildSubscriptionInfoRow(
                            sub.autoRenewing ? 'Renews' : 'Expires',
                            expiryText,
                            sub.autoRenewing
                                ? Icons.autorenew
                                : Icons.event_busy,
                          ),
                        ],
                        const SizedBox(height: 8),
                        _buildSubscriptionInfoRow(
                          'Auto-Renew',
                          sub.autoRenewing ? 'On' : 'Off',
                          Icons.repeat,
                          valueColor: sub.autoRenewing
                              ? Colors.green
                              : Colors.orange,
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
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tap to manage subscription',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey.shade400,
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
      title: 'Energy Pass',
      subtitle: isLoading
          ? 'Loading...'
          : 'Unlimited AI + Double rewards',
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.diamond,
          color: Colors.purple.shade600,
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
        Icon(icon, size: 16, color: const Color(0xFF7C3AED).withOpacity(0.6)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.grey.shade800,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select which AI powers your chat',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            // Miro AI option
            _buildAiModeOption(
              context: context,
              icon: Icons.auto_awesome,
              color: const Color(0xFF6366F1),
              title: 'Miro AI',
              subtitle: 'Powered by Gemini • Multi-language • High accuracy',
              cost: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.energy, size: 12, color: AppIcons.energyColor),
                  Text('2 + ', style: TextStyle(fontSize: 12)),
                  Icon(AppIcons.energy, size: 12, color: AppIcons.energyColor),
                  Text('/item', style: TextStyle(fontSize: 12)),
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
              color: Colors.green,
              title: 'Local AI',
              subtitle: 'On-device • English only • Basic accuracy',
              cost: const Text('Free', style: TextStyle(fontSize: 12)),
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
      title: 'Preferred Cuisine',
      subtitle: CuisineOptions.getLabel(profile.cuisinePreference),
      leading: Text(
        CuisineOptions.getFlag(profile.cuisinePreference),
        style: const TextStyle(fontSize: 20),
      ),
      onTap: () => _showCuisineDialog(context, profile),
    );
  }

  Future<void> _showCuisineDialog(BuildContext context, profile) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Your Cuisine'),
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
            child: const Text('Cancel'),
          ),
        ],
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.4)
                : Colors.grey.withOpacity(0.2),
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
                  color: isSelected ? color : Colors.grey.shade400,
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DefaultTextStyle(
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
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
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Clear all data?'),
          ],
        ),
        content: const Text(
          'All data will be deleted:\n'
          '• Food entries\n'
          '• My Meals\n'
          '• Ingredients\n'
          '• Goals\n'
          '• Personal info\n\n'
          'This cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Delete All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseService.isar.writeTxn(() async {
          // Clear all collections
          await DatabaseService.foodEntries.clear();
          await DatabaseService.myMeals.clear();
          await DatabaseService.ingredients.clear();
          await DatabaseService.userProfiles.clear();
          await DatabaseService.chatMessages.clear();
          await DatabaseService.chatSessions.clear();
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All data cleared successfully'), duration: Duration(seconds: 2)),
          );
          // กลับไป Onboarding
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            (_) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 2)),
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
        title: const Text('Show Tutorial'),
        content: const Text(
          'This will show the feature tour that highlights:\n\n'
          '• Energy System\n'
          '• Pull-to-Refresh Photo Scan\n'
          '• Chat with Miro AI\n\n'
          'You will return to the Home screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Show Tutorial'),
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
      const SnackBar(
        content: Text('Tutorial reset! Go to Home screen to view it.'),
        duration: Duration(seconds: 3),
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
      // สร้าง Backup
      final file = await BackupService.createBackup();

      // ปิด Loading
      if (context.mounted) Navigator.pop(context);

      // Share ไฟล์
      await BackupService.shareBackupFile(file);

      // แสดง Success Dialog
      if (context.mounted) {
        _showBackupSuccessDialog(context, file);
      }
    } catch (e) {
      // ปิด Loading
      if (context.mounted) Navigator.pop(context);

      // แสดง Error
      if (context.mounted) {
        _showErrorDialog(
          context,
          'Backup Failed',
          'Failed to create backup: ${e.toString()}',
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
            'Invalid Backup File',
            'This file is not a valid Miro backup file.\n\n${e.toString()}',
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
            'Restore Failed',
            result.errorMessage ?? 'Unknown error',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(
          context,
          'Error',
          'Failed to restore backup: ${e.toString()}',
        );
      }
    }
  }

  // ============================================================
  // DIALOGS
  // ============================================================

  /// Success Dialog หลัง Backup
  void _showBackupSuccessDialog(BuildContext context, File file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Backup Created!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your backup file has been created successfully.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(AppIcons.warning, size: 18, color: AppIcons.warningColor),
                SizedBox(width: 4),
                Text(
                  'Important:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '• Save this file in a safe place (Google Drive, etc.)\n'
              '• Photos are NOT included in the backup\n'
              '• Transfer Key expires in 30 days\n'
              '• Key can only be used once',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                file.path.split('/').last,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Confirmation Dialog ก่อน Restore
  Future<bool?> _showRestoreConfirmationDialog(
    BuildContext context,
    BackupInfo info,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup?'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Info
              _buildInfoRow(
                  'Backup from:', info.deviceInfo ?? 'Unknown device'),
              _buildInfoRow(
                'Date:',
                _formatDate(info.createdAt),
              ),
              _buildInfoRow('Energy:', '${info.energyBalance}'),
              _buildInfoRow('Food entries:', '${info.foodEntryCount}'),
              _buildInfoRow('My Meals:', '${info.myMealCount}'),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Important',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Current Energy on this device will be REPLACED with Energy from backup (${info.energyBalance})\n'
                      '• Food entries will be MERGED (not replaced)\n'
                      '• Photos are NOT included in backup\n'
                      '• Transfer Key will be used (cannot be reused)',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Colors.orange[900],
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Restore'),
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
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Restore Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your data has been restored successfully.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('New Energy Balance:', '${result.newEnergyBalance}'),
            _buildInfoRow(
                'Food Entries Imported:', '${result.foodEntriesImported}'),
            _buildInfoRow('My Meals Imported:', '${result.myMealsImported}'),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(AppIcons.success, size: 16, color: AppIcons.successColor),
                SizedBox(width: 4),
                Text(
                  'Your app will refresh to show the restored data.',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Refresh app state (reload providers, etc.)
            },
            child: const Text('OK'),
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
            const Icon(Icons.error, color: Colors.red, size: 28),
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
            title: const Text('Images per day'),
            subtitle: Text('Scan up to $_scanImageLimit images per day'),
            trailing:
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: _showScanLimitDialog,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.refresh, color: AppColors.warning),
            title: const Text('Reset Scan History'),
            subtitle: const Text('Delete all scanned entries and re-scan'),
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
        title: const Text('Images per day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Maximum images to scan per day\nScans only the selected date',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
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
                      _showMessage('Scan limit set to $limit images per day');
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
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetScanHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Scan History?'),
        content: const Text(
          'All gallery-scanned food entries will be deleted.\n'
          'Pull down on any date to re-scan images.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // ลบ food entries ที่มาจาก gallery scan
        final scanEntries = await DatabaseService.foodEntries
            .filter()
            .sourceEqualTo(DataSource.galleryScanned)
            .findAll();

        final ids = scanEntries.map((e) => e.id).toList();

        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.foodEntries.deleteAll(ids);
        });

        AppLogger.info('Deleted ${ids.length} gallery-scanned entries');

        if (!mounted) return;
        _showMessage(
            'Reset complete - ${ids.length} entries deleted. Pull down to re-scan.');
      } catch (e) {
        AppLogger.error('Error resetting scan history', e);
        if (!mounted) return;
        _showMessage('Error: $e');
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
                ? 'Analytics enabled - ขอบคุณที่ช่วยปรับปรุงแอป'
                : 'Analytics disabled - ไม่เก็บข้อมูลการใช้งาน',
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
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.blue.shade900 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.analytics_outlined,
            color: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
            size: 20,
          ),
        ),
        title: const Text(
          'Analytics Data Collection',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          _isEnabled
              ? 'Enabled - ช่วยปรับปรุงประสบการณ์ใช้งาน'
              : 'Disabled - ไม่เก็บข้อมูลการใช้งาน',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
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

