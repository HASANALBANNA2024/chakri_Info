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
  Box? _examBox;

  @override
  void initState() {
    super.initState();
    _initAndSmartLoad();
  }

  // ১. স্মার্ট লোডিং ইনিশিয়ালাইজেশন
  Future<void> _initAndSmartLoad() async {
    try {
      // ক্যাটাগরি অনুযায়ী আলাদা বক্স বা কি ব্যবহার করা
      String safeName = 'exams_cache_${widget.categoryName.hashCode}';
      _examBox = await Hive.openBox(safeName);

      await _loadDataLogic();
    } catch (e) {
      debugPrint("Hive error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ২. ডাটা লোড করার লজিক (আগে লোকাল, তারপর আপডেট চেক)
  Future<void> _loadDataLogic() async {
    if (_examBox == null || !_examBox!.isOpen) return;

    // ক) লোকাল ডাটা চেক
    final dynamic cachedData = _examBox!.get(_selectedType);

    if (cachedData != null && cachedData is List) {
      print("✅ Loading from Hive (Offline Memory): $_selectedType");
      setState(() {
        _examList = List<QuestionBankModel>.from(cachedData);
        _isLoading = false;
      });
      // খ) ব্যাকগ্রাউন্ডে চেক করবে নতুন আপডেট আছে কি না
      _checkForDatabaseUpdates();
    } else {
      // গ) ডাটা না থাকলে সরাসরি ফায়ারবেস থেকে আনা
      await _syncWithFirestore();
    }
  }

  // ৩. ডাটাবেস আপডেট চেক (বিনা কারণে ফুল ডাটাবেস কল বন্ধ করতে)
  Future<void> _checkForDatabaseUpdates() async {
    try {
      // ফায়ারবেসে updates/status ডকুমেন্টের version ফিল্ড চেক করবে
      var updateDoc = await FirebaseFirestore.instance.collection('updates').doc('status').get();
      int serverVersion = updateDoc.data()?['version'] ?? 0;
      int localVersion = _examBox!.get('${_selectedType}_version') ?? 0;

      if (serverVersion > localVersion) {
        await _syncWithFirestore();
        await _examBox!.put('${_selectedType}_version', serverVersion);
      }
    } catch (e) {
      debugPrint("Update Check Error: $e");
    }
  }

  // ৪. ফায়ারবেস থেকে ডাটা ফেচ (আপনার অরিজিনাল লজিক অক্ষুণ্ণ রাখা হয়েছে)
  Future<void> _syncWithFirestore() async {
    if (_examBox == null || !_examBox!.isOpen) return;

    try {
      print("📡 Full Category Sync Started for: ${widget.categoryName}");
      List<String> types = ['MCQ', 'Written', 'Viva'];

      // প্রতিটি টাইপের (MCQ, Written, Viva) জন্য আলাদা করে লুপ চলবে
      for (String type in types) {
        print("🔍 Fetching data for Type: $type...");

        var examsCollection = FirebaseFirestore.instance
            .collection('All_Question')
            .doc(widget.categoryName)
            .collection(type) // এখানে টাইপটি ডাইনামিক (MCQ/Written/Viva)
            .doc('Exams')
            .collection('All_Exams');

        QuerySnapshot examSnapshots = await examsCollection.get();

        print("📥 Received ${examSnapshots.docs.length} exam groups from Firestore.");
        List<QuestionBankModel> fetchedForThisType = [];

        for (var doc in examSnapshots.docs) {
          String examTitle = doc.id;
          QuerySnapshot itemSnap = await doc.reference.collection('Items').get();
          print("📝 Fetched ${itemSnap.docs.length} items for: $examTitle");
          for (var itemDoc in itemSnap.docs) {
            fetchedForThisType.add(
              QuestionBankModel.fromJson(itemDoc.data() as Map<String, dynamic>, examTitle, type),
            );
          }
        }

        // প্রতিটি টাইপ আলাদা কি (Key) দিয়ে Hive-এ সেভ করা
        await _examBox!.put(type, fetchedForThisType);
        print("💾 Data successfully saved to Hive for future use.");
        // যদি বর্তমান সিলেক্টেড টাইপটি এই লুপের টাইপ হয়, তবে লিস্ট আপডেট করো
        if (_selectedType == type) {
          if (mounted) {
            setState(() {
              _examList = fetchedForThisType;
              _isLoading = false;
            });
          }
        }
      }

      print("✅ All Types (MCQ, Written, Viva) cached successfully for ${widget.categoryName}!");

    } catch (e) {
      print("❌ Full Sync Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: widget.isDarkMode ? const Color(0xFF0F172A) : Colors.white,
        appBar: AppBar(
          title: Text(widget.categoryName),
          bottom: TabBar(
            // onTap: (index) {
            //   String newType = index == 0 ? 'MCQ' : index == 1 ? 'Written' : 'Viva';
            //   if (_selectedType != newType) {
            //     setState(() {
            //       _selectedType = newType;
            //       _isLoading = true;
            //       _examList = [];
            //     });
            //     _loadDataLogic(); // স্মার্ট লোড কল হবে
            //   }
            // },
            onTap: (index) {
              String newType = index == 0 ? 'MCQ' : index == 1 ? 'Written' : 'Viva';

              if (_selectedType != newType) {
                setState(() {
                  _selectedType = newType;
                  // ডাটা সরাসরি Hive থেকে লোড হবে, কোনো লোডিং বা নেটওয়ার্ক কল হবে না
                  final dynamic cachedData = _examBox!.get(_selectedType);
                  if (cachedData != null) {
                    _examList = List<QuestionBankModel>.from(cachedData);
                  } else {
                    _examList = [];
                  }
                });
                print("🔄 Tab Switched to $newType. Data loaded instantly from Hive.");
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

  // --- UI কার্ড ডিজাইন (আগে যেমন ছিল তেমনই আছে) ---
  Widget _buildList() {
    if (_examList.isEmpty) {
      return Center(child: Text("কোনো ডাটা নেই", style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black)));
    }

    Map<String, List<QuestionBankModel>> groupedExams = {};
    for (var question in _examList) {
      groupedExams.putIfAbsent(question.title, () => []).add(question);
    }
    List<String> distinctTitles = groupedExams.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: distinctTitles.length,
      itemBuilder: (context, index) {
        String examTitle = distinctTitles[index];
        List<QuestionBankModel> questionsForThisExam = groupedExams[examTitle]!;

        return Card(
          color: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          elevation: widget.isDarkMode ? 0 : 3,
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: widget.isDarkMode ? BorderSide(color: Colors.white.withOpacity(0.1), width: 1) : BorderSide.none,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                InkWell(
                  onTap: () => _navigateToExamDetail(examTitle, questionsForThisExam),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: widget.isDarkMode ? Colors.indigo.withOpacity(0.2) : Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.menu_book_rounded, color: widget.isDarkMode ? Colors.indigoAccent : Colors.indigo),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text(examTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.isDarkMode ? Colors.white : Colors.black)),
                              const SizedBox(height: 5),
                              Text("মোট প্রশ্ন: ${questionsForThisExam.length} টি", style: TextStyle(fontSize: 13, color: widget.isDarkMode ? Colors.white70 : Colors.black54)),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 18, color: widget.isDarkMode ? Colors.white38 : Colors.grey),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode ? Colors.indigoAccent : Colors.indigo.shade600,
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(12)),
                    ),
                    child: Text(
                      widget.categoryName.split(' ')[0],
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToExamDetail(String title, List<QuestionBankModel> questions) {
    print("Moving to $title with ${questions.length} questions");
  }
}