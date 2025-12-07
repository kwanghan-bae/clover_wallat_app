import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState>? navigatorKey;

  FcmService({this.navigatorKey});

  Future<void> initialize() async {
    // Request permission
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
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Get token
    String? token = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('FCM Token: $token');
    }

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Show local notification or update UI
      }
    });

    // Handle notification taps (when app is in background or terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped! Routing to screen...');
      _handleNotificationRoute(message);
    });

    // Check for initial message (when app was opened from terminated state)
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from notification');
      _handleNotificationRoute(initialMessage);
    }
  }

  void _handleNotificationRoute(RemoteMessage message) {
    final data = message.data;
    final screen = data['screen'] as String?;
    final id = data['id'] as String?;

    if (screen == null || navigatorKey?.currentState == null) return;

    print('Routing to screen: $screen with id: $id');
    
    // Navigate based on screen parameter
    switch (screen) {
      case 'history':
        // Import is handled at the top level - we'll use dynamic import
        navigatorKey!.currentState!.pushNamed('/history');
        break;
      case 'community':
        navigatorKey!.currentState!.pushNamed('/community');
        break;
      case 'number_generation':
        navigatorKey!.currentState!.pushNamed('/number_generation');
        break;
      case 'notification':
        navigatorKey!.currentState!.pushNamed('/notification');
        break;
      default:
        print('Unknown screen: $screen');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}
