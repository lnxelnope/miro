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

  /// Parse from Firestore document or Cloud Function response
  /// Handles both Timestamp objects (Firestore) and serialized formats
  factory SubscriptionData.fromFirestore(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return SubscriptionData.empty();
    }

    return SubscriptionData(
      status: SubscriptionStatusExtension.fromString(
        data['status']?.toString(),
      ),
      productId: data['productId']?.toString(),
      purchaseToken: data['purchaseToken']?.toString(),
      startDate: _parseDateTime(data['startDate']),
      expiryDate: _parseDateTime(data['expiryDate']),
      autoRenewing: data['autoRenewing'] == true,
      lastVerifiedAt: _parseDateTime(data['lastVerifiedAt']),
    );
  }

  /// Safely parse DateTime from various formats:
  /// - Firestore Timestamp object
  /// - ISO 8601 string
  /// - Serialized map {_seconds, _nanoseconds}
  /// - millisecondsSinceEpoch int
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is Map) {
      final seconds = value['_seconds'] ?? value['seconds'];
      if (seconds is num) {
        return DateTime.fromMillisecondsSinceEpoch(seconds.toInt() * 1000);
      }
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
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
  /// Includes cancelled-but-not-expired (user still has access until expiry)
  bool get isActive {
    if (status.isActive) return true;
    if (status == SubscriptionStatus.cancelled &&
        expiryDate != null &&
        expiryDate!.isAfter(DateTime.now())) {
      return true;
    }
    return false;
  }

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
