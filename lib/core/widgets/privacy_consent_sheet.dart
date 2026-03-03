import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:miro_hybrid/core/theme/app_colors.dart';
import 'package:miro_hybrid/core/theme/app_tokens.dart';
import 'package:miro_hybrid/core/services/consent_service.dart';
import 'package:miro_hybrid/core/services/analytics_service.dart';
import 'package:miro_hybrid/core/services/notification_service.dart';
import 'package:miro_hybrid/core/services/admob_consent_service.dart';
import 'package:miro_hybrid/core/database/database_service.dart';
import 'package:miro_hybrid/core/utils/logger.dart';
import 'package:miro_hybrid/l10n/app_localizations.dart';

/// Unified Privacy Consent Bottom Sheet
///
/// Combines all privacy-related permissions into a single professional sheet:
/// - Push Notifications
/// - Analytics (Firebase)
/// - Food Research (optional)
/// - Advertising (AdMob / UMP)
///
/// User must scroll to the bottom before the "Allow All" button is enabled.
class PrivacyConsentSheet extends StatefulWidget {
  const PrivacyConsentSheet({super.key});

  static const String _keyPrivacyConsentShown = 'privacy_consent_shown';
  static const String _keyPrivacyConsentVersion = 'privacy_consent_version';
  static const int _currentVersion = 1;

  static Future<bool> needsConsent() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool(_keyPrivacyConsentShown) ?? false;
    final version = prefs.getInt(_keyPrivacyConsentVersion) ?? 0;
    return !shown || version < _currentVersion;
  }

  static Future<void> _markConsentShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPrivacyConsentShown, true);
    await prefs.setInt(_keyPrivacyConsentVersion, _currentVersion);
  }

  /// Show the sheet and return true if user accepted
  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const PrivacyConsentSheet(),
    );
    return result ?? false;
  }

  @override
  State<PrivacyConsentSheet> createState() => _PrivacyConsentSheetState();
}

class _PrivacyConsentSheetState extends State<PrivacyConsentSheet>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _notificationsEnabled = true;
  bool _analyticsEnabled = true;
  bool _foodResearchEnabled = false;
  bool _adsPersonalized = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_hasScrolledToBottom) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 20) {
      setState(() => _hasScrolledToBottom = true);
      _pulseController.stop();
    }
  }

  Future<void> _openPrivacyPolicy() async {
    const url = 'https://lnxelnope.github.io/miro/privacy-policy.html';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _handleAllowAll() async {
    // 1. Notifications
    if (_notificationsEnabled) {
      try {
        await NotificationService.initialize()
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        AppLogger.warn('Notification permission: $e');
      }
    }

    // 2. Analytics
    if (_analyticsEnabled) {
      await ConsentService.grantConsent();
      await AnalyticsService.setAnalyticsEnabled(true);
    } else {
      await ConsentService.revokeConsent();
      await AnalyticsService.setAnalyticsEnabled(false);
    }

    // 3. Food Research
    try {
      final profile = await (DatabaseService.db
              .select(DatabaseService.db.userProfiles)
            ..where((tbl) => tbl.id.equals(1)))
          .getSingleOrNull();
      if (profile != null) {
        profile.foodResearchConsent = _foodResearchEnabled;
        profile.foodResearchConsentAt =
            _foodResearchEnabled ? DateTime.now() : null;
        profile.updatedAt = DateTime.now();
        await DatabaseService.db
            .into(DatabaseService.db.userProfiles)
            .insertOnConflictUpdate(profile);
      }
    } catch (_) {}

    // 4. Ads
    if (_adsPersonalized) {
      try {
        await AdmobConsentService.initializeWithConsent()
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        AppLogger.warn('AdMob consent: $e');
      }
    }

    // Mark consent as shown
    await PrivacyConsentSheet._markConsentShown();
    await ConsentService.markConsentAsked();

    AppLogger.info('Privacy consent completed: '
        'notifications=$_notificationsEnabled, '
        'analytics=$_analyticsEnabled, '
        'foodResearch=$_foodResearchEnabled, '
        'adsPersonalized=$_adsPersonalized');

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = L10n.of(context)!;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: AppRadius.sheetTop,
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Container(
              width: AppSizes.dragHandleWidth,
              height: AppSizes.dragHandleHeight,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: AppRadius.pill,
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.sm),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppRadius.lg,
                  ),
                  child: const Icon(Icons.shield_outlined,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.privacyConsentTitle,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.privacyConsentSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: Stack(
              children: [
                ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.sm,
                  ),
                  children: [
                    // --- Notifications ---
                    _buildSection(
                      icon: Icons.notifications_outlined,
                      iconColor: AppColors.warning,
                      title: l10n.privacyConsentNotifTitle,
                      description: l10n.privacyConsentNotifDesc,
                      bullets: [
                        l10n.privacyConsentNotifBullet1,
                        l10n.privacyConsentNotifBullet2,
                        l10n.privacyConsentNotifBullet3,
                      ],
                      value: _notificationsEnabled,
                      onChanged: (v) =>
                          setState(() => _notificationsEnabled = v),
                      isDark: isDark,
                    ),

                    _buildDivider(isDark),

                    // --- Analytics ---
                    _buildSection(
                      icon: Icons.analytics_outlined,
                      iconColor: AppColors.success,
                      title: l10n.consentAnalyticsSection,
                      description: l10n.consentAnalyticsDescription,
                      bullets: [
                        l10n.consentAnalyticsCollect,
                        l10n.consentAnalyticsNotCollect,
                        l10n.consentAnalyticsAnonymous,
                      ],
                      value: _analyticsEnabled,
                      onChanged: (v) =>
                          setState(() => _analyticsEnabled = v),
                      isDark: isDark,
                    ),

                    _buildDivider(isDark),

                    // --- Food Research ---
                    _buildSection(
                      icon: Icons.science_outlined,
                      iconColor: AppColors.premium,
                      title: l10n.consentFoodResearchSection,
                      description: l10n.privacyConsentResearchDesc,
                      bullets: [
                        l10n.privacyConsentResearchBullet1,
                        l10n.privacyConsentResearchBullet2,
                      ],
                      value: _foodResearchEnabled,
                      onChanged: (v) =>
                          setState(() => _foodResearchEnabled = v),
                      isDark: isDark,
                      isOptional: true,
                    ),

                    _buildDivider(isDark),

                    // --- Advertising ---
                    _buildSection(
                      icon: Icons.ads_click_outlined,
                      iconColor: const Color(0xFF5B86E5),
                      title: l10n.privacyConsentAdsTitle,
                      description: l10n.privacyConsentAdsDesc,
                      bullets: [
                        l10n.privacyConsentAdsBullet1,
                        l10n.privacyConsentAdsBullet2,
                      ],
                      value: _adsPersonalized,
                      onChanged: (v) =>
                          setState(() => _adsPersonalized = v),
                      isDark: isDark,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // --- Health info note ---
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: AppRadius.md,
                        border: Border.all(
                          color: isDark
                              ? Colors.white12
                              : AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.favorite_outline,
                              size: 20,
                              color: isDark
                                  ? Colors.redAccent.shade100
                                  : Colors.redAccent),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              l10n.privacyConsentHealthNote,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark
                                    ? Colors.white60
                                    : AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // --- Privacy Policy link + change notice ---
                    Center(
                      child: Column(
                        children: [
                          Text(
                            l10n.consentChangeAnytime,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white38
                                  : AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          GestureDetector(
                            onTap: _openPrivacyPolicy,
                            child: Text(
                              l10n.privacyConsentReadPolicy,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Extra padding at bottom for scroll detection
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),

                // Scroll-down indicator (fades out once scrolled)
                if (!_hasScrolledToBottom)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildScrollIndicator(isDark, l10n),
                  ),
              ],
            ),
          ),

          // Bottom action area
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.md,
              AppSpacing.xxl,
              AppSpacing.md + bottomPadding,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: AppSizes.buttonLarge,
              child: AnimatedOpacity(
                duration: AppDurations.normal,
                opacity: _hasScrolledToBottom ? 1.0 : 0.4,
                child: FilledButton(
                  onPressed: _hasScrolledToBottom ? _handleAllowAll : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.md,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  child: Text(_hasScrolledToBottom
                      ? l10n.privacyConsentAccept
                      : l10n.unifiedPermissionsScrollToEnable),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required List<String> bullets,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.sm,
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        if (isOptional) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white10
                                  : Colors.grey.shade100,
                              borderRadius: AppRadius.pill,
                            ),
                            child: Text(
                              L10n.of(context)!.privacyConsentOptional,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.white38
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch.adaptive(
                  value: value,
                  onChanged: onChanged,
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white54
                        : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...bullets.map((bullet) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white30 : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              bullet,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark
                                    ? Colors.white38
                                    : AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Divider(
        color: isDark ? Colors.white10 : Colors.grey.shade200,
        height: 1,
      ),
    );
  }

  Widget _buildScrollIndicator(bool isDark, L10n l10n) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            (isDark ? const Color(0xFF1C1C1E) : Colors.white)
                .withValues(alpha: 0),
            isDark ? const Color(0xFF1C1C1E) : Colors.white,
          ],
        ),
      ),
      padding: const EdgeInsets.only(
        top: AppSpacing.xxxl,
        bottom: AppSpacing.sm,
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _pulseAnimation.value,
              child: child,
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.keyboard_double_arrow_down_rounded,
                size: 22,
                color: isDark ? Colors.white38 : AppColors.textTertiary,
              ),
              const SizedBox(height: 2),
              Text(
                l10n.unifiedPermissionsScrollHint,
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? Colors.white30 : AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
