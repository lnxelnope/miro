import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../core/services/purchase_service.dart';
import '../../../core/database/database_service.dart';
import '../../scanner/services/gallery_service.dart';
import '../providers/profile_provider.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import 'api_key_screen.dart';
import 'health_goals_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final hasApiKeyAsync = ref.watch(hasApiKeyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
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

              // Pro Status / Upgrade
              _buildSectionTitle('⭐ Pro'),
              FutureBuilder<bool>(
                future: UsageLimiter.isPro(),
                builder: (context, snapshot) {
                  final isPro = snapshot.data ?? false;

                  if (isPro) {
                    // Show Pro badge
                    return _buildSettingCard(
                      context: context,
                      title: 'Miro Cal Pro',
                      subtitle: 'Thank you for your support! Unlimited AI',
                      leading: const Icon(Icons.star, color: Colors.amber),
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
                      showArrow: false,
                    );
                  }

                  // Not Pro yet → show upgrade button
                  return _buildSettingCard(
                    context: context,
                    title: 'Upgrade to Pro',
                    subtitle: 'Unlimited AI food analysis',
                    leading: const Icon(Icons.star_outline, color: Colors.purple),
                    onTap: () => PurchaseService.buyPro(),
                  );
                },
              ),
              FutureBuilder<bool>(
                future: UsageLimiter.isPro(),
                builder: (context, snapshot) {
                  final isPro = snapshot.data ?? false;
                  if (isPro) return const SizedBox.shrink();
                  
                  return _buildSettingCard(
                    context: context,
                    title: 'Restore Purchase',
                    subtitle: 'For device transfer',
                    leading: const Icon(Icons.restore),
                    onTap: () async {
                      await PurchaseService.restorePurchase();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Checking purchase...')),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // API Settings
              _buildSectionTitle('🔑 API Settings'),
              _buildSettingCard(
                context: context,
                title: 'Gemini API Key',
                subtitle: hasApiKeyAsync.when(
                  data: (hasKey) => hasKey ? '✅ Connected' : '⚠️ Not configured',
                  loading: () => 'Loading...',
                  error: (_, __) => 'Error',
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ApiKeyScreen()),
                ),
              ),
              const SizedBox(height: 16),

              // Health Goals
              _buildSectionTitle('🎯 Health Goals'),
              _buildSettingCard(
                context: context,
                title: 'Daily Goals',
                subtitle: '${profile.calorieGoal.toInt()} kcal • P ${profile.proteinGoal.toInt()}g • C ${profile.carbGoal.toInt()}g • F ${profile.fatGoal.toInt()}g',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HealthGoalsScreen()),
                ),
              ),
              const SizedBox(height: 16),

              // Gallery Scan Settings
              _buildSectionTitle('📸 Photo Scan'),
              _ScanSettingsCard(),
              const SizedBox(height: 16),

              // ===== ซ่อนสำหรับ v1.0 =====
              // Connections
              // _buildSectionTitle('📅 การเชื่อมต่อ'),
              // _buildGoogleCalendarCard(context),
              // _buildSettingCard(
              //   context: context,
              //   title: 'Health Connect',
              //   subtitle: profile.isHealthConnectConnected
              //       ? '✅ เชื่อมต่อแล้ว'
              //       : 'ยังไม่เชื่อมต่อ',
              //   onTap: () => _showComingSoon(context, 'Health Connect'),
              // ),
              // const SizedBox(height: 16),

              // Insights
              // _buildSectionTitle('📊 Insights'),
              // _buildSettingCard(
              //   context: context,
              //   title: 'สรุปสัปดาห์',
              //   subtitle: 'ดูสถิติและแนวโน้ม',
              //   onTap: () => Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (_) => const WeeklySummaryScreen()),
              //   ),
              // ),
              // const SizedBox(height: 16),
              // ===== จบซ่อน v1.0 =====

              // Data
              _buildSectionTitle('💾 Data'),
              // ===== ซ่อน Export/Import สำหรับ v1.0 =====
              // _buildSettingCard(
              //   context: context,
              //   title: 'Export Data',
              //   onTap: () => _showComingSoon(context, 'Export'),
              // ),
              // _buildSettingCard(
              //   context: context,
              //   title: 'Import Data',
              //   onTap: () => _showComingSoon(context, 'Import'),
              // ),
              // ===== จบซ่อน v1.0 =====
              _buildSettingCard(
                context: context,
                title: 'Clear All Data',
                textColor: AppColors.error,
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                onTap: () => _confirmClearAllData(context),
              ),
              const SizedBox(height: 16),

              // About
              _buildSectionTitle('ℹ️ About'),
              _buildSettingCard(
                context: context,
                title: 'Version',
                subtitle: '1.0.0',
                showArrow: false,
              ),
              _buildSettingCard(
                context: context,
                title: 'Privacy Policy',
                leading: const Icon(Icons.privacy_tip_outlined),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                ),
              ),
              _buildSettingCard(
                context: context,
                title: 'Terms of Service',
                leading: const Icon(Icons.description_outlined),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsScreen()),
                ),
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
        const CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primaryLight,
          child: Icon(
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
    Widget? leading,
    Widget? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: leading,
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
        trailing: trailing ?? (showArrow
            ? const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              )
            : null),
        onTap: onTap,
      ),
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

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถเปิดลิงก์ได้: $url')),
        );
      }
    }
  }

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
            child: const Text('Delete All', style: TextStyle(color: Colors.white)),
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
            const SnackBar(content: Text('All data cleared successfully')),
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
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
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
  int _scanDaysBack = 7;
  int _scanImageLimit = 500;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final permService = PermissionService();
    final galleryService = GalleryService();
    
    _scanDaysBack = await permService.getScanDaysBack();
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
            leading: const Icon(Icons.history, color: AppColors.primary),
            title: const Text('Scan history'),
            subtitle: Text('$_scanDaysBack days'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: _showScanDaysBackDialog,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
            title: const Text('Images to scan'),
            subtitle: Text('$_scanImageLimit images'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: _showScanLimitDialog,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.refresh, color: AppColors.warning),
            title: const Text('Reset Scan History'),
            subtitle: const Text('Re-scan all images from start'),
            onTap: _resetScanHistory,
          ),
        ],
      ),
    );
  }

  void _showScanDaysBackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan history (days)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select how many days back to scan\nHigher values take longer',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [1, 3, 7, 14, 30, 90].map((days) {
                return ChoiceChip(
                  label: Text('$days days'),
                  selected: _scanDaysBack == days,
                  onSelected: (selected) async {
                    if (selected) {
                      final permService = PermissionService();
                      await permService.setScanDaysBack(days);
                      setState(() => _scanDaysBack = days);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      _showMessage('Scan history set to $days days');
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

  void _showScanLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Images to scan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select maximum number of images to scan\nHigher values take longer',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [100, 250, 500, 1000, 2000, 5000].map((limit) {
                return ChoiceChip(
                  label: Text('$limit images'),
                  selected: _scanImageLimit == limit,
                  onSelected: (selected) async {
                    if (selected) {
                      final galleryService = GalleryService();
                      await galleryService.setScanLimit(limit);
                      setState(() => _scanImageLimit = limit);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      _showMessage('Scan limit set to $limit images');
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
          'All images will be re-scanned based on your day setting.\n'
          'Duplicate entries may appear.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_scan_timestamp');
      if (!mounted) return;
      _showMessage('Reset complete - pull down to refresh and scan again');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
