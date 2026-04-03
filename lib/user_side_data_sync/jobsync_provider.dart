import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'dart:async';

class JobProvider {
  /// Local cache to store jobs in memory for fast access
  List<JobSyncModel> _allJobs = [];
  StreamSubscription? _jobSubscription;

  /// Starts a real-time listener to sync database changes automatically
  void startRealTimeSync() {
    // Prevent multiple subscriptions
    if (_jobSubscription != null) return;

    _jobSubscription = FirebaseFirestore.instance
        .collectionGroup('circular_items')
        .snapshots()
        .listen((snapshot) {

      // Update local memory whenever database changes (Add/Edit/Delete)
      _allJobs = snapshot.docs.map((doc) {
        return JobSyncModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      print("Real-time Update: ${_allJobs.length} jobs synced to memory.");
    }, onError: (error) {
      print("Sync Error: $error");
    });
  }

  /// Live Stream for UI (StreamBuilder) to get data updates in real-time
  /// Usage: stream: jobProvider.getJobStream()
  Stream<List<JobSyncModel>> getJobStream() {
    return FirebaseFirestore.instance
        .collectionGroup('circular_items')
        .snapshots()
        .map((snapshot) {
      _allJobs = snapshot.docs.map((doc) {
        return JobSyncModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      return _allJobs;
    });
  }

  /// Filters jobs from local memory without calling the database again
  List<JobSyncModel> getJobsByFilter(String categoryName) {
    if (categoryName == 'All' || categoryName.isEmpty) return _allJobs;

    String searchKey = categoryName.toLowerCase().trim();

    // Filtering logic from local cache for better performance
    return _allJobs.where((job) =>
    job.step1.toLowerCase().contains(searchKey) ||
        job.step2.toLowerCase().contains(searchKey) ||
        (job.step3?.toLowerCase().contains(searchKey) ?? false) ||
        (job.step4?.toLowerCase().contains(searchKey) ?? false)
    ).toList();
  }

  /// Returns all jobs currently stored in memory
  List<JobSyncModel> get allJobs => _allJobs;

  /// Cancels the subscription to free up resources
  void dispose() {
    _jobSubscription?.cancel();
    _jobSubscription = null;
  }
}

/// Global instance of JobProvider
final jobProvider = JobProvider();