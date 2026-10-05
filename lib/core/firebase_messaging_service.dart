import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
}

class FirebaseMessagingService {
  FirebaseMessagingService(this._localNotifications);
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications;

  static const _fcmChannelId = 'amarillas_push';
  static const _fcmChannelName = 'Notificaciones de Amarillas';

  Future<void> init() async {
    if (kIsWeb) return;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] Notification permission denied');
      return;
    }

    if (Platform.isAndroid) {
      await _createAndroidChannel();
    }

    final token = await _messaging.getToken();
    debugPrint('[FCM] Token: $token');

    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] Token refreshed: $newToken');
    });

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleMessageTap(initial);
  }

  Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      _fcmChannelId,
      _fcmChannelName,
      description: 'Recordatorios y mensajes especiales',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _fcmChannelId,
          _fcmChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  void _handleMessageTap(RemoteMessage message) {
    debugPrint('[FCM] User tapped notification: ${message.data}');
  }

  Future<String?> getToken() => _messaging.getToken();

  Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);

  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);
}
