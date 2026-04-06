import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // ওয়েবের জন্য জরুরি

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // প্ল্যাটফর্ম চেক করতে
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// আপনার উইজেটটি ইমপোর্ট করুন (নিশ্চিত করুন এটিতে যেন dart:io না থাকে)
import '../widgets/pdf_upload_section.dart';

class AdminQuestionSyncPage extends StatefulWidget {
  @override
  _AdminQuestionSyncPageState createState() => _AdminQuestionSyncPageState();
}

class _AdminQuestionSyncPageState extends State<AdminQuestionSyncPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? s1, s2, s3, s4;
  final TextEditingController _jsonCtrl = TextEditingController();
  final TextEditingController _pdfUrlCtrl = TextEditingController();
  final TextEditingController _titleCtrl = TextEditingController();

  // ওয়েব এবং মোবাইলের জন্য ডাটা টাইপ
  XFile? _pickedImageFile;
  Uint8List? _pdfBytes;

  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  // ডাটা টেবিল (আপনার আগের ডাটাই রাখা হয়েছে)
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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) setState(() => _pickedImageFile = image);
  }

  Future<void> _uploadDataDirectly() async {
    // শুধুমাত্র অতি প্রয়োজনীয় ফিল্ডগুলো চেক
    if (s1 == null || s2 == null || _jsonCtrl.text.isEmpty) {
      _showMsg("কমপক্ষে ধাপ ১, ধাপ ২ এবং JSON ডাটা দিন!");
      return;
    }
    setState(() => _isUploading = true);

    try {
      String finalTitle = _titleCtrl.text.isEmpty
          ? (s4 ?? "Untitled_Exam")
          : _titleCtrl.text.trim();
      List rawQuestions = jsonDecode(_jsonCtrl.text);

      // ইমেজ কনভার্ট (ফাঁকা থাকলে স্কিপ হবে)
      String? base64Img;
      if (_pickedImageFile != null) {
        base64Img = base64Encode(await _pickedImageFile!.readAsBytes());
      }

      // পিডিএফ কনভার্ট (ফাঁকা থাকলে স্কিপ হবে)
      String? base64Pdf;
      if (_pdfBytes != null) {
        base64Pdf = base64Encode(_pdfBytes!);
      }

      DocumentReference examRef = _firestore
          .collection('All_Question')
          .doc(s1)
          .collection(s2!)
          .doc(s3 ?? 'General')
          .collection('Exams')
          .doc(finalTitle);

      // ১. মেটা ডাটা সেভ
      await examRef.set({
        'title': finalTitle,
        'image_preview': base64Img, // null হলে সমস্যা নেই
        'pdf_url': _pdfUrlCtrl.text,
        'pdf_direct_data': base64Pdf, // null হলে সমস্যা নেই
        'total_questions': rawQuestions.length,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // ২. ব্যাচ আপলোড
      WriteBatch batch = _firestore.batch();
      for (var q in rawQuestions) {
        DocumentReference qRef = examRef.collection('Items').doc();
        q['title'] = finalTitle;
        batch.set(qRef, q);
      }

      await batch.commit();

      _showMsg("'$finalTitle' সফলভাবে আপলোড হয়েছে!");
      _jsonCtrl.clear();
      _titleCtrl.clear();
      _pdfUrlCtrl.clear();
      setState(() {
        _pickedImageFile = null;
        _pdfBytes = null;
      });
    } catch (e) {
      _showMsg("ভুল: ${e.toString()}");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showMsg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F5F9),
      appBar: AppBar(
        title: Text("Master Question Sync"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(kIsWeb ? 32 : 16),
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 800,
                ), // পিসিতে দেখতে সুন্দর লাগবে
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionCard("ডাটাবেজ পাথ সিলেকশন", [
                      _buildDropdown(
                        "ধাপ ১",
                        s1,
                        _quesStep1Main,
                        (v) => setState(() {
                          s1 = v;
                          s2 = s3 = s4 = null;
                        }),
                      ),
                      if (s1 != null && _quesStep2Sub.containsKey(s1!))
                        _buildDropdown(
                          "ধাপ ২",
                          s2,
                          _quesStep2Sub[s1!]!,
                          (v) => setState(() {
                            s2 = v;
                            s3 = s4 = null;
                          }),
                        ),
                      if (s2 != null && _quesStep3Specific.containsKey(s2!))
                        _buildDropdown(
                          "ধাপ ৩",
                          s3,
                          _quesStep3Specific[s2!]!,
                          (v) => setState(() {
                            s3 = v;
                            s4 = null;
                          }),
                        ),
                      if (s3 != null && _quesStep4Final.containsKey(s3!))
                        _buildDropdown(
                          "ধাপ ৪",
                          s4,
                          _quesStep4Final[s3!]!,
                          (v) => setState(() => s4 = v),
                        ),
                    ]),

                    _buildSectionCard("প্রশ্ন ইমেজ ও পিডিএফ", [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 130,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: _pickedImageFile == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 30,
                                      color: Colors.grey,
                                    ),
                                    Text("ছবি সিলেক্ট করুন (ঐচ্ছিক)"),
                                  ],
                                )
                              : kIsWeb
                              ? Image.network(
                                  _pickedImageFile!.path,
                                  fit: BoxFit.contain,
                                ) // ওয়েবের জন্য
                              : Image.memory(
                                  Uint8List.fromList(
                                    File(
                                      _pickedImageFile!.path,
                                    ).readAsBytesSync(),
                                  ),
                                  fit: BoxFit.contain,
                                ), // মোবাইলের জন্য
                        ),
                      ),
                      SizedBox(height: 16),
                      // পিডিএফ সেকশন (ওয়েব এবং মোবাইলে কাজ করবে)
                      PdfUploadSection(
                        onFileSelected: (file, name) async {
                          if (file != null) {
                            final bytes = await file.readAsBytes();
                            setState(() => _pdfBytes = bytes);
                          } else {
                            setState(() => _pdfBytes = null);
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      _buildInputField(
                        "PDF ড্রাইভ লিংক (ঐচ্ছিক)",
                        Icons.link,
                        "https://...",
                        _pdfUrlCtrl,
                      ),
                    ]),

                    _buildSectionCard("পরীক্ষার তথ্য", [
                      _buildInputField(
                        "টাইটেল (ফাঁকা রাখলে ধাপ ৪ অনুযায়ী হবে)",
                        Icons.title,
                        "Ex: Dhaka University 2017",
                        _titleCtrl,
                      ),
                    ]),

                    _buildSectionCard("JSON ডাটা", [
                      TextField(
                        controller: _jsonCtrl,
                        maxLines: kIsWeb ? 15 : 8, // পিসিতে বড় দেখাবে
                        decoration: InputDecoration(
                          hintText: "Paste JSON here...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ]),

                    SizedBox(height: 20),
                    _isUploading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: _uploadDataDirectly,
                            icon: Icon(Icons.cloud_upload),
                            label: Text("Start Sync"),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 55),
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                    SizedBox(height: 40), // স্ক্রিনের নিচে বাড়তি গ্যাপ
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.indigo,
              ),
            ),
            Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true, // ওভারফ্লো রোধ করতে
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: TextStyle(fontSize: 13)),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    IconData icon,
    String hint,
    TextEditingController ctrl,
  ) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
