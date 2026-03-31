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

  // dynamic path data logic
  Future<void> saveCircular({
    required String step1,
    required String step2,
    String? step3,
    String? step4,
    required Map<String, dynamic> circularData,
  }) async {
    String finalCollection = step4 ?? step3 ?? step2;

    await _firestore
        .collection('All_Data')
        .doc(step1)
        .collection(step2)
        .doc(step3 ?? 'General')
        .collection(finalCollection)
        .add(circularData);
  }
}
