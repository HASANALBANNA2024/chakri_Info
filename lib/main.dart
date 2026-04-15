import 'dart:convert';
import 'package:chakri_info/Questions/question_bank_model.dart';
import 'package:chakri_info/notifications/notification_model.dart';
import 'package:chakri_info/screens/splash_screen.dart';
import 'package:chakri_info/services/notification_services.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';

// --- নোটিফিকেশন ডাটাকে মডেল-এ কনভার্ট করার হেল্পার ফাংশন ---
JobSyncModel _mapToJobModel(Map<String, dynamic> data) {
  return JobSyncModel(
    id: data['id']?.toString() ?? '',
    title: data['title']?.toString() ?? '',
    company: data['company']?.toString() ?? '',
    start: data['start_date']?.toString() ?? '',
    deadline: data['end_date']?.toString() ?? '',
    applyLink: data['apply_link']?.toString() ?? '',
    logo: data['logo']?.toString() ?? '',
    totalpost: (data['total_posts'] ?? '0').toString(),
    circularImage: List<String>.from(data['images'] ?? []),
    isGovt: data['is_govt'] ?? false,
    description: data['description']?.toString() ?? '',
    step1: data['step1']?.toString() ?? '',
    step2: data['step2']?.toString() ?? '',
    step3: data['step3']?.toString(),
    step4: data['step4']?.toString(),
    publishDate: data['publish_date']?.toString(),
    positions: data['positions'] as List<dynamic>?,
    education: (data['education'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
  );
}

// --- Background Message Handler ---
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(JobSyncModelAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(QuestionBankModelAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(NotificationModelAdapter());

    if (message.data['jobData'] != null) {
      final box = await Hive.openBox<JobSyncModel>('jobsBox');
      final Map<String, dynamic> data = jsonDecode(message.data['jobData']);
      final newJob = _mapToJobModel(data);
      await box.put(newJob.id, newJob);
      debugPrint("✅ Background: Saved ${newJob.title}");
    }
  } catch (e) {
    debugPrint("Background Handling Error: $e");
  }
}

ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 1. Hive Setup (First priority)
  try {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(JobSyncModelAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(QuestionBankModelAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(NotificationModelAdapter());

    await Future.wait([
      Hive.openBox<JobSyncModel>('jobsBox'),
      Hive.openBox<JobSyncModel>('bookmarkBox'),
      Hive.openBox('exam_cache'),
      Hive.openBox('settings'),
      Hive.openBox<NotificationModel>('notifications'),
    ]);
  } catch (e) {
    debugPrint("❌ Hive Error: $e");
  }

  // 2. Firebase & Notification Setup
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Set background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize Local Notifications
    await NotificationService.initialize();

    // Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.data['jobData'] != null) {
        try {
          final box = Hive.box<JobSyncModel>('jobsBox');
          final Map<String, dynamic> data = jsonDecode(message.data['jobData']);
          final newJob = _mapToJobModel(data);
          await box.put(newJob.id, newJob);
          debugPrint("✅ Foreground: Synced ${newJob.title}");
        } catch (e) {
          debugPrint("Sync Error: $e");
        }
      }
    });

    // Device Token for Testing
    NotificationService.getDeviceToken().then((token) {
      if (token != null) debugPrint("🚀 FCM TOKEN: $token");
    });

  } catch (e) {
    debugPrint("Firebase Setup Error: $e");
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
            brightness: Brightness.light,
            colorSchemeSeed: Colors.indigo,
            appBarTheme: const AppBarTheme(centerTitle: true),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.indigo,
            appBarTheme: const AppBarTheme(centerTitle: true),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}