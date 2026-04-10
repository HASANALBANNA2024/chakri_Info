import 'package:chakri_info/Questions/question_bank_model.dart';
import 'package:chakri_info/screens/splash_screen.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';

// Global Notifier for Theme Management
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  // Ensure Flutter framework is fully initialized
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Keep the native splash screen visible until initialization is complete
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Firebase with platform-specific options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase Initialize Error: $e");
  }

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register Adapters for Hive Models
  // Check registration to prevent "Adapter already registered" errors
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(JobSyncModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(QuestionBankModelAdapter());
  }

  // Open Hive Boxes for various functionalities
  try {
    // Standard jobs box
    await Hive.openBox<JobSyncModel>('jobsBox');

    // NEW: Open Bookmark box for saved jobs (Using JobSyncModel)
    await Hive.openBox<JobSyncModel>('bookmarkBox');

    // Box for exam results and caching
    await Hive.openBox('exam_cache');

    // Box for app settings and theme preferences
    await Hive.openBox('settings');
  } catch (e) {
    debugPrint("Hive Box Opening Error: $e");
  }

  // Remove the native splash screen after background tasks are done
  FlutterNativeSplash.remove();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Chakri Info',
          themeMode: currentMode,
          // Light Theme Configuration
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.light,
            ),
          ),
          // Dark Theme Configuration
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.dark,
            ),
          ),
          // App Entry Point
          home: const SplashScreen(),
        );
      },
    );
  }
}