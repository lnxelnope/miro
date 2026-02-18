import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/core/services/welcome_offer_service.dart';
import 'package:miro_hybrid/core/services/purchase_service.dart';
import 'package:miro_hybrid/core/theme/app_icons.dart';
import 'package:miro_hybrid/features/energy/providers/energy_provider.dart';
import 'package:miro_hybrid/core/models/gamification_state.dart';
import 'package:miro_hybrid/features/energy/providers/gamification_provider.dart';
import 'package:miro_hybrid/features/energy/widgets/welcome_offer_progress.dart';
import 'package:miro_hybrid/features/energy/widgets/weekly_challenge_card.dart';
import 'package:miro_hybrid/features/energy/widgets/milestone_progress_card.dart';
import 'package:miro_hybrid/features/energy/widgets/streak_display.dart';
import 'package:miro_hybrid/features/subscription/presentation/subscription_screen.dart';
import 'package:miro_hybrid/core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';

/// Energy Store - Modern Design with gradient cards
class EnergyStoreScreen extends ConsumerStatefulWidget {
  const EnergyStoreScreen({super.key});

  @override
  ConsumerState<EnergyStoreScreen> createState() => _EnergyStoreScreenState();
}

class _EnergyStoreScreenState extends ConsumerState<EnergyStoreScreen> {
  WelcomeOfferStatus _offerStatus = WelcomeOfferStatus.notStarted;
  Duration? _remainingTime;
  PromotionInfo? _activePromotion;

  @override
  void initState() {
    super.initState();
    _loadData();
    AnalyticsService.logStoreOpened();
  }

  Future<void> _loadData() async {
    final status = await WelcomeOfferService.getStatus();
    final remaining = await WelcomeOfferService.getRemainingTime();
    final promo = await WelcomeOfferService.getActivePromotion();

    if (mounted) {
      setState(() {
        _offerStatus = status;
        _remainingTime = remaining;
        _activePromotion = promo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final energyAsync = ref.watch(currentEnergyProvider);

    return energyAsync.when(
      data: (balance) => _buildScaffold(context, balance),
      loading: () => _buildScaffold(context, 0),
      error: (_, __) => _buildScaffold(context, 0),
    );
  }

  Widget _buildScaffold(BuildContext context, int balance) {
    final gamification = ref.watch(gamificationProvider);
    final isSubscriber = gamification.isSubscriber;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: AppIcons.iconWithLabel(
          AppIcons.energy,
          'Energy Store',
          iconColor: AppIcons.energyColor,
          iconSize: 24,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentEnergyProvider);
          ref.invalidate(energyBalanceProvider);
          await ref.read(gamificationProvider.notifier).refresh();
          await _loadData();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // ────── Current Balance Card ──────
            _buildBalanceCard(balance),
            const SizedBox(height: 20),

            // ────── Subscriber Active Badge (if subscriber) ──────
            if (isSubscriber) ...[
              _buildSubscriberActiveBadge(gamification),
              const SizedBox(height: 20),
            ],

            // ────── Streak & Tier Display (only for non-subscribers) ──────
            if (!isSubscriber) ...[
              const StreakDisplay(),
              const SizedBox(height: 20),
            ],

            // ────── Energy Pass Subscription CTA (only for non-subscribers) ──────
            if (!isSubscriber) ...[
              _buildSubscriptionCTA(),
              const SizedBox(height: 20),
            ],

            // ────── Active Promotion Banner ──────
            if (_activePromotion != null) ...[
              _buildPromotionBanner(_activePromotion!),
              const SizedBox(height: 20),
            ],

            // ────── Weekly Challenges & Milestones ──────
            const WeeklyChallengeCard(),
            const SizedBox(height: 12),
            const MilestoneProgressCard(),
            const SizedBox(height: 20),

            // ────── Progress to unlock Welcome Offer ──────
            if (_offerStatus == WelcomeOfferStatus.notStarted) ...[
              const WelcomeOfferProgress(),
              const SizedBox(height: 20),
            ],

            // ────── Welcome Offer Banner & Packages ──────
            if (_offerStatus == WelcomeOfferStatus.active) ...[
              _buildWelcomeOfferBanner(),
              const SizedBox(height: 16),
              _buildWelcomePackages(),
              const SizedBox(height: 28),
              Divider(height: 1, color: Colors.grey.shade300),
              const SizedBox(height: 28),
            ],

            // ────── Regular Packages ──────
            AppIcons.iconWithLabel(
              _offerStatus == WelcomeOfferStatus.active
                  ? AppIcons.money
                  : AppIcons.energy,
              _offerStatus == WelcomeOfferStatus.active
                  ? 'Regular Prices'
                  : 'Energy Packages',
              iconColor: _offerStatus == WelcomeOfferStatus.active
                  ? AppIcons.moneyColor
                  : AppIcons.energyColor,
              iconSize: 24,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 16),

            _buildModernPackageCard(
              icon: AppIcons.target,
              iconColor: AppIcons.targetColor,
              name: 'Starter Kick',
              energy: 100,
              price: 0.99,
              priceText: '\$0.99',
              productId: PurchaseService.energy100,
              gradient: [Colors.blue.shade300, Colors.blue.shade500],
            ),

            _buildModernPackageCard(
              icon: AppIcons.subscription,
              iconColor: AppColors.primary,
              name: 'Value Pack',
              energy: 550,
              price: 4.99,
              priceText: '\$4.99',
              productId: PurchaseService.energy550,
              badge: '+10% bonus',
              gradient: [Colors.purple.shade300, Colors.purple.shade500],
            ),

            _buildModernPackageCard(
              icon: AppIcons.streak,
              iconColor: AppIcons.streakColor,
              name: 'Power User',
              energy: 1200,
              price: 7.99,
              priceText: '\$7.99',
              productId: PurchaseService.energy1200,
              badge: 'POPULAR',
              isPopular: true,
              gradient: [Colors.orange.shade400, Colors.deepOrange.shade500],
            ),

            _buildModernPackageCard(
              icon: AppIcons.milestone,
              iconColor: AppIcons.milestoneColor,
              name: 'Ultimate Saver',
              energy: 2000,
              price: 9.99,
              priceText: '\$9.99',
              productId: PurchaseService.energy2000,
              badge: 'BEST VALUE',
              isBest: true,
              gradient: [Colors.amber.shade400, Colors.orange.shade600],
            ),

            const SizedBox(height: 32),

            // ────── Info Card ──────
            _buildModernInfoCard(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // MODERN WIDGETS
  // ───────────────────────────────────────────────────────────

  Widget _buildBalanceCard(int balance) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.teal.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(AppIcons.energy, size: 48, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Energy Balance',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$balance',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriberActiveBadge(GamificationState gamification) {
    final expiryDate = gamification.subscriptionExpiryDate;
    final expiryText = expiryDate != null
        ? '${expiryDate.day}/${expiryDate.month}/${expiryDate.year}'
        : '';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF7C3AED), const Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.diamond_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Energy Pass',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unlimited AI Analysis',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (expiryText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Renews: $expiryText',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCTA() {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SubscriptionScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.energy_savings_leaf,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppIcons.iconWithLabel(
                        AppIcons.energy,
                        'Energy Pass',
                        iconColor: Colors.white,
                        iconSize: 24,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unlimited AI Analysis • ฿149/month',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeOfferBanner() {
    final timeStr = _remainingTime != null
        ? WelcomeOfferService.formatRemainingTime(_remainingTime!)
        : '--';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.pink.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(AppIcons.celebration, size: 48, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Offer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const Text(
                  '40% OFF • Limited Time',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIcons.timer, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'Expires in $timeStr',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePackages() {
    return Column(
      children: [
        _buildModernPackageCard(
          icon: AppIcons.target,
          iconColor: AppIcons.targetColor,
          name: 'Starter Kick',
          energy: 100,
          price: 0.59,
          priceText: '\$0.59',
          originalPrice: '\$0.99',
          productId: PurchaseService.energy100Welcome,
          isWelcome: true,
          gradient: [Colors.blue.shade300, Colors.blue.shade500],
        ),
        _buildModernPackageCard(
          icon: AppIcons.subscription,
          iconColor: AppColors.primary,
          name: 'Value Pack',
          energy: 550,
          price: 2.99,
          priceText: '\$2.99',
          originalPrice: '\$4.99',
          productId: PurchaseService.energy550Welcome,
          badge: '+10%',
          isWelcome: true,
          gradient: [Colors.purple.shade300, Colors.purple.shade500],
        ),
        _buildModernPackageCard(
          icon: AppIcons.streak,
          iconColor: AppIcons.streakColor,
          name: 'Power User',
          energy: 1200,
          price: 4.79,
          priceText: '\$4.79',
          originalPrice: '\$7.99',
          productId: PurchaseService.energy1200Welcome,
          badge: '+20%',
          isWelcome: true,
          isPopular: true,
          gradient: [Colors.orange.shade400, Colors.deepOrange.shade500],
        ),
        _buildModernPackageCard(
          icon: AppIcons.milestone,
          iconColor: AppIcons.milestoneColor,
          name: 'Ultimate Saver',
          energy: 2000,
          price: 5.99,
          priceText: '\$5.99',
          originalPrice: '\$9.99',
          productId: PurchaseService.energy2000Welcome,
          badge: '+50%',
          isWelcome: true,
          isBest: true,
          gradient: [Colors.amber.shade400, Colors.orange.shade600],
        ),
      ],
    );
  }

  Widget _buildModernPackageCard({
    required IconData icon,
    required Color iconColor,
    required String name,
    required int energy,
    required double price,
    required String priceText,
    required String productId,
    required List<Color> gradient,
    String? originalPrice,
    String? badge,
    bool isPopular = false,
    bool isBest = false,
    bool isWelcome = false,
  }) {
    // Effective bonus = max(tier bonus, promotion bonus)
    final gamification = ref.watch(gamificationProvider);
    final tierRate = gamification.bonusRate;
    final promoRate = _activePromotion?.bonusRate ?? 0;
    final bonusRate = tierRate > promoRate ? tierRate : promoRate;
    final isPromoBonus = promoRate > tierRate;
    final bonusEnergy = (energy * bonusRate).round();
    final totalEnergy = energy + bonusEnergy;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular || isBest
              ? Colors.orange.shade400
              : Colors.grey.shade200,
          width: isPopular || isBest ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPopular || isBest ? Colors.orange : Colors.grey)
                .withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _purchasePackage(productId, energy),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // ────── Gradient Icon Container ──────
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 32, color: Colors.white),
                ),
                const SizedBox(width: 16),

                // ────── Info ──────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isBest
                                    ? Colors.orange.shade600
                                    : isPopular
                                        ? Colors.deepOrange
                                        : Colors.blue.shade600,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(AppIcons.energy, size: 14, color: AppIcons.energyColor),
                          const SizedBox(width: 4),
                          Text(
                            bonusEnergy > 0
                                ? '$energy + $bonusEnergy Bonus = $totalEnergy Energy'
                                : '$energy Energy',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (bonusEnergy > 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.orange.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPromoBonus
                                    ? Icons.local_fire_department_rounded
                                    : gamification.tierIcon,
                                size: 12,
                                color: isPromoBonus
                                    ? Colors.purple
                                    : gamification.tierColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isPromoBonus
                                    ? 'Promo Bonus: +${(bonusRate * 100).toInt()}%'
                                    : '${gamification.tierName} Bonus: +${(bonusRate * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isPromoBonus
                                      ? Colors.purple.shade700
                                      : Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ────── Price ──────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (originalPrice != null) ...[
                      Text(
                        originalPrice,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                          decorationThickness: 2,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      priceText,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isWelcome
                            ? Colors.red.shade600
                            : Colors.green.shade600,
                        letterSpacing: -0.5,
                      ),
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

  Widget _buildModernInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(AppIcons.info, size: 24, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 12),
              const Text(
                'About Energy',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(AppIcons.energy, AppIcons.energyColor, '1 Energy = 1 AI analysis'),
          _buildInfoRow(AppIcons.infinity, AppIcons.infinityColor, 'Energy never expires'),
          _buildInfoRow(AppIcons.device, AppIcons.deviceColor, 'One-time purchase, per device'),
          _buildInfoRow(Icons.favorite_rounded, Colors.green.shade600, 'Manual logging is always free'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, Color iconColor, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // ACTIONS
  // ───────────────────────────────────────────────────────────

  Widget _buildPromotionBanner(PromotionInfo promo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promo.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '+${(promo.bonusRate * 100).toInt()}% Bonus on all purchases!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  promo.remainingText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _purchasePackage(String productId, int energy) async {
    final success = await PurchaseService.purchaseEnergy(productId);
    if (success) {
      ref.invalidate(currentEnergyProvider);
      ref.invalidate(energyBalanceProvider);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Purchased $energy Energy!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Purchase failed. Please try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
