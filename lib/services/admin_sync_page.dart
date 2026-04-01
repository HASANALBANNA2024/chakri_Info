import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class JobRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;



  Stream<QuerySnapshot> getAdvancedFilteredJobs({
    String? step1,
    String? step2,
    String? step3,
    String? step4,
  }) {
    // all data receive engine
    Query query = _db.collectionGroup('circular_items');

    // filter dropdown
    if (step1 != null && step1 != "All") {
      query = query.where('step1', isEqualTo: step1);
    }
    if (step2 != null && step2 != "All") {
      query = query.where('step2', isEqualTo: step2);
    }
    if (step3 != null && step3 != "All") {
      query = query.where('step3', isEqualTo: step3);
    }
    if (step4 != null && step4 != "All") {
      query = query.where('step4', isEqualTo: step4);
    }

    return query.orderBy('timestamp', descending: true).snapshots();
  }

  // update and delete job circular

  // Future<void> updateJob(
  //   DocumentReference ref,
  //   Map<String, dynamic> updatedData,
  //   File? imageFile,
  // ) async {
  //   if (imageFile != null) {
  //     String fileName = 'jobs/${DateTime.now().millisecondsSinceEpoch}.jpg';
  //     UploadTask uploadTask = _storage.ref().child(fileName).putFile(imageFile);
  //     TaskSnapshot snapshot = await uploadTask;
  //     String downloadUrl = await snapshot.ref.getDownloadURL();
  //     updatedData['images'] = [downloadUrl];
  //   }
  //   return await ref.update(updatedData);
  // }
  //
  // Future<void> deleteJob(DocumentReference ref) async {
  //   return await ref.delete();
  // }


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
      updatedData['images'] = [downloadUrl];
    }
    return await ref.update(updatedData);
  }

  Future<void> deleteJob(DocumentReference ref) async {
    return await ref.delete();
  }
}
