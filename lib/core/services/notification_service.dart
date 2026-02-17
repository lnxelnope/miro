import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'device_id_service.dart';
import '../utils/logger.dart';

/// Service สำหรับจัดการ Push Notifications (FCM)
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _initialized = false;

  /// Initialize notification service
  /// เรียกตอน app startup ใน main.dart
  static Future<void> initialize() async {
    if (_initialized) {
      AppLogger.info('🔔 NotificationService already initialized');
      return;
    }

    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        AppLogger.info('✅ Notification permission granted');

        // Get FCM token
        final token = await _messaging.getToken();
        if (token != null) {
          await _saveFcmToken(token);
          AppLogger.info('✅ FCM token saved: ${token.substring(0, 20)}...');
        } else {
          AppLogger.warn('⚠️ FCM token is null');
        }

        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          AppLogger.info('🔄 FCM token refreshed');
          _saveFcmToken(newToken);
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          AppLogger.info('📬 Foreground notification received: ${message.notification?.title}');
          // TODO: Show in-app notification banner
        });

        // Handle notification tap (when app is in background or terminated)
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          AppLogger.info('📬 Notification tapped: ${message.notification?.title}');
          _handleNotificationTap(message);
        });

        // Check if app was opened from notification (terminated state)
        final initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          AppLogger.info('📬 App opened from notification');
          _handleNotificationTap(initialMessage);
        }

        _initialized = true;
      } else {
        AppLogger.warn('⚠️ Notification permission denied: ${settings.authorizationStatus}');
      }
    } catch (e) {
      AppLogger.error('❌ Failed to initialize NotificationService: $e');
    }
  }

  /// Save FCM token to Firestore
  static Future<void> _saveFcmToken(String token) async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final db = FirebaseFirestore.instance;

      // Update user document with FCM token
      await db.collection('users').doc(deviceId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('✅ FCM token saved to Firestore for device: $deviceId');
    } catch (e) {
      AppLogger.error('❌ Failed to save FCM token: $e');
    }
  }

  /// Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;

    AppLogger.info('🔔 Handling notification tap: type=$type');

    // TODO: Navigate to appropriate screen based on notification type
    // Example:
    // if (type == 'streak_reminder') {
    //   // Navigate to home screen
    // } else if (type == 'challenge_reminder') {
    //   // Navigate to challenges screen
    // }
  }

  /// Update notification settings
  static Future<void> updateNotificationSettings({
    bool? streakReminder,
    bool? challengeReminder,
    bool? promotions,
    String? reminderTime,
  }) async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final db = FirebaseFirestore.instance;

      final updates = <String, dynamic>{};
      if (streakReminder != null) {
        updates['notificationSettings.streakReminder'] = streakReminder;
      }
      if (challengeReminder != null) {
        updates['notificationSettings.challengeReminder'] = challengeReminder;
      }
      if (promotions != null) {
        updates['notificationSettings.promotions'] = promotions;
      }
      if (reminderTime != null) {
        updates['notificationSettings.reminderTime'] = reminderTime;
      }

      await db.collection('users').doc(deviceId).update(updates);
      AppLogger.info('✅ Notification settings updated');
    } catch (e) {
      AppLogger.error('❌ Failed to update notification settings: $e');
    }
  }

  /// Get current notification settings
  static Future<Map<String, dynamic>?> getNotificationSettings() async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final db = FirebaseFirestore.instance;
      final doc = await db.collection('users').doc(deviceId).get();

      if (doc.exists) {
        final data = doc.data();
        return data?['notificationSettings'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      AppLogger.error('❌ Failed to get notification settings: $e');
      return null;
    }
  }

  /// Delete FCM token (when user logs out or disables notifications)
  static Future<void> deleteFcmToken() async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final db = FirebaseFirestore.instance;

      await db.collection('users').doc(deviceId).update({
        'fcmToken': FieldValue.delete(),
        'fcmTokenDeletedAt': FieldValue.serverTimestamp(),
      });

      await _messaging.deleteToken();
      AppLogger.info('✅ FCM token deleted');
    } catch (e) {
      AppLogger.error('❌ Failed to delete FCM token: $e');
    }
  }
}
