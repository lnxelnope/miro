import 'package:cloud_firestore/cloud_firestore.dart';
import 'subscription_status.dart';

/// Subscription Data Model
/// 
/// Contains all subscription information for a user
class SubscriptionData {
  final SubscriptionStatus status;
  final String? productId;
  final String? purchaseToken;
  final DateTime? startDate;
  final DateTime? expiryDate;
  final bool autoRenewing;
  final DateTime? lastVerifiedAt;

  const SubscriptionData({
    required this.status,
    this.productId,
    this.purchaseToken,
    this.startDate,
    this.expiryDate,
    this.autoRenewing = false,
    this.lastVerifiedAt,
  });

  /// Empty subscription (not subscribed)
  factory SubscriptionData.empty() {
    return const SubscriptionData(
      status: SubscriptionStatus.none,
    );
  }

  /// Parse from Firestore document
  factory SubscriptionData.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      return SubscriptionData.empty();
    }

    return SubscriptionData(
      status: SubscriptionStatusExtension.fromString(
        data['status'] as String?,
      ),
      productId: data['productId'] as String?,
      purchaseToken: data['purchaseToken'] as String?,
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate(),
      autoRenewing: data['autoRenewing'] as bool? ?? false,
      lastVerifiedAt: (data['lastVerifiedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'status': status.toApiString(),
      'productId': productId,
      'purchaseToken': purchaseToken,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'autoRenewing': autoRenewing,
      'lastVerifiedAt': lastVerifiedAt != null
          ? Timestamp.fromDate(lastVerifiedAt!)
          : null,
    };
  }

  /// Check if subscription is active
  bool get isActive => status.isActive;

  /// Check if subscription will renew
  bool get willRenew => isActive && autoRenewing;

  /// Check if subscription is expiring soon (within 7 days)
  bool get isExpiringSoon {
    if (expiryDate == null || !isActive) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7 && daysUntilExpiry > 0;
  }

  /// Get days until expiry (negative if expired)
  int get daysUntilExpiry {
    if (expiryDate == null) return 0;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// Get formatted expiry date
  String get formattedExpiryDate {
    if (expiryDate == null) return 'N/A';
    return '${expiryDate!.day}/${expiryDate!.month}/${expiryDate!.year}';
  }

  /// Copy with
  SubscriptionData copyWith({
    SubscriptionStatus? status,
    String? productId,
    String? purchaseToken,
    DateTime? startDate,
    DateTime? expiryDate,
    bool? autoRenewing,
    DateTime? lastVerifiedAt,
  }) {
    return SubscriptionData(
      status: status ?? this.status,
      productId: productId ?? this.productId,
      purchaseToken: purchaseToken ?? this.purchaseToken,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      autoRenewing: autoRenewing ?? this.autoRenewing,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
    );
  }

  @override
  String toString() {
    return 'SubscriptionData(status: $status, productId: $productId, '
        'expiryDate: $expiryDate, autoRenewing: $autoRenewing)';
  }
}
