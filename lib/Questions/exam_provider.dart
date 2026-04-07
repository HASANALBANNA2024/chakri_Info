import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ExamProvider with ChangeNotifier {
  final Box _examBox = Hive.box('exam_cache');

  // ডাটা গেট করার মেইন ফাংশন (Hive First, Then Firebase)
  Stream<List<Map<String, dynamic>>> getExams(String s1, String s2) {
    return FirebaseFirestore.instance
        .collection('All_Question')
        .doc(s1)
        .collection(s2)
        .doc('Exams')
        .collection('All_Exams')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // লোকাল ডাটা (যদি অফলাইন থাকে বা ইনস্ট্যান্ট দরকার হয়)
  List<Map<String, dynamic>> getCachedExams(
    String s1,
    String s2,
    String targetFolder,
  ) {
    String cacheKey = "${s1}_${s2}_$targetFolder";
    return List<Map<String, dynamic>>.from(
      _examBox.get(cacheKey, defaultValue: []),
    );
  }
}
