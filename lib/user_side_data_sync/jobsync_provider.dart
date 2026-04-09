import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

class JobProvider {
  List<JobSyncModel> _allJobs = [];
  StreamSubscription? _jobSubscription;

  // ১. সরাসরি ভেরিয়েবল না রেখে একটি নিরাপদ Getter ব্যবহার করুন
  Box<JobSyncModel> get _myBox => Hive.box<JobSyncModel>('jobsBox');

  final StreamController<List<JobSyncModel>> _jobStreamController =
  StreamController<List<JobSyncModel>>.broadcast();

  // ২. অফলাইন ডাটা লোড
  void loadOfflineJobs() {
    // চেক করে নিন বক্সটি ওপেন আছে কি না (সেফটি ফার্স্ট)
    if (!Hive.isBoxOpen('jobsBox')) return;

    if (_myBox.isNotEmpty) {
      _allJobs = _myBox.values.toList();
      _jobStreamController.add(_allJobs);
      print("Offline Load: ${_allJobs.length} jobs retrieved.");
    }
  }

  // ৩. রিয়েল-টাইম সিঙ্ক লজিক
  void startRealTimeSync() {
    // বক্স ওপেন না থাকলে ওপেন করে নেওয়া (অতিরিক্ত সেফটি)
    if (!Hive.isBoxOpen('jobsBox')) {
      Hive.openBox<JobSyncModel>('jobsBox').then((_) => loadOfflineJobs());
    } else {
      loadOfflineJobs();
    }

    if (_jobSubscription != null) return;

    _jobSubscription = FirebaseFirestore.instance
        .collectionGroup('circular_items')
        .snapshots()
        .listen((snapshot) async {

      _allJobs = snapshot.docs.map((doc) {
        return JobSyncModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // ৪. ডাটাবেস আপডেট করার আগে চেক করা
      if (Hive.isBoxOpen('jobsBox')) {
        await _myBox.clear();
        await _myBox.addAll(_allJobs);
      }

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

  // ৫. ফিল্টারিং লজিক
  List<JobSyncModel> getJobsByFilter(String categoryName) {
    if (categoryName.isEmpty) return _allJobs;
    String searchKey = categoryName.toLowerCase().trim();

    return _allJobs.where((job) {
      return job.step1.toLowerCase().contains(searchKey) ||
          job.step2.toLowerCase().contains(searchKey) ||
          job.company.toLowerCase().contains(searchKey) ||
          (job.step3?.toLowerCase().contains(searchKey) ?? false);
    }).toList();
  }
}

final jobProvider = JobProvider();