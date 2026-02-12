# Step 04: Profile & Settings Screen

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 1 ชั่วโมง
> **ความยาก:** ปานกลาง
> **ต้องทำก่อน:** Step 02 (Home Screen)

---

## สิ่งที่ต้องทำ

1. สร้าง Profile Screen
2. สร้าง API Key Settings Screen
3. สร้าง Health Goals Settings Screen
4. สร้าง Secure Storage Service สำหรับเก็บ API Key
5. เชื่อมต่อจาก Home Screen

---

## ขั้นตอนที่ 1: สร้าง Secure Storage Service

**สร้างไฟล์:** `lib/core/services/secure_storage_service.dart`

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Gemini API Key
  static Future<void> saveGeminiApiKey(String apiKey) async {
    await _storage.write(
      key: AppConstants.apiKeyStorageKey,
      value: apiKey,
    );
  }

  static Future<String?> getGeminiApiKey() async {
    return await _storage.read(key: AppConstants.apiKeyStorageKey);
  }

  static Future<void> deleteGeminiApiKey() async {
    await _storage.delete(key: AppConstants.apiKeyStorageKey);
  }

  static Future<bool> hasGeminiApiKey() async {
    final key = await getGeminiApiKey();
    return key != null && key.isNotEmpty;
  }

  // Clear all
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

---

## ขั้นตอนที่ 2: สร้าง Profile Provider

**สร้างไฟล์:** `lib/features/profile/providers/profile_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/constants/app_constants.dart';
import '../models/user_profile.dart';

// User Profile Provider
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final profiles = await DatabaseService.userProfiles.where().findAll();
  
  if (profiles.isEmpty) {
    // สร้าง default profile
    final profile = UserProfile()
      ..name = 'User'
      ..calorieGoal = AppConstants.defaultCalorieGoal
      ..proteinGoal = AppConstants.defaultProteinGoal
      ..carbGoal = AppConstants.defaultCarbGoal
      ..fatGoal = AppConstants.defaultFatGoal
      ..waterGoal = AppConstants.defaultWaterGoal;
    
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.userProfiles.put(profile);
    });
    
    return profile;
  }
  
  return profiles.first;
});

// Has API Key Provider
final hasApiKeyProvider = FutureProvider<bool>((ref) async {
  return await SecureStorageService.hasGeminiApiKey();
});

// Update Profile Notifier
class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  ProfileNotifier() : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profiles = await DatabaseService.userProfiles.where().findAll();
      
      if (profiles.isEmpty) {
        final profile = UserProfile()
          ..name = 'User'
          ..calorieGoal = AppConstants.defaultCalorieGoal
          ..proteinGoal = AppConstants.defaultProteinGoal
          ..carbGoal = AppConstants.defaultCarbGoal
          ..fatGoal = AppConstants.defaultFatGoal;
        
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.userProfiles.put(profile);
        });
        
        state = AsyncValue.data(profile);
      } else {
        state = AsyncValue.data(profiles.first);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    profile.updatedAt = DateTime.now();
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.userProfiles.put(profile);
    });
    state = AsyncValue.data(profile);
  }

  Future<void> updateHealthGoals({
    double? calorieGoal,
    double? proteinGoal,
    double? carbGoal,
    double? fatGoal,
    double? waterGoal,
  }) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    if (calorieGoal != null) currentProfile.calorieGoal = calorieGoal;
    if (proteinGoal != null) currentProfile.proteinGoal = proteinGoal;
    if (carbGoal != null) currentProfile.carbGoal = carbGoal;
    if (fatGoal != null) currentProfile.fatGoal = fatGoal;
    if (waterGoal != null) currentProfile.waterGoal = waterGoal;

    await updateProfile(currentProfile);
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile>>((ref) {
  return ProfileNotifier();
});
```

---

## ขั้นตอนที่ 3: สร้าง Profile Screen

**สร้างไฟล์:** `lib/features/profile/presentation/profile_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/profile_provider.dart';
import 'api_key_screen.dart';
import 'health_goals_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final hasApiKeyAsync = ref.watch(hasApiKeyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์ & การตั้งค่า'),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar
              _buildAvatarSection(context, profile.name ?? 'User'),
              const SizedBox(height: 24),

              // API Settings
              _buildSectionTitle('🔑 API Settings'),
              _buildSettingCard(
                context: context,
                title: 'Gemini API Key',
                subtitle: hasApiKeyAsync.when(
                  data: (hasKey) => hasKey ? '✅ Connected' : '⚠️ ยังไม่ตั้งค่า',
                  loading: () => 'กำลังโหลด...',
                  error: (_, __) => 'Error',
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ApiKeyScreen()),
                ),
              ),
              const SizedBox(height: 16),

              // Health Goals
              _buildSectionTitle('🎯 เป้าหมายสุขภาพ'),
              _buildSettingCard(
                context: context,
                title: 'แคลอรี่/วัน',
                subtitle: '${profile.calorieGoal.toInt()} kcal',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HealthGoalsScreen()),
                ),
              ),
              _buildSettingCard(
                context: context,
                title: 'โปรตีน/วัน',
                subtitle: '${profile.proteinGoal.toInt()}g',
                showArrow: false,
              ),
              _buildSettingCard(
                context: context,
                title: 'คาร์บ/วัน',
                subtitle: '${profile.carbGoal.toInt()}g',
                showArrow: false,
              ),
              _buildSettingCard(
                context: context,
                title: 'ไขมัน/วัน',
                subtitle: '${profile.fatGoal.toInt()}g',
                showArrow: false,
              ),
              const SizedBox(height: 16),

              // Connections
              _buildSectionTitle('📅 การเชื่อมต่อ'),
              _buildSettingCard(
                context: context,
                title: 'Google Calendar',
                subtitle: profile.isGoogleCalendarConnected
                    ? '✅ เชื่อมต่อแล้ว'
                    : 'ยังไม่เชื่อมต่อ',
                onTap: () => _showComingSoon(context, 'Google Calendar'),
              ),
              _buildSettingCard(
                context: context,
                title: 'Health Connect',
                subtitle: profile.isHealthConnectConnected
                    ? '✅ เชื่อมต่อแล้ว'
                    : 'ยังไม่เชื่อมต่อ',
                onTap: () => _showComingSoon(context, 'Health Connect'),
              ),
              const SizedBox(height: 16),

              // Data
              _buildSectionTitle('💾 ข้อมูล'),
              _buildSettingCard(
                context: context,
                title: 'สำรองข้อมูล (Export)',
                onTap: () => _showComingSoon(context, 'Export'),
              ),
              _buildSettingCard(
                context: context,
                title: 'กู้คืนข้อมูล (Import)',
                onTap: () => _showComingSoon(context, 'Import'),
              ),
              _buildSettingCard(
                context: context,
                title: 'ล้างข้อมูลทั้งหมด',
                textColor: AppColors.error,
                onTap: () => _showClearDataDialog(context),
              ),
              const SizedBox(height: 16),

              // About
              _buildSectionTitle('ℹ️ เกี่ยวกับ'),
              _buildSettingCard(
                context: context,
                title: 'เวอร์ชัน',
                subtitle: '1.0.0',
                showArrow: false,
              ),
              _buildSettingCard(
                context: context,
                title: 'นโยบายความเป็นส่วนตัว',
                onTap: () => _showComingSoon(context, 'Privacy Policy'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context, String name) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primaryLight,
          child: const Icon(
            Icons.person,
            size: 50,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
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
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? AppColors.textPrimary,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(color: AppColors.textSecondary),
              )
            : null,
        trailing: showArrow
            ? const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ล้างข้อมูลทั้งหมด?'),
        content: const Text(
          'ข้อมูลทั้งหมดจะถูกลบและไม่สามารถกู้คืนได้',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Clear all data
            },
            child: const Text(
              'ลบทั้งหมด',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 4: สร้าง API Key Screen

**สร้างไฟล์:** `lib/features/profile/presentation/api_key_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/secure_storage_service.dart';
import '../providers/profile_provider.dart';

class ApiKeyScreen extends ConsumerStatefulWidget {
  const ApiKeyScreen({super.key});

  @override
  ConsumerState<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends ConsumerState<ApiKeyScreen> {
  final _controller = TextEditingController();
  bool _isObscured = true;
  bool _isLoading = false;
  bool _hasKey = false;
  String? _savedKey;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final key = await SecureStorageService.getGeminiApiKey();
    setState(() {
      _hasKey = key != null && key.isNotEmpty;
      _savedKey = key;
      if (_hasKey) {
        _controller.text = key!;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่า Gemini API Key'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Center(
              child: Icon(
                Icons.smart_toy,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Gemini AI',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'ใช้ Gemini วิเคราะห์รูปภาพและข้อความอัตโนมัติ',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // API Key input
            const Text(
              'API Key',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              obscureText: _isObscured,
              decoration: InputDecoration(
                hintText: 'AIza...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _isObscured = !_isObscured);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.paste),
                      onPressed: _pasteFromClipboard,
                    ),
                    if (_hasKey)
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: _deleteApiKey,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ℹ️ วิธีรับ API Key:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('1. ไปที่ aistudio.google.com'),
                  const Text('2. คลิก "Get API Key"'),
                  const Text('3. สร้าง Key แล้วคัดลอกมาวางที่นี่'),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openGoogleAiStudio,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('เปิด Google AI Studio'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Status
            if (_hasKey)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle, color: AppColors.success),
                    SizedBox(width: 8),
                    Text(
                      'สถานะ: ✅ เชื่อมต่อสำเร็จ',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveApiKey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'บันทึก API Key',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Test button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _hasKey ? _testConnection : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('ทดสอบการเชื่อมต่อ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _controller.text = data!.text!;
    }
  }

  Future<void> _openGoogleAiStudio() async {
    final uri = Uri.parse('https://aistudio.google.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _saveApiKey() async {
    final key = _controller.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอก API Key')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SecureStorageService.saveGeminiApiKey(key);
      
      // Update profile
      final profileNotifier = ref.read(profileNotifierProvider.notifier);
      final profile = ref.read(profileNotifierProvider).value;
      if (profile != null) {
        profile.hasGeminiApiKey = true;
        await profileNotifier.updateProfile(profile);
      }

      setState(() {
        _hasKey = true;
        _savedKey = key;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('บันทึก API Key สำเร็จ!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteApiKey() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบ API Key?'),
        content: const Text('คุณจะไม่สามารถใช้ Gemini AI ได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await SecureStorageService.deleteGeminiApiKey();
              _controller.clear();
              setState(() {
                _hasKey = false;
                _savedKey = null;
              });
            },
            child: const Text(
              'ลบ',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testConnection() async {
    // TODO: Implement API test
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ทดสอบการเชื่อมต่อ - Coming Soon!')),
    );
  }
}
```

---

## ขั้นตอนที่ 5: สร้าง Health Goals Screen

**สร้างไฟล์:** `lib/features/profile/presentation/health_goals_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/profile_provider.dart';

class HealthGoalsScreen extends ConsumerStatefulWidget {
  const HealthGoalsScreen({super.key});

  @override
  ConsumerState<HealthGoalsScreen> createState() => _HealthGoalsScreenState();
}

class _HealthGoalsScreenState extends ConsumerState<HealthGoalsScreen> {
  late TextEditingController _calorieController;
  late TextEditingController _proteinController;
  late TextEditingController _carbController;
  late TextEditingController _fatController;
  late TextEditingController _waterController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _calorieController = TextEditingController();
    _proteinController = TextEditingController();
    _carbController = TextEditingController();
    _fatController = TextEditingController();
    _waterController = TextEditingController();
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  void _initControllers(profile) {
    if (_calorieController.text.isEmpty) {
      _calorieController.text = profile.calorieGoal.toInt().toString();
      _proteinController.text = profile.proteinGoal.toInt().toString();
      _carbController.text = profile.carbGoal.toInt().toString();
      _fatController.text = profile.fatGoal.toInt().toString();
      _waterController.text = profile.waterGoal.toInt().toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('เป้าหมายสุขภาพ'),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (profile) {
          _initControllers(profile);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: AppColors.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'ตั้งเป้าหมายโภชนาการรายวันของคุณ',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Calorie Goal
                _buildGoalInput(
                  label: '🔥 แคลอรี่/วัน',
                  controller: _calorieController,
                  unit: 'kcal',
                  hint: '2000',
                ),
                const SizedBox(height: 16),

                // Macros
                const Text(
                  '💪 Macros',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildGoalInput(
                        label: 'โปรตีน',
                        controller: _proteinController,
                        unit: 'g',
                        hint: '120',
                        color: AppColors.protein,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGoalInput(
                        label: 'คาร์บ',
                        controller: _carbController,
                        unit: 'g',
                        hint: '250',
                        color: AppColors.carbs,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGoalInput(
                        label: 'ไขมัน',
                        controller: _fatController,
                        unit: 'g',
                        hint: '65',
                        color: AppColors.fat,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Water Goal
                _buildGoalInput(
                  label: '💧 น้ำ/วัน',
                  controller: _waterController,
                  unit: 'ml',
                  hint: '2500',
                ),
                const SizedBox(height: 32),

                // Quick presets
                const Text(
                  '⚡ Presets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPresetChip(
                      label: 'ลดน้ำหนัก',
                      values: {'cal': 1500, 'p': 130, 'c': 150, 'f': 50},
                    ),
                    _buildPresetChip(
                      label: 'รักษาน้ำหนัก',
                      values: {'cal': 2000, 'p': 120, 'c': 250, 'f': 65},
                    ),
                    _buildPresetChip(
                      label: 'เพิ่มกล้าม',
                      values: {'cal': 2500, 'p': 180, 'c': 300, 'f': 70},
                    ),
                    _buildPresetChip(
                      label: 'Keto',
                      values: {'cal': 1800, 'p': 120, 'c': 50, 'f': 130},
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveGoals,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'บันทึก',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalInput({
    required String label,
    required TextEditingController controller,
    required String unit,
    required String hint,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: color ?? AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: unit,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: color ?? AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip({
    required String label,
    required Map<String, int> values,
  }) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        setState(() {
          _calorieController.text = values['cal'].toString();
          _proteinController.text = values['p'].toString();
          _carbController.text = values['c'].toString();
          _fatController.text = values['f'].toString();
        });
      },
    );
  }

  Future<void> _saveGoals() async {
    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(profileNotifierProvider.notifier);
      
      await notifier.updateHealthGoals(
        calorieGoal: double.tryParse(_calorieController.text),
        proteinGoal: double.tryParse(_proteinController.text),
        carbGoal: double.tryParse(_carbController.text),
        fatGoal: double.tryParse(_fatController.text),
        waterGoal: double.tryParse(_waterController.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('บันทึกเป้าหมายสำเร็จ!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
```

---

## ขั้นตอนที่ 6: เชื่อมต่อจาก Home Screen

**แก้ไขไฟล์:** `lib/features/home/presentation/home_screen.dart`

**เพิ่ม import:**

```dart
import '../../profile/presentation/profile_screen.dart';
```

**แก้ไข method `_openProfile()`:**

```dart
void _openProfile() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ProfileScreen()),
  );
}
```

---

## ขั้นตอนที่ 7: เพิ่ม url_launcher package

**รันคำสั่ง:**

```bash
flutter pub add url_launcher
```

---

## ขั้นตอนที่ 8: ทดสอบ

```bash
flutter run
```

**ผลที่ควรได้:**
- กดที่ Avatar ซ้ายบน → ไปหน้า Profile
- หน้า Profile แสดงเมนูต่างๆ
- กด API Key → ไปหน้าตั้งค่า API Key
- สามารถกรอก API Key และบันทึกได้
- กด เป้าหมายสุขภาพ → ไปหน้าตั้งเป้าหมาย
- สามารถเลือก Preset หรือกรอกเองได้

---

## ✅ Checklist

- [ ] สร้าง secure_storage_service.dart แล้ว
- [ ] สร้าง profile_provider.dart แล้ว
- [ ] สร้าง profile_screen.dart แล้ว
- [ ] สร้าง api_key_screen.dart แล้ว
- [ ] สร้าง health_goals_screen.dart แล้ว
- [ ] เชื่อมต่อจาก Home Screen แล้ว
- [ ] ติดตั้ง url_launcher แล้ว
- [ ] ทดสอบ run app สำเร็จ

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/
├── core/
│   └── services/
│       └── secure_storage_service.dart  ← NEW
└── features/
    ├── home/
    │   └── presentation/
    │       └── home_screen.dart         ← UPDATED
    └── profile/
        ├── presentation/
        │   ├── profile_screen.dart      ← NEW
        │   ├── api_key_screen.dart      ← NEW
        │   └── health_goals_screen.dart ← NEW
        └── providers/
            └── profile_provider.dart    ← NEW
```

---

## ขั้นตอนถัดไป

ไปที่ **Step 05: Health Timeline** เพื่อสร้างหน้า Timeline ของ Health
