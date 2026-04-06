import 'package:chakri_info/user_side_data_sync/joblist_screen.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class EducationFilterWidget extends StatelessWidget {
  const EducationFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<String> eduLevels = [
      'অষ্টম শ্রেণি পাস',
      'JSC / JDC',
      'SSC / সমমান',
      'HSC / সমমান',
      'Diploma (ডিপ্লোমা)',
      'BSc / Honours (অনার্স)',
      'Masters (মাস্টার্স)',
      'BBA / MBA',
      'MBBS / BDS',
      'Fazil / Kamil',
      'PhD',
      'অন্যান্য',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: eduLevels.map((level) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                try {
                  // Instant Drawer Close
                  Navigator.of(context).pop();

                  const String boxName = 'jobsBox';
                  if (!Hive.isBoxOpen(boxName)) {
                    await Hive.openBox<JobSyncModel>(boxName);
                  }

                  final Box<JobSyncModel> jobBox = Hive.box<JobSyncModel>(
                    boxName,
                  );
                  final List<JobSyncModel> allLocalJobs = jobBox.values
                      .toList();

                  final List<String> mainDegrees = [
                    'অষ্টম শ্রেণি পাস',
                    'jsc / jdc',
                    'ssc / সমমান',
                    'hsc / সমমান',
                    'diploma (ডিপ্লোমা)',
                    'bsc / honours (অনার্স)',
                    'masters (মাস্টার্স)',
                    'bba / mba',
                    'mbbs / bds',
                    'fazil / kamil',
                    'phd',
                  ];

                  List<JobSyncModel> filteredJobs = [];

                  if (level == 'অন্যান্য') {
                    filteredJobs = allLocalJobs.where((job) {
                      if (job.education == null || job.education!.isEmpty)
                        return false;
                      return job.education!.any((edu) {
                        String val = edu.toString().trim().toLowerCase();
                        return val.contains('অন্যান্য') ||
                            !mainDegrees.contains(val);
                      });
                    }).toList();
                  } else {
                    filteredJobs = allLocalJobs.where((job) {
                      if (job.education == null) return false;
                      // Fixed: matching logic with proper closure
                      return job.education!.any(
                        (e) =>
                            e.toString().trim().toLowerCase() ==
                            level.trim().toLowerCase(),
                      );
                    }).toList(); // Added missing .toList() here
                  }

                  if (filteredJobs.isEmpty) {
                    if (context.mounted) {
                      _showModernSnackBar(context, level, isDarkMode);
                    }
                    return;
                  }

                  filteredJobs.sort(
                    (a, b) => (b.id ?? "").compareTo(a.id ?? ""),
                  );

                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            JobListScreen(title: level, jobs: filteredJobs),
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint("Filter Error: $e");
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [Colors.indigo.shade900, Colors.indigo.shade700]
                        : [Colors.white, Colors.indigo.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.indigo.shade400
                        : Colors.indigo.shade200,
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.indigo.shade800,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showModernSnackBar(
    BuildContext context,
    String level,
    bool isDarkMode,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$level-এর কোনো চাকরি বর্তমানে নেই',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isDarkMode
            ? Colors.indigoAccent
            : Colors.orange.shade900,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
