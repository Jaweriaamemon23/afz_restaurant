import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String webVapidKey =
      'BA_HuukoJgl77v8iEABgx6fpIK-QUXaWdpRC-jkrCCY91s7QXlOYxQZsrgyjBbpw83j8VKYustS_e_VfS0hvoCE';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _initialized = false;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print('Notification permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('Notifications are disabled.');
        return;
      }

      // Foreground notifications: show an in-app SnackBar.
      _messageSubscription = FirebaseMessaging.onMessage.listen((message) {
        final title = message.notification?.title ?? 'AFZ Restaurant';
        final body = message.notification?.body ?? 'You have a new update.';

        print('Foreground notification: $title - $body');

        final context = appNavigatorKey.currentContext;
        if (context != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('$title\n$body'),
                duration: const Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      });

      _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((
        message,
      ) {
        print('Notification tapped: ${message.data}');
        // Order-specific navigation can be added here.
      });

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        print('App opened from notification: ${initialMessage.data}');
      }

      // Save the token on login, including logins after initialization.
      _authSubscription = _auth.authStateChanges().listen((user) {
        if (user != null) {
          saveTokenForCurrentUser();
        }
      });

      // Keep the stored token up to date.
      _tokenSubscription = _messaging.onTokenRefresh.listen((token) {
        final user = _auth.currentUser;
        if (user != null) {
          _saveToken(user.uid, token);
        }
      });

      await saveTokenForCurrentUser();
    } catch (e) {
      _initialized = false;
      print('Notification initialization error: $e');
    }
  }

  Future<void> saveTokenForCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No signed-in user; token will be saved after login.');
        return;
      }

      final token = await _messaging.getToken(vapidKey: webVapidKey);
      if (token == null || token.isEmpty) {
        print('FCM did not return a token.');
        return;
      }
      print('========== FCM TOKEN DEBUG ==========');
      print('Current User UID: ${user.uid}');
      print('FCM Token: $token');
      print('=====================================');
      await _saveToken(user.uid, token);
    } catch (e) {
      print('Could not save FCM token: $e');
    }
  }

  Future<void> _saveToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('FCM token saved for user: $uid');
    } catch (e) {
      print('Could not save FCM token: $e');
    }
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _tokenSubscription?.cancel();
    await _messageSubscription?.cancel();
    await _openedSubscription?.cancel();

    _authSubscription = null;
    _tokenSubscription = null;
    _messageSubscription = null;
    _openedSubscription = null;
    _initialized = false;
  }
}

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

// Register this as the background handler if you also configure
// Firebase Messaging background handling for supported native platforms.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.messageId}');
}
