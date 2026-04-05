import 'package:chakri_info/screens/admin_panel_ui.dart';
import 'package:flutter/material.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_provider.dart';
import 'package:chakri_info/user_side_data_sync/joblist_screen.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:chakri_info/internal_sections/about_us.dart';
import 'package:chakri_info/internal_sections/privacy_policy.dart';
import 'package:chakri_info/internal_sections/terms_conditions.dart';
import 'package:chakri_info/internal_sections/contact_us.dart';
import '../screens/category_screen.dart';
import 'package:intl/intl.dart';

class AppDrawer extends StatefulWidget {
  final bool isDarkMode;

  const AppDrawer({super.key, required this.isDarkMode});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  // secret open to admin panel
  int _clickCount = 0;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: widget.isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        child: Column(
          children: [
            // --- drawer header secret open logic ---
            _buildDrawerHeader(widget.isDarkMode),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  _sectionTitle("প্রধান মেনু"),
                  _drawerItem(
                    Icons.home_filled,
                    "হোম",
                    () => Navigator.pop(context),
                  ),
                  // new circular
                  _drawerItem(
                    Icons.fiber_new_rounded,
                    "নতুন সার্কুলার",
                        () {
                      Navigator.pop(context);
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final activeJobs = jobProvider.allJobs.where((job) {
                        if (job.deadline.isEmpty || job.deadline.toLowerCase() == "null" || job.deadline.contains("চলমান")) {
                          return true;
                        }
                        try {
                          DateTime dDate = DateTime.parse(job.deadline);
                          DateTime compareDate = DateTime(dDate.year, dDate.month, dDate.day);
                          return compareDate.isAfter(today) || compareDate.isAtSameMomentAs(today);
                        } catch (e) {
                          return true;
                        }
                      }).toList();

                      //all active jobs circular page convert
                      if (activeJobs.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobListScreen(
                              title: "সক্রিয় সার্কুলার",
                              jobs: activeJobs,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  // browse category
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
                  _sectionTitle("সময়সীমা ও তালিকা"),
                  _drawerItem(
                    Icons.event_available_rounded,
                    "পরীক্ষার তারিখ (Exam Date)",
                        () {
                      // drawer close
                      Navigator.pop(context);

                      // filtering logic
                      final examNoticeJobs = jobProvider.allJobs.where((job) {
                        return job.step1.trim() == 'Admission (ভর্তি পরীক্ষা)';
                      }).toList();

                      // go to filter and joblist
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobListScreen(
                            title: 'Admission (ভর্তি পরীক্ষা)',
                            jobs: examNoticeJobs,
                          ),
                        ),
                      );
                    },
                  ),

                  // start deadline
                  _drawerItem(
                    Icons.fiber_new_rounded,
                    "ডেডলাইন অনুযায়ী তালিকা",
                        () {
                      Navigator.pop(context);

                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);

                      // Helper function to convert Bengali numbers and months to DateTime
                      DateTime? parseBengaliDate(String input) {
                        if (input.isEmpty || input.contains("চলমান") || input.toLowerCase() == "null") return null;

                        try {
                          // Map Bengali months to English
                          Map<String, String> monthMap = {
                            'জানুয়ারি': '01', 'ফেব্রুয়ারি': '02', 'মার্চ': '03', 'এপ্রিল': '04',
                            'মে': '05', 'জুন': '06', 'জুলাই': '07', 'আগস্ট': '08',
                            'সেপ্টেম্বর': '09', 'অক্টোবর': '10', 'নভেম্বর': '11', 'ডিসেম্বর': '12'
                          };

                          // Convert Bengali digits to English digits
                          String converted = input
                              .replaceAll('০', '0').replaceAll('১', '1').replaceAll('২', '2')
                              .replaceAll('৩', '3').replaceAll('৪', '4').replaceAll('৫', '5')
                              .replaceAll('৬', '6').replaceAll('৭', '7').replaceAll('৮', '8')
                              .replaceAll('৯', '9');

                          // Split the date (Expecting: "30 এপ্রিল 2026")
                          List<String> parts = converted.split(' ');
                          if (parts.length < 3) return null;

                          String day = parts[0].padLeft(2, '0');
                          String? month = monthMap[parts[1]];
                          String year = parts[2];

                          if (month == null) return null;

                          // Create standard YYYY-MM-DD format for parsing
                          return DateTime.parse("$year-$month-$day");
                        } catch (e) {
                          return null;
                        }
                      }

                      // 1. Filtering
                      List<JobSyncModel> activeJobs = jobProvider.allJobs.where((job) {
                        DateTime? dDate = parseBengaliDate(job.deadline);
                        if (dDate == null) return true; // Keep "Running" or invalid dates

                        return dDate.isAfter(today) || dDate.isAtSameMomentAs(today);
                      }).toList();

                      // 2. Sorting
                      activeJobs.sort((a, b) {
                        DateTime? dateA = parseBengaliDate(a.deadline);
                        DateTime? dateB = parseBengaliDate(b.deadline);

                        if (dateA == null && dateB == null) return 0;
                        if (dateA == null) return 1;  // Push "Running" to bottom
                        if (dateB == null) return -1;

                        return dateA.compareTo(dateB); // Ascending order
                      });

                      // 3. Navigation
                      if (activeJobs.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobListScreen(
                              title: "সক্রিয় সার্কুলার",
                              jobs: activeJobs,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  // end deadline
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
                  _sectionTitle("যোগ্যতা অনুযায়ী চাকরি"),
                  _buildEducationChips(),
                  const Divider(height: 30, thickness: 1),
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

  Widget _buildDrawerHeader(bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _clickCount++;

          if (_clickCount == 20) {
            _clickCount = 0;
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminPanelScreen()),
            );
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(
          top: 50,
          bottom: 20,
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F1F1F) : Colors.indigo[900],
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Row(
          children: [
            // to icon from assets
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white24,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, color: Colors.white, size: 35),
                ),
              ),
            ),
            const SizedBox(width: 15),
            const Column(
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
                  "ক্যারিয়ার গড়ুন আমাদের সাথে",
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- helper widgets ---

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
    return GestureDetector(
      onTap: () {
        if (label == "About Us") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen()));
        } else if (label == "Contact") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUsScreen()));
        } else if (label == "Terms") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsConditionsScreen()));
        } else if (label == "Privacy") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8), // ক্লিক এরিয়া একটু আরামদায়ক করার জন্য
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
