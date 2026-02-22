import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../models/subscription_plan.dart';
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

  // V3: ราคาจริงจาก Google Play ต่อ base plan
  Map<String, String> _basePlanPrices = {};

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _error = null;
    });

    try {
      final service = ref.read(subscriptionServiceProvider);
      await service.initialize();

      final available = await service.isAvailable();
      if (!available) {
        setState(() {
          _error = L10n.of(context)!.subscriptionInAppPurchasesNotAvailable;
          _isLoadingProducts = false;
        });
        return;
      }

      final products = await service.getProducts();
      // V3: ดึงราคาจริงของแต่ละ base plan
      final prices = products.isNotEmpty
          ? SubscriptionService.extractBasePlanPrices(products.first)
          : <String, String>{};
      setState(() {
        _products = products;
        _basePlanPrices = prices;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingProducts = false;
      });
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

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final hasActiveSubscription = subscriptionState.subscription.isActive;

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context)!.subscriptionEnergyPass),
        centerTitle: true,
      ),
      body: _isLoadingProducts
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : hasActiveSubscription
                  ? _buildActiveSubscription(subscriptionState.subscription)
                  : _buildSubscriptionPlans(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: AppSpacing.lg),
            Text(
              L10n.of(context)!.subscriptionFailedToLoad,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              _error ?? L10n.of(context)!.subscriptionUnknownError,
              style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildActiveSubscription(subscription) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Active Badge
          Container(
            padding: EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: AppRadius.lg,
            ),
            child: Column(
              children: [
                const Icon(Icons.verified, size: 64, color: Colors.white),
                SizedBox(height: AppSpacing.lg),
                Text(
                  L10n.of(context)!.subscriptionEnergyPassActive,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: AppSpacing.sm),
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
            icon: Icons.calendar_today,
            title: L10n.of(context)!.subscriptionStatus,
            value: subscription.status.displayText,
          ),
          SizedBox(height: AppSpacing.md),
          _buildInfoCard(
            icon: Icons.access_time,
            title: L10n.of(context)!.subscriptionRenews,
            value: subscription.formattedExpiryDate,
          ),
          SizedBox(height: AppSpacing.md),
          _buildInfoCard(
            icon: Icons.payment,
            title: L10n.of(context)!.subscriptionPrice,
            value: '\$4.99/month',
          ),

          SizedBox(height: AppSpacing.xxxl),

          // Benefits
          Text(
            L10n.of(context)!.subscriptionYourBenefits,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...SubscriptionPlan.energyPassMonthly().benefits.map(
                (benefit) => _buildBenefitItem(benefit),
              ),

          SizedBox(height: AppSpacing.xxxl),

          // Manage Button
          OutlinedButton(
            onPressed: () {
              // Open Google Play subscription management
              // TODO: Implement
            },
            child: Text(L10n.of(context)!.subscriptionManageSubscription),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans() {
    // V3: แสดง 3 plans (Weekly, Monthly, Yearly)
    final plans = SubscriptionPlan.availablePlans();
    
    // Map plans to products (ใช้ productId เดียว: miro_normal_subscription)
    // แต่ต้อง query base plans จาก Google Play Billing Library
    // ตอนนี้ใช้ placeholder — จะต้อง query base plans แยกต่างหาก
    
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: AppSpacing.lg),
            Text(L10n.of(context)!.subscriptionNoProductAvailable),
            SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _loadProducts,
              child: Text(L10n.of(context)!.subscriptionRetry),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(AppSpacing.xxxl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: AppRadius.lg,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.energy_savings_leaf,
                  size: 80,
                  color: AppColors.primary,
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'Energy Pass',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Unlimited AI Analysis',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.xxxl),

          // V3: แสดง 3 Plans
          ...plans.map((plan) => _buildPlanCard(plan)),

          const SizedBox(height: 24),

          // Benefits (ใช้จาก monthly plan)
          Text(
            L10n.of(context)!.subscriptionWhatYouGet,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...plans.firstWhere((p) => p.isPopular).benefits.map(
                (benefit) => _buildBenefitItem(benefit),
              ),

          const SizedBox(height: 24),

          // Terms
          Text(
            L10n.of(context)!.subscriptionAutoRenewTerms,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final product = _products.isNotEmpty ? _products.first : null;
    // ใช้ราคาจริงจาก Google Play ถ้ามี ไม่งั้นใช้ fallback จาก model
    final realPrice = _basePlanPrices[plan.basePlanId];
    final displayPrice = realPrice != null
        ? '$realPrice / ${plan.period}'
        : plan.displayPrice;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: plan.isPopular ? AppColors.primary.withValues(alpha: 0.05) : AppColors.background,
        borderRadius: AppRadius.lg,
        border: Border.all(
          color: plan.isPopular
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.divider,
          width: plan.isPopular ? 3 : 1,
        ),
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
                    ),
              ),
              if (plan.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.sm,
                  ),
                  child: const Text(
                    'BEST VALUE',
                    style: TextStyle(
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
                  color: AppColors.textSecondary,
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
                  : () => _handlePurchase(product, basePlanId: plan.basePlanId),
              style: ElevatedButton.styleFrom(
                backgroundColor: plan.isPopular ? AppColors.primary : AppColors.textPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.md,
                ),
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
                          : 'Subscribe',
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.md,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              benefit,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
