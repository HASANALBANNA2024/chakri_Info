import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms & Conditions")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.gavel_rounded, size: 60, color: Colors.blueGrey),
          const SizedBox(height: 20),
          const Center(child: Text("ব্যবহারের শর্তাবলী", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          const SizedBox(height: 30),
          _termCard("নির্ভুল তথ্য", "আমরা সরকারি ও বেসরকারি বিভিন্ন উৎস থেকে তথ্য সংগ্রহ করি। তথ্যের শতভাগ সঠিকতা যাচাইয়ের দায়িত্ব নিয়োগকারী কর্তৃপক্ষের।"),
          _termCard("সতর্কতা", "কোনো চাকরিপ্রার্থী যদি এই অ্যাপের মাধ্যমে পাওয়া খবরের ভিত্তিতে কাউকে টাকা লেনদেন করে, তবে তার জন্য Banna_Tech দায়ী থাকবে না।"),
          _termCard("ব্যাবহারবিধি", "এই অ্যাপের কোনো কন্টেন্ট বা লোগো বিনা অনুমতিতে কপি করা আইনত দণ্ডনীয় অপরাধ।"),
        ],
      ),
    );
  }

  Widget _termCard(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• $title", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(desc, style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.4)),
          ),
        ],
      ),
    );
  }
}