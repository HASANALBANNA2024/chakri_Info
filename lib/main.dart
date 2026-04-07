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

  // ১. Hive Initialize
  await Hive.initFlutter();

  // ২. Register Adapters
  // JobSyncModelAdapter (আগে থেকেই ছিল - ID: 0)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(JobSyncModelAdapter());
  }

  // QuestionBankModelAdapter (নতুন - ID: 1)
  // এটি তখনই কাজ করবে যখন মডেলে @HiveType(typeId: 1) থাকবে
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(QuestionBankModelAdapter());
  }

  // ৩. ওপেন লোকাল বক্সসমূহ
  await Hive.openBox<JobSyncModel>('jobsBox'); // আগের জব বক্স
  await Hive.openBox('exam_cache'); // পরীক্ষার কার্ড ক্যাশ করার বক্স

  // ৪. Firebase Initialize
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
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
