import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/energy_service.dart';
import '../ai/gemini_service.dart';
import '../../features/subscription/providers/subscription_provider.dart';
import '../../features/energy/providers/gamification_provider.dart';

/// Wrapper for GeminiService to handle subscription + freepass features
///
/// Provides unlimited AI analysis for subscribers and active freepass users
class SubscriptionAwareGeminiService {
  final EnergyService _energyService;
  final GeminiService _geminiService;
  final Ref _ref;

  SubscriptionAwareGeminiService({
    required EnergyService energyService,
    required Ref ref,
  })  : _energyService = energyService,
        _geminiService = GeminiService(energyService),
        _ref = ref;

  bool get _hasUnlimitedAccess {
    final hasSubscription = _ref.read(hasActiveSubscriptionProvider);
    if (hasSubscription) return true;
    final gamification = _ref.read(gamificationProvider);
    return gamification.freepass.isActive;
  }

  /// Check if user can use AI (has energy OR has subscription/freepass)
  Future<bool> canUseAI() async {
    if (_hasUnlimitedAccess) {
      debugPrint('[SubscriptionAware] Unlimited access (subscription or freepass)');
      return true;
    }
    return await _energyService.hasEnergy();
  }

  /// Consume energy (or skip if subscribed/freepass)
  Future<bool> consumeEnergyIfNeeded({String? description}) async {
    return await _energyService.consumeEnergy(
      description: description,
      hasSubscription: _hasUnlimitedAccess,
    );
  }

  /// Show appropriate error message
  String getInsufficientEnergyMessage() {
    if (_hasUnlimitedAccess) {
      return 'Subscription error. Please try again.';
    }
    return 'Insufficient energy. Please purchase more energy or subscribe to Energy Pass.';
  }

  /// Get GeminiService instance (for direct calls)
  GeminiService get geminiService => _geminiService;
}

/// Provider for subscription-aware Gemini service
final subscriptionAwareGeminiServiceProvider = Provider.family<
    SubscriptionAwareGeminiService,
    EnergyService>((ref, energyService) {
  return SubscriptionAwareGeminiService(
    energyService: energyService,
    ref: ref,
  );
});
