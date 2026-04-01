import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // image to Base64 text convert
  Future<List<String>> convertImagesToBase64(List<File> imageFiles) async {
    List<String> base64Images = [];
    for (var file in imageFiles) {
      List<int> imageBytes = await file.readAsBytes();
      String base64String = base64Encode(imageBytes);
      base64Images.add(base64String); // to text image
    }
    return base64Images;
  }


  Future<void> saveCircular({
    required String step1,
    required String step2,
    String? step3,
    String? step4,
    required Map<String, dynamic> circularData,
  }) async {
    // filter step
    circularData['step1'] = step1;
    circularData['step2'] = step2;
    circularData['step3'] = step3;
    circularData['step4'] = step4;

    // dynamic path
    DocumentReference docRef = _firestore.collection('All_Data').doc(step1);
    var collectionPath = docRef.collection(step2);
    var finalDoc = collectionPath.doc(step3 ?? 'General');

    // solved problem 'circular_items' collection data save
    await finalDoc
        .collection(step4 ?? step3 ?? step2)
        .doc('posts')
        .collection('circular_items')
        .add(circularData);
  }



  Future<void> updateCircular({
    required String docId,
    required Map<String, dynamic> updatedData,
  }) async {
    await _firestore.collectionGroup('circular_items')
        .where(FieldPath.documentId, isEqualTo: docId)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.update(updatedData);
      }
    });
  }

  Future<void> deleteCircular(String docId) async {
    await _firestore.collectionGroup('circular_items')
        .where(FieldPath.documentId, isEqualTo: docId)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }


}
