/// Subscription Plan Model
///
/// Google Play structure:
///   Product ID: miro_normal_subscription
///   Base Plans: energy-pass-weekly, energy-pass-monthly, energy-pass-yearly
///   Offers: first-month-free, winback-3usd
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
  static const String kWeeklyBasePlan = 'energy-pass-weekly';
  static const String kMonthlyBasePlan = 'energy-pass-monthly';
  static const String kYearlyBasePlan = 'energy-pass-yearly';

  /// iOS Product IDs (App Store: 3 separate products)
  static const String kIosWeeklyProductId = 'miro_energy_pass_weekly';
  static const String kIosMonthlyProductId = 'miro_energy_pass_monthly';
  static const String kIosYearlyProductId = 'miro_energy_pass_yearly';

  /// Offer IDs
  static const String kFreeTrialOffer = 'first-month-free';
  static const String kWinbackOffer = 'winback-3usd';

  static SubscriptionPlan energyPassWeekly() {
    return const SubscriptionPlan(
      productId: kProductId,
      basePlanId: kWeeklyBasePlan,
      iosProductId: kIosWeeklyProductId,
      name: 'Energy Pass Weekly',
      description: 'Weekly subscription',
      price: '\$1.99',
      period: 'week',
      benefits: [
        'Unlimited AI Analysis',
        'Exclusive Badge',
        'Priority Support',
      ],
    );
  }

  static SubscriptionPlan energyPassMonthly() {
    return const SubscriptionPlan(
      productId: kProductId,
      basePlanId: kMonthlyBasePlan,
      iosProductId: kIosMonthlyProductId,
      name: 'Energy Pass',
      description: 'Premium subscription with unlimited features',
      price: '\$4.99',
      period: 'month',
      benefits: [
        'Unlimited AI Analysis',
        'Exclusive Badge',
        'Priority Support',
      ],
      isPopular: true,
    );
  }

  static SubscriptionPlan energyPassYearly() {
    return const SubscriptionPlan(
      productId: kProductId,
      basePlanId: kYearlyBasePlan,
      iosProductId: kIosYearlyProductId,
      name: 'Energy Pass Yearly',
      description: 'Best value — save 62%',
      price: '\$39.99',
      period: 'year',
      benefits: [
        'Unlimited AI Analysis',
        'Exclusive Badge',
        'Priority Support',
      ],
      savingsText: 'Save 62% — \$3.33/month',
    );
  }

  /// Get all available plans
  static List<SubscriptionPlan> availablePlans() {
    return [
      energyPassWeekly(),
      energyPassMonthly(),
      energyPassYearly(),
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
