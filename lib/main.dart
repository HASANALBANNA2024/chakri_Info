import 'package:chakri_info/Questions/question_bank_model.dart';
import 'package:chakri_info/screens/dashboard_screen.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';

ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ১. Firebase Initialize (এটি সবার আগে রাখা ভালো)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ২. Hive Initialize
  await Hive.initFlutter();

  // ৩. Register Adapters (এখানে ডবল initFlutter ছিল, সেটি বাদ দেওয়া হয়েছে)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(JobSyncModelAdapter());
  }

  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(QuestionBankModelAdapter());
  }

  // ৪. ওপেন লোকাল বক্সসমূহ (await দিয়ে নিশ্চিত করা)
  try {
    await Hive.openBox<JobSyncModel>('jobsBox');

    // আপনার ৫ নম্বর ফাইলে আপনি "exams_${widget.categoryName}" নামে বক্স ওপেন করছেন।
    // কিন্তু এখানে 'exam_cache' ওপেন করছেন।
    // যদি প্রোভাইডারের জন্য 'exam_cache' লাগে তবে এটি ঠিক আছে।
    await Hive.openBox('exam_cache');
  } catch (e) {
    print("Hive Box Open Error: $e");
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
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.indigo,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
          home: DashboardScreen(),
        );
      },
    );
  }
}
