import 'package:chakri_info/models/job_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobProvider {
  List<JobModel> _allJobs = [];

  Future<void> syncJobsFromAdmin() async {
    try {
      // Matches the collection name in your Firebase Rules
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Job Circular')
          .get();

      _allJobs = snapshot.docs.map((doc) {
        return JobModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      print("Sync Success: ${_allJobs.length} jobs loaded from Job Circular.");
    } catch (e) {
      print("Sync Error: $e");
    }
  }

  List<JobModel> getJobsByCategory(String categoryName) {
    return _allJobs.where((job) => job.category == categoryName).toList();
  }

  List<JobModel> get allJobs => _allJobs;
}

final jobProvider = JobProvider();
