import 'package:chakri_info/user_side_data_sync/joblist_screen.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class EducationFilterWidget extends StatelessWidget {
  const EducationFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Admin Panel ar list
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: eduLevels.map((level) {
          return ActionChip(
            label: Text(
              level,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.indigo,
              ),
            ),
            backgroundColor: Colors.indigo.withOpacity(0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onPressed: () async {
              try {
                // job box name to equal provider: 'jobsBox'
                const String boxName = 'jobsBox';

                if (!Hive.isBoxOpen(boxName)) {
                  await Hive.openBox<JobSyncModel>(boxName);
                }

                final Box<JobSyncModel> jobBox = Hive.box<JobSyncModel>(
                  boxName,
                );
                final List<JobSyncModel> allLocalJobs = jobBox.values.toList();

                // main degree list for others
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

                // filtering logic
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
                    return job.education!.any(
                      (e) =>
                          e.toString().trim().toLowerCase() ==
                          level.trim().toLowerCase(),
                    );
                  }).toList();
                }

                //Data check
                if (filteredJobs.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$level-এর কোনো চাকরি বর্তমানে নেই'),
                        backgroundColor: Colors.orange.shade900,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  return;
                }

                // sorting id
                filteredJobs.sort((a, b) => (b.id ?? "").compareTo(a.id ?? ""));

                // Navigation
                Navigator.of(context).pop();

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
          );
        }).toList(),
      ),
    );
  }
}
