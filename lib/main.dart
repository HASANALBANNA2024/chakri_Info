import 'package:chakri_info/screens/dashboard_screen.dart';
import 'package:firebase_core/firebase_core.dart'; // নতুন যোগ করা হয়েছে
import 'package:flutter/material.dart';

import 'firebase_options.dart';

// থিম কন্ট্রোলার
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  // ১. ফ্লাটার বাইন্ডিং নিশ্চিত করা
  WidgetsFlutterBinding.ensureInitialized();

  // ২. ফায়ারবেস শুরু করা (এটি আপনার আগের এররগুলো সমাধান করবে)
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
          title: 'Chakri Info',
          // লাইট থিম সেটিংস
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.indigo,
            scaffoldBackgroundColor: const Color(0xFFF0F2F5),
          ),
          // ডার্ক থিম সেটিংস
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
          ),
          themeMode: currentMode, // থিম পরিবর্তন নিয়ন্ত্রণ করবে
          home: DashboardScreen(),
        );
      },
    );
  }
}
