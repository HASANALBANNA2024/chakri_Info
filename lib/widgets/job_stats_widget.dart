import 'package:flutter/material.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:chakri_info/user_side_data_sync/joblist_screen.dart';

class JobStatsWidget extends StatelessWidget {
  final bool isDarkMode;
  final List<JobSyncModel> allJobs;

  const JobStatsWidget({
    super.key,
    required this.isDarkMode,
    required this.allJobs,
  });

  // Helper function to convert Bengali Date ("৩০ এপ্রিল ২০২৬") to DateTime
  DateTime? _parseBengaliDate(String input) {
    if (input.isEmpty || input.contains("চলমান") || input.toLowerCase() == "null") return null;

    try {
      // Map Bengali months to numeric strings
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

      // Expecting format: "30 এপ্রিল 2026"
      List<String> parts = converted.split(' ');
      if (parts.length < 3) return null;

      String day = parts[0].padLeft(2, '0');
      String? month = monthMap[parts[1]];
      String year = parts[2];

      if (month == null) return null;

      // Returns YYYY-MM-DD format
      return DateTime.parse("$year-$month-$day");
    } catch (e) {
      return null;
    }
  }

  String toBengali(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengali = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], bengali[i]);
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Filter Active Jobs
    final activeJobs = allJobs.where((job) {
      DateTime? dDate = _parseBengaliDate(job.deadline);
      if (dDate == null) return true; // Keep "Running" or Null as active

      return dDate.isAfter(today) || dDate.isAtSameMomentAs(today);
    }).toList();

    // 2. Filter Urgent Jobs (Ending in 3 days)
    final urgentJobs = activeJobs.where((job) {
      DateTime? dDate = _parseBengaliDate(job.deadline);
      if (dDate == null) return false;

      int diffInDays = dDate.difference(today).inDays;
      // 0 = today, 1 = tomorrow, 2 = day after, 3 = 3rd day
      return diffInDays >= 0 && diffInDays <= 3;
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          _buildStatCard(
            context,
            "${toBengali(activeJobs.length.toString())} টি নতুন",
            "সক্রিয় সার্কুলার",
            isDarkMode ? Colors.indigoAccent : Colors.indigo,
            Icons.bolt_rounded,
            activeJobs,
          ),
          const SizedBox(width: 6),
          _buildStatCard(
            context,
            "${toBengali(urgentJobs.length.toString())} টি শেষ",
            "৩ দিনে দ্রুত শেষ হবে",
            isDarkMode ? Colors.redAccent : Colors.redAccent,
            Icons.timer_outlined,
            urgentJobs,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context,
      String count,
      String label,
      Color color,
      IconData icon,
      List<JobSyncModel> filteredJobs,
      ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Navigates if there are jobs in the list
          if (filteredJobs.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobListScreen(title: label, jobs: filteredJobs),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("কোনো সার্কুলার পাওয়া যায়নি")),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(isDarkMode ? 0.12 : 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withOpacity(isDarkMode ? 0.25 : 0.12),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      count,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: color,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.grey[400] : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}