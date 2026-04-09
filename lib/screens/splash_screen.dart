import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chakri_info/screens/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // ডাটাবেস এবং প্রয়োজনীয় সব ফাইল লোড করার ফাংশন
  Future<void> _initializeApp() async {
    try {
      // ১. জব সার্কুলার এবং অন্যান্য ডাটার জন্য Hive বক্সগুলো ওপেন করা
      // আপনার যেসব বক্স দরকার সেগুলো এখানে দিন
      await Future.wait([
        Hive.openBox('job_cache'),
        Hive.openBox('settings'),
        // আপনি চাইলে এখানে ১-২ সেকেন্ডের একটা কৃত্রিম ডিলে দিতে পারেন
        // যাতে লোগোটা ইউজার একটু দেখতে পায়
        Future.delayed(const Duration(seconds: 2)),
      ]);

      // ২. সব লোড হয়ে গেলে ড্যাশবোর্ডে পাঠিয়ে দেওয়া
      if (mounted) {
        // ফ্রেম রেন্ডার শেষ হওয়া পর্যন্ত অপেক্ষা করবে
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        });
      }
    } catch (e) {
      debugPrint("Initialization Error: $e");
      // এরর হলেও ড্যাশবোর্ডে পাঠিয়ে দিন যাতে অ্যাপ আটকে না থাকে
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ১. লোগো পার্ট
            Image.asset(
              'assets/images/app_icon.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 15),

            // ২. অ্যাপের নাম (Chakri Info)
            Text(
              "Chakri Info",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isDark ? Colors.white : Colors.indigo[900],
              ),
            ),

            const SizedBox(height: 10),

            // ৩. স্লোগান বা ট্যাগলাইন
            Text(
              "প্রস্তুতি নিন আত্মবিশ্বাসের সাথে",
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 40),

            // ৪. ছোট এবং ক্লিন প্রগ্রেস বার
            const SizedBox(
              width: 50,
              child: LinearProgressIndicator(
                color: Colors.indigo,
                backgroundColor: Colors.indigoAccent,
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}