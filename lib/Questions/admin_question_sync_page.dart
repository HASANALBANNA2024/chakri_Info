import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class AdminQuestionSyncPage extends StatefulWidget {
  @override
  _AdminQuestionSyncPageState createState() => _AdminQuestionSyncPageState();
}

class _AdminQuestionSyncPageState extends State<AdminQuestionSyncPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _quesStep1Main = [
    'BCS (বিসিএস প্রশ্ন)',
    'Govt Job',
    'Bank Job',
    'Primary (শিক্ষক)',
    'NTRCA (নিবন্ধন)',
    'ভর্তি প্রস্তুতি',
    'Medical & Nursing',
    'Technical (ইঞ্জিনিয়ারিং)',
    'Others (অন্যান্য)',
  ];

  final Map<String, List<String>> _quesStep2Sub = {
    'BCS (বিসিএস প্রশ্ন)': [
      'MCQ (Preliminary)',
      'Written',
      'Viva Guide',
      'PDF Solution',
    ],
    'Govt Job': ['10th-20th Grade', 'Ministry Specific', 'Non-Cadre'],
    'Bank Job': ['Govt Bank', 'Private Bank', 'Combined Bank'],
    'ভর্তি প্রস্তুতি': [
      'University Admission',
      'Engineering Admission',
      'Medical Admission',
      'Nursing Admission',
    ],
    'Medical & Nursing': ['Medical Officer', 'Nursing', 'Technician'],
    'Technical (ইঞ্জিনিয়ারিং)': ['BSC Engineering', 'Diploma Engineering'],
    'NTRCA (নিবন্ধন)': ['School Level', 'College Level'],
  };

  String? s1, s2;
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _pdfUrlCtrl = TextEditingController();
  final TextEditingController _bulkJsonCtrl = TextEditingController();

  String _examType = "MCQ"; // এটিই আপনার মেইন ফিল্টার (MCQ/Written/Viva)
  bool _isJsonMode = false;
  bool _isSingleJson = false;

  List<Map<String, TextEditingController>> _manualControllers = [];
  List<TextEditingController> _singleJsonControllers = [];

  XFile? _pickedImageFile;
  Uint8List? _pdfBytes;
  String? _selectedPdfName;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _addManualField();
    _addSingleJsonField();
  }

  void _addManualField() => setState(
    () => _manualControllers.add({
      'q': TextEditingController(),
      'o1': TextEditingController(),
      'o2': TextEditingController(),
      'o3': TextEditingController(),
      'o4': TextEditingController(),
      'ans': TextEditingController(),
      'exp': TextEditingController(),
    }),
  );

  void _addSingleJsonField() =>
      setState(() => _singleJsonControllers.add(TextEditingController()));

  // --- মেইন আপলোড ফাংশন (Updated) ---
  Future<void> _uploadDataDirectly() async {
    if (s1 == null || _titleCtrl.text.trim().isEmpty) {
      _showMsg("❌ মেইন ক্যাটাগরি এবং টাইটেল দিন!");
      return;
    }

    setState(() => _isUploading = true);
    try {
      String finalTitle = _titleCtrl.text.trim();
      List<Map<String, dynamic>> rawQuestions = [];

      // ১. ডাটা প্রসেসিং
      if (_isJsonMode) {
        if (_isSingleJson) {
          for (var c in _singleJsonControllers) {
            if (c.text.isNotEmpty) rawQuestions.add(jsonDecode(c.text));
          }
        } else {
          if (_bulkJsonCtrl.text.isNotEmpty) {
            rawQuestions = List<Map<String, dynamic>>.from(
              jsonDecode(_bulkJsonCtrl.text),
            );
          }
        }
      } else {
        for (var ctrl in _manualControllers) {
          if (ctrl['q']!.text.isNotEmpty) {
            rawQuestions.add({
              'q': ctrl['q']!.text.trim(),
              'options': _examType == "MCQ"
                  ? [
                      ctrl['o1']!.text.trim(),
                      ctrl['o2']!.text.trim(),
                      ctrl['o3']!.text.trim(),
                      ctrl['o4']!.text.trim(),
                    ]
                  : [],
              'ans': ctrl['ans']!.text.trim(),
              'exp': ctrl['exp']!.text.trim(),
            });
          }
        }
      }

      // ২. ফায়ারবেস পাথ (আপনার ইউজার প্যানেলের ট্যাবের সাথে মিল রেখে)
      // Path: All_Question -> [BCS] -> [MCQ/Written/Viva] -> Exams -> List -> All_Exams -> [Title]
      DocumentReference examRef = _firestore
          .collection('All_Question')
          .doc(s1) // Document (যেমন: BCS)
          .collection(_examType) // Collection (যেমন: MCQ)
          .doc('Exams') // Document (এটি এখন একটি নির্দিষ্ট ডক)
          .collection('List') // Collection (এর ভেতরে অনেকগুলো লিস্ট থাকতে পারে)
          .doc('All_Exams') // Document (সব এক্সাম এই ডকুমেন্টের আন্ডারে)
          .collection('Items') // Collection (আসল এক্সাম লিস্ট)
          .doc(finalTitle);

      // ৩. এক্সাম মেইন ডাটা (যা কার্ডে শো করবে)
      await examRef.set({
        'title': finalTitle,
        'exam_type': _examType,
        'sub_category': s2 ?? "General",
        'total_questions': rawQuestions.length,
        'pdf_url': _pdfUrlCtrl.text.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // ৪. প্রশ্নগুলো Items সাব-কালেকশনে আপলোড
      WriteBatch batch = _firestore.batch();
      for (var q in rawQuestions) {
        DocumentReference qRef = examRef.collection('Items').doc();
        batch.set(qRef, q);
      }
      await batch.commit();

      _showMsg("✅ $finalTitle আপলোড সফল!");
      _resetForm();
    } catch (e) {
      _showMsg("❌ এরর: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _resetForm() {
    _titleCtrl.clear();
    _bulkJsonCtrl.clear();
    setState(() {
      s1 = null;
      s2 = null;
      _manualControllers = [];
      _addManualField();
    });
  }

  void _showMsg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F5F9),
      appBar: AppBar(
        title: Text("Admin Master Sync Z"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionCard("১. ক্যাটাগরি ও টাইপ", [
              Row(
                children: [
                  "MCQ",
                  "Written",
                  "Viva",
                ].map((t) => _buildTypeBtn(t)).toList(),
              ),
              SizedBox(height: 15),
              _buildDropdown(
                "ধাপ ১ (মেইন)",
                s1,
                _quesStep1Main,
                (v) => setState(() {
                  s1 = v;
                  s2 = null;
                }),
              ),
              if (s1 != null && _quesStep2Sub.containsKey(s1))
                _buildDropdown(
                  "ধাপ ২ (সাব)",
                  s2,
                  _quesStep2Sub[s1]!,
                  (v) => setState(() => s2 = v),
                ),
            ]),
            _buildSectionCard("২. প্রশ্ন ইনপুট", [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Manual"),
                  Switch(
                    value: _isJsonMode,
                    onChanged: (v) => setState(() => _isJsonMode = v),
                    activeColor: Colors.indigo,
                  ),
                  Text("JSON Mode"),
                ],
              ),
              _isJsonMode ? _buildJsonSection() : _buildManualSection(),
            ]),
            _buildSectionCard("৩. টাইটেল ও মিডিয়া", [
              _buildInputField(
                "টাইটেল লিখুন",
                Icons.title,
                "যেমন: বিসিএস মডেল টেস্ট ১",
                _titleCtrl,
              ),
              _buildInputField(
                "ড্রাইভ লিংক",
                Icons.link,
                "https://...",
                _pdfUrlCtrl,
              ),
            ]),
            SizedBox(height: 20),
            _isUploading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadDataDirectly,
                    child: Text(
                      "START SYNC NOW",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 60),
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // --- ছোট হেল্পার উইজেটগুলো ---
  Widget _buildTypeBtn(String t) {
    bool isS = _examType == t;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _examType = t),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isS ? Colors.indigo : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.indigo),
          ),
          child: Center(
            child: Text(
              t,
              style: TextStyle(
                color: isS ? Colors.white : Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String t, List<Widget> c) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            Divider(),
            ...c,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String l,
    String? v,
    List<String> i,
    Function(String?) o,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: v,
        isExpanded: true,
        items: i
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: o,
        decoration: InputDecoration(
          labelText: l,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String l,
    IconData i,
    String h,
    TextEditingController c,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: l,
          prefixIcon: Icon(i),
          hintText: h,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // JSON ও Manual সেকশনের উইজেটগুলো আপনার দেওয়া আগের কোড অনুযায়ী কাজ করবে...
  // (জায়গা বাঁচাতে এখানে সংক্ষেপ করা হয়েছে, আপনি আপনার অরিজিনাল উইজেটগুলো এখানে রাখবেন)
  Widget _buildJsonSection() => Text("JSON Input Active");
  Widget _buildManualSection() => Text("Manual Input Active");
}
