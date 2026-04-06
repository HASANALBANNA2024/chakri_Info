// import 'dart:convert';
// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart'; // ফায়ারবেস ইমপোর্ট
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
// class AdminQuestionSyncPage extends StatefulWidget {
//   @override
//   _AdminQuestionSyncPageState createState() => _AdminQuestionSyncPageState();
// }
//
// class _AdminQuestionSyncPageState extends State<AdminQuestionSyncPage> {
//   // ফায়ারবেস ইনস্ট্যান্স
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   String? s1, s2, s3, s4;
//   final TextEditingController _jsonCtrl = TextEditingController();
//   final TextEditingController _pdfUrlCtrl = TextEditingController();
//   File? _questionImage;
//   bool _isUploading = false;
//   final ImagePicker _picker = ImagePicker();
//
//   // data table 1
//   final List<String> _quesStep1Main = [
//     'BCS (বিসিএস প্রশ্ন)',
//     'Govt Job',
//     'Bank Job',
//     'Primary (শিক্ষক)',
//     'NTRCA (নিবন্ধন)',
//     'ভর্তি প্রস্তুতি',
//     'Medical & Nursing',
//     'কৃষি ও মৎস্য',
//     'Technical (ইঞ্জিনিয়ারিং)',
//     'Others (অন্যান্য)',
//   ];
//
//   // Data Table 2
//   final Map<String, List<String>> _quesStep2Sub = {
//     'BCS (বিসিএস প্রশ্ন)': [
//       'MCQ (Preliminary)',
//       'Written',
//       'Viva Guide',
//       'PDF Solution',
//     ],
//     'Govt Job': ['10th-20th Grade', 'Ministry Specific', 'Non-Cadre'],
//     'Bank Job': ['Govt Bank', 'Private Bank', 'Combined Bank'],
//     'Admission': [
//       'University Admission',
//       'Engineering Admission',
//       'Medical Admission',
//       'Nursing Admission',
//     ],
//     'Medical & Nursing': ['Medical Officer', 'Nursing', 'Technician'],
//     'Technical (ইঞ্জিনিয়ারিং)': [
//       'MCQ (Preliminary)',
//       'Written',
//       'Viva Guide',
//       'PDF Solution',
//     ],
//     'Primary (শিক্ষক)': [
//       'MCQ (Preliminary)',
//       'Written',
//       'Viva Guide',
//       'PDF Solution',
//     ],
//     'NTRCA (নিবন্ধন)': ['School Level', 'College Level'],
//   };
//
//   // data table 3
//   final Map<String, List<String>> _quesStep3Specific = {
//     // Medical and Nursing
//     'Nursing': ['MCQ (Preliminary)', 'Written', 'Viva Guide', 'PDF Solution'],
//     'Medical': ['MCQ (Preliminary)', 'Written', 'Viva Guide', 'PDF Solution'],
//     'Technician': [
//       'MCQ (Preliminary)',
//       'Written',
//       'Viva Guide',
//       'PDF Solution',
//     ],
//     'Technologist': [
//       'MCQ (Preliminary)',
//       'Written',
//       'Viva Guide',
//       'PDF Solution',
//     ],
//
//     // Govt Job
//     '10th-20th Grade': [
//       'MCQ (Preliminary)',
//       'Written',
//       'Viva Guide',
//       'PDF Solution',
//     ],
//     'Ministry Specific': [
//       'MCQ (Preliminary)',
//       'Written',
//       'Viva Guide',
//       'PDF Solution',
//     ],
//     'Non-Cadre': ['MCQ (Preliminary)', 'Written', 'Viva Guide', 'PDF Solution'],
//
//     // Bank Job
//     'Govt Bank': ['MCQ (Preliminary)', 'Written', 'Viva Guide', 'PDF Solution'],
//     'Private Bank': [
//       'MCQ (Preliminary)',
//       'Written',
//       'Viva Guide',
//       'PDF Solution',
//     ],
//     'Combined Bank': [
//       'MCQ (Preliminary)',
//       'Written',
//       'Viva Guide',
//       'PDF Solution',
//     ],
//
//     // Admission'University', 'Engineering', 'Medical', 'Nursing'
//     'University Admission': ['MCQ (Preliminary)'],
//     'Engineering Admission': ['MCQ (Preliminary)'],
//     'Medical Admission': ['MCQ (Preliminary)'],
//     'Nursing Admission': ['MCQ (Preliminary)'],
//
//     // NTRCA
//     'School Level': ['MCQ (Preliminary)', 'Written'],
//     'College Level': ['MCQ (Preliminary)', 'Written'],
//   };
//
//   // data table 4
//   final Map<String, List<String>> _quesStep4Final = {
//     'MCQ (Preliminary)': ['A Unit', 'B Unit', 'C Unit', 'D Unit'],
//   };
//
//   // Image selection
//   Future<void> _pickImage() async {
//     final XFile? image = await _picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 50,
//     );
//     if (image != null) {
//       setState(() {
//         _questionImage = File(image.path);
//       });
//     }
//   }
//
//   // firebase upload logic
//   Future<void> _uploadDataDirectly() async {
//     if (s1 == null || s2 == null || _jsonCtrl.text.isEmpty) {
//       _showMsg("সব তথ্য এবং JSON ডাটা ঠিকমতো দিন!");
//       return;
//     }
//
//     setState(() => _isUploading = true);
//
//     try {
//       List questions = jsonDecode(_jsonCtrl.text);
//       String? base64Img;
//       if (_questionImage != null) {
//         base64Img = base64Encode(await _questionImage!.readAsBytes());
//       }
//
//       // ফায়ারবেস পাথ তৈরি
//       DocumentReference examRef = _firestore
//           .collection('All_Question')
//           .doc(s1)
//           .collection(s2!)
//           .doc(s3 ?? 'General')
//           .collection('Exams')
//           .doc(s4 ?? 'Untitled_Exam');
//
//       // ১. মেটা ডাটা সেভ
//       await examRef.set({
//         'title': s4 ?? 'Untitled',
//         'image_preview': base64Img,
//         'pdf_url': _pdfUrlCtrl.text,
//         'total_questions': questions.length,
//         'updated_at': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
//
//       // ২. ব্যাচ আপলোড
//       WriteBatch batch = _firestore.batch();
//       for (var q in questions) {
//         DocumentReference qRef = examRef.collection('Items').doc();
//         batch.set(qRef, q);
//       }
//
//       await batch.commit();
//       _showMsg("সফলভাবে ফায়ারবেসে আপলোড হয়েছে!");
//       _jsonCtrl.clear();
//       setState(() => _questionImage = null);
//     } catch (e) {
//       _showMsg("এরর: ${e.toString()}");
//     } finally {
//       setState(() => _isUploading = false);
//     }
//   }
//
//   void _showMsg(String m) =>
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF3F5F9),
//       appBar: AppBar(
//         title: Text("Master Question Sync"),
//         backgroundColor: Colors.indigo,
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _buildSectionCard("ডাটাবেজ পাথ সিলেকশন", [
//               _buildDropdown(
//                 "ধাপ ১",
//                 s1,
//                 _quesStep1Main,
//                 (v) => setState(() {
//                   s1 = v;
//                   s2 = s3 = s4 = null;
//                 }),
//               ),
//               if (s1 != null && _quesStep2Sub.containsKey(s1!))
//                 _buildDropdown(
//                   "ধাপ ২",
//                   s2,
//                   _quesStep2Sub[s1!]!,
//                   (v) => setState(() {
//                     s2 = v;
//                     s3 = s4 = null;
//                   }),
//                 ),
//               if (s2 != null && _quesStep3Specific.containsKey(s2!))
//                 _buildDropdown(
//                   "ধাপ ৩",
//                   s3,
//                   _quesStep3Specific[s2!]!,
//                   (v) => setState(() {
//                     s3 = v;
//                     s4 = null;
//                   }),
//                 ),
//               if (s3 != null && _quesStep4Final.containsKey(s3!))
//                 _buildDropdown(
//                   "ধাপ ৪",
//                   s4,
//                   _quesStep4Final[s3!]!,
//                   (v) => setState(() => s4 = v),
//                 ),
//             ]),
//
//             _buildSectionCard("প্রশ্ন ইমেজ ও পিডিএফ", [
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: Container(
//                   height: 150,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey[300]!),
//                   ),
//                   child: _questionImage == null
//                       ? Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.image, size: 40, color: Colors.grey),
//                             Text("প্রশ্নপত্রের ছবি সিলেক্ট করুন"),
//                           ],
//                         )
//                       : Image.file(_questionImage!, fit: BoxFit.cover),
//                 ),
//               ),
//               SizedBox(height: 12),
//               _buildInputField(
//                 "PDF ড্রাইভ লিংক",
//                 Icons.picture_as_pdf,
//                 "https://...",
//                 _pdfUrlCtrl,
//               ),
//             ]),
//
//             _buildSectionCard("JSON ডাটা", [
//               TextField(
//                 controller: _jsonCtrl,
//                 maxLines: 10,
//                 decoration: InputDecoration(
//                   hintText: "Paste JSON Array here...",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//             ]),
//
//             SizedBox(height: 20),
//             _isUploading
//                 ? CircularProgressIndicator()
//                 : ElevatedButton.icon(
//                     onPressed: _uploadDataDirectly,
//                     icon: Icon(Icons.cloud_upload),
//                     label: Text("Start Firebase Sync"),
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: Size(double.infinity, 55),
//                       backgroundColor: Colors.indigo,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // helper widgets
//   Widget _buildSectionCard(String title, List<Widget> children) {
//     return Card(
//       elevation: 0,
//       margin: EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: Colors.indigo,
//               ),
//             ),
//             Divider(),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDropdown(
//     String label,
//     String? value,
//     List<String> items,
//     Function(String?) onChanged,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: DropdownButtonFormField<String>(
//         value: value,
//         items: items
//             .map(
//               (e) => DropdownMenuItem(
//                 value: e,
//                 child: Text(e, style: TextStyle(fontSize: 13)),
//               ),
//             )
//             .toList(),
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInputField(
//     String label,
//     IconData icon,
//     String hint,
//     TextEditingController ctrl,
//   ) {
//     return TextField(
//       controller: ctrl,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon),
//         hintText: hint,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// আপনার উইজেটটি ইমপোর্ট করুন
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
  final TextEditingController _titleCtrl =
      TextEditingController(); // টাইটেল এর জন্য
  File? _questionImage;
  File? _finalPdfFile; // পিডিএফ ফাইল রাখার জন্য
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  // ডাটা টেবিলগুলো (আগের মতোই রাখা হয়েছে)
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
    if (image != null) setState(() => _questionImage = File(image.path));
  }

  Future<void> _uploadDataDirectly() async {
    // ভ্যালিডেশনে টাইটেল ফিল্ড চেক যোগ করুন
    if (s1 == null ||
        s2 == null ||
        _jsonCtrl.text.isEmpty ||
        _titleCtrl.text.isEmpty) {
      _showMsg("টাইটেলসহ সব তথ্য ঠিকমতো দিন!");
      return;
    }
    setState(() => _isUploading = true);

    try {
      String finalTitle = _titleCtrl.text.trim(); // ইউজারের দেওয়া টাইটেল
      List rawQuestions = jsonDecode(_jsonCtrl.text);

      // ইমেজ এবং পিডিএফ কনভার্ট (আগের মতোই)
      String? base64Img;
      if (_questionImage != null)
        base64Img = base64Encode(await _questionImage!.readAsBytes());
      String? base64Pdf;
      if (_finalPdfFile != null)
        base64Pdf = base64Encode(await _finalPdfFile!.readAsBytes());

      // ফায়ারবেস ডকুমেন্ট পাথ (টাইটেল অনুযায়ী)
      DocumentReference examRef = _firestore
          .collection('All_Question')
          .doc(s1)
          .collection(s2!)
          .doc(s3 ?? 'General')
          .collection('Exams')
          .doc(finalTitle); // এখানে টাইটেল ব্যবহার করা হয়েছে

      // ১. মেটা ডাটা সেভ
      await examRef.set({
        'title': finalTitle,
        'image_preview': base64Img,
        'pdf_url': _pdfUrlCtrl.text,
        'pdf_direct_data': base64Pdf,
        'total_questions': rawQuestions.length,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // ২. ব্যাচ আপলোড (প্রতিটি প্রশ্নের সাথে টাইটেল সহ)
      WriteBatch batch = _firestore.batch();
      for (var q in rawQuestions) {
        DocumentReference qRef = examRef.collection('Items').doc();

        // প্রশ্নের ভেতর টাইটেল ঢুকিয়ে দেওয়া যাতে ফিল্টার করা যায়
        q['title'] = finalTitle;

        batch.set(qRef, q);
      }

      await batch.commit();

      _showMsg("'$finalTitle' সফলভাবে আপলোড হয়েছে!");
      _jsonCtrl.clear();
      _titleCtrl.clear(); // আপলোড শেষে টাইটেল ক্লিয়ার করুন
      _pdfUrlCtrl.clear();
      setState(() {
        _questionImage = null;
        _finalPdfFile = null;
      });
    } catch (e) {
      _showMsg("এরর: ${e.toString()}");
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
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
              // ১. ইমেজ সিলেকশন
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
                  child: _questionImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 30, color: Colors.grey),
                            Text("ছবি সিলেক্ট করুন"),
                          ],
                        )
                      : Image.file(_questionImage!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 16),

              // ২. পিডিএফ ডিরেক্ট আপলোড (মাঝখানে)
              PdfUploadSection(
                onFileSelected: (file, name) =>
                    setState(() => _finalPdfFile = file),
              ),

              SizedBox(height: 16),

              // ৩. ড্রাইভ লিংক (নিচে)
              _buildInputField(
                "PDF ড্রাইভ লিংক",
                Icons.link,
                "https://...",
                _pdfUrlCtrl,
              ),
            ]),

            _buildSectionCard("পরীক্ষার তথ্য", [
              _buildInputField(
                "পরীক্ষার পূর্ণ নাম (Title)",
                Icons.title,
                "Ex: Dhaka University Admission 2017",
                _titleCtrl,
              ),
            ]),

            _buildSectionCard("JSON ডাটা", [
              TextField(
                controller: _jsonCtrl,
                maxLines: 8,
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
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _uploadDataDirectly,
                    icon: Icon(Icons.cloud_upload),
                    label: Text("Start Firebase Sync"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 55),
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
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
