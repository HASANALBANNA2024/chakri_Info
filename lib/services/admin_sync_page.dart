import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class JobRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ফায়ারবেস থেকে ফিল্টার করা ডাটা আনার লজিক
  Stream<QuerySnapshot> getFilteredJobs({
    String? mainCat,
    String? subCat,
    DateTimeRange? dateRange,
  }) {
    // Collection Group query (কালেকশন নাম: Job Circular)
    Query query = _db.collectionGroup('Job Circular');

    // ১. মেইন ক্যাটাগরি ফিল্টার
    if (mainCat != null && mainCat != "All") {
      query = query.where('mainCategory', isEqualTo: mainCat);
    }

    // ২. সাব ক্যাটাগরি ফিল্টার
    if (subCat != null && subCat != "All") {
      query = query.where('subCategory', isEqualTo: subCat);
    }

    // ৩. ডেট রেঞ্জ ফিল্টার (যদি ইউজার তারিখ সিলেক্ট করে)
    if (dateRange != null) {
      query = query
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start),
          )
          .where(
            'timestamp',
            isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end),
          );
    }

    // ৪. সর্টিং (অবশ্যই ইনডেক্স তৈরি থাকতে হবে)
    return query.orderBy('timestamp', descending: true).snapshots();
  }

  // ডাটা আপডেট এবং ইমেজ আপলোড লজিক
  Future<void> updateJob(
    DocumentReference ref,
    Map<String, dynamic> updatedData,
    File? imageFile,
  ) async {
    try {
      if (imageFile != null) {
        String fileName = 'jobs/${DateTime.now().millisecondsSinceEpoch}.jpg';
        UploadTask uploadTask = _storage
            .ref()
            .child(fileName)
            .putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // ইমেজের লিস্ট আপডেট
        updatedData['images'] = [downloadUrl];
      }
      return await ref.update(updatedData);
    } catch (e) {
      throw Exception("Update Failed: $e");
    }
  }

  // ডাটা ডিলিট লজিক
  Future<void> deleteJob(DocumentReference ref) async {
    return await ref.delete();
  }
}
