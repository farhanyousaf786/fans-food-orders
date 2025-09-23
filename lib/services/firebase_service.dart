import 'package:fans_food_order/services/notification_class.dart';
import 'package:fans_food_order/translations/translate.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const bool _debugMode = true;
  static const String _usersCollection = 'customers';
  static const String _deliveryUsersCollection = 'deliveryUsers';
  static const String _fcmTokenField = 'fcmToken';

  static bool _isIOS() => defaultTargetPlatform == TargetPlatform.iOS;

  static Future<void> initialize() async {
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.appAttest,
    );

    await NotificationServiceClass().initMessaging();


  }

  /// Initialize messaging and update FCM token in nested shops collection
  static Future<void> initializeMessaging({
    required String stadiumId,
    required String shopId,
  }) async {
    try {
      _log('Initializing FCM for shop: $shopId in stadium: $stadiumId');

      String? token = await _getFCMToken();
      if (token != null) {
        await _updateShopFCMToken(stadiumId, shopId, token);
      }

      _messaging.onTokenRefresh.listen(
        (newToken) {
          _log('FCM token refreshed');
          _updateShopFCMToken(stadiumId, shopId, newToken);
        },
        onError:
            (error) => _log('Error in token refresh: $error', isError: true),
      );

      FirebaseMessaging.onMessage.listen(
        _handleForegroundMessage,
        onError:
            (error) => _log(
              'Error handling foreground message: $error',
              isError: true,
            ),
      );

      _log('✅ FCM initialized for shop: $shopId');
    } catch (e, stackTrace) {
      _log('❌ Failed to initialize FCM: $e\n$stackTrace', isError: true);
      rethrow;
    }
  }

  static Future<void> _requestNotificationPermission() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      _log(
        '${Translate.get('notification_permission_status')}: ${settings.authorizationStatus}',
      );
    } catch (e, stackTrace) {
      _log(
        '❌ ${Translate.get('error_requesting_permissions')}: $e\n$stackTrace',
        isError: true,
      );
      rethrow;
    }
  }

  static Future<String?> _getFCMToken() async {
    try {
      _log('Requesting FCM token...');

      // On iOS Simulator, APNS token is not available; skip to avoid apns-token-not-set errors
      if (_isIOS()) {
        try {
          final deviceInfo = DeviceInfoPlugin();
          final ios = await deviceInfo.iosInfo;
          if (ios.isPhysicalDevice != true) {
            _log('Detected iOS Simulator; skipping FCM token request because APNS is unavailable.');
            return null;
          }
        } catch (_) {
          // If device info fails, continue gracefully and attempt token normally
        }
      }

      // Try to get FCM token; if APNS not yet set on iOS device, retry once after short delay
      try {
        final token = await _messaging.getToken();
        _log(token != null ? '✅ Token: $token' : '⚠️ ${Translate.get('fcm_token_is_null')}');
        return token;
      } catch (e) {
        final message = e.toString();
        final isApnsNotSet = message.contains('apns-token-not-set');
        if (_isIOS() && isApnsNotSet) {
          _log('APNS token not set yet. Waiting 3s and retrying...');
          await Future<void>.delayed(const Duration(seconds: 3));
          // Attempt to nudge APNS by querying it
          try { await _messaging.getAPNSToken(); } catch (_) {}
          final retry = await _messaging.getToken();
          _log(retry != null ? '✅ Token (after retry): $retry' : '⚠️ ${Translate.get('fcm_token_is_null')} (after retry)');
          return retry;
        }
        rethrow;
      }

    } catch (e, stackTrace) {
      _log(
        '❌ ${Translate.get('error_getting_fcm_token')}: $e\n$stackTrace',
        isError: true,
      );
      return null;
    }
  }

  static Future<void> _updateShopFCMToken(
    String stadiumId,
    String shopId,
    String token,
  ) async {
    try {
      _log('Updating FCM token for shop: $shopId');

      await _firestore.collection('shops').doc(shopId).update({
        'shopUserFcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });

      _log('✅ FCM token updated for shop: $shopId');
    } catch (e, stackTrace) {
      _log('❌ Error updating FCM token: $e\n$stackTrace', isError: true);
      rethrow;
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    _log('📥 Received foreground message:');
    _log('🔔 Title: ${message.notification?.title}');
    _log('📄 Body: ${message.notification?.body}');
    if (message.data.isNotEmpty) {
      _log('📦 Data payload:');
      message.data.forEach((key, value) => _log('  $key: $value'));
    }
  }

  static void _log(String message, {bool isError = false}) {
    if (_debugMode || isError) {
      print(isError ? '❌ [FCM Error] $message' : '📱 [FCM] $message');
    }
  }

  /// Update shop's location (latitude and longitude)
  static Future<bool> updateShopLocation({
    required String shopId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _firestore.collection('shops').doc(shopId).update({
        'latitude': latitude,
        'longitude': longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _log('Updated location for shop: $shopId to ($latitude, $longitude)');
      return true;
    } catch (e) {
      _log('Error updating shop location: $e', isError: true);
      return false;
    }
  }

  /// Update order status in Firestore
  static Future<bool> updateOrderStatus({
    required String orderId,
    required int newStatus,
  }) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _log('Updated order $orderId status to $newStatus');
      return true;
    } catch (e) {
      _log('Error updating order status: $e', isError: true);
      return false;
    }
  }

  /// Get FCM token for a user
  static Future<String?> getUserFcmToken(String userId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(userId).get();
      if (doc.exists) {
        return doc.data()?[_fcmTokenField] as String?;
      }
      _log('User document not found for ID: $userId', isError: true);
      return null;
    } catch (e) {
      _log('Error getting user FCM token: $e', isError: true);
      return null;
    }
  }

  /// Get FCM token for a delivery user
  static Future<String?> getDeliveryUserFcmToken(String deliveryUserId) async {
    try {
      final doc = await _firestore.collection(_deliveryUsersCollection).doc(deliveryUserId).get();
      if (doc.exists) {
        return doc.data()?[_fcmTokenField] as String?;
      }
      _log('Delivery user document not found for ID: $deliveryUserId', isError: true);
      return null;
    } catch (e) {
      _log('Error getting delivery user FCM token: $e', isError: true);
      return null;
    }
  }

  /// Get both user and delivery user FCM tokens
  static Future<Map<String, String?>> getOrderUserFcmTokens({
    required String userId,
    required String? deliveryUserId,
  }) async {
    final tokens = {
      'userToken': null as String?,
      'deliveryUserToken': null as String?,
    };

    try {
      _log('Fetching FCM tokens for user: $userId');
      if (deliveryUserId != null) {
        _log('Delivery user ID provided: $deliveryUserId');
      }

      // Get user token
      final userToken = await getUserFcmToken(userId);
      tokens['userToken'] = userToken;
      _log('User FCM token: ${userToken ?? 'Not found'}');

      // Get delivery user token if deliveryUserId is provided
      if (deliveryUserId != null && deliveryUserId.isNotEmpty) {
        final deliveryToken = await getDeliveryUserFcmToken(deliveryUserId);
        tokens['deliveryUserToken'] = deliveryToken;
        _log('Delivery user FCM token: ${deliveryToken ?? 'Not found'}');
      } else {
        _log('No delivery user ID provided, skipping delivery user token fetch');
      }
    } catch (e) {
      _log('Error getting order user FCM tokens: $e', isError: true);
    }

    _log('Final tokens: $tokens');
    return tokens;
  }
}
