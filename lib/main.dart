import 'package:chakri_info/Questions/question_bank_model.dart';
import 'package:chakri_info/screens/splash_screen.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chakri_info/services/notification_services.dart';
import 'firebase_options.dart';

// ১. ব্যাকগ্রাউন্ড নোটিফিকেশন হ্যান্ডেলার (Top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // ব্যাকগ্রাউন্ডে থাকলে নতুন করে ফায়ারবেস ইনিশিয়ালাইজ করতে হয়
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

// থিম ম্যানেজমেন্টের জন্য গ্লোবাল নোটিফায়ার
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  // নিশ্চিত করুন ফ্লাটার ইঞ্জিন লোড হয়েছে
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // স্প্ল্যাশ স্ক্রিন ধরে রাখা
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    // ২. ফায়ারবেস এবং নোটিফিকেশন সার্ভিস সেটআপ
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // ব্যাকগ্রাউন্ড লিসেনার সেটআপ
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // আপনার তৈরি করা নোটিফিকেশন সার্ভিস শুরু করা
    await NotificationService.initialize();

    // টোকেন প্রিন্ট করার আগে ৫ সেকেন্ড সময় দেওয়া (যাতে সার্ভার থেকে রেসপন্স আসার সময় পায়)
    Future.delayed(const Duration(seconds: 5), () async {
      String? token = await NotificationService.getDeviceToken();
      if (token != null) {
        print("\n\n");
        print("===============================================");
        print("🚀 YOUR DEVICE TOKEN: $token");
        print("===============================================");
        print("\n\n");
      } else {
        print("❌ Device Token still null after 5s. Check Internet/Firebase.");
      }
    });

  } catch (e) {
    debugPrint("Firebase/Notification Init Error: $e");
  }

  // ৩. হাইভ (Hive) সেটআপ - এরর হ্যান্ডেলিং সহ
  try {
    await Hive.initFlutter();

    // অ্যাডাপ্টার রেজিস্টার (একবারই করা উচিত)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(JobSyncModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(QuestionBankModelAdapter());
    }

    // বক্সগুলো ওপেন করা
    await Future.wait([
      Hive.openBox<JobSyncModel>('jobsBox'),
      Hive.openBox<JobSyncModel>('bookmarkBox'),
      Hive.openBox('exam_cache'),
      Hive.openBox('settings'),
    ]);
  } catch (e) {
    debugPrint("Hive Setup Error: $e");
  }

  // স্প্ল্যাশ স্ক্রিন সরিয়ে ফেলা
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
          // লাইট থিম
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.light,
            ),
          ),
          // ডার্ক থিম
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