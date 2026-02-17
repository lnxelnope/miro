import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/services/device_id_service.dart';
import '../../../core/theme/app_icons.dart';
import '../providers/gamification_provider.dart';

class MilestoneProgressCard extends ConsumerStatefulWidget {
  const MilestoneProgressCard({super.key});

  @override
  ConsumerState<MilestoneProgressCard> createState() => _MilestoneProgressCardState();
}

class _MilestoneProgressCardState extends ConsumerState<MilestoneProgressCard> {
  bool _isLoading = false;

  Future<void> _claimMilestone(String milestoneType) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final deviceId = await DeviceIdService.getDeviceId();
      const url =
          'https://us-central1-miro-d6856.cloudfunctions.net/claimMilestone';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': deviceId,
          'milestoneType': milestoneType,
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
                  Icon(AppIcons.celebration, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('+${data['energyReward']} Energy!'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final error = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error['error'] ?? 'Failed to claim milestone'),
              backgroundColor: Colors.red,
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
    
    final totalSpent = gamification.totalSpent;
    final spent500Claimed = gamification.spent500Claimed;
    final spent1000Claimed = gamification.spent1000Claimed;

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
              AppIcons.milestone,
              'Milestones',
              iconColor: AppIcons.milestoneColor,
              iconSize: 24,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 16),
            // 500 Energy milestone
            _buildMilestoneItem(
              title: '500 Energy spent',
              progress: totalSpent,
              target: 500,
              reward: 15,
              isClaimed: spent500Claimed,
              onClaim: () => _claimMilestone('spent500'),
            ),
            const SizedBox(height: 16),
            // 1000 Energy milestone
            _buildMilestoneItem(
              title: '1000 Energy spent',
              progress: totalSpent,
              target: 1000,
              reward: 30,
              isClaimed: spent1000Claimed,
              onClaim: () => _claimMilestone('spent1000'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneItem({
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+$reward ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(AppIcons.energy, size: 14, color: AppIcons.energyColor),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressPercent,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(progressPercent * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '[$progress/$target]',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        // Claim button
        if (isComplete && !isClaimed)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : onClaim,
              icon: const Icon(Icons.star, size: 18),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Claim +$reward '),
                  Icon(AppIcons.energy, size: 16, color: Colors.white),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
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
