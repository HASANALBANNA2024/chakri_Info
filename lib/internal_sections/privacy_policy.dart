import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("গোপনীয়তা নীতিমালা", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _policySection("১. তথ্য সংগ্রহ", "Banna_Tech আপনার ব্যক্তিগত গোপনীয়তাকে সম্মান করে। আমরা আপনার অনুমতি ছাড়া কোনো সংবেদনশীল তথ্য সংগ্রহ করি না।"),
            _policySection("২. তথ্যের ব্যবহার", "আপনার সংগৃহীত ডাটা শুধুমাত্র নোটিফিকেশন সার্ভিস এবং অ্যাপের পারফরম্যান্স উন্নত করার কাজে ব্যবহৃত হয়।"),
            _policySection("৩. কুকিজ এবং ট্র্যাকিং", "অ্যাপের বাগ ফিক্সিং এবং ইউজার এক্সপেরিয়েন্স ট্র্যাক করতে আমরা নিরাপদ অ্যানালিটিক্স ব্যবহার করি।"),
          ],
        ),
      ),
    );
  }

  Widget _policySection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.blueGrey)),
        ],
      ),
    );
  }
}