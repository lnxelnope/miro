import 'package:isar/isar.dart';

part 'energy_transaction.g.dart';

/// Model สำหรับเก็บประวัติการใช้ Energy
@collection
class EnergyTransaction {
  Id id = Isar.autoIncrement;

  /// ประเภทของ transaction
  /// 'welcome_gift', 'purchase', 'usage', 'refund', 'pro_migration', 'welcome_offer', 'beta_tester_reward'
  late String type;

  /// จำนวน Energy ที่เปลี่ยนแปลง (+100, -1, +550, ...)
  late int amount;

  /// ยอด Energy คงเหลือหลังจาก transaction นี้
  late int balanceAfter;

  /// Package ID (optional) — เช่น 'energy_100', 'energy_550_welcome'
  String? packageId;

  /// คำอธิบาย (optional) — เช่น 'Food image analysis', 'Purchased Value Pack'
  String? description;

  /// Google Play purchase token (optional) — ใช้สำหรับ verify การซื้อ
  String? purchaseToken;

  /// Device ID (optional) — ใช้สำหรับ track welcome gift
  String? deviceId;

  /// เวลาที่ทำ transaction
  @Index()
  DateTime timestamp = DateTime.now();

  /// Constructor
  EnergyTransaction({
    this.id = Isar.autoIncrement,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.packageId,
    this.description,
    this.purchaseToken,
    this.deviceId,
  });
}
