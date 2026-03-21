import 'package:cloud_firestore/cloud_firestore.dart';

/// Freepass Data Model
///
/// Freepass = วันที่แลกจาก energy, ไม่มีวันหมดอายุจนกว่าจะใช้
/// Auto-activate หลัง Energy Pass (subscription) หมดอายุ
///
/// Exchange rate: 50 energy = 1 day
/// อัตรานี้ทำให้ Energy Pass คุ้มค่ากว่าเสมอ:
///   - Ultimate Saver $9.99/2000E → 40 days → $0.25/day
///   - Yearly Pass → $0.11/day (ถูกกว่า 2.3x)
class FreepassData {
  final int totalDays;
  final bool isActive;
  final DateTime? activatedAt;
  final DateTime? currentPeriodEnd;
  final String? lastDeductedDate;

  static const int energyPerDay = 50;
  static const int minDays = 1;
  static const int maxDaysPerConversion = 60;

  const FreepassData({
    this.totalDays = 0,
    this.isActive = false,
    this.activatedAt,
    this.currentPeriodEnd,
    this.lastDeductedDate,
  });

  factory FreepassData.empty() {
    return const FreepassData();
  }

  factory FreepassData.fromFirestore(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return FreepassData.empty();

    return FreepassData(
      totalDays: (data['totalDays'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] == true,
      activatedAt: _parseDateTime(data['activatedAt']),
      currentPeriodEnd: _parseDateTime(data['currentPeriodEnd']),
      lastDeductedDate: data['lastDeductedDate']?.toString(),
    );
  }

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

  bool get hasDays => totalDays > 0;

  int get remainingActiveDays {
    if (!isActive || currentPeriodEnd == null) return 0;
    final days = currentPeriodEnd!.difference(DateTime.now()).inDays;
    return days > 0 ? days : 0;
  }

  /// Energy cost to convert to given number of days
  static int energyCost(int days) => days * energyPerDay;

  FreepassData copyWith({
    int? totalDays,
    bool? isActive,
    DateTime? activatedAt,
    DateTime? currentPeriodEnd,
    String? lastDeductedDate,
  }) {
    return FreepassData(
      totalDays: totalDays ?? this.totalDays,
      isActive: isActive ?? this.isActive,
      activatedAt: activatedAt ?? this.activatedAt,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      lastDeductedDate: lastDeductedDate ?? this.lastDeductedDate,
    );
  }

  @override
  String toString() {
    return 'FreepassData(totalDays: $totalDays, isActive: $isActive, '
        'remainingActive: $remainingActiveDays)';
  }
}
