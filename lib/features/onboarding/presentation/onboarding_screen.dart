import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/constants/cuisine_options.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/models/user_profile.dart';
import '../../profile/providers/profile_provider.dart';
import '../../../core/database/database_service.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/services/analytics_service.dart';
import 'tutorial_food_analysis_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Page 2: Cuisine + Calorie Goal
  String _selectedCuisine = 'international';
  final _calorieGoalController = TextEditingController(text: '2000');

  @override
  void dispose() {
    _pageController.dispose();
    _calorieGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Page Indicator
            Padding(
              padding: AppSpacing.paddingLg,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => _buildDot(i)),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildPage1Welcome(isDark),
                  _buildPage2CuisineAndGoal(isDark),
                  _buildPage3Ready(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ Page Indicator ============

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : AppColors.divider,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
    );
  }

  // ============ Page 1: Welcome ============

  Widget _buildPage1Welcome(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl, vertical: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          ClipRRect(
            borderRadius: AppRadius.xl,
            child: Image.asset(
              'assets/icon/logo.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'M I R O\n',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 4,
                  ),
                ),
                TextSpan(
                  text: 'My Intake Record Oracle',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            L10n.of(context)!.onboardingWelcomeSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxxl),

          _buildFeaturePill(
            icon: AppIcons.camera,
            iconColor: AppIcons.cameraColor,
            title: L10n.of(context)!.onboardingSnap,
            subtitle: L10n.of(context)!.onboardingSnapDesc,
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFeaturePill(
            icon: Icons.chat_rounded,
            iconColor: AppIcons.aiColor,
            title: L10n.of(context)!.onboardingType,
            subtitle: L10n.of(context)!.onboardingTypeDesc,
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFeaturePill(
            icon: AppIcons.edit,
            iconColor: AppIcons.editColor,
            title: L10n.of(context)!.onboardingEdit,
            subtitle: L10n.of(context)!.onboardingEditDesc,
            isDark: isDark,
          ),

          const SizedBox(height: AppSpacing.xxxxl),
          _buildNextButton(),
          const SizedBox(height: AppSpacing.xl),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: AppRadius.sm,
            ),
            child: Row(
              children: [
                const Icon(AppIcons.info, size: 20, color: AppIcons.infoColor),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    L10n.of(context)!.onboardingDisclaimer,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: AppRadius.lg,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$title → ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ Page 2: Cuisine + Calorie Goal ============

  Widget _buildPage2CuisineAndGoal(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(AppIcons.meal, size: 32, color: AppIcons.mealColor),
              const SizedBox(width: 12),
              Text(
                L10n.of(context)!.onboardingQuickSetup,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            L10n.of(context)!.onboardingHelpAiUnderstand,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          Text(
            L10n.of(context)!.onboardingYourTypicalCuisine,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CuisineOptions.options.take(6).map((option) {
              final isSelected = _selectedCuisine == option['key'];
              return ChoiceChip(
                avatar:
                    Text(option['flag']!, style: const TextStyle(fontSize: 18)),
                label: Text(
                  option['label']!,
                  style: const TextStyle(fontSize: 13),
                ),
                selected: isSelected,
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedCuisine = option['key']!);
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.xl,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          Text(
            L10n.of(context)!.onboardingDailyCalorieGoal,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _calorieGoalController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: AppRadius.md,
              ),
              suffixText: L10n.of(context)!.onboardingKcalPerDay,
              hintText: L10n.of(context)!.onboardingCalorieGoalHint,
              filled: true,
              fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            L10n.of(context)!.onboardingCanChangeAnytime,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: AppSpacing.xxxxl),
          _buildNextButton(),
        ],
      ),
    );
  }

  // ============ Page 3: You're Ready! ============

  Widget _buildPage3Ready(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.xxxxl),
          const Icon(AppIcons.celebration, size: 96, color: AppIcons.celebrationColor),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            L10n.of(context)!.onboardingYoureAllSet,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            L10n.of(context)!.onboardingStartTracking,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxxl),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: isDark ? 0.15 : 0.1),
                  AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.1),
                ],
              ),
              borderRadius: AppRadius.xl,
              border: Border.all(
                color: AppColors.success,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                AppIcons.iconWithLabel(
                  AppIcons.gift,
                  L10n.of(context)!.onboardingWelcomeGift,
                  iconColor: AppIcons.giftColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 16),
                Text(
                  L10n.of(context)!.onboardingFreeEnergy,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  L10n.of(context)!.onboardingFreeEnergyDesc,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  L10n.of(context)!.onboardingEnergyCost,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxxxl),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _completeOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.lg,
                ),
                elevation: 2,
              ),
              child: Text(
                L10n.of(context)!.onboardingStartTrackingButton,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            L10n.of(context)!.onboardingNoCreditCard,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ============ Navigation ============

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          if (_currentPage < 2) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.md,
          ),
        ),
        child: Text(
          L10n.of(context)!.onboardingNext,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============ Complete Onboarding ============

  Future<void> _completeOnboarding() async {
    // บันทึกข้อมูลลง UserProfile (minimal)
    final profile = await DatabaseService.userProfiles.get(1) ?? UserProfile();

    // เก็บแค่ cuisine + calorie goal เท่านั้น
    profile.cuisinePreference = _selectedCuisine;

    // Parse calorie goal (optional - default 2000)
    final calorieGoal = double.tryParse(_calorieGoalController.text) ?? 2000.0;
    profile.calorieGoal = calorieGoal;

    profile.onboardingComplete = true;

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.userProfiles.put(profile);
      // Clear any leftover data from previous sessions
      await DatabaseService.foodEntries.clear();
    });

    // Invalidate profile provider เพื่อ refresh
    ref.invalidate(userProfileProvider);

    // Set cuisine preference for AI analysis bias
    GeminiService.setCuisinePreference(_selectedCuisine);

    // Mark disclaimer as acknowledged (inline disclaimer on page 1)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('disclaimer_acknowledged', true);

    // Analytics: onboarding completed
    AnalyticsService.logOnboardingComplete();

    // Navigate to tutorial
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const TutorialFoodAnalysisScreen(),
        ),
      );
    }
  }
}
