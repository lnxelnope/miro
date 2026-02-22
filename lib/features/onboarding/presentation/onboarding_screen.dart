import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/constants/cuisine_options.dart';
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Page Indicator
            Padding(
              padding: const EdgeInsets.all(16),
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
                  _buildPage1Welcome(),
                  _buildPage2CuisineAndGoal(),
                  _buildPage3Ready(),
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
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // ============ Page 1: Welcome ============

  Widget _buildPage1Welcome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          // Logo
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/icon/logo.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              children: [
                TextSpan(
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
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Track calories effortlessly\nwith AI-powered analysis',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),

          // Feature Pills
          _buildFeaturePill(
            icon: AppIcons.camera,
            iconColor: AppIcons.cameraColor,
            title: 'Snap',
            subtitle: 'AI analyzes instantly',
          ),
          const SizedBox(height: 12),
          _buildFeaturePill(
            icon: Icons.chat_rounded,
            iconColor: AppIcons.aiColor,
            title: 'Type',
            subtitle: 'Log in seconds',
          ),
          const SizedBox(height: 12),
          _buildFeaturePill(
            icon: AppIcons.edit,
            iconColor: AppIcons.editColor,
            title: 'Edit',
            subtitle: 'Fine-tune accuracy',
          ),

          const SizedBox(height: 40),
          _buildNextButton(),
          const SizedBox(height: 20),

          // Inline Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(AppIcons.info, size: 20, color: AppIcons.infoColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI-estimated data. Not medical advice.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
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
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
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

  Widget _buildPage2CuisineAndGoal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(AppIcons.meal, size: 32, color: AppIcons.mealColor),
              SizedBox(width: 12),
              Text(
                'Quick Setup',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Help AI understand your food better',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),

          // Cuisine Preference
          const Text(
            'Your typical cuisine:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
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
                selectedColor: AppColors.primary.withOpacity(0.2),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedCuisine = option['key']!);
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color:
                        isSelected ? AppColors.primary : Colors.grey.shade300,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Calorie Goal (Optional)
          const Text(
            'Daily calorie goal (optional):',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _calorieGoalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixText: 'kcal/day',
              hintText: '2000',
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can change this anytime in Profile settings',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 40),
          _buildNextButton(),
        ],
      ),
    );
  }

  // ============ Page 3: You're Ready! ============

  Widget _buildPage3Ready() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(AppIcons.celebration, size: 96, color: AppIcons.celebrationColor),
          const SizedBox(height: 24),
          const Text(
            'You\'re All Set!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start tracking your meals today.\nSnap a photo or type what you ate.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),

          // Welcome Gift Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade50,
                  Colors.teal.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.green.shade300,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                AppIcons.iconWithLabel(
                  AppIcons.gift,
                  'Welcome Gift',
                  iconColor: AppIcons.giftColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 16),
                const Text(
                  '10 FREE Energy',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '= 10 AI analyses to get started',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Each analysis costs 1 Energy\n'
                  'The more you use, the more you earn!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _completeOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Start Tracking! →',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No credit card • No hidden fees',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
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
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Next →',
          style: TextStyle(
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
