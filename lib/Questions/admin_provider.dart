import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'question_bank_model.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String> uploadMasterData(
    String jsonRaw,
    Map<String, dynamic> meta,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      String examTitle = meta['exam'] ?? 'Untitled_Exam';
      List rawList = jsonDecode(jsonRaw);

      // এখানে প্রতিটি প্রশ্নকে মডেলে রূপান্তর করার সময় টাইটেল পাস করা হচ্ছে
      List<QuestionBankModel> questionModels = rawList
          .map((item) => QuestionBankModel.fromJson(item, examTitle))
          .toList();

      DocumentReference examRef = _firestore
          .collection('All_Question')
          .doc(meta['sector'])
          .collection(meta['format'])
          .doc(meta['category'] ?? 'General')
          .collection('Exams')
          .doc(examTitle);

      // মেটা ডাটা সেভ
      await examRef.set({
        'title': examTitle,
        'year': DateTime.now().year,
        'image_preview': meta['image'],
        'pdf_url': meta['pdf_link'],
        'pdf_file_data': meta['pdf_file'],
        'total_questions': questionModels.length,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // ব্যাচ আপলোড
      WriteBatch batch = _firestore.batch();
      for (var model in questionModels) {
        DocumentReference qRef = examRef.collection('Items').doc();
        batch.set(
          qRef,
          model.toJson(),
        ); // এখন প্রতিটি প্রশ্নের ভেতরেই 'title' থাকবে
      }

      await batch.commit();
      return "সফলভাবে '$examTitle' সিঙ্ক হয়েছে!";
    } catch (e) {
      return "এরর: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
