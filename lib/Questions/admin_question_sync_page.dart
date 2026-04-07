import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
    'কৃষি ও মৎস্য',
    'ভর্তি প্রস্তুতি',
    'Medical & Nursing',
    'Technical (ইঞ্জিনিয়ারিং)',
    'Others (অন্যান্য)',
  ];

  String? s1;
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _pdfUrlCtrl = TextEditingController();
  final TextEditingController _bulkJsonCtrl = TextEditingController();

  String _examType = "MCQ";
  bool _isJsonMode = false;
  bool _isSingleJson = false;

  List<Map<String, TextEditingController>> _manualControllers = [];
  List<TextEditingController> _singleJsonControllers = [];

  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _pickedImage = image);
  }

  // --- মেইন আপলোড ফাংশন ---
  Future<void> _uploadDataDirectly() async {
    if (s1 == null || _titleCtrl.text.trim().isEmpty) {
      _showMsg("❌ ক্যাটাগরি এবং টাইটেল দিন!");
      return;
    }

    setState(() => _isUploading = true);
    try {
      String finalTitle = _titleCtrl.text.trim();
      List<Map<String, dynamic>> rawQuestions = [];

      if (_isJsonMode) {
        if (_isSingleJson) {
          for (var c in _singleJsonControllers) {
            if (c.text.isNotEmpty) rawQuestions.add(jsonDecode(c.text));
          }
        } else {
          if (_bulkJsonCtrl.text.isNotEmpty)
            rawQuestions = List<Map<String, dynamic>>.from(
              jsonDecode(_bulkJsonCtrl.text),
            );
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

      DocumentReference examRef = _firestore
          .collection('All_Question')
          .doc(s1)
          .collection(_examType)
          .doc('Exams')
          .collection('All_Exams')
          .doc(finalTitle);

      await examRef.set({
        'title': finalTitle,
        'exam_type': _examType,
        'pdf_url': _pdfUrlCtrl.text.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

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
    _pdfUrlCtrl.clear();
    _bulkJsonCtrl.clear();
    setState(() {
      s1 = null;
      _pickedImage = null;
      _manualControllers = [];
      _addManualField();
    });
  }

  void _showMsg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
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
                "মেইন ক্যাটাগরি",
                s1,
                _quesStep1Main,
                (v) => setState(() => s1 = v),
              ),
            ]),

            _buildSectionCard("২. প্রশ্ন ইনপুট", [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isJsonMode ? "JSON Mode" : "Manual Mode",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Switch(
                    value: _isJsonMode,
                    onChanged: (v) => setState(() => _isJsonMode = v),
                    activeColor: Colors.indigo,
                  ),
                ],
              ),
              if (_isJsonMode) ...[
                Row(
                  children: [
                    Checkbox(
                      value: _isSingleJson,
                      onChanged: (v) => setState(() => _isSingleJson = v!),
                    ),
                    Text("Single JSON Input"),
                  ],
                ),
                _isSingleJson
                    ? _buildSingleJsonFields()
                    : _buildBulkJsonField(),
              ] else
                _buildManualFields(),
            ]),

            _buildSectionCard("৩. টাইটেল ও মিডিয়া", [
              _buildInputField(
                "টাইটেল লিখুন",
                Icons.title,
                "যেমন: বিসিএস মডেল টেস্ট",
                _titleCtrl,
              ),
              _buildInputField(
                "PDF/Drive Link",
                Icons.picture_as_pdf,
                "https://...",
                _pdfUrlCtrl,
              ),
              if (_pdfUrlCtrl.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Preview: PDF Link added ✅",
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: _pickedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 40, color: Colors.grey),
                            Text("Click to Upload Cover Image"),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            _pickedImage!.path,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                Center(child: Text("Image Selected")),
                          ),
                        ),
                ),
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
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 60),
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // --- UI Components ---
  Widget _buildManualFields() {
    return Column(
      children: [
        ..._manualControllers.map(
          (ctrl) => Card(
            color: Colors.white,
            elevation: 2,
            margin: EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: ctrl['q'],
                    decoration: InputDecoration(
                      labelText: "Question",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_examType == "MCQ") ...[
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ctrl['o1'],
                            decoration: InputDecoration(
                              labelText: "Option 1",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            controller: ctrl['o2'],
                            decoration: InputDecoration(
                              labelText: "Option 2",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ctrl['o3'],
                            decoration: InputDecoration(
                              labelText: "Option 3",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            controller: ctrl['o4'],
                            decoration: InputDecoration(
                              labelText: "Option 4",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 10),
                  TextField(
                    controller: ctrl['ans'],
                    decoration: InputDecoration(
                      labelText: "Correct Answer",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: ctrl['exp'],
                    decoration: InputDecoration(
                      labelText: "Explanation",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: _addManualField,
          icon: Icon(Icons.add_circle),
          label: Text("Add More Question"),
        ),
      ],
    );
  }

  Widget _buildSingleJsonFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          color: Colors.amber[50],
          child: Text(
            'Example: {"q": "...", "options": ["A", "B", "C", "D"], "ans": "A", "exp": "..."}',
            style: TextStyle(fontSize: 11, color: Colors.brown),
          ),
        ),
        SizedBox(height: 10),
        ..._singleJsonControllers.map(
          (c) => Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: TextField(
              controller: c,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Paste single JSON here',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: _addSingleJsonField,
          icon: Icon(Icons.add),
          label: Text("Add New JSON Row"),
        ),
      ],
    );
  }

  Widget _buildBulkJsonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          width: double.infinity,
          color: Colors.blue[50],
          child: Text(
            'Example: [{"q": "Q1", ...}, {"q": "Q2", ...}]',
            style: TextStyle(fontSize: 11, color: Colors.blue[900]),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _bulkJsonCtrl,
          maxLines: 12,
          decoration: InputDecoration(
            hintText: "Paste your bulk JSON array here",
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

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
                fontSize: 16,
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
    return DropdownButtonFormField<String>(
      value: v,
      isExpanded: true,
      items: i.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: o,
      decoration: InputDecoration(labelText: l, border: OutlineInputBorder()),
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
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
