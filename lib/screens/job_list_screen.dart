import 'package:chakri_info/screens/job_details_screen.dart';
import 'package:flutter/material.dart';

import '../models/job_model.dart';

class JobListScreen extends StatelessWidget {
  final String title;
  final List<JobModel> jobs;

  const JobListScreen({super.key, required this.title, required this.jobs});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode
            ? const Color(0xFF1F1F1F)
            : Colors.indigo[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(job.logo)),
              title: Text(
                job.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${job.company}\nশেষ তারিখ: ${job.deadline}"),
              isThreeLine: true,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // job details screen to call
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailsScreen(job: job),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
