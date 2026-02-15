import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/core/services/welcome_offer_service.dart';
import 'package:miro_hybrid/core/services/purchase_service.dart';
import 'package:miro_hybrid/features/energy/providers/energy_provider.dart';
import 'package:miro_hybrid/features/energy/widgets/welcome_offer_progress.dart';

/// Energy Store - Purchase Energy packages
class EnergyStoreScreen extends ConsumerStatefulWidget {
  const EnergyStoreScreen({super.key});

  @override
  ConsumerState<EnergyStoreScreen> createState() => _EnergyStoreScreenState();
}

class _EnergyStoreScreenState extends ConsumerState<EnergyStoreScreen> {
  WelcomeOfferStatus _offerStatus = WelcomeOfferStatus.notStarted;
  Duration? _remainingTime;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final status = await WelcomeOfferService.getStatus();
    final remaining = await WelcomeOfferService.getRemainingTime();
    
    if (mounted) {
      setState(() {
        _offerStatus = status;
        _remainingTime = remaining;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ใช้ currentEnergyProvider เพื่อ force refresh
    final energyAsync = ref.watch(currentEnergyProvider);
    
    return energyAsync.when(
      data: (balance) => _buildScaffold(context, balance),
      loading: () => _buildScaffold(context, 0),
      error: (_, __) => _buildScaffold(context, 0),
    );
  }
  
  Widget _buildScaffold(BuildContext context, int balance) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡ Energy Store'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '⚡ $balance',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh energy balance and offer status
          ref.invalidate(currentEnergyProvider);
          ref.invalidate(energyBalanceProvider);
          await _loadData();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
          // ────── Current Balance ──────
          _buildBalanceCard(balance),
          const SizedBox(height: 16),
          
          // ────── Progress to unlock Welcome Offer (ถ้ายังไม่ครบ 10 ครั้ง) ──────
          if (_offerStatus == WelcomeOfferStatus.notStarted)
            const WelcomeOfferProgress(),
          
          // ────── Welcome Offer (ถ้า active) ──────
          if (_offerStatus == WelcomeOfferStatus.active) ...[
            const SizedBox(height: 8),
            _buildWelcomeOfferSection(),
          ],
          
          const SizedBox(height: 24),
          
          // ────── Regular Packages ──────
          Text(
            _offerStatus == WelcomeOfferStatus.active 
                ? '💰 Regular Prices' 
                : '⚡ Energy Packages',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          _buildPackageCard(
            emoji: '🎯',
            name: 'Starter Kick',
            energy: 100,
            price: 0.99,
            priceText: '\$0.99',
            productId: PurchaseService.energy100,
          ),
          
          _buildPackageCard(
            emoji: '💎',
            name: 'Value Pack',
            energy: 550,
            price: 4.99,
            priceText: '\$4.99',
            productId: PurchaseService.energy550,
            badge: '+10% bonus',
          ),
          
          _buildPackageCard(
            emoji: '🔥',
            name: 'Power User',
            energy: 1200,
            price: 7.99,
            priceText: '\$7.99',
            productId: PurchaseService.energy1200,
            badge: 'POPULAR',
            isPopular: true,
          ),
          
          _buildPackageCard(
            emoji: '🏆',
            name: 'Ultimate Saver',
            energy: 2000,
            price: 9.99,
            priceText: '\$9.99',
            productId: PurchaseService.energy2000,
            badge: 'BEST DEAL',
            isBest: true,
          ),
          
          const SizedBox(height: 24),
          
          // ────── Info ──────
          _buildInfoCard(),
        ],
        ),
      ),
    );
  }
  
  // ───────────────────────────────────────────────────────────
  // WIDGETS
  // ───────────────────────────────────────────────────────────
  
  Widget _buildBalanceCard(int balance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Energy',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                '$balance',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildWelcomeOfferSection() {
    final timeStr = _remainingTime != null 
        ? WelcomeOfferService.formatRemainingTime(_remainingTime!)
        : '--';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ────── Header ──────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.red.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome Offer — 40% OFF!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '⏰ Expires in: $timeStr',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // ────── Welcome Packages ──────
        _buildPackageCard(
          emoji: '🎯',
          name: 'Starter Kick',
          energy: 100,
          price: 0.59,
          priceText: '\$0.59',
          originalPrice: '\$0.99',
          productId: PurchaseService.energy100Welcome,
          isWelcome: true,
        ),
        
        _buildPackageCard(
          emoji: '💎',
          name: 'Value Pack',
          energy: 550,
          price: 2.99,
          priceText: '\$2.99',
          originalPrice: '\$4.99',
          productId: PurchaseService.energy550Welcome,
          badge: '+10%',
          isWelcome: true,
        ),
        
        _buildPackageCard(
          emoji: '🔥',
          name: 'Power User',
          energy: 1200,
          price: 4.79,
          priceText: '\$4.79',
          originalPrice: '\$7.99',
          productId: PurchaseService.energy1200Welcome,
          badge: '+20%',
          isWelcome: true,
          isPopular: true,
        ),
        
        _buildPackageCard(
          emoji: '🏆',
          name: 'Ultimate Saver',
          energy: 2000,
          price: 5.99,
          priceText: '\$5.99',
          originalPrice: '\$9.99',
          productId: PurchaseService.energy2000Welcome,
          badge: '+50%',
          isWelcome: true,
          isBest: true,
        ),
        
        const SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildPackageCard({
    required String emoji,
    required String name,
    required int energy,
    required double price,
    required String priceText,
    required String productId,
    String? originalPrice,
    String? badge,
    bool isPopular = false,
    bool isBest = false,
    bool isWelcome = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isPopular || isBest 
            ? Colors.orange.shade50 
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPopular || isBest ? Colors.orange : Colors.grey.shade300,
          width: isPopular || isBest ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _purchasePackage(productId, energy),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // ────── Icon ──────
                Text(emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 16),
                
                // ────── Info ──────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isBest
                                    ? Colors.orange.shade600
                                    : isPopular
                                        ? Colors.deepOrange.shade500
                                        : Colors.blue.shade600,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '⚡ $energy Energy',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // ────── Price ──────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (originalPrice != null) ...[
                      Text(
                        originalPrice,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      priceText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isWelcome ? Colors.orange : Colors.green,
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
  
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('ℹ️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                'About Energy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('⚡', '1 Energy = 1 AI analysis'),
          _buildInfoRow('♾️', 'Energy never expires'),
          _buildInfoRow('📱', 'One-time purchase, per device'),
          _buildInfoRow('💚', 'Manual logging is always free'),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
  
  // ───────────────────────────────────────────────────────────
  // ACTIONS
  // ───────────────────────────────────────────────────────────
  
  Future<void> _purchasePackage(String productId, int energy) async {
    final success = await PurchaseService.purchaseEnergy(productId);
    if (success) {
      // Refresh balance
      ref.invalidate(currentEnergyProvider);
      ref.invalidate(energyBalanceProvider);
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Purchased $energy Energy!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Purchase failed. Please try again.')),
        );
      }
    }
  }
}
