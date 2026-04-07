import 'package:chakri_info/Questions/question_bank_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SubCategoryExamScreen extends StatefulWidget {
  final String categoryName;
  final bool isDarkMode;

  const SubCategoryExamScreen({
    super.key,
    required this.categoryName,
    required this.isDarkMode,
  });

  @override
  State<SubCategoryExamScreen> createState() => _SubCategoryExamScreenState();
}

class _SubCategoryExamScreenState extends State<SubCategoryExamScreen> {
  List<QuestionBankModel> _examList = [];
  bool _isLoading = true;
  String _selectedType = 'MCQ';
  Box? _examBox; // late সরিয়ে দিয়ে nullable করা হয়েছে ক্রাশ এড়াতে

  @override
  void initState() {
    super.initState();
    _initAndSync();
  }

  Future<void> _initAndSync() async {
    try {
      // বাংলা অক্ষরের বদলে hashCode ব্যবহার করলে নাম সবসময় English (ASCII) হবে
      String safeName = 'exams_cache_${widget.categoryName.hashCode}';
      _examBox = await Hive.openBox(safeName);

      _loadLocalData();
      await _syncWithFirestore();
    } catch (e) {
      print("Hive error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loadLocalData() {
    if (_examBox == null || !_examBox!.isOpen) return;

    final dynamic cachedData = _examBox!.get(_selectedType);

    if (cachedData != null && cachedData is List) {
      setState(() {
        _examList = List<QuestionBankModel>.from(cachedData);
        _isLoading = false;
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _syncWithFirestore() async {
    if (_examBox == null || !_examBox!.isOpen) return;

    try {
      // ডাইনামিক পাথ সেটআপ
      var examsCollection = FirebaseFirestore.instance
          .collection('All_Question')
          .doc(widget.categoryName) // Preparation Center থেকে আসা নাম
          .collection(_selectedType) // ট্যাব থেকে আসা (MCQ/Written/Viva)
          .doc('Exams')
          .collection('All_Exams');

      QuerySnapshot examSnapshots = await examsCollection.get();

      List<QuestionBankModel> allFetchedQuestions = [];

      // প্রতিটি পরীক্ষার ভেতরের 'Items' থেকে ডাটা ফেচ
      for (var doc in examSnapshots.docs) {
        String examTitle = doc.id;
        QuerySnapshot itemSnap = await doc.reference.collection('Items').get();

        for (var itemDoc in itemSnap.docs) {
          allFetchedQuestions.add(
            QuestionBankModel.fromJson(itemDoc.data() as Map<String, dynamic>, examTitle, _selectedType),
          );
        }
      }

      // হাইভে সেভ এবং স্টেট আপডেট
      await _examBox!.put(_selectedType, allFetchedQuestions);
      if (mounted) setState(() { _examList = allFetchedQuestions; _isLoading = false; });

    } catch (e) {
      debugPrint("Sync Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: widget.isDarkMode
            ? const Color(0xFF0F172A)
            : Colors.white,
        appBar: AppBar(
          title: Text(widget.categoryName),
          bottom: TabBar(
            onTap: (index) {
              if (_examBox == null || !_examBox!.isOpen) return;

              String newType = index == 0
                  ? 'MCQ'
                  : index == 1
                  ? 'Written'
                  : 'Viva';

              if (_selectedType != newType) {
                setState(() {
                  _selectedType = newType;
                  _isLoading = true;
                  _examList = [];
                });
                _loadLocalData();
                _syncWithFirestore();
              }
            },
            tabs: const [
              Tab(text: "MCQ"),
              Tab(text: "Written"),
              Tab(text: "Viva"),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildList(),
      ),
    );
  }

  Widget _buildList() {
    if (_examList.isEmpty) {
      return Center(
        child: Text(
          "$_selectedType সেকশনে কোনো ডাটা নেই",
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      );
    }

    // গ্রুপ বাই টাইটেল (যদি একই পরীক্ষার সব প্রশ্ন একসাথে দেখতে চান)
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _examList.length,
      itemBuilder: (context, index) {
        final item = _examList[index];
        return Card(
          color: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              item.title,
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            // ListTile এর ভেতরে subtitle বা বডিতে
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("প্রশ্ন: ${item.question}"),
                if (item.options != null && item.options!.isNotEmpty)
                  Text("অপশন আছে (MCQ)")
                else
                  Text("সরাসরি উত্তর (Written/Viva)"),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }
}
