import 'package:cloud_firestore/cloud_firestore.dart'; // ডায়নামিক ডাটার জন্য
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late Box settingsBox;

  // আপনার দেওয়া অরিজিনাল লিস্ট (এগুলো যেমন আছে তেমনই থাকবে)
  final List<String> jobCats = [
    'Government (সরকারি)',
    'Engineering (ইঞ্জিনিয়ারিং)',
    'Bank (ব্যাংক)',
    'Defense (ডিফেন্স)',
    'Medical (মেডিক্যাল)',
    'Private (বেসরকারি)',
    'BCS (বিসিএস)',
    'Teacher (শিক্ষক নিয়োগ)',
    'Pharmaceuticals (ফার্মাসিউটিক্যালস)',
    'NGO (এনজিও)',
    'IT & Software (আইটি ও সফটওয়্যার)',
    'Others (অন্যান্য)',
  ];

  final List<String> quesCats = [
    'BCS (বিসিএস প্রশ্ন)',
    'Govt Job',
    'Bank Job',
    'Primary (শিক্ষক)',
    'NTRCA (নিবন্ধন)',
    'ভর্তি প্রস্তুতি',
    'Medical & Nursing',
    'Technical (ইঞ্জিনিয়ারিং)',
    'Others (অন্যান্য)',
    'কৃষি ও মৎস্য',
  ];

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box('settings');
    // ডাটাবেস থেকে নতুন ক্যাটাগরি চেক করার জন্য কল করতে পারেন (ঐচ্ছিক)
    _syncDynamicCategories();
  }

  // ডাটাবেস থেকে নতুন কোনো ক্যাটাগরি আসলে তা লিস্টে যুক্ত করার লজিক
  Future<void> _syncDynamicCategories() async {
    try {
      final jobSnap = await FirebaseFirestore.instance.collection('All_Data').get();
      final quesSnap = await FirebaseFirestore.instance.collection('All_Question').get();

      setState(() {
        for (var doc in jobSnap.docs) {
          if (!jobCats.contains(doc.id)) jobCats.add(doc.id);
        }
        for (var doc in quesSnap.docs) {
          if (!quesCats.contains(doc.id)) quesCats.add(doc.id);
        }
      });
    } catch (e) {
      debugPrint("Dynamic sync error: $e");
    }
  }

  Future<void> _handleTopic(String category, bool subscribe) async {
    // ক্লিন টপিক নেম লজিক
    String topic = category.split(' ')[0].toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    try {
      if (subscribe) {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      }
    } catch (e) {
      debugPrint("Topic Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("নোটিফিকেশন সেটিংস", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          // আপনার ইনফো বক্স
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.indigo),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "আপনার পছন্দমতো ক্যাটাগরিগুলো অন বা অফ করে রাখুন।",
                    style: TextStyle(fontSize: 12, color: Colors.indigo),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildModernSettings(
            title: "চাকরির বিজ্ঞপ্তি নোটিফিকেশন",
            mainKey: "all_circular_enabled",
            categoryKey: "circular_map",
            categories: jobCats, // অরিজিনাল লিস্ট + ডায়নামিক
            icon: Icons.work_history_rounded,
            isDark: isDark,
          ),

          const SizedBox(height: 16),

          _buildModernSettings(
            title: "প্রশ্ন ব্যাংক নোটিফিকেশন",
            mainKey: "all_questions_enabled",
            categoryKey: "question_map",
            categories: quesCats, // অরিজিনাল লিস্ট + ডায়নামিক
            icon: Icons.menu_book_rounded,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildModernSettings({
    required String title,
    required String mainKey,
    required String categoryKey,
    required List<String> categories,
    required IconData icon,
    required bool isDark,
  }) {
    bool isMainEnabled = settingsBox.get(mainKey, defaultValue: true);
    // Hive থেকে ম্যাপটি নেওয়ার সময় টাইপ কাস্টিং নিশ্চিত করা হয়েছে
    Map categoryMap = Map.from(settingsBox.get(categoryKey, defaultValue: {}));

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: isMainEnabled ? Colors.indigo : Colors.grey.withOpacity(0.2),
            child: Icon(icon, color: isMainEnabled ? Colors.white : Colors.grey, size: 18),
          ),
          title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isMainEnabled ? (isDark ? Colors.white : Colors.indigo[900]) : Colors.grey)),
          children: [
            const Divider(height: 1, indent: 20, endIndent: 20),
            SwitchListTile(
              title: const Text("সব নোটিফিকেশন", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text("Receive all updates for this section", style: TextStyle(fontSize: 11)),
              value: isMainEnabled,
              activeColor: Colors.indigo,
              onChanged: (val) {
                setState(() => settingsBox.put(mainKey, val));
              },
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(height: 1)),
            Opacity(
              opacity: isMainEnabled ? 1.0 : 0.4,
              child: AbsorbPointer(
                absorbing: !isMainEnabled,
                child: Column(
                  children: categories.map((cat) {
                    bool isCatEnabled = categoryMap[cat] ?? true;
                    return ListTile(
                      dense: true,
                      title: Text(cat, style: const TextStyle(fontSize: 13)),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(isCatEnabled ? "ON" : "OFF", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isCatEnabled ? Colors.indigo : Colors.grey)),
                            const SizedBox(width: 4),
                            Transform.scale(
                              scale: 0.7,
                              child: Switch(
                                value: isCatEnabled,
                                activeColor: Colors.indigo,
                                onChanged: (val) {
                                  setState(() {
                                    categoryMap[cat] = val;
                                    settingsBox.put(categoryKey, categoryMap);
                                  });
                                  _handleTopic(cat, val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}