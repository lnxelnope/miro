import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/subscription_data.dart';
import '../models/subscription_plan.dart';
import '../models/subscription_status.dart';
import '../services/subscription_service.dart';
import '../providers/subscription_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';

/// Subscription Screen
/// 
/// Shows subscription plans and handles purchase flow
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isLoadingProducts = true;
  List<ProductDetails> _products = [];
  String? _error;
  bool _isPurchasing = false;
  Map<String, String> _basePlanPrices = {};

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  Future<void> _initScreen() async {
    final subscriptionState = ref.read(subscriptionProvider);
    if (subscriptionState.subscription.isActive) {
      // Subscriber: no need to load products — show details immediately
      if (mounted) setState(() => _isLoadingProducts = false);
    } else {
      await _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _error = null;
    });

    try {
      final service = ref.read(subscriptionServiceProvider);

      final available = await service.isAvailable()
          .timeout(const Duration(seconds: 10), onTimeout: () => false);
      if (!available) {
        if (mounted) {
          setState(() {
            _error = L10n.of(context)!.subscriptionInAppPurchasesNotAvailable;
            _isLoadingProducts = false;
          });
        }
        return;
      }

      final products = await service.getProducts()
          .timeout(const Duration(seconds: 15), onTimeout: () => <ProductDetails>[]);

      debugPrint('[SubscriptionScreen] Products loaded: ${products.length}');

      final prices = products.isNotEmpty
          ? (Platform.isIOS
              ? SubscriptionService.extractProductPrices(products)
              : SubscriptionService.extractBasePlanPrices(products.first))
          : <String, String>{};

      if (mounted) {
        setState(() {
          _products = products;
          _basePlanPrices = prices;
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      debugPrint('[SubscriptionScreen] Error loading products: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingProducts = false;
        });
      }
    }
  }

  Future<void> _handlePurchase(ProductDetails product, {String? basePlanId}) async {
    setState(() => _isPurchasing = true);

    try {
      final service = ref.read(subscriptionServiceProvider);
      final success = await service.purchaseSubscription(product, basePlanId: basePlanId);

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.subscriptionFailedToInitiatePurchase),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.subscriptionError(e.toString())),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  Future<void> _openSubscriptionManagement() async {
    final Uri url;
    if (Platform.isIOS) {
      url = Uri.parse('https://apps.apple.com/account/subscriptions');
    } else {
      url = Uri.parse('https://play.google.com/store/account/subscriptions');
    }
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[SubscriptionScreen] Failed to open subscription management: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subscriptionState = ref.watch(subscriptionProvider);
    final hasActiveSubscription = subscriptionState.subscription.isActive;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(L10n.of(context)!.subscriptionEnergyPass),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        elevation: 0,
      ),
      body: hasActiveSubscription
          ? _buildActiveSubscription(subscriptionState.subscription, isDark)
          : _isLoadingProducts
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildError(isDark)
                  : _buildSubscriptionPlans(isDark),
    );
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.lg),
            Text(
              L10n.of(context)!.subscriptionFailedToLoad,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error ?? L10n.of(context)!.subscriptionUnknownError,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProducts,
              child: Text(L10n.of(context)!.subscriptionRetry),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ACTIVE SUBSCRIBER: ดูรายละเอียด + จัดการ (ไม่ต้องโหลด Store)
  // ─────────────────────────────────────────────────────────────

  Widget _buildActiveSubscription(SubscriptionData subscription, bool isDark) {
    final statusColor = _statusColor(subscription.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Active Badge
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.premium, AppColors.premiumDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.lg,
              boxShadow: [
                BoxShadow(
                  color: AppColors.premium.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.diamond_rounded, size: 56, color: Colors.white),
                const SizedBox(height: AppSpacing.md),
                Text(
                  L10n.of(context)!.subscriptionEnergyPassActive,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  L10n.of(context)!.subscriptionUnlimitedAccess,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Subscription Details
          _buildInfoCard(
            icon: Icons.circle,
            iconSize: 14,
            title: L10n.of(context)!.subscriptionStatus,
            value: subscription.status.displayText,
            valueColor: statusColor,
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoCard(
            icon: Icons.event_rounded,
            title: L10n.of(context)!.subscriptionRenews,
            value: subscription.formattedExpiryDate,
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (subscription.autoRenewing)
            _buildInfoCard(
              icon: Icons.autorenew_rounded,
              title: L10n.of(context)!.subscriptionAutoRenew,
              value: L10n.of(context)!.subscriptionAutoRenewOn,
              valueColor: AppColors.success,
              isDark: isDark,
            )
          else
            _buildInfoCard(
              icon: Icons.autorenew_rounded,
              title: L10n.of(context)!.subscriptionAutoRenew,
              value: L10n.of(context)!.subscriptionAutoRenewOff,
              valueColor: AppColors.warning,
              isDark: isDark,
            ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoCard(
            icon: Icons.payment_rounded,
            title: L10n.of(context)!.subscriptionPrice,
            value: subscription.productId != null
                ? _getSubscriptionPriceLabel(subscription.productId!)
                : '\$4.99/month',
            isDark: isDark,
          ),

          const SizedBox(height: 28),

          // Benefits
          Text(
            L10n.of(context)!.subscriptionYourBenefits,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          ...SubscriptionPlan.energyPassMonthly().benefits.map(
                (benefit) => _buildBenefitItem(benefit, isDark),
              ),

          const SizedBox(height: 28),

          // Manage Subscription Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _openSubscriptionManagement,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(L10n.of(context)!.subscriptionManageSubscription),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                side: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                ),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            Platform.isIOS
                ? L10n.of(context)!.subscriptionManagedByAppStore
                : L10n.of(context)!.subscriptionManagedByPlayStore,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Color _statusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return AppColors.success;
      case SubscriptionStatus.cancelled:
        return AppColors.warning;
      case SubscriptionStatus.expired:
        return AppColors.error;
      case SubscriptionStatus.gracePeriod:
        return AppColors.warning;
      case SubscriptionStatus.none:
        return AppColors.textSecondary;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // NON-SUBSCRIBER: แสดง Plans (ต้องโหลด Store products)
  // ─────────────────────────────────────────────────────────────

  Widget _buildSubscriptionPlans(bool isDark) {
    final plans = SubscriptionPlan.availablePlans();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.05),
                ],
              ),
              borderRadius: AppRadius.lg,
            ),
            child: Column(
              children: [
                const Icon(Icons.energy_savings_leaf, size: 80, color: AppColors.primary),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  L10n.of(context)!.subscriptionEnergyPass,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  L10n.of(context)!.energyPassUnlimitedAI,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          if (_products.isEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: AppRadius.md,
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      L10n.of(context)!.subscriptionCannotLoadPrices,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadProducts,
                    child: Text(
                      L10n.of(context)!.subscriptionRetry,
                      style: const TextStyle(color: AppColors.warning, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],

          ...plans.map((plan) => _buildPlanCard(plan, isDark)),

          const SizedBox(height: 24),

          Text(
            L10n.of(context)!.subscriptionWhatYouGet,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          ...plans.firstWhere((p) => p.isPopular).benefits.map(
                (benefit) => _buildBenefitItem(benefit, isDark),
              ),

          const SizedBox(height: 24),

          Text(
            L10n.of(context)!.subscriptionAutoRenewTerms,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, bool isDark) {
    ProductDetails? product;
    if (Platform.isIOS) {
      final match = _products.where((p) => p.id == plan.iosProductId);
      product = match.isNotEmpty ? match.first : null;
    } else {
      product = _products.isNotEmpty ? _products.first : null;
    }
    final priceKey = Platform.isIOS ? plan.iosProductId : plan.basePlanId;
    final realPrice = _basePlanPrices[priceKey];
    final displayPrice = realPrice != null
        ? '$realPrice / ${plan.period}'
        : plan.displayPrice;

    final cardBg = plan.isPopular
        ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.05)
        : (isDark ? AppColors.surfaceDark : AppColors.surface);

    final borderColor = plan.isPopular
        ? AppColors.primary.withValues(alpha: 0.5)
        : (isDark ? AppColors.dividerDark : AppColors.divider);

    final btnBg = plan.isPopular
        ? AppColors.primary
        : (isDark ? AppColors.surfaceVariantDark : AppColors.textPrimary);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.lg,
        border: Border.all(color: borderColor, width: plan.isPopular ? 2.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
              ),
              if (plan.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.sm,
                  ),
                  child: Text(
                    L10n.of(context)!.subscriptionBestValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            displayPrice,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
          ),
          if (plan.savingsText != null) ...[
            const SizedBox(height: 4),
            Text(
              plan.savingsText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isPurchasing || product == null
                  ? null
                  : () => _handlePurchase(
                        product!,
                        basePlanId: Platform.isAndroid ? plan.basePlanId : null,
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: btnBg,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
              ),
              child: _isPurchasing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      plan.isPopular
                          ? L10n.of(context)!.subscriptionSubscribeNow
                          : L10n.of(context)!.subscriptionSubscribe,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SHARED WIDGETS
  // ─────────────────────────────────────────────────────────────

  String _getSubscriptionPriceLabel(String productId) {
    final plans = SubscriptionPlan.availablePlans();
    for (final plan in plans) {
      if (plan.basePlanId == productId ||
          plan.iosProductId == productId ||
          plan.productId == productId) {
        return plan.displayPrice;
      }
    }
    return '\$4.99/month';
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
    double iconSize = 20,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        borderRadius: AppRadius.md,
      ),
      child: Row(
        children: [
          Icon(icon, color: valueColor ?? AppColors.primary, size: iconSize),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: valueColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String benefit, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              benefit,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
