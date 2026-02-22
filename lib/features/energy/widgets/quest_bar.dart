import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/models/gamification_state.dart';
import '../../../core/services/device_id_service.dart';
import '../../../core/services/energy_service.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/database/database_service.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/gamification_provider.dart';
import '../providers/energy_provider.dart';
import '../widgets/weekly_challenge_card.dart';
import '../widgets/milestone_progress_card.dart';
import '../widgets/tier_celebration_card.dart';
import '../widgets/seasonal_quest_card.dart';
import '../presentation/energy_store_screen.dart';
import '../../subscription/presentation/subscription_screen.dart';

/// Quest Bar - แถบหลักแสดง Offers, Streak, Challenges, Milestones
/// ตาม ENERGY_MARKETING_BLUEPRINT.md Section 2
class QuestBar extends ConsumerStatefulWidget {
  const QuestBar({super.key});

  @override
  ConsumerState<QuestBar> createState() => _QuestBarState();
}

class _QuestBarState extends ConsumerState<QuestBar> {
  bool _isExpanded = false;
  
  // J9: Countdown Timer
  Timer? _countdownTimer;
  Duration? _remainingTime;
  
  // J10: Swipe to Dismiss (session only - ไม่ persist)
  Set<String> _dismissedOffers = {};
  Set<String> _dismissedSeasonalQuests = {};
  
  // J11: API Data
  bool _canClaim = false;
  int _claimableEnergy = 0;
  List<dynamic> _activeOffers = [];
  List<dynamic> _allOffers = []; // Original offers (ไม่ถูก dismiss, ใช้ใน expanded content)
  bool _isLoading = true;
  DateTime? _offerExpiryTime;

  // Ad Reward
  static const int _adRewardEnergy = 3;
  final AdService _adService = AdService();
  bool _isAdLoading = false;
  bool _adInitialized = false;

  // Claim loading states
  Set<String> _claimingChallenges = {};
  bool _isClaimingSeasonal = false;
  bool _isClaimingReferral = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initAdService();
  }

  // Removed: _loadDismissedOffers() and _saveDismissedOffers()
  // Dismiss เป็น session-only ตอนนี้

  Future<void> _initAdService() async {
    await _adService.initialize();
    if (mounted) setState(() => _adInitialized = true);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _adService.dispose();
    super.dispose();
  }

  // J11: Load data from API
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final deviceId = await DeviceIdService.getDeviceId();
      
      // Load active offers
      final locale = mounted ? Localizations.localeOf(context).languageCode : 'en';
      final offersResponse = await http.post(
        Uri.parse('https://us-central1-miro-d6856.cloudfunctions.net/getActiveOffersEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'deviceId': deviceId, 'locale': locale}),
      );

      if (offersResponse.statusCode == 200) {
        final offersData = jsonDecode(offersResponse.body) as Map<String, dynamic>;
        final offers = offersData['offers'] as List<dynamic>? ?? [];
        
        // Filter out dismissed offers for banner
        final filteredOffers = offers
            .where((o) => !_dismissedOffers.contains(o['id'] as String?))
            .toList();

        setState(() {
          _allOffers = List.from(offers);
          _activeOffers = filteredOffers;
          
          // Get first offer expiry for countdown
          if (filteredOffers.isNotEmpty) {
            final firstOffer = filteredOffers.first;
            final expiryTimestamp = firstOffer['expiry'];
            final remainingSeconds = firstOffer['remainingSeconds'] as int?;
            
            if (expiryTimestamp != null) {
              // Convert Firestore Timestamp to DateTime
              if (expiryTimestamp is Map) {
                final seconds = expiryTimestamp['_seconds'] as int?;
                if (seconds != null) {
                  _offerExpiryTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
                }
              }
            } else if (remainingSeconds != null && remainingSeconds > 0) {
              _offerExpiryTime = DateTime.now().add(Duration(seconds: remainingSeconds));
            }
            
            // Start countdown if we have expiry time
            if (_offerExpiryTime != null) {
              _startCountdown();
            }
          }
        });
      }

      // Load canClaim status (from syncBalanceWithServer or local fallback)
      try {
        final energyService = EnergyService(DatabaseService.isar);
        final syncData = await energyService.syncBalanceWithServer();
        final tier = syncData['tier'] as String? ?? 'starter';
        final energyMap = {
          'starter': 1,
          'bronze': 1,
          'silver': 2,
          'gold': 3,
          'diamond': 4,
        };
        final canClaim = syncData['canClaimToday'] as bool? ?? true;
        final lastCheckIn = syncData['lastCheckInDate'] as String?;

        // Cache locally เพื่อใช้ offline fallback
        if (lastCheckIn != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('last_check_in_date', lastCheckIn);
          await prefs.setString('cached_tier', tier);
        }

        setState(() {
          _canClaim = canClaim;
          _claimableEnergy = energyMap[tier] ?? 1;
        });
      } catch (e) {
        debugPrint('[QuestBar] Sync failed, using local fallback: $e');
        // Fallback: ใช้ local cache แทน — optimistic (assume can claim)
        final prefs = await SharedPreferences.getInstance();
        final cachedDate = prefs.getString('last_check_in_date');
        final cachedTier = prefs.getString('cached_tier') ?? 'starter';
        final energyMap = {
          'starter': 1, 'bronze': 1, 'silver': 2, 'gold': 3, 'diamond': 4,
        };
        final todayUtc7 = DateTime.now().toUtc().add(const Duration(hours: 7));
        final todayStr = todayUtc7.toIso8601String().substring(0, 10);
        final canClaimOffline = cachedDate == null || cachedDate != todayStr;
        
        setState(() {
          _canClaim = canClaimOffline;
          _claimableEnergy = energyMap[cachedTier] ?? 1;
        });
      }
    } catch (e) {
      debugPrint('[QuestBar] Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // J9: Start countdown timer
  void _startCountdown() {
    _countdownTimer?.cancel();
    
    if (_offerExpiryTime == null) return;
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      final now = DateTime.now();
      final remaining = _offerExpiryTime!.difference(now);
      
      if (remaining.isNegative) {
        timer.cancel();
        setState(() {
          _remainingTime = null;
          _offerExpiryTime = null;
        });
        // Refresh offers (expired)
        _loadData();
      } else {
        setState(() => _remainingTime = remaining);
      }
    });
  }

  // J9: Format duration to HH:MM:SS
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    return '${hours.toString().padLeft(2, '0')}:'
           '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }

  // J10: Dismiss offer (session only - กลับมาเมื่อเปิดแอปใหม่)
  void _dismissOffer(String offerId) {
    setState(() {
      _dismissedOffers.add(offerId);
      _activeOffers.removeWhere((o) => o['id'] == offerId);
    });
  }

  // Dismiss seasonal quest (session only)
  void _dismissSeasonalQuest(String questId) {
    setState(() {
      _dismissedSeasonalQuests.add(questId);
    });
  }

  // Ad Reward: ดูโฆษณาแล้วได้ +3 Energy
  Future<void> _handleWatchAd() async {
    if (_isAdLoading || !_adService.canWatchAd) return;
    setState(() => _isAdLoading = true);

    try {
      final reward = await _adService.showRewardedAd();

      if (reward > 0 && mounted) {
        ref.invalidate(energyBalanceProvider);
        ref.read(gamificationProvider.notifier).refresh();
        _loadData();

        final l10n = L10n.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.questBarAdSuccess(reward)),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      } else if (mounted) {
        final l10n = L10n.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.questBarAdNotReady),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdLoading = false);
    }
  }

  // J12: Share referral link
  Future<void> _shareReferralLink() async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      
      // TODO: Replace with actual Firebase Dynamic Link when available
      final referralLink = 'https://miro.app/ref/$deviceId';
      
      final l10n = L10n.of(context)!;
      await Share.share(
        l10n.questBarShareText(referralLink),
        subject: l10n.questBarShareSubject,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.questBarShareReferralError('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gamification = ref.watch(gamificationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Check if we have active offers (after filtering dismissed)
    final visibleOffers = _activeOffers
        .where((o) => !_dismissedOffers.contains(o['id'] as String?))
        .toList();
    final hasActiveOffer = visibleOffers.isNotEmpty;

    // ถ้ายังมี offer → แสดงแค่ offer banner, ซ่อน quest bar
    // ผู้ใช้ต้องปิด offer ก่อนถึงจะเห็น streak
    if (hasActiveOffer) {
      return _buildOfferBanner(context, visibleOffers.first, isDark);
    }

    // ไม่มี offer แล้ว → แสดง quest bar ปกติ
    final allActiveSeasonalQuests = gamification.seasonalQuests
        .where((q) => q.isActive && !q.isComplete)
        .toList();
    final visibleSeasonalQuests = allActiveSeasonalQuests
        .where((q) => !_dismissedSeasonalQuests.contains(q.id))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ────── Seasonal Quest Banner (ปิดได้ เหมือน offer) ──────
        ...visibleSeasonalQuests.map((q) => Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg).copyWith(bottom: AppSpacing.sm),
              child: Dismissible(
                key: Key('seasonal_banner_${q.id}'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _dismissSeasonalQuest(q.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: AppRadius.md,
                  ),
                  child: const Icon(Icons.visibility_off, color: Colors.white, size: 28),
                ),
                child: _buildSeasonalQuestBanner(context, q, isDark),
              ),
            )),

        // ────── Quest Bar (Streak + Expandable) ──────
        Container(
          margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [AppColors.surfaceDark, AppColors.surfaceDark]
                  : [
                      AppColors.primary.withValues(alpha: 0.04),
                      AppColors.primary.withValues(alpha: 0.08),
                    ],
            ),
            borderRadius: AppRadius.md,
            border: Border.all(
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.primary.withValues(alpha: 0.2),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStreakRow(context, gamification, isDark),

              // ────── Collapsible Section ──────
              if (_isExpanded) ...[
                Divider(
                  height: 1,
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                ),
                _buildExpandedContent(context, isDark),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Offer Banner - แสดง inline เหนือ quest bar (ไม่ใช้ overlay)
  Widget _buildOfferBanner(BuildContext context, dynamic offer, bool isDark) {
    final l10n = L10n.of(context)!;
    final offerId = offer['id'] as String? ?? '';
    final title = offer['title'] as String? ?? '';
    final description = offer['description'] as String? ?? '';
    final ctaText = offer['ctaText'] as String? ?? l10n.questBarViewDetails;
    final offerType = offer['type'] as String? ?? '';

    final isUrgent = offerType == 'first_purchase';
    final isSubscription = offerType == 'winback' || offerType == 'sub_upsell';

    final gradientColors = isSubscription
        ? [AppColors.premiumLight, AppColors.info]
        : isUrgent
            ? [AppColors.warning, AppColors.error]
            : [AppColors.warning, AppColors.warning];

    final borderColor = isSubscription
        ? AppColors.premium
        : isUrgent
            ? AppColors.warning
            : AppColors.warning;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg).copyWith(top: AppSpacing.sm),
      child: Dismissible(
        key: Key('offer_banner_$offerId'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _dismissOffer(offerId),
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: AppRadius.md,
          ),
          child: const Icon(Icons.delete_sweep, color: Colors.white, size: 28),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.md,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _handleOfferTap(context, offerType, offerId: offerId),
            borderRadius: AppRadius.md,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: AppRadius.md,
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: isUrgent ? AppColors.error : AppColors.warning,
                        size: 24,
                      ),
                      SizedBox(width: AppSpacing.xs + AppSpacing.xs),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _dismissOffer(offerId),
                        child: const Padding(
                          padding: EdgeInsets.all(AppSpacing.xs),
                          child: Icon(Icons.close, size: 18, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                  if (_remainingTime != null) ...[
                        SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
                    Row(
                      children: [
                        Icon(Icons.timer, color: AppColors.error, size: 15),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          l10n.questBarTimeRemaining(_formatDuration(_remainingTime!)),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleOfferTap(context, offerType, offerId: offerId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSubscription ? AppColors.premium : AppColors.warning,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xs + AppSpacing.xxs),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.sm,
                        ),
                      ),
                      child: Text(
                        ctaText,
                        style: const TextStyle(
                          fontSize: 15,
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
      ),
    );
  }

  /// Seasonal Quest Banner - แสดงเด่นด้านบน quest bar (ปิดได้)
  Widget _buildSeasonalQuestBanner(
    BuildContext context,
    SeasonalQuestData quest,
    bool isDark,
  ) {
    final l10n = L10n.of(context)!;

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.md,
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md + AppSpacing.xxs),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.warning.withValues(alpha: 0.2), AppColors.warning.withValues(alpha: 0.2)],
          ),
          borderRadius: AppRadius.md,
          border: Border.all(color: AppColors.warning, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(quest.icon, style: const TextStyle(fontSize: 24)),
                SizedBox(width: AppSpacing.xs + AppSpacing.xxs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs + AppSpacing.xxs, vertical: AppSpacing.xxs),
                            decoration: BoxDecoration(
                                color: AppColors.error,
                              borderRadius: BorderRadius.circular(AppSpacing.xs),
                            ),
                            child: Text(
                              l10n.seasonalQuestLimitedTime,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs + AppSpacing.xxs),
                          Text(
                            l10n.seasonalQuestDaysLeft(quest.daysRemaining),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        quest.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _dismissSeasonalQuest(quest.id),
                  child: const Padding(
                    padding: EdgeInsets.all(AppSpacing.xs),
                    child:
                        Icon(Icons.close, size: 18, color: Colors.black54),
                  ),
                ),
              ],
            ),
            if (quest.description.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
              Text(
                quest.description,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
            SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(AppIcons.energy,
                          size: 16, color: AppColors.warning),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        quest.claimType == 'daily'
                            ? l10n.seasonalQuestRewardDaily(
                                quest.rewardPerClaim)
                            : l10n.seasonalQuestRewardOnce(
                                quest.rewardPerClaim),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
                if (quest.canClaimToday)
                  _buildSeasonalClaimButton(quest)
                else if (quest.claimType == 'one_time' && quest.claimed)
                  _buildSeasonalClaimedBadge(l10n.seasonalQuestClaimed,
                      AppColors.success)
                else if (quest.claimType == 'daily' && !quest.canClaimToday)
                  _buildSeasonalClaimedBadge(l10n.seasonalQuestClaimedToday,
                      AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonalClaimButton(SeasonalQuestData quest) {
    return GestureDetector(
      onTap: _isClaimingSeasonal ? null : () => _claimSeasonalQuest(quest.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isClaimingSeasonal
                ? [AppColors.textTertiary, AppColors.textTertiary]
                : [AppColors.warning, AppColors.warning],
          ),
          borderRadius: AppRadius.pill,
        ),
        child: _isClaimingSeasonal
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+${quest.rewardPerClaim}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  const Icon(AppIcons.energy, size: 14, color: Colors.white),
                ],
              ),
      ),
    );
  }

  Widget _buildSeasonalClaimedBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
                  borderRadius: AppRadius.sm,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Future<void> _claimSeasonalQuest(String questId) async {
    if (_isClaimingSeasonal) return;
    setState(() => _isClaimingSeasonal = true);

    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final response = await http.post(
        Uri.parse(
            'https://us-central1-miro-d6856.cloudfunctions.net/completeChallenge'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': deviceId,
          'challengeType': 'seasonal',
          'questId': questId,
        }),
      );

      if (response.statusCode == 200) {
        ref.read(gamificationProvider.notifier).refresh();
        ref.invalidate(energyBalanceProvider);
        if (mounted) {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('+${data['reward']}E!'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        final error = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error['error'] ?? L10n.of(context)!.errorFailed),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('[QuestBar] Seasonal claim error: $e');
    } finally {
      if (mounted) {
        setState(() => _isClaimingSeasonal = false);
      }
    }
  }

  /// Streak Row
  Widget _buildStreakRow(
    BuildContext context,
    GamificationState gamification,
    bool isDark,
  ) {
    final currentStreak = gamification.currentStreak;
    final tierName = gamification.tierName;
    final tierIcon = gamification.tierIcon;
    final tierColor = gamification.tierColor;

    // คำนวณว่าต้อง streak กี่วันถึง tier ถัดไป
    final streakRequirements = {
      'Starter': 7, // Bronze
      'Bronze': 14, // Silver
      'Silver': 30, // Gold
      'Gold': 60, // Diamond
      'Diamond': 60, // Max
    };
    final nextTierDays = streakRequirements[tierName] ?? 60;
    final remainingDays = (nextTierDays - currentStreak).clamp(0, 999);
    final nextTierName = {
      'Starter': 'Bronze',
      'Bronze': 'Silver',
      'Silver': 'Gold',
      'Gold': 'Diamond',
      'Diamond': 'Diamond',
    }[tierName];

    final progress = currentStreak / nextTierDays;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tierIcon, color: tierColor, size: 24),
                    SizedBox(height: AppSpacing.xxs),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+$_claimableEnergy',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _canClaim ? tierColor : AppColors.textSecondary,
                          ),
                        ),
                        if (!_canClaim) ...[
                          SizedBox(width: AppSpacing.xxs),
                          const Icon(Icons.check, size: 10, color: AppColors.textSecondary),
                        ],
                      ],
                    ),
                  ],
                ),
                SizedBox(width: AppSpacing.md),
                // Streak text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        L10n.of(context)!.questBarStreak(currentStreak),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (tierName != 'Diamond')
                        Text(
                          L10n.of(context)!.questBarDaysToNextTier(remainingDays, nextTierName ?? 'Diamond'),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        )
                      else
                        Text(
                          L10n.of(context)!.questBarMaxTier,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                // Expand icon
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ],
            ),
            // Progress Bar
            if (tierName != 'Diamond') ...[
              SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.xs),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor:
                      isDark ? AppColors.surfaceVariantDark : AppColors.divider,
                  valueColor: AlwaysStoppedAnimation(tierColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Collapsible Content - แสดง Daily Claim, Ad Reward, Challenges, Milestones, Referral
  Widget _buildExpandedContent(BuildContext context, bool isDark) {
    final energyAsync = ref.watch(energyBalanceProvider);
    final currentBalance = energyAsync.valueOrNull ?? 0;
    final showAd = currentBalance <= 4 && _adInitialized && _adService.canWatchAd;
    final gamification = ref.watch(gamificationProvider);

    // Dismissed seasonal quests (ย้ายเข้ามาแสดงใน expanded content)
    final dismissedSeasonalQuests = gamification.seasonalQuests
        .where((q) => q.isActive && !q.isComplete && _dismissedSeasonalQuests.contains(q.id))
        .toList();

    return Padding(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ────── 0. Seasonal Quests (dismissed → แสดงใน expanded) ──────
          ...dismissedSeasonalQuests.map((q) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: SeasonalQuestCard(quest: q),
              )),
          if (dismissedSeasonalQuests.isNotEmpty)
            SizedBox(height: AppSpacing.sm),

          // ────── 1. Ad Reward (balance <= 4) ──────
          if (showAd) ...[
            GestureDetector(
              onTap: _isAdLoading ? null : _handleWatchAd,
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.warning.withValues(alpha: 0.3), AppColors.warning.withValues(alpha: 0.3)],
                  ),
                  borderRadius: AppRadius.md,
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.sm,
                      ),
                      child: _isAdLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.play_circle_filled_rounded,
                              color: AppColors.warning,
                              size: 24,
                            ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L10n.of(context)!.questBarWatchAd(_adRewardEnergy),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                          Text(
                            L10n.of(context)!.questBarAdRemaining(_adService.remainingAds, AdService.maxAdsPerDay),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs + AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.warning, AppColors.warning],
                        ),
                        borderRadius: AppRadius.pill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            AppIcons.energy,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            '+$_adRewardEnergy',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
          ],

          // ────── 2. Offers (ปิดไม่ได้, แสดงเสมอ) ──────
          if (_allOffers.isNotEmpty) ...[
            ..._allOffers.map((offer) => _buildOfferCard(context, offer, isDark)),
            SizedBox(height: AppSpacing.lg),
          ],

          // ────── 2.5. Tier Celebrations (active celebrations only) ──────
          ...gamification.tierCelebrations.entries
              .where((e) => !e.value.isComplete)
              .map((e) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.lg),
                    child: TierCelebrationCard(
                      tierKey: e.key,
                      celebration: e.value,
                    ),
                  )),

          // ────── 3. Daily Challenge ──────
          Text(
            L10n.of(context)!.questBarDailyChallenge,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.sm),
          _buildDailyChallengeRow(context, gamification, isDark),
          SizedBox(height: AppSpacing.lg),

          // ────── 4. Weekly Challenges ──────
          Text(
            L10n.of(context)!.questBarWeeklyChallenges,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.sm),
          const WeeklyChallengeCard(compact: true),
          SizedBox(height: AppSpacing.lg),

          // ────── 5. Milestones ──────
          Text(
            L10n.of(context)!.questBarMilestones,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.sm),
          const MilestoneProgressCard(compact: true),
          SizedBox(height: AppSpacing.lg),

          // ────── 6. Referral (Weekly Quest: +5E per friend, max 10/week) ──────
          _buildReferralRow(context, gamification, isDark),
        ],
      ),
    );
  }

  /// Daily Challenge section — 2 challenges: AI 1 time, AI 10 times
  Widget _buildDailyChallengeRow(
    BuildContext context,
    GamificationState gamification,
    bool isDark,
  ) {
    final dailyAi = gamification.dailyAiCount;
    final claimed = gamification.dailyClaimedRewards;
    final tier = gamification.tier;

    // dailyAi1: 1E + tier bonus
    final tierBonus = {
      'starter': 0, 'bronze': 0, 'silver': 1, 'gold': 2, 'diamond': 3,
    };
    final ai1Reward = 1 + (tierBonus[tier] ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChallengeItem(
          context: context,
          isDark: isDark,
          icon: Icons.bolt,
          label: L10n.of(context)!.questBarUseAi,
          current: dailyAi,
          target: 1,
          reward: ai1Reward,
          claimed: claimed.contains('dailyAi1'),
          isLoading: _claimingChallenges.contains('dailyAi1'),
          onClaim: () => _claimChallenge('dailyAi1'),
        ),
        SizedBox(height: AppSpacing.md),
        _buildChallengeItem(
          context: context,
          isDark: isDark,
          icon: Icons.bolt,
          label: L10n.of(context)!.challengeUseAi10,
          current: dailyAi,
          target: 10,
          reward: 2,
          claimed: claimed.contains('dailyAi10'),
          isLoading: _claimingChallenges.contains('dailyAi10'),
          onClaim: () => _claimChallenge('dailyAi10'),
        ),
      ],
    );
  }

  /// Reusable challenge row (daily & can be used elsewhere)
  Widget _buildChallengeItem({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String label,
    required int current,
    required int target,
    required int reward,
    required bool claimed,
    required VoidCallback onClaim,
    bool isLoading = false,
  }) {
    final completed = current >= target;
    final color = claimed ? AppColors.success : (completed ? AppColors.warning : AppColors.info);
    final progress = (current / target).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  children: [
                    TextSpan(text: label),
                    TextSpan(
                      text: ' (+$reward',
                      style: TextStyle(
                        color: completed ? AppColors.success : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    WidgetSpan(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                        child: Icon(
                          AppIcons.energy,
                          size: 12,
                          color: completed ? AppColors.success : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: ')',
                      style: TextStyle(
                        color: completed ? AppColors.success : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (claimed)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                          SizedBox(width: AppSpacing.xs),
                  Text(
                    L10n.of(context)!.questBarClaimed,
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            else if (completed)
              _buildClaimPill(reward, onClaim, isLoading: isLoading)
            else
              Text(
                '[$current/$target]',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
          ],
        ),
                        SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  /// Small claim pill button
  Widget _buildClaimPill(int reward, VoidCallback onClaim, {bool isLoading = false}) {
    return GestureDetector(
      onTap: isLoading ? null : onClaim,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs + AppSpacing.xxs, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading
                ? [AppColors.textTertiary, AppColors.textTertiary]
                : [AppColors.warning, AppColors.warning],
          ),
          borderRadius: AppRadius.md,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            else ...[
              Text(
                '+$reward',
                style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white,
                ),
              ),
              SizedBox(width: AppSpacing.xxs),
              const Icon(AppIcons.energy, size: 12, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }

  /// Claim a daily or weekly challenge
  Future<void> _claimChallenge(String challengeType) async {
    if (_claimingChallenges.contains(challengeType)) return;
    setState(() => _claimingChallenges.add(challengeType));

    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final response = await http.post(
        Uri.parse('https://us-central1-miro-d6856.cloudfunctions.net/completeChallenge'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': deviceId,
          'challengeType': challengeType,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(L10n.of(context)!.questBarClaimed)),
          );
          ref.read(gamificationProvider.notifier).refresh();
        }
      } else {
        debugPrint('[QuestBar] Claim failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('[QuestBar] Claim error: $e');
    } finally {
      if (mounted) {
        setState(() => _claimingChallenges.remove(challengeType));
      }
    }
  }

  /// Referral row — แสดง 10 ระดับพร้อมปุ่ม claim
  Widget _buildReferralRow(
    BuildContext context,
    GamificationState gamification,
    bool isDark,
  ) {
    final l10n = L10n.of(context)!;
    final referFriends = gamification.referFriendsProgress;
    final claimedRewards = gamification.weeklyClaimedRewards;

    // 10 levels (like milestones)
    const levels = [
      {'level': 1, 'target': 1, 'reward': 5},
      {'level': 2, 'target': 2, 'reward': 5},
      {'level': 3, 'target': 3, 'reward': 5},
      {'level': 4, 'target': 4, 'reward': 5},
      {'level': 5, 'target': 5, 'reward': 5},
      {'level': 6, 'target': 6, 'reward': 5},
      {'level': 7, 'target': 7, 'reward': 5},
      {'level': 8, 'target': 8, 'reward': 5},
      {'level': 9, 'target': 9, 'reward': 5},
      {'level': 10, 'target': 10, 'reward': 25},
    ];

    // หา level ถัดไปที่ยังไม่ได้ claim
    int? nextLevel;
    for (final level in levels) {
      final claimKey = 'referFriends_${level['level']}';
      if (!claimedRewards.contains(claimKey)) {
        nextLevel = level['level'] as int;
        break;
      }
    }

    // ถ้า claim ครบทุก level แล้ว
    if (nextLevel == null) {
      return Row(
        children: [
          const Icon(Icons.people, color: AppColors.success, size: 20),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              l10n.inviteFriendsSubtitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                          SizedBox(width: AppSpacing.xs),
          Text(
            l10n.referralAllLevelsClaimed,
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    // Non-null assertion safe here (checked above)
    final levelNum = nextLevel;
    final currentLevel = levels[levelNum - 1];
    final target = currentLevel['target'] as int;
    final reward = currentLevel['reward'] as int;
    final canClaim = referFriends >= target;
    final progress = (referFriends / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.people,
              size: 20,
              color: canClaim ? AppColors.success : AppColors.info,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  children: [
                    TextSpan(text: l10n.referralLevel(levelNum, l10n.inviteFriendsSubtitle)),
                    TextSpan(
                      text: ' (+$reward',
                      style: TextStyle(
                        color: canClaim ? AppColors.success : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    WidgetSpan(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                        child: Icon(
                          AppIcons.energy,
                          size: 12,
                          color: canClaim ? AppColors.success : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: ')',
                      style: TextStyle(
                        color: canClaim ? AppColors.success : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (canClaim)
              GestureDetector(
                onTap: _isClaimingReferral ? null : () => _claimReferralLevel(levelNum),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + AppSpacing.xxs),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isClaimingReferral
                          ? [AppColors.textTertiary, AppColors.textTertiary]
                          : [AppColors.warning, AppColors.warning],
                    ),
                    borderRadius: AppRadius.pill,
                  ),
                  child: _isClaimingReferral
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(AppIcons.energy, size: 14, color: Colors.white),
                            SizedBox(width: AppSpacing.xs),
                            Text(
                              '+$reward',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              )
            else
              GestureDetector(
                onTap: _shareReferralLink,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.info, AppColors.premium],
                    ),
                    borderRadius: AppRadius.pill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.share, size: 14, color: Colors.white),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.questBarShareSubject,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(
              canClaim ? AppColors.success : AppColors.info,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          l10n.referralProgress(referFriends, target, levelNum, levels.length),
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Future<void> _claimReferralLevel(int level) async {
    if (_isClaimingReferral) return;
    setState(() => _isClaimingReferral = true);

    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final response = await http.post(
        Uri.parse('https://us-central1-miro-d6856.cloudfunctions.net/completeChallenge'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'deviceId': deviceId,
          'challengeType': 'referFriends',
          'referralLevel': level,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reward = data['reward'] as int;

        // Refresh state
        await ref.read(gamificationProvider.notifier).refresh();
        ref.invalidate(energyBalanceProvider);

        if (mounted) {
          final l10n = L10n.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.referralClaimedLevel(level, reward)),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        final error = json.decode(response.body);
        if (mounted) {
          final l10n = L10n.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error['error'] ?? l10n.errorFailedToClaim),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error claiming referral level: $e');
      if (mounted) {
        final l10n = L10n.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorGeneric('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isClaimingReferral = false);
      }
    }
  }

  /// Offer card ใน expanded content — ปิดไม่ได้, กดแล้วไป Energy Store
  Widget _buildOfferCard(BuildContext context, dynamic offer, bool isDark) {
    final l10n = L10n.of(context)!;
    final offerId = offer['id'] as String? ?? '';
    final title = offer['title'] as String? ?? '';
    final description = offer['description'] as String? ?? '';
    final ctaText = offer['ctaText'] as String? ?? l10n.questBarViewDetails;
    final offerType = offer['type'] as String? ?? '';

    final isUrgent = offerType == 'first_purchase';
    final isSubscription = offerType == 'winback' || offerType == 'sub_upsell';

    final gradientColors = isSubscription
        ? [AppColors.premiumLight, AppColors.info]
        : isUrgent
            ? [AppColors.warning, AppColors.error]
            : [AppColors.warning, AppColors.warning];

    final borderColor = isSubscription
        ? AppColors.premium
        : isUrgent
            ? AppColors.warning
            : AppColors.warning;

    final isFirstOffer =
        _activeOffers.isNotEmpty && _activeOffers.first['id'] == (offer['id'] as String?);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
                    borderRadius: AppRadius.md,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _handleOfferTap(context, offerType, offerId: offerId),
          borderRadius: AppRadius.md,
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: AppRadius.md,
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: isUrgent ? AppColors.error : AppColors.warning,
                  size: 22,
                ),
                SizedBox(width: AppSpacing.xs + AppSpacing.xxs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title.isNotEmpty)
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      if (description.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                      if (isFirstOffer && _remainingTime != null) ...[
                        SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Icon(Icons.timer, color: AppColors.error, size: 13),
                            SizedBox(width: AppSpacing.xxs + AppSpacing.xxs),
                            Text(
                              l10n.questBarTimeRemaining(_formatDuration(_remainingTime!)),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: () => _handleOfferTap(context, offerType, offerId: offerId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSubscription ? AppColors.premium : AppColors.warning,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md + AppSpacing.xxs,
                      vertical: AppSpacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.pill,
                    ),
                    minimumSize: const Size(64, 36),
                  ),
                  child: Text(
                    ctaText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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

  /// Navigate to appropriate screen based on offer type
  void _handleOfferTap(BuildContext context, String offerType, {String? offerId}) {
    if (offerType == 'winback' || offerType == 'sub_upsell') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EnergyStoreScreen(highlightOfferId: offerId),
        ),
      );
    }
  }
}
