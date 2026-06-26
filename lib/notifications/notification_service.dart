import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'cineflow_channel',
      'CineFlow Notifications',
      channelDescription: 'CineFlow app notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'cineflow_reminder_channel',
      'CineFlow Reminders',
      channelDescription: 'CineFlow reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      // ignore: deprecated_member_use
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> showNewReleaseNotification({
    required String movieTitle,
    required String releaseDate,
  }) async {
    final title = 'new_release'.tr;
    final body = '$movieTitle $releaseDate tarihinde yayınlanacak!';
    
    await showNotification(
      title: title,
      body: body,
      payload: 'new_release',
    );
  }

  Future<void> showFavoriteActorNotification({
    required String actorName,
    required String movieTitle,
  }) async {
    final title = 'favorite_actor_movie'.tr;
    final body = '$actorName yeni bir filmde: $movieTitle';
    
    await showNotification(
      title: title,
      body: body,
      payload: 'favorite_actor',
    );
  }

  Future<void> showReminderNotification({
    required String title,
    required String message,
    required DateTime reminderTime,
  }) async {
    final reminderTitle = 'reminder'.tr;
    final body = '$title: $message';
    
    await scheduleNotification(
      title: reminderTitle,
      body: body,
      scheduledDate: reminderTime,
      payload: 'reminder',
    );
  }

  Future<void> showNewsNotification({
    required String newsTitle,
    required String newsSummary,
  }) async {
    final title = 'news'.tr;
    final body = '$newsTitle: $newsSummary';
    
    await showNotification(
      title: title,
      body: body,
      payload: 'news',
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
} 