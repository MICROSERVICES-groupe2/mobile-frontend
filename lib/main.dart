import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'core/notifications/notification_service.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to initialize Firebase, but ignore if config is missing for now
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization skipped or failed: $e');
  }

  // Initialize dependency injection
  await di.initDependencies();

  // Initialize Notification Service
  try {
    final notificationService = di.sl<NotificationService>();
    await notificationService.init();
  } catch (e) {
    debugPrint('Notification Service initialization failed: $e');
  }

  runApp(const BankPlatformApp());
}
