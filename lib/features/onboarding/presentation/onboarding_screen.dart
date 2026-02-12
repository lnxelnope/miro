import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/tdee_calculator.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/models/user_profile.dart';
import '../../profile/presentation/api_key_screen.dart';
import '../../profile/providers/profile_provider.dart';
import '../../home/presentation/home_screen.dart';
import '../../../core/database/database_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Page 3: ข้อมูลพื้นฐาน
  String _gender = 'male';
  final _ageController = TextEditingController(text: '25');
  final _weightController = TextEditingController(text: '65');
  final _heightController = TextEditingController(text: '170');
  String _activityLevel = 'moderate';

  double? _tdee;
  Map<String, int>? _suggestions;

  @override
  void initState() {
    super.initState();
    // คำนวณ TDEE ครั้งแรกเมื่อ init
    WidgetsBinding.instance.addPostFrameCallback((_) => _recalculate());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
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
                children: List.generate(4, (i) => _buildDot(i)),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildPage1Welcome(),
                  _buildPage2Features(),
                  _buildPage3UserInfo(),
                  _buildPage4ApiKey(),
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
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon หรือ ภาพประกอบ
          const Icon(Icons.restaurant_menu, size: 100, color: AppColors.primary),
          const SizedBox(height: 32),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'MIRO\n',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 4,
                  ),
                ),
                TextSpan(
                  text: 'Intake Oracle',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Smart AI-powered food tracking',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 48),
          _buildNextButton(),
        ],
      ),
    );
  }

  // ============ Page 2: Features ============

  Widget _buildPage2Features() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFeatureRow(Icons.camera_alt, 'ถ่ายรูปอาหาร', 'AI วิเคราะห์ kcal อัตโนมัติ'),
          const SizedBox(height: 24),
          _buildFeatureRow(Icons.chat_bubble, 'พิมพ์แชท', 'บอกว่า "กินข้าวผัด" → บันทึกให้เลย'),
          const SizedBox(height: 24),
          _buildFeatureRow(Icons.bar_chart, 'สรุปทุกวัน', 'ดู kcal, โปรตีน, คาร์บ, ไขมัน'),
          const SizedBox(height: 48),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  // ============ Page 3: User Info + TDEE ============

  Widget _buildPage3UserInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Basic Info',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('To calculate your recommended daily calories',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),

          // Gender
          const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'male', label: Text('Male'), icon: Icon(Icons.male)),
              ButtonSegment(value: 'female', label: Text('Female'), icon: Icon(Icons.female)),
            ],
            selected: {_gender},
            onSelectionChanged: (v) {
              setState(() => _gender = v.first);
              _recalculate();
            },
          ),
          const SizedBox(height: 16),

          // Age + Weight + Height (Row)
          Row(
            children: [
              Expanded(child: _buildNumberField('Age', _ageController, 'years')),
              const SizedBox(width: 12),
              Expanded(child: _buildNumberField('Weight', _weightController, 'kg')),
              const SizedBox(width: 12),
              Expanded(child: _buildNumberField('Height', _heightController, 'cm')),
            ],
          ),
          const SizedBox(height: 16),

          // Activity Level
          const Text('Activity Level', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _activityLevel,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: TdeeCalculator.activityLevels.map((level) {
              return DropdownMenuItem(
                value: level['key'],
                child: Text(level['th']!, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _activityLevel = v);
                _recalculate();
              }
            },
          ),
          const SizedBox(height: 24),

          // แสดงผล TDEE
          if (_tdee != null) _buildTdeeResult(),

          const SizedBox(height: 24),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller, String suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            suffixText: suffix,
            isDense: true,
          ),
          onChanged: (_) => _recalculate(),
        ),
      ],
    );
  }

  Widget _buildTdeeResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recommended Goals',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Text('Your TDEE: ${_tdee!.round()} kcal/day',
              style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          if (_suggestions != null) ...[
            Text('• Maintain weight: ${_suggestions!["maintain"]} kcal',
                style: const TextStyle(fontSize: 13)),
            Text('• Lose weight: ${_suggestions!["loss"]} kcal',
                style: const TextStyle(fontSize: 13)),
            Text('• Gain weight: ${_suggestions!["gain"]} kcal',
                style: const TextStyle(fontSize: 13)),
          ],
        ],
      ),
    );
  }

  void _recalculate() {
    final age = int.tryParse(_ageController.text);
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (age != null && weight != null && height != null &&
        age > 0 && weight > 0 && height > 0) {
      final tdee = TdeeCalculator.calculateTDEE(
        weightKg: weight,
        heightCm: height,
        age: age,
        gender: _gender,
        activityLevel: _activityLevel,
      );
      setState(() {
        _tdee = tdee;
        _suggestions = TdeeCalculator.suggestGoals(tdee: tdee);
      });
    }
  }

  // ============ Page 4: API Key ============

  Widget _buildPage4ApiKey() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.smart_toy, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          const Text('Set up Gemini AI',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Snap food photos → AI calculates calories automatically\nCreate API Key for free! Takes just 5 minutes',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ApiKeyScreen()),
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('Set up now'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _completeOnboarding,
              child: const Text('Skip for now'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can still log food manually without API Key',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
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
          if (_currentPage < 3) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
          // Page 3 → recalculate TDEE ก่อนไปต่อ
          if (_currentPage == 2) {
            _recalculate();
          }
        },
        child: const Text('ถัดไป'),
      ),
    );
  }

  // ============ Complete Onboarding ============

  Future<void> _completeOnboarding() async {
    // บันทึกข้อมูลลง UserProfile
    final profile = await DatabaseService.userProfiles.get(1) ?? UserProfile();

    profile.gender = _gender;
    profile.age = int.tryParse(_ageController.text);
    profile.weight = double.tryParse(_weightController.text);
    profile.height = double.tryParse(_heightController.text);
    profile.activityLevel = _activityLevel;
    profile.onboardingComplete = true;

    // บันทึกเป้าหมาย kcal (ใช้ค่า "ลดน้ำหนัก" เป็น default)
    if (_suggestions != null && _suggestions!['loss'] != null) {
      profile.calorieGoal = _suggestions!['loss']!.toDouble();
    }

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.userProfiles.put(profile);
      // Clear any leftover data from previous sessions
      await DatabaseService.foodEntries.clear();
    });

    // Invalidate profile provider เพื่อ refresh
    ref.invalidate(userProfileProvider);

    // Navigate ไป HomeScreen
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,  // ลบ stack ทั้งหมด
      );
    }
  }
}
