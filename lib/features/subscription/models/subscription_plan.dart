import 'package:flutter/widgets.dart';
import '../../../l10n/app_localizations.dart';

/// Subscription Plan Model
///
/// Google Play structure:
///   Product ID: miro_normal_subscription
///   Base Plans: energy-pass-monthly, energy-pass-yearly
///   Offers: first-month-free, winback-3usd
///
/// Pricing strategy (Mar 2026):
///   Monthly $9.99 — gateway plan
///   Yearly  $22.99 — ★ Best Value (covers CAC, save 81%)
class SubscriptionPlan {
  final String productId;
  final String basePlanId;
  final String name;
  final String description;
  final String price;
  final String period;
  final List<String> benefits;
  final bool isPopular;
  final String? savingsText;
  /// iOS: Product ID บน App Store (แต่ละ plan = 1 product)
  final String iosProductId;

  const SubscriptionPlan({
    required this.productId,
    required this.basePlanId,
    required this.name,
    required this.description,
    required this.price,
    required this.period,
    required this.benefits,
    this.isPopular = false,
    this.savingsText,
    required this.iosProductId,
  });

  /// Google Play subscription product ID (single product with multiple base plans)
  static const String kProductId = 'miro_normal_subscription';

  /// Base Plan IDs (hyphens required by Google Play)
  static const String kMonthlyBasePlan = 'energy-pass-monthly';
  static const String kYearlyBasePlan = 'energy-pass-yearly';

  /// iOS Product IDs (App Store: each plan = 1 product)
  static const String kIosMonthlyProductId = 'miro_energy_pass_monthly';
  static const String kIosYearlyProductId = 'miro_energy_pass_yearly';

  /// Offer IDs
  static const String kFreeTrialOffer = 'first-month-free';
  static const String kWinbackOffer = 'winback-3usd';

  static SubscriptionPlan energyPassMonthly([BuildContext? context]) {
    final l10n = context != null ? L10n.of(context) : null;
    return SubscriptionPlan(
      productId: kProductId,
      basePlanId: kMonthlyBasePlan,
      iosProductId: kIosMonthlyProductId,
      name: l10n?.subscriptionPlanMonthlyName ?? 'Energy Pass Monthly',
      description: l10n?.subscriptionPlanMonthlyDesc ?? 'Unlimited AI analysis',
      price: '\$9.99',
      period: l10n?.subscriptionPeriodMonth ?? 'month',
      benefits: [
        l10n?.subscriptionBenefitUnlimitedAI ?? 'Unlimited AI Analysis',
        l10n?.subscriptionBenefitExclusiveBadge ?? 'Exclusive Badge',
        l10n?.subscriptionBenefitPrioritySupport ?? 'Priority Support',
      ],
    );
  }

  static SubscriptionPlan energyPassYearly([BuildContext? context]) {
    final l10n = context != null ? L10n.of(context) : null;
    return SubscriptionPlan(
      productId: kProductId,
      basePlanId: kYearlyBasePlan,
      iosProductId: kIosYearlyProductId,
      name: l10n?.subscriptionPlanYearlyName ?? 'Energy Pass Yearly',
      description: l10n?.subscriptionPlanYearlyDesc ?? 'Best value — save 81%',
      price: '\$22.99',
      period: l10n?.subscriptionPeriodYear ?? 'year',
      benefits: [
        l10n?.subscriptionBenefitUnlimitedAI ?? 'Unlimited AI Analysis',
        l10n?.subscriptionBenefitExclusiveBadge ?? 'Exclusive Badge',
        l10n?.subscriptionBenefitPrioritySupport ?? 'Priority Support',
      ],
      isPopular: true,
      savingsText: l10n?.subscriptionSavePercent('\$1.92') ?? 'Save 81% — \$1.92/month',
    );
  }

  /// Get all available plans (pass context for localized names)
  static List<SubscriptionPlan> availablePlans([BuildContext? context]) {
    return [
      energyPassMonthly(context),
      energyPassYearly(context),
    ];
  }


  /// Get display price with period
  String get displayPrice => '$price / $period';

  /// Get full price text
  String get fullPriceText {
    if (savingsText != null) {
      return '$displayPrice ($savingsText)';
    }
    return displayPrice;
  }

  @override
  String toString() {
    return 'SubscriptionPlan(basePlan: $basePlanId, price: $displayPrice)';
  }
}
