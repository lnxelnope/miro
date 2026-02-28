import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service for managing user consent for analytics data collection
/// Complies with GDPR, PDPA, and store policies
class ConsentService {
  static const String _keyAnalyticsConsent = 'analytics_consent_granted';
  static const String _keyConsentVersion = 'consent_version';
  static const String _keyConsentAsked = 'consent_asked';
  
  // Increment this when Privacy Policy changes significantly
  static const int currentConsentVersion = 1;

  /// Check if user has granted analytics consent
  static Future<bool> hasConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final granted = prefs.getBool(_keyAnalyticsConsent) ?? false;
      final version = prefs.getInt(_keyConsentVersion) ?? 0;
      
      // If consent version changed, need to ask again
      if (granted && version < currentConsentVersion) {
        debugPrint('[Consent] Consent version outdated, need to ask again');
        return false;
      }
      
      return granted;
    } catch (e) {
      debugPrint('[Consent] Error checking consent: $e');
      return false; // Default to no consent on error
    }
  }

  /// Check if we need to show consent dialog (never asked before)
  static Future<bool> needsConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final asked = prefs.getBool(_keyConsentAsked) ?? false;
      final version = prefs.getInt(_keyConsentVersion) ?? 0;
      
      // Need consent if never asked OR version changed
      return !asked || version < currentConsentVersion;
    } catch (e) {
      debugPrint('[Consent] Error checking if needs consent: $e');
      return true; // Default to showing dialog on error
    }
  }

  /// Grant analytics consent
  static Future<void> grantConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyAnalyticsConsent, true);
      await prefs.setBool(_keyConsentAsked, true);
      await prefs.setInt(_keyConsentVersion, currentConsentVersion);
      debugPrint('[Consent] Analytics consent GRANTED (v$currentConsentVersion)');
    } catch (e) {
      debugPrint('[Consent] Error granting consent: $e');
    }
  }

  /// Revoke analytics consent
  static Future<void> revokeConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyAnalyticsConsent, false);
      await prefs.setBool(_keyConsentAsked, true);
      await prefs.setInt(_keyConsentVersion, currentConsentVersion);
      debugPrint('[Consent] Analytics consent REVOKED');
    } catch (e) {
      debugPrint('[Consent] Error revoking consent: $e');
    }
  }

  /// Mark that consent dialog was shown (user saw it, even if declined)
  static Future<void> markConsentAsked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyConsentAsked, true);
      debugPrint('[Consent] Consent dialog shown');
    } catch (e) {
      debugPrint('[Consent] Error marking consent asked: $e');
    }
  }

  /// Clear all consent data (for testing or data reset)
  static Future<void> clearConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAnalyticsConsent);
      await prefs.remove(_keyConsentVersion);
      await prefs.remove(_keyConsentAsked);
      debugPrint('[Consent] All consent data cleared');
    } catch (e) {
      debugPrint('[Consent] Error clearing consent: $e');
    }
  }

  /// Get consent status for debugging
  static Future<Map<String, dynamic>> getConsentStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'granted': prefs.getBool(_keyAnalyticsConsent) ?? false,
        'version': prefs.getInt(_keyConsentVersion) ?? 0,
        'asked': prefs.getBool(_keyConsentAsked) ?? false,
        'currentVersion': currentConsentVersion,
      };
    } catch (e) {
      debugPrint('[Consent] Error getting status: $e');
      return {
        'granted': false,
        'version': 0,
        'asked': false,
        'currentVersion': currentConsentVersion,
      };
    }
  }
}
