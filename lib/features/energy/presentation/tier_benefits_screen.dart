import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';

/// Tier Benefits Screen
/// 
/// แสดงข้อมูลสิทธิประโยชน์ของแต่ละระดับ Tier
class TierBenefitsScreen extends StatelessWidget {
  const TierBenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Tier Benefits',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Card
          _buildHeaderCard(),
          const SizedBox(height: 24),

          // How it works
          _buildHowItWorksCard(),
          const SizedBox(height: 24),

          // Tier List
          Text(
            'All Tiers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),

          _buildTierCard(
            tier: 'Starter',
            icon: AppIcons.tierStarter,
            color: AppIcons.tierStarterColor,
            streakRequired: '0-6 days',
            checkInBonus: '+1 Energy/day',
            purchaseBonus: '0%',
            gracePeriod: '0 days',
            isStarting: true,
          ),
          const SizedBox(height: 12),

          _buildTierCard(
            tier: 'Bronze',
            icon: AppIcons.tierBronze,
            color: AppColors.tierBronze,
            streakRequired: '7+ days',
            checkInBonus: '+1 Energy/day',
            purchaseBonus: '0%',
            gracePeriod: '0 days',
          ),
          const SizedBox(height: 12),

          _buildTierCard(
            tier: 'Silver',
            icon: AppIcons.tierSilver,
            color: AppColors.tierSilver,
            streakRequired: '14+ days',
            checkInBonus: '+2 Energy/day',
            purchaseBonus: '0%',
            gracePeriod: '1 day',
          ),
          const SizedBox(height: 12),

          _buildTierCard(
            tier: 'Gold',
            icon: AppIcons.tierGold,
            color: AppColors.tierGold,
            streakRequired: '30+ days',
            checkInBonus: '+3 Energy/day',
            purchaseBonus: '+10%',
            gracePeriod: '1 day',
            isRecommended: true,
          ),
          const SizedBox(height: 12),

          _buildTierCard(
            tier: 'Diamond',
            icon: AppIcons.tierDiamond,
            color: AppColors.tierDiamond,
            streakRequired: '60+ days',
            checkInBonus: '+4 Energy/day',
            purchaseBonus: '+20%',
            gracePeriod: '1 day',
            isPremium: true,
          ),

          const SizedBox(height: 24),

          // Tips Card
          _buildTipsCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Unlock Rewards\nwith Daily Streaks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Keep your streak alive to unlock higher tiers and earn amazing benefits!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              const Text(
                'How It Works',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBenefitExplanation(
            icon: Icons.calendar_today,
            color: Colors.blue,
            title: 'Daily Energy Reward',
            description: 'Use AI at least once per day to earn bonus energy. Higher tiers = more daily energy!',
          ),
          const SizedBox(height: 12),
          _buildBenefitExplanation(
            icon: Icons.shopping_bag,
            color: Colors.orange,
            title: 'Purchase Bonus',
            description: 'Gold & Diamond tiers get extra energy on every purchase (10-20% more!)',
            highlight: true,
          ),
          const SizedBox(height: 12),
          _buildBenefitExplanation(
            icon: Icons.shield,
            color: Colors.green,
            title: 'Grace Period',
            description: 'Miss a day without losing your streak. Silver+ tiers get protection!',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitExplanation({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight ? Colors.orange.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: highlight
            ? Border.all(color: Colors.orange.shade200, width: 1)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (highlight) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard({
    required String tier,
    required IconData icon,
    required Color color,
    required String streakRequired,
    required String checkInBonus,
    required String purchaseBonus,
    required String gracePeriod,
    bool isStarting = false,
    bool isRecommended = false,
    bool isPremium = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPremium
              ? color.withOpacity(0.5)
              : isRecommended
                  ? Colors.orange.withOpacity(0.5)
                  : Colors.grey.shade200,
          width: isPremium || isRecommended ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tier,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'POPULAR',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                          if (isPremium) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    color,
                                    color.withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'BEST',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        streakRequired,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Benefits
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildBenefitRow(
                  icon: AppIcons.streak,
                  iconColor: AppIcons.streakColor,
                  label: 'Daily Check-in',
                  value: checkInBonus,
                ),
                const Divider(height: 20),
                _buildBenefitRow(
                  icon: Icons.shopping_bag,
                  iconColor: Colors.orange,
                  label: 'Purchase Bonus',
                  value: purchaseBonus,
                  highlight: purchaseBonus != '0%',
                ),
                const Divider(height: 20),
                _buildBenefitRow(
                  icon: Icons.shield,
                  iconColor: Colors.green,
                  label: 'Grace Period',
                  value: gracePeriod,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: highlight ? Colors.orange.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: highlight
                ? Border.all(color: Colors.orange.shade200, width: 1)
                : null,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: highlight ? Colors.orange.shade700 : Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade100, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.orange.shade700, size: 24),
              const SizedBox(width: 8),
              Text(
                'Pro Tips',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipRow('Use AI daily to earn free energy and build your streak'),
          const SizedBox(height: 8),
          _buildTipRow('Diamond tier earns +4 Energy per day — that\'s 120/month!'),
          const SizedBox(height: 8),
          _buildTipRow(
            'Purchase Bonus applies to ALL energy packages!',
            highlight: true,
          ),
          const SizedBox(height: 8),
          _buildTipRow('Grace period protects your streak if you miss a day'),
        ],
      ),
    );
  }

  Widget _buildTipRow(String text, {bool highlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: highlight ? Colors.orange.shade700 : Colors.orange.shade600,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.4,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
