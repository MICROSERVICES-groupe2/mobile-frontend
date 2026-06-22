import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../injection_container.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Handling a background message: ${message.messageId}');
  }
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Request permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    // 2. Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Local Notifications Setup
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );

    // 4. Create local notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'bank_notifications', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important bank notifications.', // description
      importance: Importance.high,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 5. Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null && !kIsWeb) {
        _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
            ),
          ),
          payload: message.data['type'],
        );
      }
    });

    // 6. Handle app opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data['type']);
    });

    // 7. Get and Upload token
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        if (kDebugMode) {
          print("FCM Token: $token");
        }
        await uploadToken(token);
      }
      
      _fcm.onTokenRefresh.listen((newToken) async {
        await uploadToken(newToken);
      });
    } catch (e) {
      if (kDebugMode) {
        print("Failed to get FCM token: $e");
      }
    }
  }

  Future<void> uploadToken(String token) async {
    try {
      final authRepo = sl<AuthRepository>();
      final isAuthResult = await authRepo.isAuthenticated();
      final isAuth = isAuthResult.fold((_) => false, (authenticated) => authenticated);
      
      if (isAuth) {
        await authRepo.sendFcmToken(token);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to upload FCM token: $e");
      }
    }
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null) return;
    if (kDebugMode) {
      print("Notification tapped with payload: $payload");
    }
    
    // Router pattern based on type
    // In production we would navigate using go_router
    // For now we just print it or can use a global navigator key or let app.dart listen
  }
}
