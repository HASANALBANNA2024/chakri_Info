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

  // ইংরেজি সংখ্যাকে বাংলায় রূপান্তর করার ফাংশন
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

    // ১. সক্রিয় সার্কুলার ফিল্টার
    final activeJobs = allJobs.where((job) {
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

    // ২. ৩ দিনের মধ্যে শেষ হবে এমন সার্কুলার
    final urgentJobs = activeJobs.where((job) {
      if (job.deadline.isEmpty || job.deadline == "null") return false;
      DateTime? dDate = DateTime.tryParse(job.deadline);
      if (dDate == null) return false;
      int diffInDays = dDate.difference(today).inDays;
      return diffInDays >= 0 && diffInDays <= 3;
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0), // টপ প্যাডিং কমানো হয়েছে
      child: Row(
        children: [
          _buildStatCard(
            context,
            "${toBengali(activeJobs.length.toString())} টি নতুন", // বাংলা সংখ্যা
            "সক্রিয় সার্কুলার",
            isDarkMode ? Colors.indigoAccent : Colors.indigo,
            Icons.bolt_rounded,
            activeJobs,
          ),
          const SizedBox(width: 6), // গ্যাপ কমানো হয়েছে
          _buildStatCard(
            context,
            "${toBengali(urgentJobs.length.toString())} টি শেষ", // বাংলা সংখ্যা
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
          if (filteredJobs.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobListScreen(title: label, jobs: filteredJobs),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6), // প্যাডিং কমানো হয়েছে
          decoration: BoxDecoration(
            color: color.withOpacity(isDarkMode ? 0.12 : 0.06),
            borderRadius: BorderRadius.circular(10), // রেডিয়াস কিছুটা কমানো
            border: Border.all(
              color: color.withOpacity(isDarkMode ? 0.25 : 0.12),
              width: 0.8, // বর্ডার উইডথ কমানো
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16), // আইকন সাইজ ১৮ থেকে ১৬ করা হয়েছে
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
                        fontSize: 12, // ফন্ট সাইজ ১৪ থেকে ১২ করা হয়েছে
                        color: color,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10, // ফন্ট সাইজ ৯ থেকে ৮ করা হয়েছে
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