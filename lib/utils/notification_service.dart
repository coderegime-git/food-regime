import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_routes.dart';
import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised before this is called by the OS.
  // You can do lightweight work here (save to prefs, update badge count, etc.)
  debugPrint('🔔 [BG] message: ${message.messageId}');
}

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final _fcm = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  /// High-importance Android channel (required for heads-up banners)
  static const _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications',
    importance: Importance.high,
    playSound: true,
  );

  // ── Public init ─────────────────────────────────────────────────────────────

  Future<void> init() async {
    // 1. Request permission (iOS + Android 13+)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Create the Android channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // 3. Initialise flutter_local_notifications
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false, // already requested via FCM above
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTap,
      settings: initSettings,
    );

    // 4. Register background handler (must happen before runApp)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 5. Force foreground notifications on iOS
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 6. Listen to streams
    _listenForeground();
    _listenOnMessageOpenedApp();

    // 7. Handle notification that launched the app from terminated state
    await _handleTerminatedMessage();

    // 8. Print / save FCM token
    final token = await _fcm.getToken();
    debugPrint('✅ FCM Token: $token');
    // TODO: send token to your backend if needed
    // ApiService().saveFcmToken(token);

    // Token refresh listener
    _fcm.onTokenRefresh.listen((newToken) async {
      debugPrint('🔄 FCM Token refreshed: $newToken');
      await ApiService().updateFCMToken(fcm: newToken);
    });
  }

  // ── Foreground messages ─────────────────────────────────────────────────────
  // FCM does NOT show a banner automatically when the app is in foreground.
  // We use flutter_local_notifications to do it manually.

  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 [FG] ${message.notification?.title}');
      _showLocalNotification(message);
    });
  }

  // ── Notification opened app from background ─────────────────────────────────

  void _listenOnMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('👆 [TAP-BG] ${message.data}');
      _handleNavigation(message.data);
    });
  }

  // ── App launched from a terminated-state notification ──────────────────────

  Future<void> _handleTerminatedMessage() async {
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      debugPrint('🚀 [TERMINATED TAP] ${initial.data}');
      // Small delay so the widget tree is ready
      await Future.delayed(const Duration(milliseconds: 500));
      _handleNavigation(initial.data);
    }
  }

  // ── Show local notification banner (foreground) ────────────────────────────

  Future<void> _showLocalNotification(RemoteMessage message) async {
    print(message.data);
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          // Optional: large icon (e.g. restaurant logo)
          largeIcon:
              const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      // Pass data payload so we can navigate on tap
      payload: jsonEncode(message.data),
    );
  }

  // ── Notification tap handler ───────────────────────────────────────────────

  @pragma('vm:entry-point')
  static void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      debugPrint('👆 [TAP-LOCAL] $data');
      NotificationService.instance._handleNavigation(data);
    } catch (_) {}
  }

  // ── Navigation routing from notification data ──────────────────────────────
  // Customize the `type` values to match what your backend sends.

  void _handleNavigation(Map<String, dynamic> data) {
    final context = AppRouter.rootNavigatorKey.currentContext;
    if (context == null) return;

    final type = data['type'] as String?;
    final status = type!.contains("order") ? "order_accepted" : "order_update";
    switch (status) {
      case 'order_update' || "order_accepted":
        final orderId = data['order_id'] as String?;
        if (orderId != null) {
          context.push(AppRoutes.orderDetailPath(orderId));
        }
        break;

      case 'promo':
        Navigator.of(context).pushNamed('/offers');
        break;

      // Add more cases as needed
      default:
        // Just open the home screen
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    }
  }
}
