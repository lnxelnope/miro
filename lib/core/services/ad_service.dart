/// ad_service.dart
///
/// Rewarded Ads Service (Google AdMob)
/// Max 3 ads/day, +3E per ad
library;

import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'device_id_service.dart';

class AdService {
  static const String _rewardedAdUnitId =
      'ca-app-pub-6145254112451474/4582480782';
  static const String _claimUrl =
      'https://us-central1-miro-d6856.cloudfunctions.net/claimAdReward';
  static const String _statusUrl =
      'https://us-central1-miro-d6856.cloudfunctions.net/getAdStatus';

  RewardedAd? _rewardedAd;
  int _adsWatchedToday = 0;
  static const int maxAdsPerDay = 3;

  bool get canWatchAd => _adsWatchedToday < maxAdsPerDay;
  int get remainingAds => maxAdsPerDay - _adsWatchedToday;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await _loadRewardedAd();
    await _syncAdStatus();
  }

  Future<void> _syncAdStatus() async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final response = await http.post(
        Uri.parse(_statusUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'deviceId': deviceId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _adsWatchedToday = data['watchedToday'] as int? ?? 0;
        debugPrint(
            '[AdService] Synced: $_adsWatchedToday/$maxAdsPerDay');
      }
    } catch (e) {
      debugPrint('[AdService] Sync failed: $e');
    }
  }

  Future<void> _loadRewardedAd() async {
    final deviceId = await DeviceIdService.getDeviceId();

    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdService] Rewarded ad loaded');
          ad.setServerSideOptions(
            ServerSideVerificationOptions(customData: deviceId),
          );
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] Ad failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  /// Show ad, claim reward from backend, return reward amount (0 = failed)
  Future<int> showRewardedAd() async {
    if (_rewardedAd == null) {
      debugPrint('[AdService] Ad not loaded');
      return 0;
    }

    if (!canWatchAd) {
      debugPrint('[AdService] Daily limit reached');
      return 0;
    }

    bool earned = false;
    final completer = Completer<bool>();

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
        if (!completer.isCompleted) completer.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] Ad failed to show: $error');
        ad.dispose();
        _loadRewardedAd();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('[AdService] User earned reward');
        earned = true;
      },
    );

    _rewardedAd = null;
    final didEarn = await completer.future;

    if (!didEarn) return 0;

    // Call backend to claim energy
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final response = await http.post(
        Uri.parse(_claimUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'deviceId': deviceId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _adsWatchedToday = data['adsToday'] as int? ?? (_adsWatchedToday + 1);
        final reward = data['reward'] as int? ?? 3;
        debugPrint('[AdService] Claimed: +${reward}E');
        return reward;
      } else {
        debugPrint('[AdService] Claim failed: ${response.body}');
        return 0;
      }
    } catch (e) {
      debugPrint('[AdService] Claim error: $e');
      return 0;
    }
  }

  Future<void> refreshStatus() async {
    await _syncAdStatus();
  }

  void dispose() {
    _rewardedAd?.dispose();
  }
}
