import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationServices {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize(BuildContext context) async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Get the FCM registration token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Registration Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(message.notification!.title ?? 'No Title'),
              content: Text(message.notification!.body ?? 'No Body'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    });

    // Handle background and terminated state notifications
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      // Navigate to a specific screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NotificationScreen(
            title: message.notification?.title ?? 'No Title',
            body: message.notification?.body ?? 'No Body',
          ),
        ),
      );
    });
  }
}

class NotificationScreen extends StatelessWidget {
  final String title;
  final String body;

  NotificationScreen({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(body),
      ),
    );
  }
}
