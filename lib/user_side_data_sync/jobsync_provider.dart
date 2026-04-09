import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

class JobProvider {
  List<JobSyncModel> _allJobs = [];
  StreamSubscription? _jobSubscription;

  Box<JobSyncModel> get _myBox => Hive.box<JobSyncModel>('jobsBox');
  // ভার্সন সেভ করার জন্য একটি সাধারণ বক্স (এটি মেইন ফাংশনে ওপেন করে নিবেন)
  Box get _settingsBox => Hive.box('settings');

  final StreamController<List<JobSyncModel>> _jobStreamController =
  StreamController<List<JobSyncModel>>.broadcast();

  // ১. অফলাইন ডাটা লোড (আগের মতোই)
  void loadOfflineJobs() {
    if (!Hive.isBoxOpen('jobsBox')) return;
    if (_myBox.isNotEmpty) {
      _allJobs = _myBox.values.toList();
      _jobStreamController.add(_allJobs);
      print("Offline Load: ${_allJobs.length} jobs retrieved.");
    }
  }

  // ২. নতুন ভার্সন চেক লজিক (এটি রিফ্রেশ করলে কল হবে)
  Future<void> checkUpdateAndSync() async {
    try {
      // ফায়ারবেস থেকে শুধু ১টি ডকুমেন্ট রিড হবে (ভার্সন চেক)
      var doc = await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('db_version')
          .get();

      if (doc.exists) {
        int serverVersion = doc.data()?['version_code'] ?? 0;
        int localVersion = _settingsBox.get('local_db_version', defaultValue: 0);

        if (serverVersion > localVersion) {
          print("New Version Found! Syncing...");
          startRealTimeSync(); // নতুন ভার্সন থাকলে ডাটাবেস কল হবে
          await _settingsBox.put('local_db_version', serverVersion);
        } else {
          print("Database is up to date.");
          loadOfflineJobs(); // আপডেট না থাকলে হাইভ থেকেই দেখাবে
        }
      } else {
        startRealTimeSync();
      }
    } catch (e) {
      print("Version Check Error: $e");
      loadOfflineJobs();
    }
  }

  // ৩. রিয়েল-টাইম সিঙ্ক লজিক (আগের মতোই)
  void startRealTimeSync() {
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

      if (Hive.isBoxOpen('jobsBox')) {
        await _myBox.clear();
        await _myBox.addAll(_allJobs);
      }

      _jobStreamController.add(_allJobs);
      print("Sync Complete: Firebase to Hive updated.");
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