import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class JobRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Advance query
  Stream<QuerySnapshot> getFilteredJobs({
    String? mainCat,
    String? subCat,
    DateTimeRange? dateRange,
  }) {
    // collectionGroup
    Query query = _db.collectionGroup('Job Circular');

    if (mainCat != null && mainCat != "All") {
      query = query.where('mainCategory', isEqualTo: mainCat);
    }
    if (subCat != null && subCat != "All") {
      query = query.where('subCategory', isEqualTo: subCat);
    }

    // publish date
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

    return query.orderBy('timestamp', descending: true).snapshots();
  }

  // image and all data update logic
  Future<void> updateJob(
    DocumentReference ref,
    Map<String, dynamic> updatedData,
    File? imageFile,
  ) async {
    if (imageFile != null) {
      String fileName = 'jobs/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = _storage.ref().child(fileName).putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // firebase database image if list
      updatedData['images'] = [downloadUrl];
    }
    return await ref.update(updatedData);
  }

  // delete logic
  Future<void> deleteJob(DocumentReference ref) async {
    return await ref.delete();
  }
}
