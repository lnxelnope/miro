import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

/// Tier Benefits Screen
/// 
/// แสดงข้อมูลสิทธิประโยชน์ของแต่ละระดับ Tier
class TierBenefitsScreen extends StatelessWidget {
  const TierBenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          L10n.of(context)!.tierBenefitsTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.xl),
        children: [
          // Header Card
          _buildHeaderCard(context),
          SizedBox(height: AppSpacing.xxl),

          // How it works
          _buildHowItWorksCard(context),
          SizedBox(height: AppSpacing.xxl),

          // Tier List
          Text(
            L10n.of(context)!.tierBenefitsAllTiers,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          _buildTierCard(
            context: context,
            tier: 'Starter',
            icon: AppIcons.tierStarter,
            color: AppIcons.tierStarterColor,
            streakRequired: '0-6 days',
            checkInBonus: '+1 Energy/day',
            purchaseBonus: '0%',
            gracePeriod: '0 days',
            isStarting: true,
          ),
          SizedBox(height: AppSpacing.md),

          _buildTierCard(
            context: context,
            tier: 'Bronze',
            icon: AppIcons.tierBronze,
            color: AppColors.tierBronze,
            streakRequired: '7+ days',
            checkInBonus: '+1 Energy/day',
            purchaseBonus: '0%',
            gracePeriod: '0 days',
          ),
          SizedBox(height: AppSpacing.md),

          _buildTierCard(
            context: context,
            tier: 'Silver',
            icon: AppIcons.tierSilver,
            color: AppColors.tierSilver,
            streakRequired: '14+ days',
            checkInBonus: '+2 Energy/day',
            purchaseBonus: '0%',
            gracePeriod: '1 day',
          ),
          SizedBox(height: AppSpacing.md),

          _buildTierCard(
            context: context,
            tier: 'Gold',
            icon: AppIcons.tierGold,
            color: AppColors.tierGold,
            streakRequired: '30+ days',
            checkInBonus: '+3 Energy/day',
            purchaseBonus: '+10%',
            gracePeriod: '1 day',
            isRecommended: true,
          ),
          SizedBox(height: AppSpacing.md),

          _buildTierCard(
            context: context,
            tier: 'Diamond',
            icon: AppIcons.tierDiamond,
            color: AppColors.tierDiamond,
            streakRequired: '60+ days',
            checkInBonus: '+4 Energy/day',
            purchaseBonus: '+20%',
            gracePeriod: '1 day',
            isPremium: true,
          ),

          SizedBox(height: AppSpacing.xxl),

          // Tips Card
          _buildTipsCard(context),
          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.xl,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
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
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppRadius.md,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  L10n.of(context)!.tierBenefitsUnlockRewards,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            L10n.of(context)!.tierBenefitsKeepStreakDescription,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              const Icon(Icons.info_outline, color: AppColors.primary, size: 24),
              SizedBox(width: AppSpacing.sm),
              Text(
                L10n.of(context)!.tierBenefitsHowItWorks,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          _buildBenefitExplanation(
            context: context,
            icon: Icons.calendar_today,
            color: AppColors.info,
            title: L10n.of(context)!.tierBenefitsDailyEnergyReward,
            description: L10n.of(context)!.tierBenefitsDailyEnergyDescription,
          ),
          SizedBox(height: AppSpacing.md),
          _buildBenefitExplanation(
            context: context,
            icon: Icons.shopping_bag,
            color: AppColors.warning,
            title: L10n.of(context)!.tierBenefitsPurchaseBonus,
            description: L10n.of(context)!.tierBenefitsPurchaseBonusDescription,
            highlight: true,
          ),
          SizedBox(height: AppSpacing.md),
          _buildBenefitExplanation(
            context: context,
            icon: Icons.shield,
            color: AppColors.success,
            title: L10n.of(context)!.tierBenefitsGracePeriod,
            description: L10n.of(context)!.tierBenefitsGracePeriodDescription,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitExplanation({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    bool highlight = false,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: highlight ? AppColors.warning.withValues(alpha: 0.1) : AppColors.background,
          borderRadius: AppRadius.md,
          border: highlight
            ? Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppRadius.sm,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: AppSpacing.md),
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
                      SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs + AppSpacing.xxs,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(AppSpacing.xs + 6),
                        ),
                        child: Text(
                          L10n.of(context)!.tierBenefitsNew,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
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
    required BuildContext context,
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
        borderRadius: AppRadius.lg,
        border: Border.all(
          color: isPremium
              ? color.withValues(alpha: 0.5)
              : isRecommended
                  ? AppColors.warning.withValues(alpha: 0.5)
                  : AppColors.divider,
          width: isPremium || isRecommended ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.vertical(
                top: AppRadius.lg.topLeft,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.xs + 6),
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                SizedBox(width: AppSpacing.md),
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
                            SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(AppSpacing.xs + 6),
                              ),
                              child: Text(
                                L10n.of(context)!.tierBenefitsPopular,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                          if (isPremium) ...[
                            SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    color,
                                    color.withValues(alpha: 0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(AppSpacing.xs + 6),
                              ),
                              child: Text(
                                L10n.of(context)!.tierBenefitsBest,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        streakRequired,
                        style: TextStyle(
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
          // Benefits
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _buildBenefitRow(
                  context: context,
                  icon: AppIcons.streak,
                  iconColor: AppIcons.streakColor,
                  label: L10n.of(context)!.tierBenefitsDailyCheckIn,
                  value: checkInBonus,
                ),
                const Divider(height: 20),
                _buildBenefitRow(
                  context: context,
                  icon: Icons.shopping_bag,
                  iconColor: AppColors.warning,
                  label: L10n.of(context)!.tierBenefitsPurchaseBonus,
                  value: purchaseBonus,
                  highlight: purchaseBonus != '0%',
                ),
                const Divider(height: 20),
                _buildBenefitRow(
                  context: context,
                  icon: Icons.shield,
                  iconColor: AppColors.success,
                  label: L10n.of(context)!.tierBenefitsGracePeriod,
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
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + AppSpacing.xxs),
          decoration: BoxDecoration(
            color: highlight ? AppColors.warning.withValues(alpha: 0.1) : AppColors.surfaceVariant,
            borderRadius: AppRadius.md,
            border: highlight
                ? Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 1)
                : null,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: highlight ? AppColors.warning : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.warning.withValues(alpha: 0.3), AppColors.warning.withValues(alpha: 0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.warning, size: 24),
              SizedBox(width: AppSpacing.sm),
              Text(
                L10n.of(context)!.tierBenefitsProTips,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _buildTipRow(context, L10n.of(context)!.tierBenefitsTip1),
          SizedBox(height: AppSpacing.sm),
          _buildTipRow(context, L10n.of(context)!.tierBenefitsTip2),
          SizedBox(height: AppSpacing.sm),
          _buildTipRow(
            context,
            L10n.of(context)!.tierBenefitsTip3,
            highlight: true,
          ),
          SizedBox(height: AppSpacing.sm),
          _buildTipRow(context, L10n.of(context)!.tierBenefitsTip4),
        ],
      ),
    );
  }

  Widget _buildTipRow(BuildContext context, String text, {bool highlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: AppSpacing.xs + AppSpacing.xxs),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: highlight ? AppColors.warning : AppColors.warning,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: AppSpacing.xs + AppSpacing.xxs),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
