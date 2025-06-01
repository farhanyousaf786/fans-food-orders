import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class FirebaseService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const bool _debugMode = true;

  static Future<void> initialize() async {
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.appAttest,
    );

    await _requestNotificationPermission();
    await NotificationService.initialize();
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
        onError: (error) => _log('Error in token refresh: $error', isError: true),
      );

      FirebaseMessaging.onMessage.listen(
        _handleForegroundMessage,
        onError: (error) => _log('Error handling foreground message: $error', isError: true),
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

      _log('Notification permission status: ${settings.authorizationStatus}');
    } catch (e, stackTrace) {
      _log('❌ Error requesting permissions: $e\n$stackTrace', isError: true);
      rethrow;
    }
  }

  static Future<String?> _getFCMToken() async {
    try {
      _log('Requesting FCM token...');
      final token = await _messaging.getToken();
      _log(token != null ? '✅ Token: $token' : '⚠️ FCM token is null');
      return token;
    } catch (e, stackTrace) {
      _log('❌ Error getting FCM token: $e\n$stackTrace', isError: true);
      return null;
    }
  }

  static Future<void> _updateShopFCMToken(String stadiumId, String shopId, String token) async {
    try {
      _log('Updating FCM token for shop: $shopId');

      await _firestore
          .collection('stadiums')
          .doc(stadiumId)
          .collection('shops')
          .doc(shopId)
          .update({
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
}
