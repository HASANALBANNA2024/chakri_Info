import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contact Us")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("যেকোনো প্রয়োজনে আমাদের জানান", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          _contactTile(context, Icons.email_outlined, "অফিসিয়াল ইমেইল", "support@bannatech.com", Colors.red),
          _contactTile(context, Icons.language_outlined, "ওয়েবসাইট", "www.bannatech.com", Colors.blue),
          _contactTile(context, Icons.location_on_outlined, "হেড অফিস", "বনানী, ঢাকা, বাংলাদেশ", Colors.green),
          const SizedBox(height: 40),
          const Text("সোশ্যাল মিডিয়া", style: TextStyle(fontWeight: FontWeight.bold)),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.facebook, color: Colors.blue, size: 35)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.camera_alt_outlined, color: Colors.pink, size: 35)),
            ],
          )
        ],
      ),
    );
  }

  Widget _contactTile(BuildContext context, IconData icon, String title, String value, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontSize: 13)),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }
}