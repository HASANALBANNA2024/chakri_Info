import 'package:chakri_info/Questions/question_bank_model.dart';
import 'package:chakri_info/screens/splash_screen.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'; // নতুন যোগ করা হয়েছে
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';

// Global Notifier
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  // Flutter binding confirm
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Native splash screen dore rakha
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // ৩. Firebase Initialize
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase Initialize Error: $e");
  }

  // ৪. Hive Initialize
  await Hive.initFlutter();

  // adapter register
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(JobSyncModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(QuestionBankModelAdapter());
  }

  // box open
  try {
    await Hive.openBox<JobSyncModel>('jobsBox'); // জব সার্কুলারের জন্য
    await Hive.openBox('exam_cache'); // এক্সাম রেজাল্ট বা ছোট ডাটার জন্য
    await Hive.openBox('settings'); // থিম বা অন্য সেটিংসে জন্য
  } catch (e) {
    debugPrint("Hive Box Opening Error: $e");
  }

  // after completed the work of android then native remove
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
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.light,
            ),
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
