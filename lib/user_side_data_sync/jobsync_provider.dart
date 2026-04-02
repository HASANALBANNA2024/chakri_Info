import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';

class JobProvider {
  List<JobSyncModel> _allJobs = [];

  // সব নেস্টেড ডাটা একসাথে সিঙ্ক করার জন্য collectionGroup
  Future<void> syncJobsFromAdmin() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collectionGroup('circular_items')
          .get();

      _allJobs = snapshot.docs.map((doc) {
        return JobSyncModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      print("Sync Success: ${_allJobs.length} jobs loaded.");
    } catch (e) {
      print("Sync Error: $e");
    }
  }

  // এই ফাংশনটিই আপনার ক্যাটাগরি অনুযায়ী ডাটা ফিল্টার করে দিবে (Yes, it works!)
  List<JobSyncModel> getJobsByFilter(String categoryName) {
    if (categoryName == 'All' || categoryName.isEmpty) return _allJobs;

    String searchKey = categoryName.toLowerCase().trim();

    return _allJobs.where((job) =>
    job.step1.toLowerCase().contains(searchKey) ||
        job.step2.toLowerCase().contains(searchKey) ||
        (job.step3?.toLowerCase().contains(searchKey) ?? false) ||
        (job.step4?.toLowerCase().contains(searchKey) ?? false)
    ).toList();
  }

  List<JobSyncModel> get allJobs => _allJobs;
}

final jobProvider = JobProvider();