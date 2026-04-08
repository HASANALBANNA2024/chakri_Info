import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/pdf_upload_section.dart';

// question sync
class AdminQuestionSyncPage extends StatefulWidget {
  @override
  _AdminQuestionSyncPageState createState() => _AdminQuestionSyncPageState();
}

class _AdminQuestionSyncPageState extends State<AdminQuestionSyncPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Data Source ---
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
    'কৃষি ও মৎস্য',
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
    'Technical (ইঞ্জিনিয়ারিং)': [
      'MCQ (Preliminary)',
      'Written',
      'Viva Guide',
      'PDF Solution',
    ],
    'Primary (শিক্ষক)': [
      'MCQ (Preliminary)',
      'Written',
      'Viva Guide',
      'PDF Solution',
    ],
    'NTRCA (নিবন্ধন)': ['School Level', 'College Level'],
  };

  final Map<String, List<String>> _quesStep3Specific = {
    '10th-20th Grade': [
      'MCQ (Preliminary)',
      'Written',
      'Viva Guide',
      'PDF Solution',
    ],
    'University Admission': ['MCQ (Preliminary)'],
    'School Level': ['MCQ (Preliminary)', 'Written'],
    'College Level': ['MCQ (Preliminary)', 'Written'],
  };

  final Map<String, List<String>> _quesStep4Final = {
    'MCQ (Preliminary)': ['A Unit', 'B Unit', 'C Unit', 'D Unit'],
  };

  // ড্রপডাউন ভ্যালু স্টোর করার ভ্যারিয়েবল
  String? s1, s2, s3, s4;

  // অন্যান্য কন্ট্রোলার
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _pdfUrlCtrl = TextEditingController();
  final TextEditingController _bulkJsonCtrl = TextEditingController();

  String _examType = "MCQ";
  bool _isJsonMode = false;
  bool _isSingleJson = false;

  List<Map<String, TextEditingController>> _manualControllers = [];
  List<TextEditingController> _singleJsonControllers = [];

  XFile? _pickedImageFile;
  Uint8List? _pdfBytes;
  String? _selectedPdfName;
  String? _selectedPdfSize;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  // JSON স্যাম্পল
  final String _singleRealSample =
      '{"q": "বাংলাদেশের জাতীয় পতাকার ডিজাইনার কে?", "options": ["জয়নুল আবেদিন", "কামরুল হাসান", "হামিদুর রহমান", "এস এম সুলতান"], "ans": "কামরুল হাসান", "exp": "কামরুল হাসান বাংলাদেশের জাতীয় পতাকার বর্তমান রূপটি ডিজাইন করেন।"}';
  final String _bulkRealSample = '''[
  {"q": "বাংলাদেশের স্বাধীনতা দিবস কবে?", "options": ["২১শে মার্চ", "২৬শে মার্চ", "১৬ই ডিসেম্বর", "১৪ই এপ্রিল"], "ans": "২৬শে মার্চ", "exp": "১৯৭১ সালের ২৬শে মার্চ বাংলাদেশের স্বাধীনতা ঘোষণা করা হয়।"},
  {"q": "সৌরজগতের ক্ষুদ্রতম গ্রহ কোনটি?", "options": ["শুক্র", "মঙ্গল", "বুধ", "প্লুটো"], "ans": "বুধ", "exp": "বুধ সূর্য থেকে নিকটতম এবং ক্ষুদ্রতম গ্রহ।"},
  {"q": "জাতীয় স্মৃতিসৌধের স্থপতি কে?", "options": ["মাইনুল হোসেন", "হামিদুর রহমান", "আব্দুর রাজ্জাক", "শামীম শিকদার"], "ans": "মাইনুল হোসেন", "exp": "সাভারে অবস্থিত স্মৃতিসৌধটি মাইনুল হোসেনের নকশা করা।"},
  {"q": "পদ্মা সেতুর মোট পিলারের সংখ্যা কতটি?", "options": ["৪০টি", "৪১টি", "৪২টি", "৪৩টি"], "ans": "৪২টি", "exp": "পদ্মা বহুমুখী সেতুর মোট পিলারের সংখ্যা ৪২টি।"}
]''';

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
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) setState(() => _pickedImageFile = image);
  }

  Future<void> _uploadDataDirectly() async {
    // ১. প্রাথমিক ভ্যালিডেশন
    if (s1 == null || _titleCtrl.text.trim().isEmpty) {
      _showMsg("❌ ক্যাটাগরি এবং পরীক্ষার টাইটেল অবশ্যই দিন!");
      return;
    }

    List<Map<String, dynamic>> rawQuestions = [];
    try {
      // ২. ডাটা কালেকশন লজিক (JSON অথবা Manual)
      if (_isJsonMode) {
        if (!_isSingleJson) {
          if (_bulkJsonCtrl.text.trim().isEmpty) throw "Bulk JSON বক্সটি খালি!";
          var decoded = jsonDecode(_bulkJsonCtrl.text.trim());
          if (decoded is List) {
            rawQuestions = List<Map<String, dynamic>>.from(decoded);
          } else {
            rawQuestions.add(Map<String, dynamic>.from(decoded));
          }
        } else {
          for (var c in _singleJsonControllers) {
            if (c.text.trim().isEmpty) continue;
            var d = jsonDecode(c.text.trim());
            rawQuestions.add(Map<String, dynamic>.from(d));
          }
        }
      } else {
        for (var ctrl in _manualControllers) {
          if (ctrl['q']!.text.trim().isEmpty) continue;

          Map<String, dynamic> qMap = {
            'q': ctrl['q']!.text.trim(),
            'ans': ctrl['ans']!.text.trim(),
            'exp': ctrl['exp']!.text.trim(),
            'type': _examType, // MCQ/Written/Viva স্টোর করা হচ্ছে
            'created_at': DateTime.now().toIso8601String(),
          };

          // MCQ হলে অপশন অ্যাড হবে, না হলে হবে না
          if (_examType == "MCQ") {
            qMap['options'] = [
              ctrl['o1']!.text.trim(),
              ctrl['o2']!.text.trim(),
              ctrl['o3']!.text.trim(),
              ctrl['o4']!.text.trim(),
            ];
          } else {
            qMap['options'] = []; // Written/Viva এর জন্য খালি লিস্ট
          }
          rawQuestions.add(qMap);
        }
      }

      if (rawQuestions.isEmpty) throw "অন্তত একটি প্রশ্ন ইনপুট দিন!";

      setState(() => _isUploading = true);

      // ৪. ইমেজ হ্যান্ডলিং
      String finalTitle = _titleCtrl.text.trim();
      String? base64Img;
      if (_pickedImageFile != null) {
        base64Img = base64Encode(await _pickedImageFile!.readAsBytes());
      }

      // ৫. Firebase ডাইনামিক পাথ
      DocumentReference examRef = _firestore
          .collection('All_Question')
          .doc(s1)
          .collection(_examType)
          .doc('Exams')
          .collection('All_Exams')
          .doc(finalTitle);

      // ৬. মেইন ডকুমেন্ট (Bundle System)
      // ✅ এখানে 'questions' কী-তে পুরো লিস্টটা পাঠিয়ে দেওয়া হচ্ছে
      await examRef.set({
        'title': finalTitle,
        'image_preview': base64Img,
        'pdf_url': _pdfUrlCtrl.text.trim(),
        'total_questions': rawQuestions.length,
        'exam_type': _examType,
        'status': 'active',
        'updated_at': FieldValue.serverTimestamp(),
        'questions': rawQuestions, // এক ডকুমেন্টেই সব ডাটা!
      }, SetOptions(merge: true));

      // ✅ আলাদা করে 'Items' সাব-কালেকশনে লুপ চালানোর দরকার নেই।
      // এতে ১টি রিডেই সব প্রশ্ন পাওয়া যাবে।

      _showMsg("✅ '$finalTitle' সফলভাবে সিঙ্ক হয়েছে!");
      _resetForm();
    } catch (e) {
      print("Upload Error: $e");
      String errorMsg = "তথ্য আপলোড করতে সমস্যা হয়েছে!";
      if (e is FormatException) errorMsg = "JSON ফরম্যাট ঠিক নেই!";
      _showMsg("⚠️ এরর: $errorMsg");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _resetForm() {
    _bulkJsonCtrl.clear();
    _titleCtrl.clear();
    _pdfUrlCtrl.clear();
    setState(() {
      _pickedImageFile = null;
      _pdfBytes = null;
      _selectedPdfName = null;
      s1 = null;
      s2 = null;
      s3 = null;
      s4 = null;
      _manualControllers = [];
      _addManualField();
    });
  }

  void _showMsg(String m) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(m),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.indigo,
    ),
  );

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
            // ১. ডাইনামিক ক্যাটাগরি সেকশন (৪টি ধাপ)
            _buildSectionCard("১. ক্যাটাগরি সিলেকশন", [
              Row(
                children: [
                  _buildTypeBtn("MCQ"),
                  SizedBox(width: 8),
                  _buildTypeBtn("Written"),
                  SizedBox(width: 8),
                  _buildTypeBtn("Viva"),
                ],
              ),
              SizedBox(height: 15),
              _buildDropdown(
                "ধাপ ১ (মেইন)",
                s1,
                _quesStep1Main,
                (v) => setState(() {
                  s1 = v;
                  s2 = null;
                  s3 = null;
                  s4 = null;
                }),
              ),
              if (s1 != null && _quesStep2Sub.containsKey(s1))
                _buildDropdown(
                  "ধাপ ২ (সাব)",
                  s2,
                  _quesStep2Sub[s1]!,
                  (v) => setState(() {
                    s2 = v;
                    s3 = null;
                    s4 = null;
                  }),
                ),
              if (s2 != null && _quesStep3Specific.containsKey(s2))
                _buildDropdown(
                  "ধাপ ৩ (স্পেসিফিক)",
                  s3,
                  _quesStep3Specific[s2]!,
                  (v) => setState(() {
                    s3 = v;
                    s4 = null;
                  }),
                ),
              if (s3 != null && _quesStep4Final.containsKey(s3))
                _buildDropdown(
                  "ধাপ ৪ (ফাইনাল)",
                  s4,
                  _quesStep4Final[s3]!,
                  (v) => setState(() => s4 = v),
                ),
            ]),

            // ২. ইনপুট মেথড ও স্যাম্পল
            _buildSectionCard("২. ইনপুট মেথড ও স্যাম্পল", [
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
              Divider(),
              _isJsonMode ? _buildJsonSection() : _buildManualSection(),
            ]),

            // ৩. মিডিয়া ও পিডিএফ প্রিভিউ
            _buildSectionCard("৩. টাইটেল ও মিডিয়া", [
              _buildInputField(
                "টাইটেল লিখুন",
                Icons.title,
                "যেমন: বিসিএস প্রিলি মডেল টেস্ট ১",
                _titleCtrl,
              ),
              _buildImagePicker(),
              SizedBox(height: 15),

              PdfUploadSection(
                onFileSelected: (file, name, bytes) {
                  setState(() {
                    _selectedPdfName = name; // এটি UI তে নাম দেখানোর জন্য
                    _pdfBytes = bytes; // এটি আপলোডের মূল ডাটা
                  });
                },
              ),
              SizedBox(height: 10),
              _buildInputField(
                "ড্রাইভ লিংক",
                Icons.link,
                "https://drive.google.com/...",
                _pdfUrlCtrl,
              ),
            ]),

            SizedBox(height: 25),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- উইজেট হেল্পারস ---
  Widget _buildJsonSection() {
    String currentSample = _isSingleJson ? _singleRealSample : _bulkRealSample;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isSingleJson
                        ? "Single Real Sample:"
                        : "Bulk Real Sample (4 Qs):",
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, color: Colors.amber, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: currentSample));
                      _showMsg("কপি হয়েছে!");
                    },
                  ),
                ],
              ),
              Divider(color: Colors.white24),
              SelectableText(
                currentSample,
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Bulk"),
            Switch(
              value: _isSingleJson,
              onChanged: (v) => setState(() => _isSingleJson = v),
              activeColor: Colors.indigo,
            ),
            Text("Single (+)"),
          ],
        ),
        _isSingleJson
            ? _buildSingleJsonList()
            : TextField(
                controller: _bulkJsonCtrl,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: "Paste Bulk JSON here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildSingleJsonList() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _singleJsonControllers.length,
          itemBuilder: (c, i) => Row(
            children: [
              Expanded(
                child: _buildMiniField(
                  _singleJsonControllers[i],
                  'JSON Object',
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () =>
                    setState(() => _singleJsonControllers.removeAt(i)),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: _addSingleJsonField,
          icon: Icon(Icons.add),
          label: Text("Add Box"),
        ),
      ],
    );
  }

  Widget _buildManualSection() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _manualControllers.length,
          itemBuilder: (c, i) => _buildManualItem(i),
        ),
        IconButton(
          onPressed: _addManualField,
          icon: Icon(Icons.add_circle, color: Colors.indigo, size: 35),
        ),
      ],
    );
  }

  Widget _buildManualItem(int i) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Question #${i + 1}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () =>
                      setState(() => _manualControllers.removeAt(i)),
                ),
              ],
            ),
            _buildMiniField(
              _manualControllers[i]['q']!,
              "প্রশ্নটি এখানে লিখুন",
            ),

            // MCQ হলে ৪টি অপশন দেখাবে
            if (_examType == "MCQ") ...[
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniField(
                      _manualControllers[i]['o1']!,
                      "Option A",
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: _buildMiniField(
                      _manualControllers[i]['o2']!,
                      "Option B",
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniField(
                      _manualControllers[i]['o3']!,
                      "Option C",
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: _buildMiniField(
                      _manualControllers[i]['o4']!,
                      "Option D",
                    ),
                  ),
                ],
              ),
            ],

            // উত্তর এবং ব্যাখ্যা (Explanation) ফিল্ড
            _buildMiniField(
              _manualControllers[i]['ans']!,
              "সঠিক উত্তর (যেমন: ক অথবা সরাসরি টেক্সট)",
            ),
            _buildMiniField(
              _manualControllers[i]['exp']!,
              "ব্যাখ্যা (Explanation) - ঐচ্ছিক",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBtn(String t) {
    bool isS = _examType == t;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _examType = t),
        child: Container(
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

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 120,
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: _pickedImageFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, color: Colors.indigo),
                  Text("কভার ফটো"),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.network(_pickedImageFile!.path, fit: BoxFit.contain)
                    : Image.file(
                        File(_pickedImageFile!.path),
                        fit: BoxFit.contain,
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
                fontSize: 15,
                color: Colors.indigo,
              ),
            ),
            Divider(height: 25),
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
          prefixIcon: Icon(i, size: 20),
          hintText: h,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildMiniField(TextEditingController c, String h) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: h,
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.all(12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
