import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize Firebase services including App Check and FCM
  static Future<void> initialize() async {
    // Initialize Firebase App Check
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.appAttest,
    );

    // Request notification permissions
    await _requestNotificationPermission();
  }

  /// Initialize FCM for a specific shop
  static Future<void> initializeMessaging(String shopId) async {
    // Get initial token
    String? token = await _getFCMToken();
    if (token != null) {
      await _updateShopFCMToken(shopId, token);
    }

    // Listen to token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _updateShopFCMToken(shopId, newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  /// Request notification permissions
  static Future<void> _requestNotificationPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  /// Get FCM token
  static Future<String?> _getFCMToken() async {
    try {
      String? token = await _messaging.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Update shop's FCM token
  static Future<void> _updateShopFCMToken(String shopId, String? token) async {
    try {
      await _firestore.collection('shops').doc(shopId).update({
        'shopUserFcmToken': token,
      });
      print('FCM token updated for shop: $shopId');
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  /// Handle incoming foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  }
}
