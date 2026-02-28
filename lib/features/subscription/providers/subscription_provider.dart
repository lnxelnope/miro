import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription_data.dart';
import '../services/subscription_service.dart';
import '../../../core/services/device_id_service.dart';

/// Subscription State
class SubscriptionState {
  final SubscriptionData subscription;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    required this.subscription,
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    SubscriptionData? subscription,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      subscription: subscription ?? this.subscription,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Subscription Provider
/// 
/// Manages subscription state and data from Firestore
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier(this._service)
      : super(SubscriptionState(subscription: SubscriptionData.empty())) {
    _initialize();
  }

  final SubscriptionService _service;
  StreamSubscription<DocumentSnapshot>? _subscriptionListener;

  /// Initialize and listen to subscription changes
  Future<void> _initialize() async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      debugPrint('[SubscriptionProvider] Listening to users/$deviceId');

      _subscriptionListener = FirebaseFirestore.instance
          .collection('users')
          .doc(deviceId)
          .snapshots()
          .listen(
        (snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data();
            final rawSub = data?['subscription'];
            debugPrint('[SubscriptionProvider] Firestore data received. '
                'subscription=$rawSub');

            final subscriptionData = SubscriptionData.fromFirestore(
              rawSub as Map<String, dynamic>?,
            );

            debugPrint('[SubscriptionProvider] Parsed: '
                'status=${subscriptionData.status}, '
                'isActive=${subscriptionData.isActive}');

            state = state.copyWith(
              subscription: subscriptionData,
              isLoading: false,
              error: null,
            );
          } else {
            debugPrint('[SubscriptionProvider] User doc does not exist');
          }
        },
        onError: (error) {
          debugPrint('[SubscriptionProvider] Firestore listener error: $error');
          state = state.copyWith(
            error: error.toString(),
            isLoading: false,
          );
        },
      );
    } catch (e) {
      debugPrint('[SubscriptionProvider] Init error: $e');
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Refresh subscription status from backend
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final subscription = await _service.checkSubscriptionStatus(deviceId);

      state = state.copyWith(
        subscription: subscription,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  @override
  void dispose() {
    _subscriptionListener?.cancel();
    super.dispose();
  }
}

/// Subscription Service Provider
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

/// Subscription State Provider
final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return SubscriptionNotifier(service);
});

/// Convenience providers for specific subscription checks

/// Check if user has active subscription
final hasActiveSubscriptionProvider = Provider<bool>((ref) {
  final state = ref.watch(subscriptionProvider);
  return state.subscription.isActive;
});

/// Check if user has unlimited AI access
final hasUnlimitedAIProvider = Provider<bool>((ref) {
  final state = ref.watch(subscriptionProvider);
  return SubscriptionService.hasUnlimitedAI(state.subscription);
});

/// Check if user gets double rewards
final hasDoubleRewardsProvider = Provider<bool>((ref) {
  final state = ref.watch(subscriptionProvider);
  return SubscriptionService.hasDoubleRewards(state.subscription);
});

/// Check if user has exclusive badge
final hasExclusiveBadgeProvider = Provider<bool>((ref) {
  final state = ref.watch(subscriptionProvider);
  return SubscriptionService.hasExclusiveBadge(state.subscription);
});
