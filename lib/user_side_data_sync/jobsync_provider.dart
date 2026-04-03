import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'dart:async';

class JobProvider {
  // ১. মেমোরি ক্যাশ এবং স্ট্রিম কন্ট্রোলার
  List<JobSyncModel> _allJobs = [];
  StreamSubscription? _jobSubscription;

  // Broadcast controller যাতে একাধিক স্ক্রিন থেকে একই ডেটা দেখা যায়
  final StreamController<List<JobSyncModel>> _jobStreamController =
  StreamController<List<JobSyncModel>>.broadcast();

  // ২. রিয়েল-টাইম লিসেনার (এটিই আপনার মেইন ইঞ্জিন)
  void startRealTimeSync() {
    if (_jobSubscription != null) return;

    // snapshots() ফাংশনটি নিজে থেকেই শুধু 'Delta' বা পরিবর্তনটুকু নিয়ে আসে
    _jobSubscription = FirebaseFirestore.instance
        .collectionGroup('circular_items')
        .snapshots()
        .listen((snapshot) {

      // ডাটাবেসে কোনো চেঞ্জ আসলে (Add/Edit/Delete) সেটি প্রসেস করা
      _allJobs = snapshot.docs.map((doc) {
        return JobSyncModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // মেমোরিতে ডেটা আপডেট করে স্ট্রিম-এ পাঠিয়ে দেওয়া
      _jobStreamController.add(_allJobs);

      print("Sync Info: ${_allJobs.length} jobs are now in memory (Only changes synced).");
    }, onError: (error) {
      print("Sync Error: $error");
    });
  }

  // ৩. UI-এর জন্য স্ট্রিম (এটি এখন আর ডাটাবেস কল করবে না, মেমোরি থেকে ডেটা দিবে)
  Stream<List<JobSyncModel>> getJobStream() {
    // যদি লিসেনার চালু না থাকে, তবে চালু করে দিবে
    if (_jobSubscription == null) {
      startRealTimeSync();
    }

    // সরাসরি কন্ট্রোলার থেকে স্ট্রিম দিবে, ফলে ডাটাবেসে রিড কম হবে
    return _jobStreamController.stream;
  }

  // ৪. ফিল্টারিং (এটিও মেমোরি থেকে হয়, ডাটাবেস কল নেই)
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

  void dispose() {
    _jobSubscription?.cancel();
    _jobSubscription = null;
    _jobStreamController.close();
  }
}

final jobProvider = JobProvider();