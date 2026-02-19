import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/services/device_id_service.dart';
import '../../../core/theme/app_icons.dart';
import '../providers/gamification_provider.dart';

class WeeklyChallengeCard extends ConsumerStatefulWidget {
  const WeeklyChallengeCard({super.key});

  @override
  ConsumerState<WeeklyChallengeCard> createState() => _WeeklyChallengeCardState();
}

class _WeeklyChallengeCardState extends ConsumerState<WeeklyChallengeCard> {
  Map<String, dynamic>? _challengeData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChallengeData();
  }

  Future<void> _loadChallengeData() async {
    // Load จาก gamification provider หรือ sync จาก server
    final gamification = ref.read(gamificationProvider);
    // TODO: เพิ่ม challenge data ใน GamificationState
  }

  Future<void> _claimChallenge(String challengeType) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final deviceId = await DeviceIdService.getDeviceId();
      const url =
          'https://us-central1-miro-d6856.cloudfunctions.net/completeChallenge';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': deviceId,
          'challengeType': challengeType,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Refresh gamification state
        ref.read(gamificationProvider.notifier).refresh();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(AppIcons.celebration, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('+${data['energyReward']} Energy!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        final error = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error['error'] ?? 'Failed to claim reward'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gamification = ref.watch(gamificationProvider);
    
    final logMealsProgress = gamification.logMealsProgress;
    final useAiProgress = gamification.useAiProgress;
    final claimedRewards = gamification.claimedRewards;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIcons.iconWithLabel(
              AppIcons.challenge,
              'Weekly Challenges',
              iconColor: AppIcons.challengeColor,
              iconSize: 24,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 16),
            // Log Meals Challenge
            _buildChallengeItem(
              icon: AppIcons.meal,
              iconColor: AppIcons.mealColor,
              title: 'Log 7 meals',
              progress: logMealsProgress,
              target: 7,
              reward: 5,
              isClaimed: claimedRewards.contains('logMeals'),
              onClaim: () => _claimChallenge('logMeals'),
            ),
            const SizedBox(height: 12),
            // Use AI Challenge
            _buildChallengeItem(
              icon: AppIcons.ai,
              iconColor: AppIcons.aiColor,
              title: 'Use AI 3 times',
              progress: useAiProgress,
              target: 3,
              reward: 5,
              isClaimed: claimedRewards.contains('useAi'),
              onClaim: () => _claimChallenge('useAi'),
            ),
            const SizedBox(height: 12),
            // Reset info
            AppIcons.iconWithLabel(
              AppIcons.timer,
              'Resets every Monday',
              iconColor: AppIcons.timerColor,
              iconSize: 14,
              fontSize: 12,
              textColor: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int progress,
    required int target,
    required int reward,
    required bool isClaimed,
    required VoidCallback onClaim,
  }) {
    final isComplete = progress >= target;
    final progressPercent = (progress / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '[$progress/$target]',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressPercent,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              isComplete ? Colors.green : Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Claim button
        if (isComplete && !isClaimed)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : onClaim,
              icon: const Icon(Icons.check_circle, size: 18),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Claim +$reward '),
                  const Icon(AppIcons.energy, size: 16, color: Colors.white),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          )
        else if (isClaimed)
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 18),
              const SizedBox(width: 4),
              Text(
                'Claimed!',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
