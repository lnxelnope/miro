/// admob_consent_service.dart
///
/// Handles Google UMP (User Messaging Platform) consent.
/// Must be called BEFORE MobileAds.instance.initialize().
///
/// Flow:
///   1. Request UMP consent info update
///   2. Show consent form if required (GDPR/EEA users)
///   3. Initialize MobileAds SDK
///
/// No ATT — AdMob serves non-personalized ads by default.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobConsentService {
  static bool _initialized = false;
  static bool _consentCompleted = false;

  static bool get isInitialized => _initialized;

  static Future<void> initializeWithConsent() async {
    if (_initialized) return;

    try {
      await _requestUmpConsent();
      await MobileAds.instance.initialize();
      _initialized = true;
      debugPrint('[AdmobConsent] ✅ MobileAds initialized');
    } catch (e) {
      debugPrint('[AdmobConsent] Error during consent flow: $e');
      try {
        await MobileAds.instance.initialize();
        _initialized = true;
        debugPrint('[AdmobConsent] ✅ MobileAds initialized (fallback)');
      } catch (e2) {
        debugPrint('[AdmobConsent] ❌ MobileAds init failed: $e2');
      }
    }
  }

  static Future<void> _requestUmpConsent() async {
    if (_consentCompleted) return;

    final completer = Completer<void>();
    final params = ConsentRequestParameters();

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        debugPrint('[AdmobConsent] Consent info updated');

        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          await _showConsentForm();
        }

        _consentCompleted = true;
        if (!completer.isCompleted) completer.complete();
      },
      (error) {
        debugPrint('[AdmobConsent] Consent info error: '
            '${error.errorCode} - ${error.message}');
        _consentCompleted = true;
        if (!completer.isCompleted) completer.complete();
      },
    );

    await completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('[AdmobConsent] Consent timeout — proceeding');
        _consentCompleted = true;
      },
    );
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

  static void reset() {
    ConsentInformation.instance.reset();
    _initialized = false;
    _consentCompleted = false;
    debugPrint('[AdmobConsent] Consent state reset');
  }
}
