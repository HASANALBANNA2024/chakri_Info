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
          "কোনো ডাটা নেই",
          style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
        ),
      );
    }

    // ১. ইউনিক টাইটেল অনুযায়ী প্রশ্নগুলোকে গ্রুপ করা
    // Map<টাইটেল, প্রশ্নের লিস্ট>
    Map<String, List<QuestionBankModel>> groupedExams = {};

    for (var question in _examList) {
      if (!groupedExams.containsKey(question.title)) {
        groupedExams[question.title] = [];
      }
      groupedExams[question.title]!.add(question);
    }

    // ২. শুধুমাত্র ইউনিক টাইটেলগুলোর লিস্ট বের করা (যেমন: BCS Written 2026)
    List<String> distinctTitles = groupedExams.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: distinctTitles.length,
      itemBuilder: (context, index) {
        String examTitle = distinctTitles[index];
        List<QuestionBankModel> questionsForThisExam = groupedExams[examTitle]!;

        return Card(
          color: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              // ৩. এখানে ক্লিক করলে আপনার কুইজ বা প্রশ্ন দেখানোর পেজে যাবে
              // আমরা পুরো প্রশ্নর লিস্ট (questionsForThisExam) পাঠিয়ে দিচ্ছি
              _navigateToExamDetail(examTitle, questionsForThisExam);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  // আইকন বা লোগো
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: Colors.indigo),
                  ),
                  const SizedBox(width: 15),
                  // টাইটেল এবং ইনফো
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          examTitle, // যেমন: BCS Written 2026
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "মোট প্রশ্ন: ${questionsForThisExam.length} টি",
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// ৪. নেভিগেশন ফাংশন (আপনার ফিউচার লজিক অনুযায়ী এখানে পেজ নাম দিবেন)
  void _navigateToExamDetail(String title, List<QuestionBankModel> questions) {
    // উদাহরণস্বরূপ:
    /* Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => YourQuestionShowPage(
        examTitle: title,
        allQuestions: questions,
      ),
    ),
  ); */
    print("Moving to $title with ${questions.length} questions");
  }
}
