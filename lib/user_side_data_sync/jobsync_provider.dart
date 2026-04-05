import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

class JobProvider {
  List<JobSyncModel> _allJobs = [];
  StreamSubscription? _jobSubscription;
  final _myBox = Hive.box<JobSyncModel>('jobsBox');

  final StreamController<List<JobSyncModel>> _jobStreamController =
  StreamController<List<JobSyncModel>>.broadcast();

  // ১. অফলাইন ডাটা লোড
  void loadOfflineJobs() {
    if (_myBox.isNotEmpty) {
      _allJobs = _myBox.values.toList();
      _jobStreamController.add(_allJobs);
      print("Offline Load: ${_allJobs.length} jobs retrieved.");
    }
  }

  // ২. রিয়েল-টাইম সিঙ্ক লজিক
  void startRealTimeSync() {
    loadOfflineJobs(); // আগে অফলাইন দেখাও

    if (_jobSubscription != null) return;

    _jobSubscription = FirebaseFirestore.instance
        .collectionGroup('circular_items')
        .snapshots()
        .listen((snapshot) async {

      _allJobs = snapshot.docs.map((doc) {
        return JobSyncModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // ৩. ডাটাবেস আপডেট (অফলাইনের জন্য সেভ)
      await _myBox.clear();
      await _myBox.addAll(_allJobs);

      _jobStreamController.add(_allJobs);
      print("Sync Complete: Local memory updated from Server.");
    });
  }

  Stream<List<JobSyncModel>> getJobStream() {
    if (_jobSubscription == null) startRealTimeSync();
    return _jobStreamController.stream;
  }

  List<JobSyncModel> get allJobs => _allJobs;

  void dispose() {
    _jobSubscription?.cancel();
    _jobStreamController.close();
  }

  // ৪. ফিল্টারিং লজিক (Category Screen এর জন্য)
  List<JobSyncModel> getJobsByFilter(String categoryName) {
    if (categoryName.isEmpty) return _allJobs;

    // সার্চ কি-ওয়ার্ড ছোট হাতের করে নেওয়া যাতে সঠিক রেজাল্ট আসে
    String searchKey = categoryName.toLowerCase().trim();

    return _allJobs.where((job) {
      // step1, step2 বা company-তে ওই নাম আছে কি না চেক করবে
      return job.step1.toLowerCase().contains(searchKey) ||
          job.step2.toLowerCase().contains(searchKey) ||
          job.company.toLowerCase().contains(searchKey) ||
          (job.step3?.toLowerCase().contains(searchKey) ?? false);
    }).toList();
  }
}

final jobProvider = JobProvider();