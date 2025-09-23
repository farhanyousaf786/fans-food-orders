import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:fans_food_order/services/server.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import '../models/push_notification_model.dart';



// @pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('_firebaseMessagingBackgroundHandler');




}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
// ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
// ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

class NotificationServiceClass {
  late FlutterLocalNotificationsPlugin _fltNotification;
  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  Future<void> initMessaging() async {
    var androidInit =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInit = const DarwinInitializationSettings(defaultPresentSound: true);
    var initSetting =
        InitializationSettings(android: androidInit, iOS: iosInit);
    _fltNotification = FlutterLocalNotificationsPlugin();
    _fltNotification.initialize(
      initSetting,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationStream.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            // TODO: Handle this case.
            selectNotificationStream.add(notificationResponse.payload);
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

     await _firebaseMessaging.requestPermission();
    //***********************************************************//

    _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);

    ///| =========message handler========== |///

    remoteMessageHandler(RemoteMessage message) async {
      if (message.notification != null) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        log("Notification: $notification");

        if (notification != null && android != null) {
          log("Notification Show  '${message.data}'");

          _fltNotification.show(
              notification.hashCode,
              notification.title,
              notification.body,
              const NotificationDetails(
                  android: AndroidNotificationDetails(
                'high_importance_channel',
                'High Importance Notifications',
                // 'channel Description',
                priority: Priority.high,
                importance: Importance.max,
                playSound: true,
              )),
              payload: json.encode(message.data));


        }
      }
    }

    FirebaseMessaging.onMessage.listen(remoteMessageHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('payload....open app>>> ${message.data}');

      // MyApp.navigatorKey.currentState!
      //     .pushNamed('/notificationPage', arguments: message.data);
    });
    //****************************************************************//
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _configureSelectNotificationSubject();
  }

  //****************************************************************//

  void _configureSelectNotificationSubject() {
    log('1. payload....open app null');
    selectNotificationStream.stream.listen((String? payload) async {
      log('payload....open app null');
      if (payload == null) return;
      log('payload....open app $payload');

      // Decode the JSON string into a map
     // Map<String, dynamic> data = json.decode(payload);

      // Assuming you want to pass the whole data map
      // MyApp.navigatorKey.currentState!
      //     .pushNamed('/notificationPage', arguments: data);

      // Or if you specifically want to pass androidPayload
      // Map<String, dynamic> androidPayload = data['Android']['content']['payload'];
      // MyApp.navigatorKey.currentState!
      //     .pushNamed('/notificationPage', arguments: androidPayload);
    });
  }


  void showNotification(
      {required String title,
      required String body,
      required Map<String, dynamic> data}) {
    var androidInit =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInit = const DarwinInitializationSettings(defaultPresentSound: true);
    var initSetting =
        InitializationSettings(android: androidInit, iOS: iosInit);
    FlutterLocalNotificationsPlugin notify = FlutterLocalNotificationsPlugin();
    notify.initialize(
      initSetting,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationStream.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            // TODO: Handle this case.
            selectNotificationStream.add(notificationResponse.payload);
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    notify.show(
        123,
        title,
        body,
        const NotificationDetails(
            android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          // 'channel Description',
          priority: Priority.high,
          importance: Importance.max,
          playSound: true,
        )),
        payload: json.encode(data));
  }

  void initialNotificationHandle() async {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      log('payload....open app initial 0');
      if (message != null) {
        log('payload....open app initial 1');

        // MyApp.navigatorKey.currentState!
        //     .pushNamed('/notificationPage', arguments: message.data);
      }
    });
  }



  Future<void> sendNotification(String token, String title, String notifyBody) async {
    try {
    var notification=  PushNotificationModel(title: title, body: notifyBody);
    final accessToken = await GetServerKey().getServerKeyToken();

    // final body = {
      //   "to": token,
      //   "notification": {
      //     "title": title,
      //     "body": notifyBody,
      //   },
      //   // "data": {
      //   //   "username": username,
      //   //   "url": url,
      //   //   "click_action": "FLUTTER_NOTIFICATION_CLICK",
      //   // },
      // };
      final url = Uri.parse('https://fcm.googleapis.com/v1/projects/fans-food-stf/messages:send');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(notification.toFCMPayload(token)),
    );

      if (response.statusCode != 200) {
        print('❌ Failed to send notification: ${response.body}');

        // Clean up invalid tokens
        if (response.statusCode == 404 || response.body.contains('UNREGISTERED')) {
          print('🧹 Removing unregistered token: ');

        }
      } else {
        print('📤 Push sent [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      print('❌ Push notification failed: $e');
    }
  }


}
