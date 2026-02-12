# Step 17: Finance Assets Tracking

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 3-4 ชั่วโมง
> **ความยาก:** ยาก
> **ต้องทำก่อน:** Step 16 (Health Workout)

---

## 🎯 เป้าหมาย

- ติดตามสินทรัพย์: หุ้น, กองทุน, Crypto, ทองคำ
- ดึงราคาล่าสุดอัตโนมัติ
- แสดง portfolio รวม
- คำนวณกำไร/ขาดทุน

---

## สิ่งที่ต้องทำ

1. ตรวจสอบ Asset Model
2. สร้าง Asset Holdings Model
3. สร้าง Price Service
4. สร้าง Assets Provider
5. สร้าง Assets Tab UI
6. สร้าง Add Asset Screen
7. ทดสอบ

---

## ขั้นตอนที่ 1: ตรวจสอบ/อัปเดต Asset Model

**ตรวจสอบ/แก้ไขไฟล์:** `lib/features/finance/models/asset.dart`

```dart
import 'package:isar/isar.dart';

part 'asset.g.dart';

@collection
class Asset {
  Id id = Isar.autoIncrement;

  /// ชื่อสินทรัพย์ เช่น "AAPL", "BTC", "ทองคำ"
  late String symbol;

  /// ชื่อเต็ม เช่น "Apple Inc.", "Bitcoin"
  String? name;

  @enumerated
  AssetType type = AssetType.stock;

  @enumerated
  AssetCurrency currency = AssetCurrency.thb;

  /// จำนวนที่ถือครอง
  double quantity = 0;

  /// ต้นทุนเฉลี่ยต่อหน่วย
  double averageCost = 0;

  /// ราคาปัจจุบัน (จาก API)
  double? currentPrice;

  /// อัปเดตราคาล่าสุดเมื่อ
  DateTime? priceUpdatedAt;

  /// หมายเหตุ
  String? notes;

  bool isArchived = false;

  late DateTime createdAt;
  DateTime? updatedAt;

  // ============================================
  // COMPUTED PROPERTIES
  // ============================================

  /// มูลค่าที่ถือครอง
  @ignore
  double get marketValue => quantity * (currentPrice ?? averageCost);

  /// ต้นทุนรวม
  @ignore
  double get totalCost => quantity * averageCost;

  /// กำไร/ขาดทุน
  @ignore
  double get profitLoss => marketValue - totalCost;

  /// % กำไร/ขาดทุน
  @ignore
  double get profitLossPercent {
    if (totalCost == 0) return 0;
    return (profitLoss / totalCost) * 100;
  }

  /// สีตาม profit/loss
  @ignore
  bool get isProfit => profitLoss >= 0;
}

enum AssetType {
  stock,      // หุ้น
  mutualFund, // กองทุนรวม
  crypto,     // Cryptocurrency
  gold,       // ทองคำ
  bond,       // พันธบัตร
  property,   // อสังหาริมทรัพย์
  cash,       // เงินสด
  other,      // อื่นๆ
}

extension AssetTypeExtension on AssetType {
  String get displayName {
    switch (this) {
      case AssetType.stock: return 'หุ้น';
      case AssetType.mutualFund: return 'กองทุน';
      case AssetType.crypto: return 'Crypto';
      case AssetType.gold: return 'ทองคำ';
      case AssetType.bond: return 'พันธบัตร';
      case AssetType.property: return 'อสังหา';
      case AssetType.cash: return 'เงินสด';
      case AssetType.other: return 'อื่นๆ';
    }
  }

  String get emoji {
    switch (this) {
      case AssetType.stock: return '📈';
      case AssetType.mutualFund: return '📊';
      case AssetType.crypto: return '₿';
      case AssetType.gold: return '🥇';
      case AssetType.bond: return '📜';
      case AssetType.property: return '🏠';
      case AssetType.cash: return '💵';
      case AssetType.other: return '📦';
    }
  }
}

enum AssetCurrency {
  thb,
  usd,
  btc,
}

extension AssetCurrencyExtension on AssetCurrency {
  String get symbol {
    switch (this) {
      case AssetCurrency.thb: return '฿';
      case AssetCurrency.usd: return '\$';
      case AssetCurrency.btc: return '₿';
    }
  }
}
```

---

## ขั้นตอนที่ 2: สร้าง Asset Transaction Model

**สร้างไฟล์:** `lib/features/finance/models/asset_transaction.dart`

```dart
import 'package:isar/isar.dart';

part 'asset_transaction.g.dart';

/// บันทึกการซื้อ/ขายสินทรัพย์
@collection
class AssetTransaction {
  Id id = Isar.autoIncrement;

  late int assetId;

  @enumerated
  AssetTransactionType type = AssetTransactionType.buy;

  /// จำนวน
  double quantity = 0;

  /// ราคาต่อหน่วย
  double pricePerUnit = 0;

  /// ค่าธรรมเนียม
  double fee = 0;

  /// หมายเหตุ
  String? notes;

  late DateTime date;
  late DateTime createdAt;

  /// มูลค่ารวม (quantity * price + fee)
  @ignore
  double get totalValue {
    final value = quantity * pricePerUnit;
    if (type == AssetTransactionType.buy) {
      return value + fee;
    } else {
      return value - fee;
    }
  }
}

enum AssetTransactionType {
  buy,      // ซื้อ
  sell,     // ขาย
  dividend, // ปันผล
  transfer, // โอน
}

extension AssetTransactionTypeExtension on AssetTransactionType {
  String get displayName {
    switch (this) {
      case AssetTransactionType.buy: return 'ซื้อ';
      case AssetTransactionType.sell: return 'ขาย';
      case AssetTransactionType.dividend: return 'ปันผล';
      case AssetTransactionType.transfer: return 'โอน';
    }
  }
}
```

---

## ขั้นตอนที่ 3: อัปเดต Database Service

**แก้ไขไฟล์:** `lib/core/database/database_service.dart`

**เพิ่ม imports:**

```dart
import '../../features/finance/models/asset.dart';
import '../../features/finance/models/asset_transaction.dart';
```

**เพิ่มใน schemas (ถ้ายังไม่มี):**

```dart
AssetSchema,
AssetTransactionSchema,
```

**เพิ่ม getters:**

```dart
static IsarCollection<Asset> get assets => _isar!.assets;
static IsarCollection<AssetTransaction> get assetTransactions => _isar!.assetTransactions;
```

---

## ขั้นตอนที่ 4: รัน Build Runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## ขั้นตอนที่ 5: สร้าง Price Service

**สร้างไฟล์:** `lib/core/services/price_service.dart`

```dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../features/finance/models/asset.dart';

/// Service สำหรับดึงราคาสินทรัพย์
class PriceService {
  // ============================================
  // STOCK PRICES (Thai stocks from SET)
  // ============================================

  /// ดึงราคาหุ้นไทย (mock data - ใช้ API จริงต้องสมัคร)
  static Future<double?> getThaiStockPrice(String symbol) async {
    // TODO: ใช้ API จริง เช่น SETTRADE, Alpha Vantage
    // นี่เป็น mock data
    
    final mockPrices = {
      'PTT': 32.50,
      'ADVANC': 198.00,
      'CPALL': 62.75,
      'SCB': 95.25,
      'KBANK': 132.00,
      'BTS': 6.85,
      'AOT': 58.50,
      'TRUE': 9.20,
      'DELTA': 680.00,
      'GULF': 42.00,
    };

    return mockPrices[symbol.toUpperCase()];
  }

  // ============================================
  // US STOCK PRICES
  // ============================================

  /// ดึงราคาหุ้น US (ใช้ free API)
  static Future<double?> getUSStockPrice(String symbol) async {
    try {
      // ใช้ Yahoo Finance API (unofficial)
      final url = Uri.parse(
        'https://query1.finance.yahoo.com/v8/finance/chart/$symbol'
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['chart']['result'];
        if (result != null && result.isNotEmpty) {
          final price = result[0]['meta']['regularMarketPrice'];
          return price?.toDouble();
        }
      }
    } catch (e) {
      debugPrint('Error fetching US stock price: $e');
    }

    return null;
  }

  // ============================================
  // CRYPTO PRICES
  // ============================================

  /// ดึงราคา Crypto (ใช้ CoinGecko free API)
  static Future<double?> getCryptoPrice(String symbol, {String currency = 'thb'}) async {
    try {
      // Map common symbols to CoinGecko IDs
      final coinIds = {
        'BTC': 'bitcoin',
        'ETH': 'ethereum',
        'BNB': 'binancecoin',
        'XRP': 'ripple',
        'ADA': 'cardano',
        'SOL': 'solana',
        'DOGE': 'dogecoin',
        'DOT': 'polkadot',
        'MATIC': 'matic-network',
        'LINK': 'chainlink',
      };

      final coinId = coinIds[symbol.toUpperCase()];
      if (coinId == null) return null;

      final url = Uri.parse(
        'https://api.coingecko.com/api/v3/simple/price?ids=$coinId&vs_currencies=$currency'
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data[coinId]?[currency]?.toDouble();
      }
    } catch (e) {
      debugPrint('Error fetching crypto price: $e');
    }

    return null;
  }

  // ============================================
  // GOLD PRICE
  // ============================================

  /// ดึงราคาทองคำ (ใช้ API หรือ mock)
  static Future<double?> getGoldPrice() async {
    try {
      // Gold API (ต้องสมัคร API key)
      // นี่เป็น mock data - ราคาทองคำไทยต่อบาท
      return 32500.0; // บาทละ 32,500
    } catch (e) {
      debugPrint('Error fetching gold price: $e');
    }

    return null;
  }

  // ============================================
  // MUTUAL FUND (Thai)
  // ============================================

  /// ดึงราคา NAV กองทุน (mock)
  static Future<double?> getMutualFundNav(String symbol) async {
    // TODO: ใช้ API จริงจาก FinNet หรือ Morningstar
    
    final mockNavs = {
      'KFLTFDIV': 15.4532,
      'TMBGQG': 12.8765,
      'KTAM-RMF': 28.4321,
      'B-BHARATA': 8.9012,
      'SCBSE': 45.6789,
    };

    return mockNavs[symbol.toUpperCase()];
  }

  // ============================================
  // AUTO PRICE UPDATE
  // ============================================

  /// อัปเดตราคาสินทรัพย์ตามประเภท
  static Future<double?> getPrice(Asset asset) async {
    switch (asset.type) {
      case AssetType.stock:
        // ตรวจสอบว่าเป็นหุ้นไทยหรือ US
        if (asset.currency == AssetCurrency.thb) {
          return await getThaiStockPrice(asset.symbol);
        } else {
          return await getUSStockPrice(asset.symbol);
        }

      case AssetType.crypto:
        final currency = asset.currency == AssetCurrency.usd ? 'usd' : 'thb';
        return await getCryptoPrice(asset.symbol, currency: currency);

      case AssetType.gold:
        return await getGoldPrice();

      case AssetType.mutualFund:
        return await getMutualFundNav(asset.symbol);

      default:
        return null;
    }
  }
}
```

---

## ขั้นตอนที่ 6: สร้าง Assets Provider

**สร้างไฟล์:** `lib/features/finance/providers/assets_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../../../core/services/price_service.dart';
import '../models/asset.dart';
import '../models/asset_transaction.dart';

// ============================================
// ASSETS PROVIDERS
// ============================================

/// Provider สำหรับ Assets ทั้งหมด
final assetsProvider = FutureProvider<List<Asset>>((ref) async {
  return await DatabaseService.assets
      .filter()
      .isArchivedEqualTo(false)
      .sortByCreatedAtDesc()
      .findAll();
});

/// Provider สำหรับ Portfolio Summary
final portfolioSummaryProvider = FutureProvider<PortfolioSummary>((ref) async {
  final assets = await ref.watch(assetsProvider.future);

  double totalValue = 0;
  double totalCost = 0;

  for (final asset in assets) {
    totalValue += asset.marketValue;
    totalCost += asset.totalCost;
  }

  final profitLoss = totalValue - totalCost;
  final profitLossPercent = totalCost > 0 ? (profitLoss / totalCost) * 100 : 0;

  // Group by type
  final byType = <AssetType, double>{};
  for (final asset in assets) {
    byType[asset.type] = (byType[asset.type] ?? 0) + asset.marketValue;
  }

  return PortfolioSummary(
    totalValue: totalValue,
    totalCost: totalCost,
    profitLoss: profitLoss,
    profitLossPercent: profitLossPercent,
    assetCount: assets.length,
    byType: byType,
  );
});

class PortfolioSummary {
  final double totalValue;
  final double totalCost;
  final double profitLoss;
  final double profitLossPercent;
  final int assetCount;
  final Map<AssetType, double> byType;

  PortfolioSummary({
    required this.totalValue,
    required this.totalCost,
    required this.profitLoss,
    required this.profitLossPercent,
    required this.assetCount,
    required this.byType,
  });

  bool get isProfit => profitLoss >= 0;
}

/// Provider สำหรับ Transactions ของ Asset
final assetTransactionsProvider = FutureProvider.family<List<AssetTransaction>, int>((ref, assetId) async {
  return await DatabaseService.assetTransactions
      .filter()
      .assetIdEqualTo(assetId)
      .sortByDateDesc()
      .findAll();
});

// ============================================
// ASSETS NOTIFIER
// ============================================

class AssetsNotifier extends StateNotifier<AsyncValue<List<Asset>>> {
  final Ref ref;

  AssetsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadAssets();
  }

  Future<void> loadAssets() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(assetsProvider.future);
    });
  }

  /// เพิ่ม Asset ใหม่
  Future<Asset> addAsset({
    required String symbol,
    String? name,
    required AssetType type,
    AssetCurrency currency = AssetCurrency.thb,
  }) async {
    final asset = Asset()
      ..symbol = symbol.toUpperCase()
      ..name = name
      ..type = type
      ..currency = currency
      ..createdAt = DateTime.now();

    // ลองดึงราคาปัจจุบัน
    final price = await PriceService.getPrice(asset);
    if (price != null) {
      asset.currentPrice = price;
      asset.priceUpdatedAt = DateTime.now();
    }

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.assets.put(asset);
    });

    await loadAssets();
    ref.invalidate(portfolioSummaryProvider);

    return asset;
  }

  /// บันทึกการซื้อ
  Future<void> buyAsset({
    required int assetId,
    required double quantity,
    required double pricePerUnit,
    double fee = 0,
    String? notes,
    DateTime? date,
  }) async {
    await DatabaseService.isar.writeTxn(() async {
      // บันทึก transaction
      final txn = AssetTransaction()
        ..assetId = assetId
        ..type = AssetTransactionType.buy
        ..quantity = quantity
        ..pricePerUnit = pricePerUnit
        ..fee = fee
        ..notes = notes
        ..date = date ?? DateTime.now()
        ..createdAt = DateTime.now();

      await DatabaseService.assetTransactions.put(txn);

      // อัปเดต Asset
      final asset = await DatabaseService.assets.get(assetId);
      if (asset != null) {
        // คำนวณ average cost ใหม่
        final oldTotalCost = asset.quantity * asset.averageCost;
        final newCost = quantity * pricePerUnit;
        final newTotalQuantity = asset.quantity + quantity;

        if (newTotalQuantity > 0) {
          asset.averageCost = (oldTotalCost + newCost) / newTotalQuantity;
        }
        asset.quantity = newTotalQuantity;
        asset.updatedAt = DateTime.now();

        await DatabaseService.assets.put(asset);
      }
    });

    await loadAssets();
    ref.invalidate(portfolioSummaryProvider);
  }

  /// บันทึกการขาย
  Future<void> sellAsset({
    required int assetId,
    required double quantity,
    required double pricePerUnit,
    double fee = 0,
    String? notes,
    DateTime? date,
  }) async {
    await DatabaseService.isar.writeTxn(() async {
      // บันทึก transaction
      final txn = AssetTransaction()
        ..assetId = assetId
        ..type = AssetTransactionType.sell
        ..quantity = quantity
        ..pricePerUnit = pricePerUnit
        ..fee = fee
        ..notes = notes
        ..date = date ?? DateTime.now()
        ..createdAt = DateTime.now();

      await DatabaseService.assetTransactions.put(txn);

      // อัปเดต Asset
      final asset = await DatabaseService.assets.get(assetId);
      if (asset != null) {
        asset.quantity -= quantity;
        if (asset.quantity < 0) asset.quantity = 0;
        asset.updatedAt = DateTime.now();

        await DatabaseService.assets.put(asset);
      }
    });

    await loadAssets();
    ref.invalidate(portfolioSummaryProvider);
  }

  /// อัปเดตราคา
  Future<void> refreshPrices() async {
    final assets = state.valueOrNull;
    if (assets == null) return;

    await DatabaseService.isar.writeTxn(() async {
      for (final asset in assets) {
        final price = await PriceService.getPrice(asset);
        if (price != null) {
          asset.currentPrice = price;
          asset.priceUpdatedAt = DateTime.now();
          await DatabaseService.assets.put(asset);
        }
      }
    });

    await loadAssets();
    ref.invalidate(portfolioSummaryProvider);
  }

  /// ลบ Asset
  Future<void> deleteAsset(int assetId) async {
    await DatabaseService.isar.writeTxn(() async {
      // ลบ transactions
      await DatabaseService.assetTransactions
          .filter()
          .assetIdEqualTo(assetId)
          .deleteAll();
      // ลบ asset
      await DatabaseService.assets.delete(assetId);
    });

    await loadAssets();
    ref.invalidate(portfolioSummaryProvider);
  }
}

final assetsNotifierProvider =
    StateNotifierProvider<AssetsNotifier, AsyncValue<List<Asset>>>((ref) {
  return AssetsNotifier(ref);
});
```

---

## ขั้นตอนที่ 7: สร้าง Assets Tab UI

**สร้างไฟล์:** `lib/features/finance/presentation/finance_assets_tab.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/assets_provider.dart';
import '../models/asset.dart';

class FinanceAssetsTab extends ConsumerWidget {
  const FinanceAssetsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(assetsNotifierProvider);
    final summaryAsync = ref.watch(portfolioSummaryProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(assetsNotifierProvider.notifier).refreshPrices(),
      child: CustomScrollView(
        slivers: [
          // Portfolio Summary
          SliverToBoxAdapter(
            child: summaryAsync.when(
              loading: () => const SizedBox(height: 150),
              error: (e, _) => Text('Error: $e'),
              data: (summary) => _buildPortfolioSummary(summary),
            ),
          ),

          // Add Asset Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () => _showAddAssetDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('เพิ่มสินทรัพย์'),
              ),
            ),
          ),

          // Assets List
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  const Text(
                    '📊 สินทรัพย์',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () =>
                        ref.read(assetsNotifierProvider.notifier).refreshPrices(),
                    tooltip: 'อัปเดตราคา',
                  ),
                ],
              ),
            ),
          ),
          assetsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e')),
            data: (assets) {
              if (assets.isEmpty) {
                return SliverToBoxAdapter(
                  child: _buildEmptyState(context, ref),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildAssetCard(context, ref, assets[index]),
                  childCount: assets.length,
                ),
              );
            },
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSummary(PortfolioSummary summary) {
    final formatter = NumberFormat('#,##0.00', 'th');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: summary.isProfit
              ? [Colors.green.shade700, Colors.green.shade500]
              : [Colors.red.shade700, Colors.red.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Portfolio',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '฿${formatter.format(summary.totalValue)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                summary.isProfit ? Icons.trending_up : Icons.trending_down,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${summary.isProfit ? '+' : ''}฿${formatter.format(summary.profitLoss)} (${summary.profitLossPercent.toStringAsFixed(2)}%)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${summary.assetCount} สินทรัพย์',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard(BuildContext context, WidgetRef ref, Asset asset) {
    final formatter = NumberFormat('#,##0.00', 'th');
    final qtyFormatter = NumberFormat('#,##0.####', 'th');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: InkWell(
          onTap: () => _showAssetDetail(context, ref, asset),
          onLongPress: () => _showAssetOptions(context, ref, asset),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                CircleAvatar(
                  backgroundColor: asset.isProfit
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  child: Text(
                    asset.type.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            asset.symbol,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              asset.type.displayName,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${qtyFormatter.format(asset.quantity)} หน่วย @ ${asset.currency.symbol}${formatter.format(asset.currentPrice ?? asset.averageCost)}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Value & P/L
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '฿${formatter.format(asset.marketValue)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          asset.isProfit
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: asset.isProfit ? Colors.green : Colors.red,
                          size: 12,
                        ),
                        Text(
                          '${asset.profitLossPercent.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: asset.isProfit ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text('📊', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'ยังไม่มีสินทรัพย์',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'เพิ่มหุ้น, กองทุน, Crypto หรือทองคำ\nเพื่อติดตาม portfolio ของคุณ',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('เพิ่มสินทรัพย์แรก'),
            onPressed: () => _showAddAssetDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showAddAssetDialog(BuildContext context, WidgetRef ref) {
    final symbolController = TextEditingController();
    final nameController = TextEditingController();
    AssetType selectedType = AssetType.stock;
    AssetCurrency selectedCurrency = AssetCurrency.thb;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '➕ เพิ่มสินทรัพย์',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Type
                DropdownButtonFormField<AssetType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'ประเภท',
                    border: OutlineInputBorder(),
                  ),
                  items: AssetType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text('${t.emoji} ${t.displayName}'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedType = v);
                  },
                ),
                const SizedBox(height: 16),

                // Symbol
                TextField(
                  controller: symbolController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Symbol',
                    hintText: _getSymbolHint(selectedType),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Name (optional)
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อ (optional)',
                    hintText: 'เช่น Apple Inc.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Currency
                DropdownButtonFormField<AssetCurrency>(
                  value: selectedCurrency,
                  decoration: const InputDecoration(
                    labelText: 'สกุลเงิน',
                    border: OutlineInputBorder(),
                  ),
                  items: AssetCurrency.values.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text('${c.symbol} ${c.name.toUpperCase()}'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedCurrency = v);
                  },
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('ยกเลิก'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (symbolController.text.trim().isEmpty) return;

                          await ref.read(assetsNotifierProvider.notifier).addAsset(
                                symbol: symbolController.text.trim(),
                                name: nameController.text.trim().isEmpty
                                    ? null
                                    : nameController.text.trim(),
                                type: selectedType,
                                currency: selectedCurrency,
                              );

                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('เพิ่ม'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSymbolHint(AssetType type) {
    switch (type) {
      case AssetType.stock:
        return 'เช่น PTT, AAPL';
      case AssetType.crypto:
        return 'เช่น BTC, ETH';
      case AssetType.gold:
        return 'GOLD';
      case AssetType.mutualFund:
        return 'เช่น KFLTFDIV';
      default:
        return 'Symbol';
    }
  }

  void _showAssetDetail(BuildContext context, WidgetRef ref, Asset asset) {
    final formatter = NumberFormat('#,##0.00', 'th');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(asset.type.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.symbol,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (asset.name != null)
                      Text(
                        asset.name!,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),

            _buildDetailRow('ประเภท', asset.type.displayName),
            _buildDetailRow('จำนวน', '${asset.quantity}'),
            _buildDetailRow('ต้นทุนเฉลี่ย', '${asset.currency.symbol}${formatter.format(asset.averageCost)}'),
            _buildDetailRow('ราคาปัจจุบัน', '${asset.currency.symbol}${formatter.format(asset.currentPrice ?? 0)}'),
            _buildDetailRow('มูลค่ารวม', '฿${formatter.format(asset.marketValue)}'),
            _buildDetailRow('ต้นทุนรวม', '฿${formatter.format(asset.totalCost)}'),
            _buildDetailRow(
              'กำไร/ขาดทุน',
              '${asset.isProfit ? '+' : ''}฿${formatter.format(asset.profitLoss)} (${asset.profitLossPercent.toStringAsFixed(2)}%)',
              valueColor: asset.isProfit ? Colors.green : Colors.red,
            ),

            if (asset.priceUpdatedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'อัปเดตราคา: ${DateFormat('dd/MM HH:mm').format(asset.priceUpdatedAt!)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showBuySellDialog(context, ref, asset, isBuy: true);
                    },
                    child: const Text('ซื้อเพิ่ม'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: asset.quantity > 0
                        ? () {
                            Navigator.pop(context);
                            _showBuySellDialog(context, ref, asset, isBuy: false);
                          }
                        : null,
                    child: const Text('ขาย'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showBuySellDialog(BuildContext context, WidgetRef ref, Asset asset, {required bool isBuy}) {
    final quantityController = TextEditingController();
    final priceController = TextEditingController(
      text: (asset.currentPrice ?? asset.averageCost).toString(),
    );
    final feeController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBuy ? '🛒 ซื้อ ${asset.symbol}' : '💰 ขาย ${asset.symbol}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'จำนวน',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'ราคาต่อหน่วย (${asset.currency.symbol})',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: feeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ค่าธรรมเนียม',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = double.tryParse(quantityController.text);
              final price = double.tryParse(priceController.text);
              final fee = double.tryParse(feeController.text) ?? 0;

              if (quantity == null || quantity <= 0) return;
              if (price == null || price <= 0) return;

              if (isBuy) {
                await ref.read(assetsNotifierProvider.notifier).buyAsset(
                      assetId: asset.id,
                      quantity: quantity,
                      pricePerUnit: price,
                      fee: fee,
                    );
              } else {
                if (quantity > asset.quantity) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('จำนวนเกินที่มี')),
                  );
                  return;
                }
                await ref.read(assetsNotifierProvider.notifier).sellAsset(
                      assetId: asset.id,
                      quantity: quantity,
                      pricePerUnit: price,
                      fee: fee,
                    );
              }

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isBuy ? 'ซื้อสำเร็จ!' : 'ขายสำเร็จ!')),
                );
              }
            },
            child: Text(isBuy ? 'ซื้อ' : 'ขาย'),
          ),
        ],
      ),
    );
  }

  void _showAssetOptions(BuildContext context, WidgetRef ref, Asset asset) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('อัปเดตราคา'),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(assetsNotifierProvider.notifier).refreshPrices();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('อัปเดตราคาแล้ว')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('ลบ', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref, asset);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Asset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบสินทรัพย์?'),
        content: Text('ลบ ${asset.symbol} และประวัติทั้งหมด?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(assetsNotifierProvider.notifier).deleteAsset(asset.id);
              Navigator.pop(context);
            },
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 8: อัปเดต Finance Page

**แก้ไขไฟล์:** `lib/features/finance/presentation/finance_page.dart`

**เพิ่ม import และ tab:**

```dart
import 'finance_assets_tab.dart';

// แก้ไข TabBar และ TabBarView ให้มี 3 tabs
TabBar(
  controller: _tabController,
  tabs: const [
    Tab(text: 'Timeline'),
    Tab(text: 'Assets'),  // เพิ่ม
    // ... อื่นๆ
  ],
),

// TabBarView
children: [
  const FinanceTimelineTab(),
  const FinanceAssetsTab(),  // เพิ่ม
  // ... อื่นๆ
],
```

**ตัวอย่างไฟล์เต็ม:**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'finance_timeline_tab.dart';
import 'finance_assets_tab.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.finance,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.finance,
            tabs: const [
              Tab(text: 'Timeline'),
              Tab(text: 'Assets'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              FinanceTimelineTab(),
              FinanceAssetsTab(),
            ],
          ),
        ),
      ],
    );
  }
}
```

---

## ขั้นตอนที่ 9: ทดสอบ

```bash
flutter run
```

### ทดสอบ:

1. **Finance → Assets tab**
2. **เพิ่มสินทรัพย์** - เช่น BTC, PTT
3. **บันทึกการซื้อ** - กด Asset > ซื้อเพิ่ม
4. **ดู Portfolio** - ดูมูลค่ารวม, กำไร/ขาดทุน
5. **Refresh ราคา** - กด refresh ดึงราคาใหม่

---

## ✅ Checklist

- [ ] อัปเดต `asset.dart` model แล้ว
- [ ] สร้าง `asset_transaction.dart` model แล้ว
- [ ] อัปเดต DatabaseService แล้ว
- [ ] รัน build_runner แล้ว
- [ ] สร้าง `price_service.dart` แล้ว
- [ ] สร้าง `assets_provider.dart` แล้ว
- [ ] สร้าง `finance_assets_tab.dart` แล้ว
- [ ] อัปเดต `finance_page.dart` แล้ว
- [ ] ทดสอบเพิ่ม Asset ได้
- [ ] ทดสอบซื้อ/ขายได้
- [ ] ทดสอบ Portfolio แสดงถูกต้อง

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/
├── core/
│   ├── database/
│   │   └── database_service.dart   ← UPDATED
│   └── services/
│       └── price_service.dart      ← NEW
└── features/finance/
    ├── models/
    │   ├── asset.dart              ← UPDATED
    │   ├── asset.g.dart            ← GENERATED
    │   ├── asset_transaction.dart  ← NEW
    │   └── asset_transaction.g.dart ← GENERATED
    ├── providers/
    │   └── assets_provider.dart    ← NEW
    └── presentation/
        ├── finance_page.dart       ← UPDATED
        └── finance_assets_tab.dart ← NEW
```

---

## 🎉 Congratulations!

คุณได้ทำ Implementation Guides ครบทั้ง 17 Steps แล้ว! 

**สรุปสิ่งที่ทำได้:**
- ✅ Foundation (Setup, Models, Navigation)
- ✅ Health (Timeline, Diet, Food AI, Workout)
- ✅ Finance (Timeline, Transactions, Assets)
- ✅ Tasks (Today, Calendar, Lists, Habits)
- ✅ Chat + AI Integration
- ✅ Google Calendar Sync

**Next Steps (Optional):**
- เพิ่ม AI ที่ฉลาดขึ้น (ใช้ Gemini Pro)
- เพิ่ม Notifications/Reminders
- เพิ่ม Data Export/Backup
- เพิ่ม Widgets สำหรับ Home Screen
- เพิ่ม Dark Mode toggle
