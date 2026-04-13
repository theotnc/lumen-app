import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Paris'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final iosGranted = await ios?.requestPermissions(
      alert: true, badge: true, sound: true,
    );
    final androidGranted = await android?.requestNotificationsPermission();
    return (iosGranted ?? false) || (androidGranted ?? false);
  }

  Future<void> scheduleAll(List<int> hours) async {
    await _plugin.cancelAll();
    for (final hour in hours) {
      await _scheduleDailyAt(hour);
    }
  }

  Future<void> _scheduleDailyAt(int hour) async {
    final (title, body) = _contentFor(hour);

    await _plugin.zonedSchedule(
      hour, // id unique par heure
      title,
      body,
      _nextInstanceOf(hour),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'Rappels de prière',
          channelDescription: 'Notifications pour les moments de prière',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOf(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  (String, String) _contentFor(int hour) {
    switch (hour) {
      case 6: return ('Laudes', 'Commencez votre journée avec la prière du matin.');
      case 12: return ('Angélus', "L'ange du Seigneur a annoncé à Marie...");
      case 18: return ('Vêpres', 'Prenez un moment pour la prière du soir.');
      case 21: return ('Complies', 'Terminez votre journée dans la paix du Seigneur.');
      default: return ('Moment de prière', 'Un instant pour prier.');
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
