import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/energy_service.dart';
import '../ai/gemini_service.dart';
import '../../features/subscription/providers/subscription_provider.dart';

/// Wrapper for GeminiService to handle subscription features
/// 
/// This provides unlimited AI analysis for subscribers
class SubscriptionAwareGeminiService {
  final EnergyService _energyService;
  final GeminiService _geminiService;
  final WidgetRef _ref;

  SubscriptionAwareGeminiService({
    required EnergyService energyService,
    required WidgetRef ref,
  })  : _energyService = energyService,
        _geminiService = GeminiService(energyService),
        _ref = ref;

  /// Check if AI analysis should consume energy
  bool _shouldConsumeEnergy() {
    final hasSubscription = _ref.read(hasActiveSubscriptionProvider);
    return !hasSubscription; // Don't consume if subscribed
  }

  /// Check if user can use AI (has energy OR has subscription)
  Future<bool> canUseAI() async {
    // Subscribers always have access
    final hasSubscription = _ref.read(hasActiveSubscriptionProvider);
    if (hasSubscription) {
      debugPrint('[SubscriptionAware] ⚡ Subscriber - unlimited access');
      return true;
    }

    // Non-subscribers need energy
    return await _energyService.hasEnergy();
  }

  /// Consume energy (or skip if subscribed)
  Future<bool> consumeEnergyIfNeeded({String? description}) async {
    final hasSubscription = _ref.read(hasActiveSubscriptionProvider);
    
    return await _energyService.consumeEnergy(
      description: description,
      hasSubscription: hasSubscription,
    );
  }

  /// Show appropriate error message
  String getInsufficientEnergyMessage() {
    final hasSubscription = _ref.read(hasActiveSubscriptionProvider);
    
    if (hasSubscription) {
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
