import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'package:sentimento_app/core/nav/nav.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');
}

/// NotificationService - Manages FCM and local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _fcmTokenKey = 'fcm_token';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize the notification service
  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize Firebase
    await Firebase.initializeApp();

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Request permissions
    await _requestPermissions();

    // Get FCM token
    await _getFCMToken();

    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Set up notification tap handler
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Schedule daily notifications
    await scheduleDailyNotifications();

    debugPrint('NotificationService initialized successfully');
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'sentimento_daily',
      'Lembretes Diários',
      description: 'Notificações diárias sobre humor e metas',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
      'Notification permission status: ${settings.authorizationStatus}',
    );
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      // Save token locally
      if (_fcmToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_fcmTokenKey, _fcmToken!);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_fcmTokenKey, newToken);
        debugPrint('FCM Token refreshed: $newToken');
      });
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.notification?.title}');

    final notification = message.notification;
    if (notification != null) {
      _showLocalNotification(
        title: notification.title ?? 'Sentimento',
        body: notification.body ?? '',
      );
    }
  }

  /// Handle notification tap from FCM
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.data}');
    _navigateToScreen(message.data['screen'] as String?);
  }

  /// Handle local notification tap
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    _navigateToScreen(response.payload);
  }

  /// Navigate to specific screen based on payload
  void _navigateToScreen(String? screen) {
    final context = appNavigatorKey.currentContext;
    if (context == null) return;

    switch (screen) {
      case 'home':
        context.pushNamed('Home');
        break;
      case 'goals':
        context.pushNamed('Goals');
        break;
      case 'journal':
        context.pushNamed('Journal');
        break;
      default:
        // Default: go to main page
        context.pushNamed('Main');
        break;
    }
  }

  /// Show a local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'sentimento_daily',
      'Lembretes Diários',
      channelDescription: 'Notificações diárias sobre humor e metas',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Schedule daily notifications
  Future<void> scheduleDailyNotifications() async {
    // Cancel existing scheduled notifications
    await _localNotifications.cancelAll();

    // Schedule morning notification (9:00 AM)
    await _scheduleNotification(
      id: 1,
      title: 'Bom dia! 🌅',
      body: 'Como você está se sentindo hoje? Registre seu humor!',
      hour: 9,
      minute: 0,
    );

    // Schedule evening notification (8:00 PM)
    await _scheduleNotification(
      id: 2,
      title: 'Boa noite! 🌙',
      body: 'Não esqueça de suas metas! Confira seu progresso.',
      hour: 20,
      minute: 0,
    );

    debugPrint('Daily notifications scheduled');
  }

  /// Schedule a notification at specific time
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'sentimento_daily',
      'Lembretes Diários',
      channelDescription: 'Notificações diárias sobre humor e metas',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  /// Enable/disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);

    if (enabled) {
      await scheduleDailyNotifications();
    } else {
      await _localNotifications.cancelAll();
    }
  }

  /// Send test notification
  Future<void> sendTestNotification() async {
    await _showLocalNotification(
      title: 'Teste de Notificação 🎉',
      body: 'As notificações estão funcionando corretamente!',
    );
  }
}
