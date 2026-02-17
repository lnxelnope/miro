/// Subscription Plan Model
/// 
/// Represents available subscription plans
class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final String price;
  final String period;
  final List<String> benefits;
  final bool isPopular;
  final String? trialPeriod;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.period,
    required this.benefits,
    this.isPopular = false,
    this.trialPeriod,
  });

  /// Energy Pass Monthly Plan
  static SubscriptionPlan energyPassMonthly() {
    return const SubscriptionPlan(
      id: 'energy_pass_monthly',
      name: 'Energy Pass',
      description: 'Premium subscription with unlimited features',
      price: '฿149',
      period: 'month',
      benefits: [
        'Unlimited AI Analysis',
        'Double Streak Rewards',
        'Exclusive Badge',
        'Priority Support',
      ],
      isPopular: true,
      trialPeriod: null, // No trial for now
    );
  }

  /// Get all available plans
  static List<SubscriptionPlan> availablePlans() {
    return [
      energyPassMonthly(),
      // Add more plans here if needed (e.g., yearly)
    ];
  }

  /// Get display price with period
  String get displayPrice => '$price / $period';

  /// Get full price text
  String get fullPriceText {
    if (trialPeriod != null) {
      return '$displayPrice after $trialPeriod trial';
    }
    return displayPrice;
  }

  @override
  String toString() {
    return 'SubscriptionPlan(id: $id, name: $name, price: $displayPrice)';
  }
}
