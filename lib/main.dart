import 'package:chakri_info/screens/dashboard_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'firebase_options.dart';


ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ১. Hive Initialize
  await Hive.initFlutter();

  // ২. Register Adapter (অবশ্যই মডেল ফাইল সেভ করে বিল্ড রান করতে হবে)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(JobSyncModelAdapter());
  }

  // ৩. ওপেন লোকাল বক্স
  await Hive.openBox<JobSyncModel>('jobsBox');

  // Firebase Initialize
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(brightness: Brightness.light, primarySwatch: Colors.indigo),
          darkTheme: ThemeData(brightness: Brightness.dark),
          home: DashboardScreen(),
        );
      },
    );
  }
}