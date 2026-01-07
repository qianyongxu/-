// import 'package:jpush_flutter/jpush_flutter.dart';

class PushService {
  // final JPush jpush = new JPush();

  Future<void> initPlatformState() async {
    // try {
    //   jpush.addEventHandler(
    //     onReceiveNotification: (Map<String, dynamic> message) async {
    //       print("flutter onReceiveNotification: $message");
    //     },
    //     onOpenNotification: (Map<String, dynamic> message) async {
    //       print("flutter onOpenNotification: $message");
    //     },
    //     onReceiveMessage: (Map<String, dynamic> message) async {
    //       print("flutter onReceiveMessage: $message");
    //     },
    //     onReceiveNotificationAuthorization: (Map<String, dynamic> message) async {
    //       print("flutter onReceiveNotificationAuthorization: $message");
    //     },
    //   );
    //   jpush.setup(
    //     appKey: "YOUR_JPUSH_APP_KEY",
    //     channel: "theChannel",
    //     production: false,
    //     debug: true,
    //   );
    //   jpush.applyPushAuthority(new NotificationSettingsIOS(
    //     sound: true,
    //     alert: true,
    //     badge: true,
    //   ));
    // } catch (e) {
    //   print("Error initializing JPush: $e");
    // }
  }
}
