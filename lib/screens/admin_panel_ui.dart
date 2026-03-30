import 'dart:io';

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
  // image
  File? _selectedImage;
  bool _isCompressing = false;

  // --- Admin Credentials ---
  final String _adminEmail = "albannamdhasan48@gmail.com";
  final String _adminPass = "940911";
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _isLoggedIn = false;

  late TabController _tabController;

  // --- Step 1: Main Tables ---
  final List<String> _step1Main = [
    'Job Circular',
    'Question Bank',
    'Admission',
    'Notice or Result',
  ];

  // --- Step 2: Sub Tables ---
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

  // --- Step 3: Specific Categories ---
  final Map<String, List<String>> _step3Specific = {
    'Engineering': ['BSc Engineering', 'Diploma Engineering'],
    'Government': ['Ministry', 'Railway', 'Teacher'],
    'Defense': ['Forces', 'Security'],
    'Bank': ['Govt Bank', 'Private Bank'],
  };

  // --- Step 4: Final Collections ---
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

  // --- Selection Variables ---
  String? selectedStep1;
  String? selectedStep2;
  String? selectedStep3;
  String? selectedStep4;

  String? filterMain;
  bool isGovtJob = true;

  // --- New Controllers ---
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _totalPostCtrl = TextEditingController();
  final TextEditingController _jsonCtrl = TextEditingController();

  // Multiple Positions Controller (Updated with Salary)
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

  // image future builder
  Future<void> _pickAndCompressImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() => _isCompressing = true);
      final dir = await path_provider.getTemporaryDirectory();
      final targetPath =
          "${dir.absolute.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg";

      var result = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        targetPath,
        quality: 10,
        minWidth: 600,
        minHeight: 600,
      );

      if (result != null) {
        File compressedFile = File(result.path);
        int fileSize = await compressedFile.length();
        setState(() {
          _selectedImage = compressedFile;
          _isCompressing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "ইমেজ সাইজ: ${(fileSize / 1024).toStringAsFixed(2)} KB",
            ),
          ),
        );
      }
    }
  }

  void _calculateTotalPosts() {
    int total = 0;
    for (var pos in positions) {
      int count = int.tryParse(pos['post']!.text) ?? 0;
      total += count;
    }
    setState(() {
      _totalPostCtrl.text = total.toString();
    });
  }

  void _addPositionField() {
    setState(() {
      positions.add({
        'name': TextEditingController(),
        'post': TextEditingController(),
        'salary': TextEditingController(),
      });
    });
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
          _buildSectionCard("Circular Image", [_buildImagePickerBox()]),

          _buildSectionCard("ডাটাবেস টেবিল সিলেকশন (৪-ধাপ)", [
            _buildDropdown("ধাপ ১: মূল টেবিল", selectedStep1, _step1Main, (
              val,
            ) {
              setState(() {
                selectedStep1 = val;
                selectedStep2 = null;
                selectedStep3 = null;
                selectedStep4 = null;
              });
            }),
            if (selectedStep1 != null && _step2Sub.containsKey(selectedStep1))
              _buildDropdown(
                "ধাপ ২: সাব টেবিল",
                selectedStep2,
                _step2Sub[selectedStep1]!,
                (val) {
                  setState(() {
                    selectedStep2 = val;
                    selectedStep3 = null;
                    selectedStep4 = null;
                  });
                },
              ),
            if (selectedStep2 != null &&
                _step3Specific.containsKey(selectedStep2))
              _buildDropdown(
                "ধাপ ৩: ক্যাটাগরি",
                selectedStep3,
                _step3Specific[selectedStep2]!,
                (val) {
                  setState(() {
                    selectedStep3 = val;
                    selectedStep4 = null;
                  });
                },
              ),
            if (selectedStep3 != null && _step4Final.containsKey(selectedStep3))
              _buildDropdown(
                "ধাপ ৪: সুনির্দিষ্ট বিভাগ (Table)",
                selectedStep4,
                _step4Final[selectedStep3]!,
                (val) {
                  setState(() => selectedStep4 = val);
                },
              ),
          ]),

          _buildSectionCard("পদ ও বিস্তারিত তথ্য", [
            _buildInputField(
              "সার্কুলার টাইটেল",
              Icons.title,
              "উদা: প্রাণ গ্রুপে বিশাল নিয়োগ বিজ্ঞপ্তি",
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
              null,
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
                    null,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildInputField(
                    "শেষ তারিখ",
                    Icons.timer_off_outlined,
                    "দিন-মাস-বছর",
                    null,
                  ),
                ),
              ],
            ),
            _buildInputField("আবেদন লিংক", Icons.link, "https://...", null),
            SizedBox(height: 10),
            _buildLargeTextField("বিস্তারিত বর্ণনা", null),
          ]),

          SizedBox(height: 15),
          _buildActionButton(
            "পাবলিশ করুন (Firebase Sync)",
            Colors.blueAccent,
            () {},
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDynamicPositionsList() {
    return Column(
      children: [
        ...positions.asMap().entries.map((entry) {
          int index = entry.key;
          var ctrl = entry.value;
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue.shade100.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildInlineInput(ctrl['name']!, "পদের নাম"),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: _buildInlineInput(
                        ctrl['post']!,
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
                        onPressed: () => _removePositionField(index),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                _buildInlineInput(
                  ctrl['salary']!,
                  isGovtJob
                      ? "এই পদের গ্রেড (যেমন: ১১তম গ্রেড)"
                      : "এই পদের বেতন (যেমন: ২৫,০০০/-)",
                ),
              ],
            ),
          );
        }).toList(),
        TextButton.icon(
          onPressed: _addPositionField,
          icon: Icon(Icons.add_circle_outline, size: 16),
          label: Text("নতুন পদ ও বেতন যোগ করুন"),
        ),
      ],
    );
  }

  // ================= HELPERS (NO UI CHANGE) =================
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

  Widget _buildImagePickerBox() {
    return GestureDetector(
      onTap: _pickAndCompressImage,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blue.shade100),
          image: _selectedImage != null
              ? DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.contain,
                )
              : null,
        ),
        child: _isCompressing
            ? Center(child: CircularProgressIndicator())
            : (_selectedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          color: Colors.blueAccent,
                          size: 40,
                        ),
                        Text(
                          "সার্কুলার ইমেজ সিলেক্ট করুন",
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ],
                    )
                  : null),
      ),
    );
  }

  // --- REST OF THE CODE (No Change) ---
  Widget _buildManageCircularTab() {
    return Column(
      children: [
        _buildFilterHeader(),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: 3,
            itemBuilder: (context, index) =>
                _buildDataCard("নমুনা ডেটা", "ধাপ: ${filterMain ?? 'সব'}"),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionBankTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard("নতুন প্রশ্ন সেট আপলোড", [
            _buildDropdown("মেইন বিভাগ", null, ['Job', 'Admission'], (v) {}),
            _buildInputField(
              "পরীক্ষার নাম",
              Icons.account_tree_outlined,
              "উদা: ৪৫তম বিসিএস",
              null,
            ),
            _buildLargeTextField("JSON ডাটা...", _jsonCtrl),
            SizedBox(height: 10),
            _buildActionButton("আপলোড করুন", Colors.orangeAccent, () {}),
          ]),
        ],
      ),
    );
  }

  Widget _buildDataCard(String title, String sub) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.description_outlined, color: Colors.blue),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(sub, style: TextStyle(fontSize: 12)),
        trailing: Icon(Icons.edit, size: 18, color: Colors.blue),
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _step1Main
              .map(
                (c) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: filterMain == c,
                    onSelected: (s) => setState(() {
                      filterMain = s ? c : null;
                    }),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

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
