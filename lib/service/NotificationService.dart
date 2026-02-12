import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:ui';
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationConfig {
  final bool enableVibration;
  final bool enableSound;
  final String? soundFile;
  final bool enableLed;
  final int? ledColor;
  final bool useBigText;
  final Importance importance;
  final Priority priority;
  final bool showBadge;
  final String? category;

  const NotificationConfig({
    this.enableVibration = true,
    this.enableSound = true,
    this.soundFile,
    this.enableLed = true,
    this.ledColor = 0xFF00FF00,
    this.useBigText = false,
    this.importance = Importance.max,
    this.priority = Priority.high,
    this.showBadge = true,
    this.category,
  });
}

class NotificationService extends GetxService {
  static NotificationService get to => Get.find<NotificationService>();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      tz.initializeTimeZones();
      late String timeZoneName;

      try {
        final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
        timeZoneName = timeZoneInfo.identifier; // ✅ Fixed for v5.0.1
        if (timeZoneName == "Asia/Calcutta") {
          timeZoneName = "Asia/Kolkata";
        }
      } catch (e) {
        Get.log('Error getting local timezone: $e', isError: true);
        timeZoneName = 'Asia/Kolkata';
      }

      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      }

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
            requestCriticalPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidSettings, iOS: iosSettings);

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onSelectNotification,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      await _createAndroidChannel();
      await requestPermissions();

      Get.log('✅ NotificationService initialized successfully');
    } catch (e, stackTrace) {
      Get.log('Error initializing notifications: $e', isError: true);
      Get.log(stackTrace.toString(), isError: true);
      rethrow;
    }
  }

  Future<void> _createAndroidChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'main_channel',
      'Main Channel',
      description: 'Main notification channel for app',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Color(0xFF00FF00),
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> requestPermissions() async {
    try {
      if (GetPlatform.isAndroid) {
        final androidPlugin = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final notificationsGranted = await androidPlugin
            ?.requestNotificationsPermission();
        final alarmsGranted = await androidPlugin
            ?.requestExactAlarmsPermission();

        if (!(notificationsGranted ?? false)) {
          Get.snackbar(
            'Warning',
            'Notification permissions not granted. Please enable them in Settings.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }

        if (!(alarmsGranted ?? false)) {
          Get.snackbar(
            'Warning',
            'Exact alarms permission not granted. Scheduled notifications may not work.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else if (GetPlatform.isIOS) {
        final iosPlugin = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        final granted = await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
          critical: true,
        );
        if (!(granted ?? false)) {
          Get.snackbar(
            'Warning',
            'Notification permissions not granted. Please enable them in Settings.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e, stackTrace) {
      Get.log('Error requesting permissions: $e', isError: true);
      Get.log(stackTrace.toString(), isError: true);
      rethrow;
    }
  }

  void _onSelectNotification(NotificationResponse response) {
    Get.log('Notification tapped with payload: ${response.payload}');
    if (response.payload != null) {
      switch (response.payload) {
        case 'default_morning_habit':
          Get.toNamed('/addHabit');
          break;
        case 'default_midday_breathing':
          Get.toNamed('/meditation');
          break;
        case 'default_evening_reflection':
          Get.toNamed('/addReflection');
          break;
        default:
          Get.log('Unknown payload: ${response.payload}');
      }
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    NotificationConfig config = const NotificationConfig(),
  }) async {
    try {
      final now = DateTime.now();
      DateTime finalScheduledTime = scheduledTime;
      if (scheduledTime.isBefore(now)) {
        final tomorrow = now.add(const Duration(days: 1));
        finalScheduledTime = DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          scheduledTime.hour,
          scheduledTime.minute,
        );
      }

      final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
        finalScheduledTime,
        tz.local,
      );

      final androidDetails = AndroidNotificationDetails(
        'main_channel',
        'Main Channel',
        channelDescription: 'Main notification channel for app',
        importance: config.importance,
        priority: config.priority,
        showWhen: true,
        enableVibration: config.enableVibration,
        playSound: config.enableSound,
        sound: config.soundFile != null
            ? RawResourceAndroidNotificationSound(
                config.soundFile!.replaceAll('.mp3', ''),
              )
            : null,
        enableLights: config.enableLed,
        ledColor: config.ledColor != null ? Color(config.ledColor!) : null,
        ledOnMs: config.enableLed ? 1000 : null,
        ledOffMs: config.enableLed ? 500 : null,
        styleInformation: config.useBigText
            ? BigTextStyleInformation(body)
            : null,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: config.showBadge,
        presentSound: config.enableSound,
        sound: config.soundFile,
        categoryIdentifier: config.category,
        presentBanner: true,
        presentList: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: null, // ✅ replaced deprecated parameter
        payload: payload,
      );
    } catch (e, stackTrace) {
      Get.log('Error scheduling notification: $e', isError: true);
      Get.log(stackTrace.toString(), isError: true);
      rethrow;
    }
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationConfig config = const NotificationConfig(),
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'main_channel',
        'Main Channel',
        channelDescription: 'Main notification channel for app',
        importance: config.importance,
        priority: config.priority,
        showWhen: true,
        enableVibration: config.enableVibration,
        playSound: config.enableSound,
        sound: config.soundFile != null
            ? RawResourceAndroidNotificationSound(
                config.soundFile!.replaceAll('.mp3', ''),
              )
            : null,
        enableLights: config.enableLed,
        ledColor: config.ledColor != null ? Color(config.ledColor!) : null,
        ledOnMs: config.enableLed ? 1000 : null,
        ledOffMs: config.enableLed ? 500 : null,
        styleInformation: config.useBigText
            ? BigTextStyleInformation(body)
            : null,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: config.showBadge,
        presentSound: config.enableSound,
        sound: config.soundFile,
        categoryIdentifier: config.category,
        presentBanner: true,
        presentList: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e, stackTrace) {
      Get.log('Error showing instant notification: $e', isError: true);
      Get.log(stackTrace.toString(), isError: true);
      rethrow;
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {
      Get.log('Error cancelling notification: $e', isError: true);
      rethrow;
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      Get.log('Error cancelling all notifications: $e', isError: true);
      rethrow;
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
    } catch (e) {
      Get.log('Error getting pending notifications: $e', isError: true);
      return [];
    }
  }

  Future<bool> isNotificationPermissionGranted() async {
    try {
      if (GetPlatform.isAndroid) {
        final bool? granted = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.areNotificationsEnabled();
        return granted ?? false;
      } else if (GetPlatform.isIOS) {
        final iosPlugin = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        final settings = await iosPlugin?.checkPermissions();
        return settings != null &&
            (settings.isAlertEnabled ||
                settings.isBadgeEnabled ||
                settings.isSoundEnabled);
      }
      return false;
    } catch (e) {
      Get.log('Error checking permissions: $e', isError: true);
      return false;
    }
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  Get.log('Background notification tapped: ${response.payload}');
}
