import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About Us"), elevation: 0),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // App logo section
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: ClipOval(
                  child: Image.asset('assets/logo.png', // আপনার লোগো পাথ
                      height: 100, width: 100, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.business, size: 50)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Chakri Info", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text("Developed by Banna_Tech", style: TextStyle(color: Colors.blue, letterSpacing: 1.2)),
            const Padding(
              padding: EdgeInsets.all(25.0),
              child: Text(
                "Banna_Tech-এর একটি নির্ভরযোগ্য প্ল্যাটফর্ম হলো 'Chakri Info'। আমরা বেকারত্ব দূরীকরণে বদ্ধপরিকর। আমাদের লক্ষ্য হলো দেশের প্রতিটি প্রান্তে সঠিক চাকরির খবর দ্রুত পৌঁছে দেওয়া। আমরা কঠোরভাবে তথ্য যাচাই করি যাতে আপনি কোনো বিভ্রান্তিকর তথ্য না পান।",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}