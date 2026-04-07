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
    // ১. বক্স চেক (Nullable handle করা হয়েছে)
    if (_examBox == null || !_examBox!.isOpen) {
      debugPrint("Hive Box is not open yet!");
      return;
    }

    try {
      // ২. ডাটাবেস ভার্সন চেক (Settings -> db_status)
      DocumentSnapshot statusDoc = await FirebaseFirestore.instance
          .collection('Settings')
          .doc('db_status')
          .get();

      int remoteVersion = 0;
      if (statusDoc.exists && statusDoc.data() != null) {
        remoteVersion =
            (statusDoc.data() as Map<String, dynamic>)['version'] ?? 0;
      }

      int localVersion = _examBox!.get('version_$_selectedType') as int? ?? 0;

      // ৩. কন্ডিশন: ভার্সন নতুন হলে অথবা লোকাল লিস্ট একদম খালি থাকলে ডাটা ফেচ হবে
      if (remoteVersion > localVersion || _examList.isEmpty) {
        debugPrint(
          "Fetching fresh data for: ${widget.categoryName} -> $_selectedType",
        );

        // সঠিক পাথ: All_Question -> Category -> Type -> Exams -> All_Exams
        QuerySnapshot examSnapshots = await FirebaseFirestore.instance
            .collection('All_Question')
            .doc(widget.categoryName)
            .collection(_selectedType)
            .doc('Exams')
            .collection('All_Exams')
            .get();

        if (examSnapshots.docs.isEmpty) {
          debugPrint("No exams found in Firestore for this path.");
          if (mounted) setState(() => _isLoading = false);
          return;
        }

        List<QuestionBankModel> allFetchedQuestions = [];

        // ৪. প্রতিটি পরীক্ষার ভেতরের 'Items' সাব-কালেকশন থেকে প্রশ্ন আনা
        for (var doc in examSnapshots.docs) {
          String examTitle = doc.data().toString().contains('title')
              ? (doc.get('title') ?? doc.id)
              : doc.id;

          // সাব-কালেকশন 'Items' থেকে ডাটা রিড
          QuerySnapshot itemSnap = await doc.reference
              .collection('Items')
              .get();

          for (var itemDoc in itemSnap.docs) {
            final data = itemDoc.data() as Map<String, dynamic>;
            // মডেলের factory method ব্যবহার করে ডাটা অ্যাড করা
            allFetchedQuestions.add(
              QuestionBankModel.fromJson(data, examTitle, _selectedType),
            );
          }
        }

        // ৫. হাইভে ডাটা এবং নতুন ভার্সন সেভ করা
        if (allFetchedQuestions.isNotEmpty) {
          await _examBox!.put(_selectedType, allFetchedQuestions);
          await _examBox!.put('version_$_selectedType', remoteVersion);
        }

        if (mounted) {
          setState(() {
            _examList = allFetchedQuestions;
            _isLoading = false;
          });
        }
      } else {
        // ভার্সন সেম থাকলে শুধু লোডিং বন্ধ হবে (লোকাল ডাটা অলরেডি লোড হয়েছে)
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Firestore Sync Error: $e");
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
            subtitle: Text(
              "প্রশ্ন: ${item.question.substring(0, item.question.length > 30 ? 30 : item.question.length)}...",
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }
}
