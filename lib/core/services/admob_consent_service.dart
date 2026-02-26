/// admob_consent_service.dart
///
/// Handles Google UMP (User Messaging Platform) consent + iOS ATT (App Tracking Transparency).
/// Must be called BEFORE MobileAds.instance.initialize().
///
/// Flow:
///   1. Request UMP consent info update
///   2. Show consent form if required (GDPR/EEA users)
///   3. On iOS 14+, request ATT permission
///   4. Initialize MobileAds SDK
///
/// If user denies consent → AdMob automatically serves non-personalized ads.
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class AdmobConsentService {
  static bool _initialized = false;
  static bool _consentCompleted = false;

  static bool get isInitialized => _initialized;

  /// Run full consent flow then initialize MobileAds.
  /// Safe to call multiple times — will skip if already done.
  static Future<void> initializeWithConsent() async {
    if (_initialized) return;

    try {
      await _requestUmpConsent();
      if (Platform.isIOS) {
        await _requestATTPermission();
      }
      await MobileAds.instance.initialize();
      _initialized = true;
      debugPrint('[AdmobConsent] MobileAds initialized with consent');
    } catch (e) {
      debugPrint('[AdmobConsent] Error during consent flow: $e');
      // Fallback: initialize anyway with non-personalized ads
      try {
        await MobileAds.instance.initialize();
        _initialized = true;
        debugPrint('[AdmobConsent] MobileAds initialized (fallback)');
      } catch (e2) {
        debugPrint('[AdmobConsent] MobileAds init failed: $e2');
      }
    }
  }

  /// Google UMP consent flow (required for GDPR/EEA).
  /// For non-EEA users, this completes immediately without showing a form.
  static Future<void> _requestUmpConsent() async {
    if (_consentCompleted) return;

    final params = ConsentRequestParameters();

    // Request latest consent info (returns void, uses callbacks)
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        debugPrint('[AdmobConsent] Consent info updated');

        // Show consent form if required and available
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          await _showConsentForm();
        }

        _consentCompleted = true;
      },
      (error) {
        debugPrint('[AdmobConsent] Consent info error: '
            '${error.errorCode} - ${error.message}');
        _consentCompleted = true;
      },
    );

    // Wait a bit for async callbacks to complete
    int waited = 0;
    while (!_consentCompleted && waited < 10000) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      waited += 100;
    }
  }

  static Future<void> _showConsentForm() async {
    ConsentForm.loadConsentForm(
      (form) {
        final status = ConsentInformation.instance.getConsentStatus();
        if (status == ConsentStatus.required) {
          form.show((error) {
            if (error != null) {
              debugPrint('[AdmobConsent] Form error: ${error.message}');
            } else {
              debugPrint('[AdmobConsent] Consent form completed');
            }
          });
        }
      },
      (error) {
        debugPrint('[AdmobConsent] Form load error: '
            '${error.errorCode} - ${error.message}');
      },
    );
  }

  /// iOS App Tracking Transparency (ATT) — iOS 14+.
  /// Shows native "Allow app to track?" dialog.
  /// If user denies, AdMob still works with non-personalized ads.
  static Future<void> _requestATTPermission() async {
    try {
      final status =
          await AppTrackingTransparency.trackingAuthorizationStatus;

      if (status == TrackingStatus.notDetermined) {
        // Small delay recommended by Apple before showing ATT dialog
        await Future<void>.delayed(const Duration(seconds: 1));

        final result =
            await AppTrackingTransparency.requestTrackingAuthorization();
        debugPrint('[AdmobConsent] ATT result: $result');
      } else {
        debugPrint('[AdmobConsent] ATT already resolved: $status');
      }
    } catch (e) {
      debugPrint('[AdmobConsent] ATT error: $e');
    }
  }

  /// Reset consent state (for testing/debugging).
  static void reset() {
    ConsentInformation.instance.reset();
    _initialized = false;
    _consentCompleted = false;
    debugPrint('[AdmobConsent] Consent state reset');
  }
}
