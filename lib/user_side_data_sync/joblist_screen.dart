import 'package:flutter/material.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:chakri_info/user_side_data_sync/job_card_widget.dart';

class JobListScreen extends StatelessWidget {
  final String title;
  final List<JobSyncModel> jobs;

  const JobListScreen({super.key, required this.title, required this.jobs});

  @override
  Widget build(BuildContext context) {
    // ১. ডার্ক মোড চেক করা হচ্ছে (এটি build মেথডের ভেতরে)
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // ২. টোটাল আইটেম সংখ্যা বের করা (জব ডাটা + অ্যাড পজিশন)
    int totalItems = jobs.length + (jobs.length ~/ 4);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: jobs.isEmpty
          ? Center(
        child: Text(
          "এই ক্যাটাগরিতে কোনো সার্কুলার পাওয়া যায়নি।",
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
            fontSize: 16,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: totalItems,
        itemBuilder: (context, index) {
          // লজিক: প্রতি ৪টি জবের পর একটি ব্যানার (index 4, 9, 14...)
          if ((index + 1) % 5 == 0) {
            // ৩. এখানে isDarkMode ভ্যালুটা প্যারামিটার হিসেবে পাঠানো হচ্ছে
            return _buildJobBannerAd(isDarkMode);
          }

          // ৪. অরিজিনাল ডাটার ইনডেক্স বের করা
          final int actualIndex = index - (index ~/ 5);

          if (actualIndex >= jobs.length) return const SizedBox.shrink();

          return JobCardWidget(job: jobs[actualIndex]);
        },
      ),
    );
  }

  // --- ৫. রেড লাইন ফিক্স করার জন্য এখানে (bool isDarkMode) রিসিভ করা হয়েছে ---
  Widget _buildJobBannerAd(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 130,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [const Color(0xFF1E293B), const Color(0xFF334155)]
              : [Colors.indigo.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : Colors.indigo.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: isDarkMode
                    ? Colors.white.withOpacity(0.02)
                    : Colors.indigo.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.indigoAccent.withOpacity(0.2)
                          : Colors.indigo.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.telegram_rounded, // টেলিগ্রাম আইকন
                      color: isDarkMode ? Colors.indigoAccent : Colors.indigo,
                      size: 35,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "চাকরির আপডেট সবার আগে!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDarkMode ? Colors.white : Colors.indigo[900],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "আমাদের টেলিগ্রাম গ্রুপে জয়েন করুন প্রতিদিনের সার্কুলার পেতে।",
                          style: TextStyle(
                            fontSize: 12,
                            // ৬. এখানে এরর আসছিল, এখন isDarkMode প্যারামিটার থাকায় এটি ঠিক হয়ে গেছে
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}