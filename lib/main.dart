import 'package:chakri_info/Questions/question_bank_model.dart';
import 'package:chakri_info/screens/dashboard_screen.dart';
import 'package:chakri_info/screens/splash_screen.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';

// গ্লোবাল থিম নটিফায়ার
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  // ১. ফ্ল্যাটার বাইন্ডিং নিশ্চিত করা
  WidgetsFlutterBinding.ensureInitialized();

  // ২. Firebase Initialize
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint("Firebase Initialize Error: $e");
  }

  // ৩. Hive Initialize
  await Hive.initFlutter();

  // অ্যাডাপ্টারগুলো রেজিস্টার করা
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(JobSyncModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(QuestionBankModelAdapter());
  }

  // ৪. সবচাইতে গুরুত্বপূর্ণ বক্সগুলো এখানে ওপেন করুন (যাতে Box Not Found এরর না আসে)
  try {
    await Hive.openBox<JobSyncModel>('jobsBox'); // জব সার্কুলারের জন্য
    await Hive.openBox('exam_cache');            // এক্সাম রেজাল্ট বা ছোট ডাটার জন্য
    await Hive.openBox('settings');              // থিম বা অন্য সেটিংসে জন্য
  } catch (e) {
    debugPrint("Hive Box Opening Error: $e");
  }

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
          home: const SplashScreen(), // লোডিং এর কাজ Splash এ হবে, কিন্তু Box রেডি থাকবে
        );
      },
    );
  }
}