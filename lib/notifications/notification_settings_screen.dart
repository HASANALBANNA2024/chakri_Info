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

  // List of Job Circular categories
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

  // List of Question Bank categories
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
    // Load settings from Hive box
    settingsBox = Hive.box('settings');
  }

  @override
  Widget build(BuildContext context) {
    // Check if the theme is in dark mode
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "নোটিফিকেশন সেটিংস",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          // Info box to guide the user
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
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

          // 1. Job Circular Settings Section
          _buildModernSettings(
            title: "চাকরির বিজ্ঞপ্তি নোটিফিকেশন",
            mainKey: "all_circular_enabled",
            categoryKey: "circular_map",
            categories: jobCats,
            icon: Icons.work_history_rounded,
            isDark: isDark,
          ),

          const SizedBox(height: 16),

          // 2. Question Bank Settings Section
          _buildModernSettings(
            title: "প্রশ্ন ব্যাংক নোটিফিকেশন",
            mainKey: "all_questions_enabled",
            categoryKey: "question_map",
            categories: quesCats,
            icon: Icons.menu_book_rounded,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // Custom function to build the modern settings card
  Widget _buildModernSettings({
    required String title,
    required String mainKey,
    required String categoryKey,
    required List<String> categories,
    required IconData icon,
    required bool isDark,
  }) {
    // Master switch status from Hive
    bool isMainEnabled = settingsBox.get(mainKey, defaultValue: true);
    // Specific categories map from Hive
    Map categoryMap = settingsBox.get(categoryKey, defaultValue: {});

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
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
          // Set to 'false' so it stays closed initially
          initiallyExpanded: false,
          leading: CircleAvatar(
            backgroundColor: isMainEnabled
                ? Colors.indigo
                : Colors.grey.withOpacity(0.2),
            child: Icon(
              icon,
              color: isMainEnabled ? Colors.white : Colors.grey,
              size: 18,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isMainEnabled
                  ? (isDark ? Colors.white : Colors.indigo[900])
                  : Colors.grey,
            ),
          ),
          children: [
            const Divider(height: 1, indent: 20, endIndent: 20),

            // Section Master Switch controller of decision of notification control
            SwitchListTile(
              title: const Text(
                "সব নোটিফিকেশন",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: const Text(
                "Receive all updates for this section",
                style: TextStyle(fontSize: 11),
              ),
              value: isMainEnabled,
              activeColor: Colors.indigo,
              onChanged: (val) {
                setState(() {
                  settingsBox.put(mainKey, val);
                });
              },
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1),
            ),

            // Individual Categories
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
                            Text(
                              isCatEnabled ? "ON" : "OFF",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCatEnabled
                                    ? Colors.indigo
                                    : Colors.grey,
                              ),
                            ),
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
