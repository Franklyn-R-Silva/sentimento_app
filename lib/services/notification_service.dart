import 'dart:convert';
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
  static const String _schedulesKey = 'notification_schedules';

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  List<NotificationSchedule> _schedules = [];
  List<NotificationSchedule> get schedules => List.unmodifiable(_schedules);

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

    // Load schedules
    await _loadSchedules();

    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Set up notification tap handler
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

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

  /// Load schedules from SharedPreferences
  Future<void> _loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final String? schedulesJson = prefs.getString(_schedulesKey);

    if (schedulesJson != null) {
      try {
        final decoded = jsonDecode(schedulesJson) as List<dynamic>;
        _schedules = decoded
            .map(
              (e) => NotificationSchedule.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      } catch (e) {
        debugPrint('Error loading schedules: $e');
        _schedules = [];
      }
    }

    // Initialize defaults if empty
    if (_schedules.isEmpty) {
      debugPrint('Initializing default schedules');
      _schedules = [
        NotificationSchedule(
          id: 'morning',
          hour: 8,
          minute: 0,
          title: 'Bom dia! 🌅',
          body: 'Como você está se sentindo hoje? Registre seu humor!',
          activeDays: [1, 2, 3, 4, 5, 6, 7], // Every day
        ),
        NotificationSchedule(
          id: 'afternoon',
          hour: 12,
          minute: 0,
          title: 'Boa tarde! ☀️',
          body: 'Tire um momento para respirar e registrar seu dia.',
          activeDays: [1, 2, 3, 4, 5, 6, 7],
        ),
        NotificationSchedule(
          id: 'evening',
          hour: 18,
          minute: 0,
          title: 'Boa noite! 🌙',
          body: 'Não esqueça de suas metas! Confira seu progresso.',
          activeDays: [1, 2, 3, 4, 5, 6, 7],
        ),
      ];
      await _saveSchedules();
    }

    // Reschedule everything
    await rescheduleAll();
  }

  /// Save schedules to SharedPreferences
  Future<void> _saveSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _schedules.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_schedulesKey, encoded);

    // Refresh notifications
    await rescheduleAll();
  }

  /// Add a new schedule
  Future<void> addSchedule(NotificationSchedule schedule) async {
    _schedules.add(schedule);
    await _saveSchedules();
  }

  /// Update an existing schedule
  Future<void> updateSchedule(NotificationSchedule schedule) async {
    final index = _schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _schedules[index] = schedule;
      await _saveSchedules();
    }
  }

  /// Delete a schedule
  Future<void> deleteSchedule(String id) async {
    _schedules.removeWhere((s) => s.id == id);
    await _saveSchedules();
  }

  /// Reschedule all notifications based on current configuration
  Future<void> rescheduleAll() async {
    // 1. Cancel all existing notifications
    await _localNotifications.cancelAll();

    // 2. Check if global notifications are enabled
    if (!await areNotificationsEnabled()) {
      debugPrint('Notifications globally disabled. Skipping scheduling.');
      return;
    }

    // 3. Schedule each enabled item
    int notificationIdCounter = 100;

    for (var schedule in _schedules) {
      if (!schedule.isEnabled) continue;

      for (var day in schedule.activeDays) {
        // We generate a unique ID for each day of the week for this schedule
        // ID format: schedule_hash + dayIndex
        final notificationId = notificationIdCounter++;

        await _scheduleNotificationForDay(
          id: notificationId,
          title: schedule.title,
          body: schedule.body,
          hour: schedule.hour,
          minute: schedule.minute,
          dayOfWeek: day,
        );
      }
    }

    debugPrint(
      'All notifications rescheduled. Total active: ${notificationIdCounter - 100}',
    );
  }

  /// Schedule a single notification for a specific day of week
  Future<void> _scheduleNotificationForDay({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required int dayOfWeek, // 1 = Mon, 7 = Sun
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

    // Calculate the next occurrence of this day and time
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Adjust to correct day of week
    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // If time passed on this specific day (and it's today), move to next week
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          DateTimeComponents.dayOfWeekAndTime, // Repeat weekly on this day/time
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
      await rescheduleAll();
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

  /// Get pending notifications (debug)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }
}

class NotificationSchedule {
  final String id;
  final int hour;
  final int minute;
  final String title;
  final String body;
  final List<int> activeDays; // 1 = Mon, 7 = Sun
  final bool isEnabled;

  NotificationSchedule({
    required this.id,
    required this.hour,
    required this.minute,
    required this.title,
    required this.body,
    required this.activeDays,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'hour': hour,
    'minute': minute,
    'title': title,
    'body': body,
    'activeDays': activeDays,
    'isEnabled': isEnabled,
  };

  factory NotificationSchedule.fromJson(Map<String, dynamic> json) =>
      NotificationSchedule(
        id: json['id'] as String,
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        title: json['title'] as String,
        body: json['body'] as String,
        activeDays: List<int>.from(json['activeDays'] as List),
        isEnabled: json['isEnabled'] as bool,
      );
}
