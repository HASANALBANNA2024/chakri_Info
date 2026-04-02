import 'package:flutter/material.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:chakri_info/user_side_data_sync/job_card_widget.dart';

class JobListScreen extends StatelessWidget {
  final String title;
  final List<JobSyncModel> jobs;

  const JobListScreen({super.key, required this.title, required this.jobs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(title: Text(title), backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white),
      body: jobs.isEmpty
          ? const Center(child: Text("এই ক্যাটাগরিতে কোনো সার্কুলার পাওয়া যায়নি।"))
          : ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) => JobCardWidget(job: jobs[index]),
      ),
    );
  }
}