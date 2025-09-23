

class PushNotificationModel {
  final String title;
  final String body;

  final String? actionRoute;
  final String? image; // FCM image URL
  final Map<String, dynamic>? data;

  PushNotificationModel({
    required this.title,
    required this.body,

    this.actionRoute,
    this.image,
    this.data,
  });

  Map<String, dynamic> toFCMPayload(String fcmToken) {
    return {
      "message": {
        "token": fcmToken,
        "notification": {
          "title": title,
          "body": body,
          if (image != null) "image": image,
        },
        "data": {
          "actionRoute": actionRoute ?? '',
          ...?data,
        },
        "android": {
          "priority": "high",
        },
        "apns": {
          "payload": {
            "aps": {
              "sound": "default",
            }
          }
        }
      }
    };
  }
}
