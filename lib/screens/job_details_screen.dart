import 'package:flutter/material.dart';

import '../models/job_model.dart';

class JobDetailsScreen extends StatelessWidget {
  final JobModel job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("বিস্তারিত", style: TextStyle(color: Colors.white)),
        backgroundColor: isDarkMode
            ? const Color(0xFF1F1F1F)
            : Colors.indigo[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              job.company,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              "সার্কুলার ইমেজ (জুম করে দেখুন):",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            InteractiveViewer(
              clipBehavior: Clip.none, // zoom
              panEnabled: true, // doing image drug
              minScale: 0.5, // minimum size
              maxScale: 4.0, // maximum size
              child: Center(
                child: Image.asset(
                  job.description,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        Text("সার্কুলার ইমেজটি পাওয়া যায়নি"),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
