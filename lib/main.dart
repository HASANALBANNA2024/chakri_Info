import 'package:chakri_info/Questions/question_bank_model.dart';
import 'package:chakri_info/notifications/notification_model.dart';
import 'package:chakri_info/screens/splash_screen.dart';
import 'package:chakri_info/services/notification_service.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await NotificationService.initialize();

    Future.delayed(const Duration(seconds: 5), () async {
      String? token = await NotificationService.getDeviceToken();
      if (token != null) {
        debugPrint("\n🚀 DEVICE TOKEN: $token\n");
      }
    });
  } catch (e) {
    debugPrint("Firebase Init Error: $e");
  }

  // Hive Setup
  try {
    await Hive.initFlutter();

    // Register Adapters
    if (!Hive.isAdapterRegistered(0))
      Hive.registerAdapter(JobSyncModelAdapter());
    if (!Hive.isAdapterRegistered(1))
      Hive.registerAdapter(QuestionBankModelAdapter());
    // Updated to Adapter ID 2
    if (!Hive.isAdapterRegistered(2))
      Hive.registerAdapter(NotificationModelAdapter());

    // Open boxes
    await Future.wait([
      Hive.openBox<JobSyncModel>('jobsBox'),
      Hive.openBox<JobSyncModel>('bookmarkBox'),
      Hive.openBox('exam_cache'),
      Hive.openBox('settings'),
      Hive.openBox<NotificationModel>('notifications'),
    ]);
  } catch (e) {
    debugPrint("Hive Setup Error: $e");
  }

  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Chakri Info',
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.dark,
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
