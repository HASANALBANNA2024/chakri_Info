import 'package:flutter/material.dart';

import '../screens/category_screen.dart'; // আপনার ক্যাটাগরি স্ক্রিনের পাথ অনুযায়ী ইমপোর্ট করুন

class AppDrawer extends StatelessWidget {
  final bool isDarkMode;

  const AppDrawer({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        child: Column(
          children: [
            // --- ড্রয়ার হেডার ---
            _buildDrawerHeader(isDarkMode),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  // --- প্রধান মেনু ---
                  _sectionTitle("প্রধান মেনু"),
                  _drawerItem(
                    Icons.home_filled,
                    "হোম",
                    () => Navigator.pop(context),
                  ),
                  _drawerItem(Icons.fiber_new_rounded, "নতুন সার্কুলার", () {}),
                  _drawerItem(Icons.grid_view_rounded, "ব্রাউজ ক্যাটাগরি", () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CategoryScreen()),
                    );
                  }),
                  _drawerItem(
                    Icons.bookmark_rounded,
                    "ফেভারিট ও বুকমার্ক",
                    () {},
                  ),

                  // --- ডেডলাইন ও সময়সীমা ---
                  _sectionTitle("সময়সীমা ও তালিকা"),
                  _drawerItem(
                    Icons.event_available_rounded,
                    "পরীক্ষার তারিখ (Exam Date)",
                    () {},
                  ),
                  _drawerItem(
                    Icons.timer_outlined,
                    "ডেডলাইন অনুযায়ী তালিকা",
                    () {},
                  ),

                  // --- প্রিপারেশন সেন্টার (Quiz & Model Test) ---
                  _sectionTitle("প্রিপারেশন সেন্টার"),
                  _drawerItem(
                    Icons.menu_book_rounded,
                    "ভর্তি প্রস্তুতি (Admission)",
                    () {},
                  ),
                  _drawerItem(
                    Icons.work_history_rounded,
                    "জব প্রিপারেশন (General)",
                    () {},
                  ),
                  _drawerItem(
                    Icons.biotech_rounded,
                    "মেডিকেল জব প্রিপারেশন",
                    () {},
                  ),
                  _drawerItem(
                    Icons.agriculture_rounded,
                    "কৃষি ও মৎস্য প্রিপারেশন",
                    () {},
                  ),
                  _drawerItem(
                    Icons.computer_rounded,
                    "টেকনিক্যাল জব প্রিপারেশন",
                    () {},
                  ),
                  _drawerItem(
                    Icons.quiz_rounded,
                    "কুইজ ও মডেল টেস্ট",
                    () {},
                    isHighlight: true,
                  ),

                  // --- শিক্ষাগত যোগ্যতা অনুযায়ী ---
                  _sectionTitle("যোগ্যতা অনুযায়ী চাকরি"),
                  _buildEducationChips(),

                  const Divider(height: 30, thickness: 1),

                  // --- লিগ্যাল ও সাপোর্ট ---
                  _buildSupportGrid(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildDrawerHeader(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F1F1F) : Colors.indigo[900],
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(30)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 35),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "চাকরি ইনফো",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                "ক্যারিয়ার গড়ুন আমাদের সাথে",
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isHighlight = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isHighlight ? Colors.orange : Colors.grey[600],
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
          color: isHighlight ? Colors.orange[800] : null,
        ),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildEducationChips() {
    List<String> edu = [
      "SSC",
      "HSC",
      "Diploma",
      "BSc",
      "Hons/Degree",
      "MBBS",
      "Masters",
      "PhD",
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 6,
        runSpacing: 0,
        children: edu
            .map(
              (e) => ActionChip(
                label: Text(e, style: const TextStyle(fontSize: 11)),
                padding: EdgeInsets.zero,
                backgroundColor: Colors.indigo.withOpacity(0.05),
                onPressed: () {},
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSupportGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          _supportButton(Icons.info_rounded, "About Us"),
          _supportButton(Icons.contact_support_rounded, "Contact"),
          _supportButton(Icons.gavel_rounded, "Terms"),
          _supportButton(Icons.privacy_tip_rounded, "Privacy"),
        ],
      ),
    );
  }

  Widget _supportButton(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
