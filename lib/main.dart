import 'package:chakri_info/screens/dashboard_screen.dart';
import 'package:firebase_core/firebase_core.dart'; // নতুন যোগ করা হয়েছে
import 'package:flutter/material.dart';

import 'firebase_options.dart';

// Theme controller
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  //flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // firebase start
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
          // light theme
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.indigo,
            scaffoldBackgroundColor: const Color(0xFFF0F2F5),
          ),
          // dark theme
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
          ),
          themeMode: currentMode, // theme control
          home: DashboardScreen(),
        );
      },
    );
  }
}
