/// Subscription Status Model
/// 
/// Represents the current subscription state from Firestore
enum SubscriptionStatus {
  /// No active subscription
  none,
  
  /// Active subscription with valid payment
  active,
  
  /// Subscription cancelled but still valid until expiry
  cancelled,
  
  /// Subscription expired
  expired,
  
  /// Grace period - payment failed but still has access
  gracePeriod,
}

/// Extension for parsing subscription status
extension SubscriptionStatusExtension on SubscriptionStatus {
  /// Parse from string (from Firestore)
  static SubscriptionStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return SubscriptionStatus.active;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'grace_period':
        return SubscriptionStatus.gracePeriod;
      default:
        return SubscriptionStatus.none;
    }
  }

  /// Convert to string for API/Firestore
  String toApiString() {
    switch (this) {
      case SubscriptionStatus.active:
        return 'active';
      case SubscriptionStatus.cancelled:
        return 'cancelled';
      case SubscriptionStatus.expired:
        return 'expired';
      case SubscriptionStatus.gracePeriod:
        return 'grace_period';
      case SubscriptionStatus.none:
        return 'none';
    }
  }

  /// Check if subscription is currently active
  bool get isActive {
    return this == SubscriptionStatus.active ||
        this == SubscriptionStatus.gracePeriod;
  }

  /// Get display text for UI
  String get displayText {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.gracePeriod:
        return 'Grace Period';
      case SubscriptionStatus.none:
        return 'Not Subscribed';
    }
  }

  /// Get color for status indicator
  String get colorHex {
    switch (this) {
      case SubscriptionStatus.active:
        return '#10B981'; // Green
      case SubscriptionStatus.cancelled:
        return '#F59E0B'; // Yellow
      case SubscriptionStatus.expired:
        return '#EF4444'; // Red
      case SubscriptionStatus.gracePeriod:
        return '#F59E0B'; // Yellow
      case SubscriptionStatus.none:
        return '#6B7280'; // Gray
    }
  }
}
