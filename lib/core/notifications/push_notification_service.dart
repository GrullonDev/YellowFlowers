import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:yellow_flowers/core/auth/auth_service.dart';
import 'package:yellow_flowers/core/notifications/notification_service.dart';

/// Top-level background message handler. `firebase_messaging` requires this
/// to be a top-level (or static) function annotated with
/// `@pragma('vm:entry-point')` so the OS can invoke it in a separate
/// isolate when the app is backgrounded/terminated.
///
/// The app's widget tree, Provider state and GetIt container are NOT
/// guaranteed to exist when this runs, so it must stay minimal — it only
/// exists so a background push isn't silently dropped by the platform.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
      'PushNotificationService: background message ${message.messageId}');
}

/// Firebase Cloud Messaging integration — Fase 1 (ver
/// YellowFlowers_Analisis_Dinamismo_Social.docx, secciones 3.4 y 4.A).
///
/// This is the client-side half of push notifications: request
/// permission, obtain/refresh the device token, save it to Firestore
/// under the signed-in (anonymous) user, and show a local notification
/// when a push arrives while the app is in the foreground (neither
/// Android nor iOS auto-display a push notification while the app is
/// already open).
///
/// There is intentionally no server here — actually *sending* a push
/// (e.g. "tu flor fue vista", a streak-milestone celebration, a
/// re-engagement nudge) requires a backend job, which is Fase 3 work
/// once accounts/sync land. This class only makes the app *ready* to
/// receive and display them, and gives a future backend a token to
/// target.
class PushNotificationService {
  PushNotificationService({
    required AuthService authService,
    required NotificationService localNotifications,
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
  })  : _authService = authService,
        _localNotifications = localNotifications,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final AuthService _authService;
  final NotificationService _localNotifications;
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<String>? _tokenRefreshSub;
  bool _initialized = false;

  /// Requests permission (no-op / auto-granted on platforms that don't
  /// prompt), syncs the current token to Firestore, and starts listening
  /// for foreground pushes and token refreshes. Safe to call multiple
  /// times and never throws — push notifications are a nice-to-have, not
  /// a startup-blocking dependency.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!granted) return;

      await _syncToken();
      _tokenRefreshSub ??= _messaging.onTokenRefresh.listen(_saveToken);
      _foregroundSub ??=
          FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    } catch (e) {
      debugPrint('PushNotificationService: init failed: $e');
    }
  }

  Future<void> _syncToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) await _saveToken(token);
    } catch (e) {
      debugPrint('PushNotificationService: could not read token: $e');
    }
  }

  /// Saves the FCM token on the user's own Firestore doc
  /// (`users/{uid}.fcmToken`) — already covered by the existing
  /// firestore.rules, which only let a signed-in uid read/write its own
  /// document.
  Future<void> _saveToken(String token) async {
    final uid = _authService.uid;
    if (uid == null) return;
    try {
      await _firestore.collection('users').doc(uid).set(
        {
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('PushNotificationService: could not save token: $e');
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    unawaited(_localNotifications.showNow(
      title: notification.title ?? 'Yellow Flowers',
      body: notification.body ?? '',
    ));
  }

  void dispose() {
    _foregroundSub?.cancel();
    _tokenRefreshSub?.cancel();
  }
}
