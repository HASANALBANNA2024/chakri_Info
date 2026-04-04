import 'package:flutter/material.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:chakri_info/user_side_data_sync/job_card_widget.dart';

class JobListScreen extends StatelessWidget {
  final String title;
  final List<JobSyncModel> jobs;

  const JobListScreen({super.key, required this.title, required this.jobs});

  @override
  Widget build(BuildContext context) {
    // Dark Mode Checker
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Dark mode color
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F7F9),

      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        // AppBar Dark mode color
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
        itemCount: jobs.length,
        itemBuilder: (context, index) => JobCardWidget(job: jobs[index]),
      ),
    );
  }
}