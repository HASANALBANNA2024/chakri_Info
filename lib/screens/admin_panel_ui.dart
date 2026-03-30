// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart' as path_provider;
//
// class AdminPanelScreen extends StatefulWidget {
//   @override
//   _AdminPanelScreenState createState() => _AdminPanelScreenState();
// }
//
// class _AdminPanelScreenState extends State<AdminPanelScreen>
//     with SingleTickerProviderStateMixin {
//   // --- Updated Image State ---
//   List<File> _selectedImages = []; // একাধিক ইমেজ রাখার জন্য লিস্ট
//   bool _isCompressing = false;
//
//   // --- Admin Credentials ---
//   final String _adminEmail = "albannamdhasan48@gmail.com";
//   final String _adminPass = "940911";
//   final TextEditingController _emailCtrl = TextEditingController();
//   final TextEditingController _passCtrl = TextEditingController();
//   bool _isLoggedIn = false;
//
//   late TabController _tabController;
//
//   // --- Multi-Step Selection Data ---
//   final List<String> _step1Main = [
//     'Job Circular',
//     'Question Bank',
//     'Admission',
//     'Notice or Result',
//   ];
//   final Map<String, List<String>> _step2Sub = {
//     'Job Circular': [
//       'Government',
//       'Engineering',
//       'Defense',
//       'Bank',
//       'Medical',
//       'Others',
//     ],
//     'Question Bank': ['Job Questions', 'Admission Questions'],
//     'Admission': ['University', 'Engineering', 'Medical'],
//     'Notice or Result': ['Job Result', 'Exam Notice'],
//   };
//   final Map<String, List<String>> _step3Specific = {
//     'Engineering': ['BSc Engineering', 'Diploma Engineering'],
//     'Government': ['Ministry', 'Railway', 'Teacher'],
//     'Defense': ['Forces', 'Security'],
//     'Bank': ['Govt Bank', 'Private Bank'],
//   };
//   final Map<String, List<String>> _step4Final = {
//     'BSc Engineering': [
//       'Computer',
//       'Civil',
//       'Electrical',
//       'Mechanical',
//       'Textile',
//     ],
//     'Diploma Engineering': [
//       'Computer (Dip)',
//       'Civil (Dip)',
//       'Electrical (Dip)',
//     ],
//     'Forces': ['Army', 'Navy', 'Air Force'],
//     'Security': ['Police', 'Ansar', 'BGB'],
//     'Ministry': ['Education Ministry', 'Health Ministry', 'Railway Ministry'],
//   };
//
//   String? selectedStep1,
//       selectedStep2,
//       selectedStep3,
//       selectedStep4,
//       filterMain;
//   bool isGovtJob = true;
//
//   final TextEditingController _titleCtrl = TextEditingController();
//   final TextEditingController _totalPostCtrl = TextEditingController();
//   final TextEditingController _jsonCtrl = TextEditingController();
//
//   List<Map<String, TextEditingController>> positions = [
//     {
//       'name': TextEditingController(),
//       'post': TextEditingController(),
//       'salary': TextEditingController(),
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }
//
//   // --- Updated Image Picker & Compressor Logic ---
//   Future<void> _pickAndCompressImages() async {
//     final picker = ImagePicker();
//     // একসাথে একাধিক ইমেজ সিলেক্ট করার জন্য pickMultiImage
//     final List<XFile>? pickedFiles = await picker.pickMultiImage();
//
//     if (pickedFiles != null && pickedFiles.isNotEmpty) {
//       setState(() => _isCompressing = true);
//
//       List<File> compressedList = [];
//       double totalSizeKB = 0;
//
//       for (var file in pickedFiles) {
//         final dir = await path_provider.getTemporaryDirectory();
//         final targetPath =
//             "${dir.absolute.path}/temp_${DateTime.now().millisecondsSinceEpoch}_${compressedList.length}.jpg";
//
//         // Quality 7-10 এবং MinWidth 1000 দিলে সাইজ খুব কম হয় কিন্তু লেখা পরিষ্কার থাকে
//         var result = await FlutterImageCompress.compressAndGetFile(
//           file.path,
//           targetPath,
//           quality: 8,
//           minWidth: 1000,
//           minHeight: 1000,
//         );
//
//         if (result != null) {
//           File compressedFile = File(result.path);
//           compressedList.add(compressedFile);
//           totalSizeKB += (await compressedFile.length()) / 1024;
//         }
//       }
//
//       setState(() {
//         _selectedImages.addAll(compressedList);
//         _isCompressing = false;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             "মোট ${compressedList.length}টি ইমেজ যোগ হয়েছে। গড় সাইজ: ${(totalSizeKB / compressedList.length).toStringAsFixed(2)} KB",
//           ),
//         ),
//       );
//     }
//   }
//
//   void _calculateTotalPosts() {
//     int total = 0;
//     for (var pos in positions) {
//       int count = int.tryParse(pos['post']!.text) ?? 0;
//       total += count;
//     }
//     setState(() => _totalPostCtrl.text = total.toString());
//   }
//
//   void _addPositionField() {
//     setState(
//       () => positions.add({
//         'name': TextEditingController(),
//         'post': TextEditingController(),
//         'salary': TextEditingController(),
//       }),
//     );
//   }
//
//   void _removePositionField(int index) {
//     if (positions.length > 1) {
//       setState(() {
//         positions.removeAt(index);
//         _calculateTotalPosts();
//       });
//     }
//   }
//
//   void _handleLogin() {
//     if (_emailCtrl.text == _adminEmail && _passCtrl.text == _adminPass) {
//       setState(() => _isLoggedIn = true);
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("ভুল ইমেইল বা পাসওয়ার্ড!")));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_isLoggedIn) return _buildLoginScreen();
//     return Scaffold(
//       backgroundColor: Color(0xFFF3F5F9),
//       appBar: AppBar(
//         title: Text(
//           "Admin Control Panel",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         bottom: TabBar(
//           controller: _tabController,
//           labelColor: Colors.blueAccent,
//           unselectedLabelColor: Colors.grey,
//           isScrollable: true,
//           tabs: [
//             Tab(icon: Icon(Icons.post_add), text: "Create Circular"),
//             Tab(icon: Icon(Icons.storage_rounded), text: "Database Sync"),
//             Tab(icon: Icon(Icons.quiz_rounded), text: "Question Bank"),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildAddCircularTab(),
//           _buildManageCircularTab(),
//           _buildQuestionBankTab(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAddCircularTab() {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // ইমেজ পিকার সেকশন
//           _buildSectionCard("Circular Images (Multiple)", [
//             _buildMultiImagePicker(),
//           ]),
//
//           _buildSectionCard("ডাটাবেস টেবিল সিলেকশন (৪-ধাপ)", [
//             _buildDropdown("ধাপ ১: মূল টেবিল", selectedStep1, _step1Main, (
//               val,
//             ) {
//               setState(() {
//                 selectedStep1 = val;
//                 selectedStep2 = null;
//                 selectedStep3 = null;
//                 selectedStep4 = null;
//               });
//             }),
//             if (selectedStep1 != null && _step2Sub.containsKey(selectedStep1))
//               _buildDropdown(
//                 "ধাপ ২: সাব টেবিল",
//                 selectedStep2,
//                 _step2Sub[selectedStep1]!,
//                 (val) {
//                   setState(() {
//                     selectedStep2 = val;
//                     selectedStep3 = null;
//                     selectedStep4 = null;
//                   });
//                 },
//               ),
//             if (selectedStep2 != null &&
//                 _step3Specific.containsKey(selectedStep2))
//               _buildDropdown(
//                 "ধাপ ৩: ক্যাটাগরি",
//                 selectedStep3,
//                 _step3Specific[selectedStep2]!,
//                 (val) {
//                   setState(() {
//                     selectedStep3 = val;
//                     selectedStep4 = null;
//                   });
//                 },
//               ),
//             if (selectedStep3 != null && _step4Final.containsKey(selectedStep3))
//               _buildDropdown(
//                 "ধাপ ৪: সুনির্দিষ্ট বিভাগ (Table)",
//                 selectedStep4,
//                 _step4Final[selectedStep3]!,
//                 (val) {
//                   setState(() => selectedStep4 = val);
//                 },
//               ),
//           ]),
//
//           _buildSectionCard("পদ ও বিস্তারিত তথ্য", [
//             _buildInputField(
//               "সার্কুলার টাইটেল",
//               Icons.title,
//               "উদা: প্রাণ গ্রুপে বিশাল নিয়োগ বিজ্ঞপ্তি",
//               _titleCtrl,
//             ),
//             SwitchListTile(
//               title: Text("সরকারি চাকরি? (গ্রেড সিস্টেম)"),
//               value: isGovtJob,
//               onChanged: (v) => setState(() => isGovtJob = v),
//             ),
//             _buildInputField(
//               "প্রতিষ্ঠানের নাম",
//               Icons.business,
//               "উদা: সোনালী ব্যাংক",
//               null,
//             ),
//             _buildDynamicPositionsList(),
//             _buildInputField(
//               "মোট পদের সংখ্যা (Auto)",
//               Icons.groups_3_outlined,
//               "টোটাল পদ",
//               _totalPostCtrl,
//               isReadOnly: true,
//             ),
//           ]),
//
//           _buildSectionCard("তারিখ ও লিংক", [
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildInputField(
//                     "শুরুর তারিখ",
//                     Icons.calendar_today,
//                     "দিন-মাস-বছর",
//                     null,
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: _buildInputField(
//                     "শেষ তারিখ",
//                     Icons.timer_off_outlined,
//                     "দিন-মাস-বছর",
//                     null,
//                   ),
//                 ),
//               ],
//             ),
//             _buildInputField("আবেদন লিংক", Icons.link, "https://...", null),
//             SizedBox(height: 10),
//             _buildLargeTextField("বিস্তারিত বর্ণনা", null),
//           ]),
//
//           SizedBox(height: 15),
//           _buildActionButton(
//             "পাবলিশ করুন (Firebase Sync)",
//             Colors.blueAccent,
//             () {},
//           ),
//           SizedBox(height: 30),
//         ],
//       ),
//     );
//   }
//
//   // --- Updated Multi-Image UI ---
//   Widget _buildMultiImagePicker() {
//     return Column(
//       children: [
//         if (_selectedImages.isNotEmpty)
//           Container(
//             height: 120,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: _selectedImages.length,
//               itemBuilder: (context, index) {
//                 return Stack(
//                   children: [
//                     Container(
//                       margin: EdgeInsets.only(right: 10),
//                       width: 100,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: Colors.blue.shade100),
//                         image: DecorationImage(
//                           image: FileImage(_selectedImages[index]),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       right: 5,
//                       top: 0,
//                       child: GestureDetector(
//                         onTap: () =>
//                             setState(() => _selectedImages.removeAt(index)),
//                         child: CircleAvatar(
//                           radius: 12,
//                           backgroundColor: Colors.red,
//                           child: Icon(
//                             Icons.close,
//                             size: 15,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         SizedBox(height: 10),
//         GestureDetector(
//           onTap: _pickAndCompressImages,
//           child: Container(
//             height: 80,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               borderRadius: BorderRadius.circular(15),
//               border: Border.all(
//                 color: Colors.blue.shade100,
//                 style: BorderStyle.solid,
//               ),
//             ),
//             child: _isCompressing
//                 ? Center(child: CircularProgressIndicator())
//                 : Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.add_photo_alternate, color: Colors.blueAccent),
//                       SizedBox(width: 10),
//                       Text(
//                         "ইমেজ যোগ করুন (একাধিক সম্ভব)",
//                         style: TextStyle(
//                           color: Colors.blueAccent,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDynamicPositionsList() {
//     return Column(
//       children: [
//         ...positions.asMap().entries.map((entry) {
//           int index = entry.key;
//           var ctrl = entry.value;
//           return Container(
//             margin: EdgeInsets.only(bottom: 12),
//             padding: EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(15),
//               border: Border.all(color: Colors.blue.shade100.withOpacity(0.5)),
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       flex: 3,
//                       child: _buildInlineInput(ctrl['name']!, "পদের নাম"),
//                     ),
//                     SizedBox(width: 8),
//                     Expanded(
//                       flex: 1,
//                       child: _buildInlineInput(
//                         ctrl['post']!,
//                         "সংখ্যা",
//                         isNum: true,
//                         onChanged: (v) => _calculateTotalPosts(),
//                       ),
//                     ),
//                     if (positions.length > 1)
//                       IconButton(
//                         icon: Icon(
//                           Icons.cancel,
//                           color: Colors.redAccent,
//                           size: 20,
//                         ),
//                         onPressed: () => _removePositionField(index),
//                       ),
//                   ],
//                 ),
//                 SizedBox(height: 8),
//                 _buildInlineInput(
//                   ctrl['salary']!,
//                   isGovtJob
//                       ? "এই পদের গ্রেড (যেমন: ১১তম গ্রেড)"
//                       : "এই পদের বেতন (যেমন: ২৫,০০০/-)",
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//         TextButton.icon(
//           onPressed: _addPositionField,
//           icon: Icon(Icons.add_circle_outline, size: 16),
//           label: Text("নতুন পদ ও বেতন যোগ করুন"),
//         ),
//       ],
//     );
//   }
//
//   // --- HELPERS (UI NO CHANGE) ---
//   Widget _buildSectionCard(String title, List<Widget> children) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 15),
//       padding: EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.indigo,
//               fontSize: 14,
//             ),
//           ),
//           Divider(height: 25),
//           ...children,
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInputField(
//     String label,
//     IconData icon,
//     String hint,
//     TextEditingController? ctrl, {
//     bool isReadOnly = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: TextField(
//         controller: ctrl,
//         readOnly: isReadOnly,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(
//             icon,
//             size: 20,
//             color: isReadOnly ? Colors.orange : Colors.blueAccent,
//           ),
//           filled: true,
//           fillColor: isReadOnly ? Colors.orange.shade50 : Color(0xFFF8FAFC),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLargeTextField(String hint, TextEditingController? ctrl) {
//     return TextField(
//       controller: ctrl,
//       maxLines: 4,
//       decoration: InputDecoration(
//         hintText: hint,
//         filled: true,
//         fillColor: Color(0xFFF8FAFC),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
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
//       padding: const EdgeInsets.only(bottom: 12),
//       child: DropdownButtonFormField<String>(
//         isExpanded: true,
//         value: value,
//         items: items
//             .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//             .toList(),
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           labelText: label,
//           filled: true,
//           fillColor: Color(0xFFF8FAFC),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInlineInput(
//     TextEditingController ctrl,
//     String hint, {
//     bool isNum = false,
//     Function(String)? onChanged,
//   }) {
//     return TextField(
//       controller: ctrl,
//       onChanged: onChanged,
//       keyboardType: isNum ? TextInputType.number : TextInputType.text,
//       decoration: InputDecoration(
//         hintText: hint,
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.blue.shade50),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         onPressed: onTap,
//         child: Text(
//           label,
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildManageCircularTab() {
//     return Column(
//       children: [
//         _buildFilterHeader(),
//         Expanded(
//           child: ListView.builder(
//             padding: EdgeInsets.all(12),
//             itemCount: 3,
//             itemBuilder: (context, index) =>
//                 _buildDataCard("নমুনা ডেটা", "ধাপ: ${filterMain ?? 'সব'}"),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildQuestionBankTab() {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         children: [
//           _buildSectionCard("নতুন প্রশ্ন সেট আপলোড", [
//             _buildDropdown("মেইন বিভাগ", null, ['Job', 'Admission'], (v) {}),
//             _buildInputField(
//               "পরীক্ষার নাম",
//               Icons.account_tree_outlined,
//               "উদা: ৪৫তম বিসিএস",
//               null,
//             ),
//             _buildLargeTextField("JSON ডাটা...", _jsonCtrl),
//             SizedBox(height: 10),
//             _buildActionButton("আপলোড করুন", Colors.orangeAccent, () {}),
//           ]),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDataCard(String title, String sub) {
//     return Card(
//       margin: EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         leading: Icon(Icons.description_outlined, color: Colors.blue),
//         title: Text(
//           title,
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//         ),
//         subtitle: Text(sub, style: TextStyle(fontSize: 12)),
//         trailing: Icon(Icons.edit, size: 18, color: Colors.blue),
//       ),
//     );
//   }
//
//   Widget _buildFilterHeader() {
//     return Container(
//       width: double.infinity,
//       color: Colors.white,
//       padding: EdgeInsets.symmetric(vertical: 8),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: _step1Main
//               .map(
//                 (c) => Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 4),
//                   child: ChoiceChip(
//                     label: Text(c),
//                     selected: filterMain == c,
//                     onSelected: (s) => setState(() {
//                       filterMain = s ? c : null;
//                     }),
//                   ),
//                 ),
//               )
//               .toList(),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoginScreen() {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(35.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.admin_panel_settings, size: 70, color: Colors.indigo),
//               SizedBox(height: 20),
//               _buildInputField("অ্যাডমিন ইমেইল", Icons.email, "", _emailCtrl),
//               _buildInputField("পাসওয়ার্ড", Icons.lock, "", _passCtrl),
//               _buildActionButton("লগইন করুন", Colors.indigo, _handleLogin),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';

import 'package:chakri_info/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class AdminPanelScreen extends StatefulWidget {
  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  // --- Service & State ---
  final FirebaseService _firebaseService = FirebaseService();
  List<File> _selectedImages = [];
  bool _isCompressing = false;
  bool _isPublishing = false;

  // --- Admin Credentials ---
  final String _adminEmail = "albannamdhasan48@gmail.com";
  final String _adminPass = "940911";
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _isLoggedIn = false;

  late TabController _tabController;

  // --- Selection Data ---
  final List<String> _step1Main = [
    'Job Circular',
    'Question Bank',
    'Admission',
    'Notice or Result',
  ];
  final Map<String, List<String>> _step2Sub = {
    'Job Circular': [
      'Government',
      'Engineering',
      'Defense',
      'Bank',
      'Medical',
      'Others',
    ],
    'Question Bank': ['Job Questions', 'Admission Questions'],
    'Admission': ['University', 'Engineering', 'Medical'],
    'Notice or Result': ['Job Result', 'Exam Notice'],
  };
  final Map<String, List<String>> _step3Specific = {
    'Engineering': ['BSc Engineering', 'Diploma Engineering'],
    'Government': ['Ministry', 'Railway', 'Teacher'],
    'Defense': ['Forces', 'Security'],
    'Bank': ['Govt Bank', 'Private Bank'],
  };
  final Map<String, List<String>> _step4Final = {
    'BSc Engineering': [
      'Computer',
      'Civil',
      'Electrical',
      'Mechanical',
      'Textile',
    ],
    'Diploma Engineering': [
      'Computer (Dip)',
      'Civil (Dip)',
      'Electrical (Dip)',
    ],
    'Forces': ['Army', 'Navy', 'Air Force'],
    'Security': ['Police', 'Ansar', 'BGB'],
    'Ministry': ['Education Ministry', 'Health Ministry', 'Railway Ministry'],
  };

  String? selectedStep1,
      selectedStep2,
      selectedStep3,
      selectedStep4,
      filterMain;
  bool isGovtJob = true;

  // --- Controllers ---
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _totalPostCtrl = TextEditingController();
  final TextEditingController _jsonCtrl = TextEditingController();
  final TextEditingController _companyCtrl = TextEditingController();
  final TextEditingController _startDateCtrl = TextEditingController();
  final TextEditingController _endDateCtrl = TextEditingController();
  final TextEditingController _linkCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  List<Map<String, TextEditingController>> positions = [
    {
      'name': TextEditingController(),
      'post': TextEditingController(),
      'salary': TextEditingController(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // --- Image Picker & Compressor ---
  Future<void> _pickAndCompressImages() async {
    final picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() => _isCompressing = true);
      List<File> compressedList = [];
      for (var file in pickedFiles) {
        final dir = await path_provider.getTemporaryDirectory();
        final targetPath =
            "${dir.absolute.path}/temp_${DateTime.now().millisecondsSinceEpoch}_${compressedList.length}.jpg";
        var result = await FlutterImageCompress.compressAndGetFile(
          file.path,
          targetPath,
          quality: 8,
          minWidth: 1000,
          minHeight: 1000,
        );
        if (result != null) compressedList.add(File(result.path));
      }
      setState(() {
        _selectedImages.addAll(compressedList);
        _isCompressing = false;
      });
    }
  }

  // --- Preview & Publish Logic ---
  void _showPreviewDialog() {
    if (_selectedImages.isEmpty ||
        selectedStep1 == null ||
        _titleCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("সব তথ্য এবং ইমেজ প্রদান করুন!")));
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("পাবলিশ করার আগে দেখে নিন"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "টাইটেল: ${_titleCtrl.text}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("পাথ: $selectedStep1 > $selectedStep2"),
              Text("মোট ইমেজ: ${_selectedImages.length} টি"),
              Text("মোট পদ: ${_totalPostCtrl.text}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("এডিট করুন"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handlePublish();
            },
            child: Text("পাবলিশ নিশ্চিত করুন"),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePublish() async {
    setState(() => _isPublishing = true);
    try {
      // ১. স্টোরেজ ছাড়া ইমেজগুলোকে সরাসরি টেক্সটে (Base64) রূপান্তর করা
      // এর জন্য আমরা সরাসরি ফাইল থেকে বাইটস নিয়ে এনকোড করবো
      List<String> base64Images = [];
      for (var file in _selectedImages) {
        List<int> imageBytes = await file.readAsBytes();
        String base64String = base64Encode(imageBytes);
        base64Images.add(base64String);
      }

      List<Map<String, dynamic>> positionData = positions
          .map(
            (p) => {
              'name': p['name']!.text,
              'post': p['post']!.text,
              'salary_grade': p['salary']!.text,
            },
          )
          .toList();

      Map<String, dynamic> fullData = {
        'title': _titleCtrl.text,
        'company': _companyCtrl.text,
        'images': base64Images, // এখন ইমেজের বদলে টেক্সট ডাটা যাবে
        'positions': positionData,
        'total_posts': _totalPostCtrl.text,
        'start_date': _startDateCtrl.text,
        'end_date': _endDateCtrl.text,
        'apply_link': _linkCtrl.text,
        'description': _descCtrl.text,
        'is_govt': isGovtJob,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // ২. ডাটাবেসে সেভ করা
      await _firebaseService.saveCircular(
        step1: selectedStep1!,
        step2: selectedStep2!,
        step3: selectedStep3,
        step4: selectedStep4,
        circularData: fullData,
      );

      setState(() {
        _selectedImages.clear();
        _titleCtrl.clear();
        _companyCtrl.clear();
        _startDateCtrl.clear();
        _endDateCtrl.clear();
        _linkCtrl.clear();
        _descCtrl.clear();
        positions = [
          {
            'name': TextEditingController(),
            'post': TextEditingController(),
            'salary': TextEditingController(),
          },
        ];
        _isPublishing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("সফলভাবে পাবলিশ হয়েছে (Firestore-এ সেভড!)")),
      );
    } catch (e) {
      setState(() => _isPublishing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _calculateTotalPosts() {
    int total = 0;
    for (var pos in positions) {
      int count = int.tryParse(pos['post']!.text) ?? 0;
      total += count;
    }
    setState(() => _totalPostCtrl.text = total.toString());
  }

  void _addPositionField() {
    setState(
      () => positions.add({
        'name': TextEditingController(),
        'post': TextEditingController(),
        'salary': TextEditingController(),
      }),
    );
  }

  void _removePositionField(int index) {
    if (positions.length > 1) {
      setState(() {
        positions.removeAt(index);
        _calculateTotalPosts();
      });
    }
  }

  void _handleLogin() {
    if (_emailCtrl.text == _adminEmail && _passCtrl.text == _adminPass) {
      setState(() => _isLoggedIn = true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("ভুল ইমেইল বা পাসওয়ার্ড!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) return _buildLoginScreen();
    return Scaffold(
      backgroundColor: Color(0xFFF3F5F9),
      appBar: AppBar(
        title: Text(
          "Admin Control Panel",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          tabs: [
            Tab(icon: Icon(Icons.post_add), text: "Create Circular"),
            Tab(icon: Icon(Icons.storage_rounded), text: "Database Sync"),
            Tab(icon: Icon(Icons.quiz_rounded), text: "Question Bank"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAddCircularTab(),
          _buildManageCircularTab(),
          _buildQuestionBankTab(),
        ],
      ),
    );
  }

  Widget _buildAddCircularTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard("Circular Images (Multiple)", [
            _buildMultiImagePicker(),
          ]),
          _buildSectionCard("ডাটাবেস টেবিল সিলেকশন (৪-ধাপ)", [
            _buildDropdown(
              "ধাপ ১: মূল টেবিল",
              selectedStep1,
              _step1Main,
              (val) => setState(() {
                selectedStep1 = val;
                selectedStep2 = null;
                selectedStep3 = null;
                selectedStep4 = null;
              }),
            ),
            if (selectedStep1 != null && _step2Sub.containsKey(selectedStep1))
              _buildDropdown(
                "ধাপ ২: সাব টেবিল",
                selectedStep2,
                _step2Sub[selectedStep1]!,
                (val) => setState(() {
                  selectedStep2 = val;
                  selectedStep3 = null;
                  selectedStep4 = null;
                }),
              ),
            if (selectedStep2 != null &&
                _step3Specific.containsKey(selectedStep2))
              _buildDropdown(
                "ধাপ ৩: ক্যাটাগরি",
                selectedStep3,
                _step3Specific[selectedStep2]!,
                (val) => setState(() {
                  selectedStep3 = val;
                  selectedStep4 = null;
                }),
              ),
            if (selectedStep3 != null && _step4Final.containsKey(selectedStep3))
              _buildDropdown(
                "ধাপ ৪: সুনির্দিষ্ট বিভাগ (Table)",
                selectedStep4,
                _step4Final[selectedStep3]!,
                (val) => setState(() => selectedStep4 = val),
              ),
          ]),
          _buildSectionCard("পদ ও বিস্তারিত তথ্য", [
            _buildInputField(
              "সার্কুলার টাইটেল",
              Icons.title,
              "উদা: প্রাণ গ্রুপে বিশাল নিয়োগ বিজ্ঞপ্তি",
              _titleCtrl,
            ),
            SwitchListTile(
              title: Text("সরকারি চাকরি? (গ্রেড সিস্টেম)"),
              value: isGovtJob,
              onChanged: (v) => setState(() => isGovtJob = v),
            ),
            _buildInputField(
              "প্রতিষ্ঠানের নাম",
              Icons.business,
              "উদা: সোনালী ব্যাংক",
              _companyCtrl,
            ),
            _buildDynamicPositionsList(),
            _buildInputField(
              "মোট পদের সংখ্যা (Auto)",
              Icons.groups_3_outlined,
              "টোটাল পদ",
              _totalPostCtrl,
              isReadOnly: true,
            ),
          ]),
          _buildSectionCard("তারিখ ও লিংক", [
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    "শুরুর তারিখ",
                    Icons.calendar_today,
                    "দিন-মাস-বছর",
                    _startDateCtrl,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildInputField(
                    "শেষ তারিখ",
                    Icons.timer_off_outlined,
                    "দিন-মাস-বছর",
                    _endDateCtrl,
                  ),
                ),
              ],
            ),
            _buildInputField(
              "আবেদন লিংক",
              Icons.link,
              "https://...",
              _linkCtrl,
            ),
            SizedBox(height: 10),
            _buildLargeTextField("বিস্তারিত বর্ণনা", _descCtrl),
          ]),
          SizedBox(height: 15),
          _buildActionButton(
            _isPublishing ? "পাবলিশ হচ্ছে..." : "পাবলিশ করুন (Preview)",
            Colors.blueAccent,
            _isPublishing ? () {} : _showPreviewDialog,
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- Helper Widgets (No UI Change) ---
  Widget _buildMultiImagePicker() {
    return Column(
      children: [
        if (_selectedImages.isNotEmpty)
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) => Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade100),
                      image: DecorationImage(
                        image: FileImage(_selectedImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 5,
                    top: 0,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedImages.removeAt(index)),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close, size: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: _pickAndCompressImages,
          child: Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.blue.shade100,
                style: BorderStyle.solid,
              ),
            ),
            child: _isCompressing
                ? Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, color: Colors.blueAccent),
                      SizedBox(width: 10),
                      Text(
                        "ইমেজ যোগ করুন (একাধিক)",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicPositionsList() {
    return Column(
      children: [
        ...positions
            .asMap()
            .entries
            .map(
              (entry) => Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.blue.shade100.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildInlineInput(
                            entry.value['name']!,
                            "পদের নাম",
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: _buildInlineInput(
                            entry.value['post']!,
                            "সংখ্যা",
                            isNum: true,
                            onChanged: (v) => _calculateTotalPosts(),
                          ),
                        ),
                        if (positions.length > 1)
                          IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            onPressed: () => _removePositionField(entry.key),
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    _buildInlineInput(
                      entry.value['salary']!,
                      isGovtJob ? "গ্রেড (উদা: ১১তম)" : "বেতন (উদা: ২৫,০০০/-)",
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        TextButton.icon(
          onPressed: _addPositionField,
          icon: Icon(Icons.add_circle_outline, size: 16),
          label: Text("নতুন পদ ও বেতন যোগ করুন"),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
              fontSize: 14,
            ),
          ),
          Divider(height: 25),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    IconData icon,
    String hint,
    TextEditingController? ctrl, {
    bool isReadOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        readOnly: isReadOnly,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            size: 20,
            color: isReadOnly ? Colors.orange : Colors.blueAccent,
          ),
          filled: true,
          fillColor: isReadOnly ? Colors.orange.shade50 : Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLargeTextField(String hint, TextEditingController? ctrl) {
    return TextField(
      controller: ctrl,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
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
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildInlineInput(
    TextEditingController ctrl,
    String hint, {
    bool isNum = false,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: ctrl,
      onChanged: onChanged,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade50),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildManageCircularTab() =>
      Center(child: Text("Database Management Coming Soon"));
  Widget _buildQuestionBankTab() =>
      Center(child: Text("Question Bank Coming Soon"));

  Widget _buildLoginScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(35.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.admin_panel_settings, size: 70, color: Colors.indigo),
              SizedBox(height: 20),
              _buildInputField("অ্যাডমিন ইমেইল", Icons.email, "", _emailCtrl),
              _buildInputField("পাসওয়ার্ড", Icons.lock, "", _passCtrl),
              _buildActionButton("লগইন করুন", Colors.indigo, _handleLogin),
            ],
          ),
        ),
      ),
    );
  }
}
