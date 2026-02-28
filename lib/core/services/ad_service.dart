/// ad_service.dart
///
/// Rewarded Ads Service (Google AdMob)
/// Max 3 ads/day, +3E per ad
/// Singleton — ใช้ AdService.instance แทนการ new AdService()
library;

import 'dart:async';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'device_id_service.dart';
import 'admob_consent_service.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  static const String _androidRewardedAdUnitId =
      'ca-app-pub-6145254112451474/4582480782';
  static const String _iosRewardedAdUnitId =
      'ca-app-pub-6145254112451474/9226831595';

  static const String _iosTestAdUnitId =
      'ca-app-pub-3940256099942544/1712485313';
  static const String _androidTestAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  static String get _rewardedAdUnitId {
    if (kDebugMode) {
      return Platform.isIOS ? _iosTestAdUnitId : _androidTestAdUnitId;
    }
    return Platform.isIOS ? _iosRewardedAdUnitId : _androidRewardedAdUnitId;
  }

  static const String _claimUrl =
      'https://us-central1-miro-d6856.cloudfunctions.net/claimAdReward';
  static const String _statusUrl =
      'https://us-central1-miro-d6856.cloudfunctions.net/getAdStatus';

  RewardedAd? _rewardedAd;
  int _adsWatchedToday = 0;
  static const int maxAdsPerDay = 3;
  bool _initialized = false;
  bool _isLoading = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  bool get isAdReady => _rewardedAd != null;
  bool get canWatchAd => _adsWatchedToday < maxAdsPerDay;
  int get remainingAds => maxAdsPerDay - _adsWatchedToday;

  Future<void> initialize() async {
    if (_initialized) return;
    await AdmobConsentService.initializeWithConsent();
    _initialized = true;
    debugPrint('[AdService] Platform: ${Platform.isIOS ? "iOS" : "Android"}, '
        'AdUnit: $_rewardedAdUnitId');
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
        debugPrint('[AdService] Synced: $_adsWatchedToday/$maxAdsPerDay');
      }
    } catch (e) {
      debugPrint('[AdService] Sync failed: $e');
    }
  }

  Completer<bool>? _loadCompleter;

  /// Loads a rewarded ad and waits until it succeeds or fails.
  Future<bool> _loadRewardedAd() async {
    if (_rewardedAd != null) return true;
    if (_isLoading && _loadCompleter != null) {
      return _loadCompleter!.future;
    }

    _isLoading = true;
    _loadCompleter = Completer<bool>();

    final deviceId = await DeviceIdService.getDeviceId();
    debugPrint('[AdService] Loading ad... (unit: $_rewardedAdUnitId)');

    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdService] ✅ Rewarded ad loaded');
          ad.setServerSideOptions(
            ServerSideVerificationOptions(customData: deviceId),
          );
          _rewardedAd = ad;
          _isLoading = false;
          _retryCount = 0;
          if (_loadCompleter != null && !_loadCompleter!.isCompleted) {
            _loadCompleter!.complete(true);
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] ❌ Ad failed to load: '
              'code=${error.code}, domain=${error.domain}, '
              'message=${error.message}');
          _rewardedAd = null;
          _isLoading = false;
          if (_loadCompleter != null && !_loadCompleter!.isCompleted) {
            _loadCompleter!.complete(false);
          }
          _retryWithBackoff();
        },
      ),
    );

    return _loadCompleter!.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        debugPrint('[AdService] ⏱ Ad load timeout (15s)');
        _isLoading = false;
        return false;
      },
    );
  }

  void _retryWithBackoff() {
    if (_retryCount >= _maxRetries) {
      debugPrint('[AdService] Max retries reached ($_maxRetries)');
      _retryCount = 0;
      return;
    }
    _retryCount++;
    final delay = Duration(seconds: _retryCount * 5);
    debugPrint('[AdService] Retry $_retryCount/$_maxRetries in ${delay.inSeconds}s');
    Future.delayed(delay, () {
      if (_rewardedAd == null) _loadRewardedAd();
    });
  }

  /// Show ad, claim reward from backend, return reward amount (0 = failed)
  Future<int> showRewardedAd() async {
    if (_rewardedAd == null) {
      debugPrint('[AdService] Ad not loaded — loading now...');
      final loaded = await _loadRewardedAd();
      if (!loaded || _rewardedAd == null) {
        debugPrint('[AdService] Ad still not ready after load attempt');
        return 0;
      }
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

  /// Preload an ad if one isn't already loaded
  Future<void> preload() async {
    if (_rewardedAd == null && !_isLoading) {
      await _loadRewardedAd();
    }
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
