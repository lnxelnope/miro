import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:miro_hybrid/core/services/purchase_service.dart';
import 'package:miro_hybrid/core/services/device_id_service.dart';
import 'package:miro_hybrid/core/theme/app_icons.dart';
import 'package:miro_hybrid/features/energy/providers/energy_provider.dart';
import 'package:miro_hybrid/core/models/gamification_state.dart';
import 'package:miro_hybrid/features/energy/providers/gamification_provider.dart';
import 'package:miro_hybrid/features/subscription/presentation/subscription_screen.dart';
import 'package:miro_hybrid/core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';


/// Energy Store - Modern Design with gradient cards
class EnergyStoreScreen extends ConsumerStatefulWidget {
  final String? highlightOfferId;

  const EnergyStoreScreen({
    super.key,
    this.highlightOfferId,
  });

  @override
  ConsumerState<EnergyStoreScreen> createState() => _EnergyStoreScreenState();
}

class _EnergyStoreScreenState extends ConsumerState<EnergyStoreScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _activeOffers = [];
  bool _offersLoading = true;
  Timer? _countdownTimer;
  Duration? _remainingTime;
  DateTime? _offerExpiryTime;
  bool _isClaimingFreeEnergy = false;
  final Map<String, GlobalKey> _offerKeys = {};
  String? _userLocale;

  AnimationController? _highlightController;
  Animation<double>? _highlightAnimation;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logStoreOpened();

    if (widget.highlightOfferId != null) {
      _highlightController = AnimationController(
        duration: const Duration(milliseconds: 2500),
        vsync: this,
      );
      _highlightAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _highlightController!, curve: Curves.easeOut),
      );
      _highlightController!.forward();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    if (_userLocale != locale) {
      _userLocale = locale;
      _loadOffers();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _highlightController?.dispose();
    super.dispose();
  }

  Future<void> _loadOffers() async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final locale = _userLocale ?? 'en';
      final response = await http.post(
        Uri.parse('https://us-central1-miro-d6856.cloudfunctions.net/getActiveOffersEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'deviceId': deviceId, 'locale': locale}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final offers = data['offers'] as List<dynamic>? ?? [];

        if (mounted) {
          setState(() {
            _activeOffers = offers;
            _offersLoading = false;
          });

          // Start countdown for first offer with expiry
          if (offers.isNotEmpty) {
            final firstOffer = offers.first;
            final remainingSeconds = firstOffer['remainingSeconds'] as int?;
            final expiryTimestamp = firstOffer['expiry'];

            if (expiryTimestamp is Map) {
              final seconds = expiryTimestamp['_seconds'] as int?;
              if (seconds != null) {
                _offerExpiryTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
              }
            } else if (remainingSeconds != null && remainingSeconds > 0) {
              _offerExpiryTime = DateTime.now().add(Duration(seconds: remainingSeconds));
            }

            if (_offerExpiryTime != null) _startCountdown();
          }

          if (widget.highlightOfferId != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToOffer(widget.highlightOfferId!);
            });
          }
        }
      } else {
        if (mounted) setState(() => _offersLoading = false);
      }
    } catch (e) {
      debugPrint('[EnergyStore] Error loading offers: $e');
      if (mounted) setState(() => _offersLoading = false);
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    if (_offerExpiryTime == null) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      final remaining = _offerExpiryTime!.difference(DateTime.now());
      if (remaining.isNegative) {
        timer.cancel();
        setState(() { _remainingTime = null; _offerExpiryTime = null; });
        _loadOffers();
      } else {
        setState(() => _remainingTime = remaining);
      }
    });
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// bonus rate จาก active offer ที่มี rewardType == 'bonus_rate' (เอาค่าสูงสุด)
  double get _offerBonusRate {
    double maxRate = 0;
    for (final offer in _activeOffers) {
      final rewardType = offer['rewardType'] as String?;
      final type = offer['type'] as String?;
      if (rewardType == 'bonus_rate' || type == 'bonus_40' || type == 'tier_promo') {
        final metadata = offer['metadata'] as Map<String, dynamic>?;
        final rate = (metadata?['bonusRate'] as num?)?.toDouble() ?? 0;
        if (rate > maxRate) maxRate = rate;
      }
    }
    return maxRate;
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
      backgroundColor: AppColors.background,
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
          await _loadOffers();
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

            // ────── Energy Pass Subscription CTA (only for non-subscribers) ──────
            if (!isSubscriber) ...[
              _buildSubscriptionCTA(),
              const SizedBox(height: 20),
            ],

            // ────── Active Offers from Backend ──────
            ..._buildOfferCards(),

            // ────── Regular Packages ──────
            AppIcons.iconWithLabel(
              AppIcons.energy,
              'Energy Packages',
              iconColor: AppIcons.energyColor,
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
              gradient: [AppColors.info.withValues(alpha: 0.6), AppColors.info],
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
              gradient: [AppColors.premium.withValues(alpha: 0.6), AppColors.premium],
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
              gradient: [AppColors.warning.withValues(alpha: 0.7), AppColors.warning],
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
              gradient: [AppColors.warning.withValues(alpha: 0.7), AppColors.warning],
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
  // OFFER CARDS (from backend API — same as quest bar)
  // ───────────────────────────────────────────────────────────

  List<Widget> _buildOfferCards() {
    if (_offersLoading || _activeOffers.isEmpty) return [];

    final widgets = <Widget>[];
    for (final offer in _activeOffers) {
      final type = offer['type'] as String? ?? '';
      if (type == 'winback' || type == 'sub_upsell') continue;

      // Use rewardType if available, otherwise infer from type (backward compat)
      final rewardType = offer['rewardType'] as String? ?? _inferRewardType(type);
      final offerId = offer['id'] as String? ?? '';

      // Create GlobalKey for highlighting
      if (offerId.isNotEmpty && !_offerKeys.containsKey(offerId)) {
        _offerKeys[offerId] = GlobalKey();
      }

      Widget? card;
      switch (rewardType) {
        case 'special_product':
          card = _buildFirstPurchaseCard(offer);
          break;
        case 'bonus_rate':
          card = _buildBonusBanner(offer);
          break;
        case 'free_energy':
          card = _buildFreeEnergyCard(offer);
          break;
        case 'subscription_deal':
          // Navigate to SubscriptionScreen
          card = _buildSubscriptionDealCard(offer);
          break;
        default:
          // Fallback to old type-based logic
          if (type == 'first_purchase') {
            card = _buildFirstPurchaseCard(offer);
          } else if (type == 'bonus_40' || type == 'tier_promo') {
            card = _buildBonusBanner(offer);
          }
      }

      if (card != null) {
        final isHighlighted = widget.highlightOfferId == offerId && offerId.isNotEmpty;
        final globalKey = offerId.isNotEmpty ? _offerKeys[offerId] : null;

        Widget wrappedCard;
        if (isHighlighted && _highlightAnimation != null) {
          wrappedCard = AnimatedBuilder(
            animation: _highlightAnimation!,
            builder: (_, child) => Container(
              key: globalKey,
              decoration: BoxDecoration(
                borderRadius: AppRadius.xl,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warning.withValues(alpha: _highlightAnimation!.value * 0.6),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: child,
            ),
            child: card,
          );
        } else {
          wrappedCard = Container(
            key: globalKey,
            child: card,
          );
        }

        widgets.add(wrappedCard);
        widgets.add(const SizedBox(height: 16));
      }
    }
    return widgets;
  }

  // Helper: Infer rewardType from old type (backward compat)
  String _inferRewardType(String? offerType) {
    switch (offerType) {
      case 'first_purchase':
        return 'special_product';
      case 'bonus_40':
      case 'tier_promo':
        return 'bonus_rate';
      default:
        return 'bonus_rate';
    }
  }

  /// First Purchase offer — $1 = 200 Energy (special card)
  Widget _buildFirstPurchaseCard(dynamic offer) {
    final title = offer['title'] as String? ?? 'Starter Deal';
    final description = offer['description'] as String? ?? '';
    final ctaText = offer['ctaText'] as String? ?? 'Buy Now';
    final metadata = offer['metadata'] as Map<String, dynamic>?;
    final productId = metadata?['productId'] as String? ?? 'energy_first_purchase_200';
    final energyAmount = (metadata?['energyAmount'] as num?)?.toInt() ?? 200;
    final price = metadata?['price'] as String? ?? '\$1.00';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.warning.withValues(alpha: 0.7), AppColors.error],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.xl,
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _purchasePackage(productId, energyAmount),
          borderRadius: AppRadius.xl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: AppRadius.md,
                      ),
                      child: const Icon(Icons.local_fire_department_rounded, size: 28, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: AppRadius.sm,
                            ),
                            child: const Text(
                              'LIMITED TIME',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          price,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(AppIcons.energy, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '$energyAmount Energy',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
                if (_remainingTime != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.timer, color: Colors.white.withOpacity(0.9), size: 15),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(_remainingTime!),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _purchasePackage(productId, energyAmount),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.warning,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.md,
                      ),
                    ),
                    child: Text(
                      ctaText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Free Energy Card (claim ได้เลย ไม่ต้องซื้อ)
  Widget _buildFreeEnergyCard(dynamic offer) {
    final title = offer['title'] as String? ?? 'Free Energy';
    final description = offer['description'] as String? ?? '';
    final ctaText = offer['ctaText'] as String? ?? 'Claim';
    final icon = offer['icon'] as String? ?? '🎁';
    final metadata = offer['metadata'] as Map<String, dynamic>?;
    final amount = (metadata?['amount'] as num?)?.toInt() ?? 0;
    final offerId = offer['id'] as String? ?? '';
    final remainingSeconds = offer['remainingSeconds'] as int?;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success.withValues(alpha: 0.7), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.xl,
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isClaimingFreeEnergy ? null : () => _claimFreeEnergy(offerId),
          borderRadius: AppRadius.xl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: AppRadius.md,
                      ),
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '+$amount Energy',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (remainingSeconds != null && remainingSeconds > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            _formatDuration(Duration(seconds: remainingSeconds)),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _isClaimingFreeEnergy ? null : () => _claimFreeEnergy(offerId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      foregroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.md,
                        ),
                      ),
                      child: Text(
                        _isClaimingFreeEnergy ? 'Claiming...' : ctaText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

  Future<void> _claimFreeEnergy(String offerId) async {
    setState(() => _isClaimingFreeEnergy = true);

    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final url = Uri.parse('https://us-central1-miro-d6856.cloudfunctions.net/claimFreeEnergyEndpoint');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': deviceId,
          'templateId': offerId,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['success'] == true) {
        final energyAdded = data['energyAdded'] as int? ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ได้รับ $energyAdded Energy!'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadOffers(); // Reload offer list
        ref.invalidate(energyBalanceProvider); // Update balance display
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] as String? ?? 'ไม่สามารถ claim ได้'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      debugPrint('[EnergyStore] Error claiming free energy: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('เกิดข้อผิดพลาด'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isClaimingFreeEnergy = false);
      }
    }
  }

  /// Bonus banner (40% bonus / tier promo)
  Widget _buildBonusBanner(dynamic offer) {
    final title = offer['title'] as String? ?? 'Bonus';
    final description = offer['description'] as String? ?? '';
    final metadata = offer['metadata'] as Map<String, dynamic>?;
    final bonusRate = (metadata?['bonusRate'] as num?)?.toDouble() ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.premium.withValues(alpha: 0.7), AppColors.info.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.lg,
        boxShadow: [
          BoxShadow(
            color: AppColors.premium.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
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
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  )
                else if (bonusRate > 0)
                  Text(
                    '+${(bonusRate * 100).toInt()}% Bonus on all purchases!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          if (_remainingTime != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: AppRadius.xl,
              ),
              child: Text(
                _formatDuration(_remainingTime!),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
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
          colors: [AppColors.success.withValues(alpha: 0.7), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.xl,
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.4),
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
              borderRadius: AppRadius.lg,
            ),
            child: const Icon(AppIcons.energy, size: 48, color: Colors.white),
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
        gradient: const LinearGradient(
          colors: [AppColors.premium, AppColors.premiumDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.xl,
        boxShadow: [
          BoxShadow(
            color: AppColors.premium.withValues(alpha: 0.3),
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
                    borderRadius: AppRadius.lg,
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
                              borderRadius: AppRadius.sm,
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
                  borderRadius: AppRadius.md,
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
          borderRadius: AppRadius.xl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: AppRadius.lg,
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
                        'Unlimited AI Analysis • from \$3.33/month',
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
  }) {
    final gamification = ref.watch(gamificationProvider);
    final tierRate = gamification.bonusRate;
    final promoRate = _offerBonusRate;
    final bonusRate = tierRate > promoRate ? tierRate : promoRate;
    final isPromoBonus = promoRate > tierRate;
    final bonusEnergy = (energy * bonusRate).round();
    final totalEnergy = energy + bonusEnergy;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lg,
        border: Border.all(
          color: isPopular || isBest
              ? AppColors.warning.withValues(alpha: 0.7)
              : AppColors.divider,
          width: isPopular || isBest ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPopular || isBest ? AppColors.warning : AppColors.textSecondary)
                .withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _purchasePackage(productId, energy),
          borderRadius: AppRadius.lg,
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
                    borderRadius: AppRadius.lg,
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
                                    ? AppColors.warning
                                    : isPopular
                                        ? AppColors.warning
                                        : AppColors.info,
                                borderRadius: AppRadius.sm,
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
                          const Icon(AppIcons.energy, size: 14, color: AppIcons.energyColor),
                          const SizedBox(width: 4),
                          Text(
                            bonusEnergy > 0
                                ? '$energy + $bonusEnergy Bonus = $totalEnergy Energy'
                                : '$energy Energy',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
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
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: AppRadius.sm,
                            border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.3),
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
                                    ? AppColors.premium
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
                                      ? AppColors.premium
                                      : AppColors.warning,
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

                // ────── Price + Bonus Overlay ──────
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (originalPrice != null) ...[
                          Text(
                            originalPrice,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
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
                            color: AppColors.success,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    if (bonusRate > 0)
                      Positioned(
                        top: -50,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isPromoBonus
                                  ? [AppColors.premium, AppColors.premiumDark]
                                  : [AppColors.warning.withValues(alpha: 0.7), AppColors.warning],
                            ),
                            borderRadius: AppRadius.md,
                            boxShadow: [
                              BoxShadow(
                                color: (isPromoBonus ? AppColors.premium : AppColors.warning)
                                    .withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPromoBonus
                                    ? Icons.local_fire_department_rounded
                                    : Icons.star_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '+${(bonusRate * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
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
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.2),
                  borderRadius: AppRadius.md,
                ),
                child: const Icon(AppIcons.info, size: 24, color: AppColors.info),
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
          _buildInfoRow(Icons.favorite_rounded, AppColors.success, 'Manual logging is always free'),
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
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Subscription Deal card — navigate to SubscriptionScreen
  Widget _buildSubscriptionDealCard(dynamic offer) {
    final title = offer['title'] as String? ?? 'Subscription Deal';
    final description = offer['description'] as String? ?? '';
    final ctaText = offer['ctaText'] as String? ?? 'View Deal';
    final icon = offer['icon'] as String? ?? '💎';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.premium.withValues(alpha: 0.7), AppColors.ai],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.xl,
        boxShadow: [
          BoxShadow(
            color: AppColors.premium.withValues(alpha: 0.4),
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
              MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
            );
          },
          borderRadius: AppRadius.xl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.premium,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.md,
                    ),
                  ),
                  child: Text(
                    ctaText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _scrollToOffer(String offerId) {
    final key = _offerKeys[offerId];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
    }
  }

  // ───────────────────────────────────────────────────────────
  // ACTIONS
  // ───────────────────────────────────────────────────────────

  Future<void> _purchasePackage(String productId, int energy) async {
    final success = await PurchaseService.purchaseEnergy(productId);
    if (success) {
      ref.invalidate(currentEnergyProvider);
      ref.invalidate(energyBalanceProvider);

      // Remove used offers from local state immediately
      // so user can't re-purchase before _loadOffers() completes
      if (mounted) {
        setState(() {
          _activeOffers.removeWhere((offer) {
            final rewardType = offer['rewardType'] as String?;
            final type = offer['type'] as String?;
            final metadata = offer['metadata'] as Map<String, dynamic>?;
            final offerProductId = metadata?['productId'] as String?;
            // Remove bonus_rate offers (one-time use per activation)
            if (rewardType == 'bonus_rate' ||
                type == 'bonus_40' ||
                type == 'tier_promo') {
              return true;
            }
            // Remove special_product offers if productId matches
            if (rewardType == 'special_product' && offerProductId == productId) {
              return true;
            }
            return false;
          });
        });
      }

      await _loadOffers();

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Purchased $energy Energy!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Purchase failed. Please try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
