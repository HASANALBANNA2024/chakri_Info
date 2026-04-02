import 'dart:convert';
import 'dart:io';

import 'package:chakri_info/services/admin_sync_page.dart';
import 'package:chakri_info/services/firebase_service.dart';
import 'package:chakri_info/widgets/admin_syn_page_section.dart';
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
  File? _selectedLogo;
  bool _isLogoCompressing = false;

  List<File> _selectedImages = [];
  bool _isCompressing = false;
  bool _isPublishing = false;
  // job repository / and admin sync page ar object create
  final JobRepository _jobRepo = JobRepository();
  String _selectedCategory = "All";
  DateTime? _adminFilterDate;

  // --- Admin Credentials ---
  final String _adminEmail = "albannamdhasan48@gmail.com";
  final String _adminPass = "940911";
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _isLoggedIn = false;

  late TabController _tabController;

  // --- Selection Data ---
  final List<String> _step1Main = [
    'All',
    'Job Circular',
    'Question Bank (প্রশ্ন ব্যাংক)',
    'Admission (ভর্তি পরীক্ষা)',
    'Notice or Result (নোটিশ ও রেজাল্ট)',
  ];
  final Map<String, List<String>> _step2Sub = {
    'Job Circular': [
      'All',
      'Government (সরকারি)',
      'Engineering (ইঞ্জিনিয়ারিং)',
      'Defense (ডিফেন্স)',
      'Bank (ব্যাংক)',
      'Medical (মেডিক্যাল)',
      'Private (বেসরকারি)',
      'Others (অন্যান্য)',
    ],
    'Question Bank (প্রশ্ন ব্যাংক)': [
      'All',
      'BCS Questions (বিসিএস প্রশ্ন)',
      'Govt Job - MCQ (সরকারি চাকরি)',
      'Govt Job - Written (লিখিত পরীক্ষা)',
      'Bank Job (ব্যাংক জব প্রশ্ন)',
      'Primary & NTRCA (শিক্ষক নিয়োগ)',
      'Engineering Job (ইঞ্জিনিয়ারিং জব)',
      'Medical Job (মেডিক্যাল জব)',
      'University Admission (বিশ্ববিদ্যালয় ভর্তি)',
      'Engineering Admission (ইঞ্জিনিয়ারিং ভর্তি)',
      'Medical Admission (মেডিক্যাল ভর্তি)',
      'Nursing & Midwifery (নার্সিং ভর্তি)',
      'Defense & Forces (ডিফেন্স পরীক্ষা)',
      'Departmental Exam (বিভাগীয় পরীক্ষা)',
      'Current Affairs (সাম্প্রতিক প্রশ্নোত্তর)',
    ],
    'Admission (ভর্তি পরীক্ষা)': [
      'All',
      'Public University (পাবলিক বিশ্ববিদ্যালয়)',
      'Engineering University (ইঞ্জিনিয়ারিং বিশ্ববিদ্যালয়)',
      'Medical & Dental (মেডিক্যাল ও ডেন্টাল)',
      'GST Cluster (গুচ্ছ ভর্তি পরীক্ষা)',
      'Agriculture Cluster (কৃষি গুচ্ছ)',
      'National University (জাতীয় বিশ্ববিদ্যালয়)',
      'Seven College (ঢাকা বিশ্ববিদ্যালয় অধিভুক্ত ৭ কলেজ)',
      'Private University (বেসরকারি বিশ্ববিদ্যালয়)',
      'Diploma Admission (ডিপ্লোমা ভর্তি)',
      'Nursing & Midwifery (নার্সিং ও মিডওয়াইফারি)',
      'Armed Forces Medical (আর্মড ফোর্সেস মেডিক্যাল)',
      'IUT & BUP (আইইউটি ও বিইউপি)',
      'Marine & Aviation (মেরিন ও এভিয়েশন)',
      'Science & Technology (বিজ্ঞান ও প্রযুক্তি)',
    ],
    'Notice or Result (নোটিশ ও রেজাল্ট)': [
      'All',
      'Job Result (চাকরির ফলাফল)',
      'Exam Date Notice (পরীক্ষার তারিখ)',
      'Admit Card Download (প্রবেশপত্র ডাউনলোড)',
      'Viva Schedule (ভাইভা সময়সূচী)',
      'BCS Result & Notice (বিসিএস রেজাল্ট)',
      'Govt Bank Result (সরকারি ব্যাংক রেজাল্ট)',
      'Primary & NTRCA Result (শিক্ষক নিয়োগ)',
      'Medical & Nursing Result (মেডিক্যাল রেজাল্ট)',
      'University Admission Result (ভর্তি পরীক্ষার ফল)',
      'Seat Plan Notice (আসন বিন্যাস)',
      'General Notice (সাধারণ নোটিশ)',
      'Circular Amendment (সংশোধন বিজ্ঞপ্তি)',
      'Office Order (অফিস আদেশ)',
    ],
  };
  final Map<String, List<String>> _step3Specific = {
    'Engineering (ইঞ্জিনিয়ারিং)': [
      'All',
      'BSc Engineering',
      'Diploma Engineering',
    ],
    'Government (সরকারি)': [
      'All',
      'BCS (বিসিএস)',
      'Ministry (মন্ত্রণালয়)',
      'Directorate/Department (অধিদপ্তর)',
      'Teacher (শিক্ষক নিয়োগ)',
      'Autonomous Body (স্বায়ত্তশাসিত প্রতিষ্ঠান)',
      'Audit & Accounts (অডিট ও অ্যাকাউন্টস)',
      'Tax & Customs (কর ও কাস্টমস)',
      'Public Service (জনসেবা ও প্রশাসন)',
      'Judiciary (বিচার বিভাগ)',
      'Railway (রেলওয়ে)',
      'Social Service (সমাজসেবা)',
      'Others Govt (অন্যান্য সরকারি)',
    ],
    'Private (বেসরকারি)': [
      'All',
      'Office Admin (অফিস অ্যাডমিন)',
      'HR & Administration (এইচআর ও প্রশাসন)',
      'Accounts & Finance (অ্যাকাউন্টস ও ফিন্যান্স)',
      'Marketing & Sales (মার্কেটিং ও সেলস)',
      'IT & Software (আইটি ও সফটওয়্যার)',
      'Garments & Textile (গার্মেন্টস ও টেক্সটাইল)',
      'E-commerce & F-commerce (ই-কমার্স)',
      'Customer Support (কাস্টমার সাপোর্ট)',
      'Reception & Front Desk (রিসেপশন)',
      'Digital Marketing (ডিজিটাল মার্কেটিং)',
      'Media & Journalism (মিডিয়া ও সাংবাদিকতা)',
      'Supply Chain & Logistics (সাপ্লাই চেইন)',
      'Legal & Law (আইনি ও আইন)',
      'Architecture & Interior (আর্কিটেকচার)',
      'Graphic & UI/UX Design (ডিজাইন)',
      'Real Estate & Developer (রিয়েল এস্টেট)',
      'Insurance (বীমা কোম্পানি)',
      'Security & Guard (সিকিউরিটি ও গার্ড)',
    ],
    'Defense (ডিফেন্স)': ['All', 'Forces'],
    'Bank (ব্যাংক)': ['All', 'Govt Bank', 'Private Bank'],
    'Medical (মেডিক্যাল)': [
      'All',
      'Govt Hospital (সরকারি হাসপাতাল)',
      'Private Hospital (বেসরকারি হাসপাতাল)',
      'Diagnostic Center (ডায়াগনস্টিক সেন্টার)',
      'Pharmaceuticals (ফার্মাসিউটিক্যালস)',
    ],
    'Others (অন্যান্য)': [
      'All',
      'NGO (এনজিও)',
      'Microfinance (ক্ষুদ্রঋণ ও সঞ্চয়)',
      'Hotel & Restaurant (হোটেল ও রেস্টুরেন্ট)',
      'Tourism & Travel (পর্যটন ও ট্রাভেল)',
      'Data Entry & Typing (ডাটা এন্ট্রি)',
      'Driver & Logistics (ড্রাইভার ও লজিস্টিকস)',
      'Security Guard (নিরাপত্তা প্রহরী)',
      'Delivery & Courier (ডেলিভারি ও কুরিয়ার)',
      'Agriculture & Fisheries (কৃষি ও মৎস্য)',
      'Poultry & Livestock (পোল্ট্রি ও গবাদি পশু)',
      'Part-time & Student Job (পার্ট-টাইম)',
      'Cleaning & Maintenance (ক্লিনিং ও মেইনটেন্যান্স)',
      'Event Management (ইভেন্ট ম্যানেজমেন্ট)',
      'Beautician & Lifestyle (বিউটিশিয়ান ও লাইফস্টাইল)',
      'Electrician & Technician (ইলেকট্রিশিয়ান ও টেকনিশিয়ান)',
      'Carpentry & Furniture (কাঠের কাজ ও ফার্নিচার)',
      'General Worker (সাধারণ শ্রমিক)',
      'Housekeeping (হাউসকিপিং)',
      'Freelancing & Remote (ফ্রিল্যান্সিং ও রিমোট)',
    ],
  };
  final Map<String, List<String>> _step4Final = {
    'BSC Engineering': [
      'All',
      'CSE (Computer Science)',
      'EEE (Electrical & Electronic)',
      'Civil Engineering',
      'Mechanical Engineering',
      'Textile Engineering',
      'Architecture',
      'IPE (Industrial & Production)',
      'ETE / ECE (Electronics & Telecom)',
      'ME (Marine Engineering)',
      'Chemical Engineering',
      'Agriculture Engineering',
      'SWE (Software Engineering)',
      'URP (Urban & Regional Planning)',
      'BME (Biomedical Engineering)',
      'WRE (Water Resources Engineering)',
      'PME (Petroleum & Mining)',
      'Leather Engineering',
      'Nuclear Engineering',
      'Aeronautical Engineering',
      'GCE (Glass & Ceramics)',
      'Materials & Metallurgical',
      'Environmental Engineering',
    ],
    'Diploma Engineering': [
      'All',
      'Computer (Dip)',
      'Civil (Dip)',
      'Electrical (Dip)',
      'Mechanical (Dip)',
      'Electronics (Dip)',
      'Textile (Dip)',
      'Architecture (Dip)',
      'Power (Dip)',
      'Automobile (Dip)',
      'Chemical (Dip)',
      'Refrigeration & AC (Dip)',
      'Mining & Mine Survey (Dip)',
      'Surveying (Dip)',
      'Graphic Design (Dip)',
      'Agriculture (Dip)',
      'Marine (Dip)',
      'Shipbuilding (Dip)',
      'Mechatronics (Dip)',
      'Food (Dip)',
      'Environmental (Dip)',
      'Electromedical (Dip)',
    ],
    'Forces': [
      'All',
      'Bangladesh Army (সেনাবাহিনী)',
      'Bangladesh Navy (নৌবাহিনী)',
      'Bangladesh Air Force (বিমান বাহিনী)',
      'Border Guard Bangladesh (BGB)',
      'Bangladesh Coast Guard (কোস্ট গার্ড)',
      'Bangladesh Police (পুলিশ)',
      'Ansar & VDP (আনসার ও ভিডিপি)',
      'Rapid Action Battalion (RAB)',
      'Special Security Force (SSF)',
      'Fire Service & Civil Defence',
      'Prison Guard (কারারক্ষী)',
      'BNCC (Bangladesh National Cadet Corps)',
    ],
    'Ministry (মন্ত্রণালয়)': [
      'All',
      'Primary & Mass Education (প্রাথমিক ও গণশিক্ষা)',
      'Education Ministry (শিক্ষা মন্ত্রণালয়)',
      'Health & Family Welfare (স্বাস্থ্য ও পরিবার কল্যাণ)',
      'Railway Ministry (রেলপথ মন্ত্রণালয়)',
      'Ministry of Defence (প্রতিরক্ষা মন্ত্রণালয়)',
      'Home Affairs (স্বরাষ্ট্র মন্ত্রণালয়)',
      'Agriculture Ministry (কৃষি মন্ত্রণালয়)',
      'Public Administration (জনপ্রশাসন মন্ত্রণালয়)',
      'Local Government (স্থানীয় সরকার মন্ত্রণালয়)',
      'Social Welfare (সমাজকল্যাণ মন্ত্রণালয়)',
      'Information & Broadcasting (তথ্য ও সম্প্রচার)',
      'Post & Telecom (ডাক ও টেলিযোগাযোগ)',
      'Power & Energy (বিদ্যুৎ ও জ্বালানি)',
      'Women & Children Affairs (মহিলা ও শিশু বিষয়ক)',
      'Environment & Forest (পরিবেশ ও বন)',
      'Disaster Management (দুর্যোগ ব্যবস্থাপনা)',
      'Planning Ministry (পরিকল্পনা মন্ত্রণালয়)',
      'Labour & Employment (শ্রম ও কর্মসংস্থান)',
      'Land Ministry (ভূমি মন্ত্রণালয়)',
      'Food Ministry (খাদ্য মন্ত্রণালয়)',
      'Expatriates Welfare (প্রবাসী কল্যাণ)',
      'Youth & Sports (যুব ও ক্রীড়া)',
    ],
    'Directorate অধিদপ্তর': [
      'All',
      'Health Services - DGHS (স্বাস্থ্য অধিদপ্তর)',
      'Primary Education - DPE (প্রাথমিক শিক্ষা)',
      'Secondary & Higher Education - DSHE (মাউশি)',
      'Agricultural Extension - DAE (কৃষি সম্প্রসারণ)',
      'Family Planning - DGFP (পরিবার পরিকল্পনা)',
      'Land Records & Survey (ভূমি রেকর্ড ও জরিপ)',
      'Social Services - DSS (সমাজসেবা অধিদপ্তর)',
      'Youth Development - DYD (যুব উন্নয়ন)',
      'Technical Education - DTE (কারিগরি শিক্ষা)',
      'Disaster Management (দুর্যোগ ব্যবস্থাপনা)',
      'Environment - DoE (পরিবেশ অধিদপ্তর)',
      'Food - DG Food (খাদ্য অধিদপ্তর)',
      'Public Health Eng. - DPHE (জনস্বাস্থ্য প্রকৌশল)',
      'Roads & Highways - RHD (সড়ক ও জনপথ)',
      'Statistics & Informatics (পরিসংখ্যান ও তথ্য)',
      'Labour - DoL (শ্রম অধিদপ্তর)',
      'Livestock Services - DLS (প্রাণিসম্পদ)',
      'Fisheries - DoF (মৎস্য অধিদপ্তর)',
      'Narcotics Control - DNC (মাদকদ্রব্য নিয়ন্ত্রণ)',
      'Passport & Immigration (পাসপোর্ট ও ইমিগ্রেশন)',
      'Fire Service & Civil Defence (ফায়ার সার্ভিস)',
      'Cooperative - DoC (সমবায় অধিদপ্তর)',
    ],
    'Teacher (শিক্ষক নিয়োগ)': [
      'All',
      'Primary School (সরকারি প্রাথমিক বিদ্যালয়)',
      'NTRCA - School (বেসরকারি স্কুল - এনটিআরসিএ)',
      'NTRCA - College (বেসরকারি কলেজ - এনটিআরসিএ)',
      'NTRCA - Madrasah (মাদ্রাসা - এনটিআরসিএ)',
      'Govt Secondary School (সরকারি মাধ্যমিক বিদ্যালয়)',
      'Govt College - BCS (সরকারি কলেজ - বিসিএস)',
      'Technical & Vocational (কারিগরি ও ভোকেশনাল)',
      'Primary Teacher Training - PTI (পিটিআই ইন্সট্রাক্টর)',
      'Non-Govt Primary (বেসরকারি প্রাথমিক বিদ্যালয়)',
      'Public University (পাবলিক বিশ্ববিদ্যালয়)',
      'Private University (বেসরকারি বিশ্ববিদ্যালয়)',
      'Kindergarten & Coaching (কিন্ডারগার্টেন ও কোচিং)',
      'Special Education (বিশেষ শিক্ষা ও অটিজম স্কুল)',
    ],
    'Govt Hospital (সরকারি হাসপাতাল)': [
      'All',
      'Medical Officer (মেডিক্যাল অফিসার)',
      'Senior Staff Nurse (সিনিয়র স্টাফ নার্স)',
      'Specialist Doctor (বিশেষজ্ঞ ডাক্তার)',
      'Health Assistant (স্বাস্থ্য সহকারী)',
      'Medical Technologist (মেডিক্যাল টেকনোলজিস্ট)',
      'Pharmacist (ফার্মাসিস্ট)',
      'Radiology & Imaging (রেডিওলজি ও ইমেজিং)',
      'OT Assistant (ওটি অ্যাসিস্ট্যান্ট)',
      'Ward Boy / Aya (ওয়ার্ড বয়/আয়া)',
      'Driver (অ্যাম্বুলেন্স ড্রাইভার)',
    ],
    'Private Hospital (বেসরকারি হাসপাতাল)': [
      'All',
      'Resident Medical Officer (RMO)',
      'Staff Nurse (স্টাফ নার্স)',
      'Consultant (কনসালট্যান্ট)',
      'Nursing Supervisor (নার্সিং সুপারভাইজার)',
      'Receptionist (রিসেপশনিস্ট)',
      'Customer Care Executive (কাস্টমার কেয়ার)',
      'Hospital Manager (হাসপাতাল ম্যানেজার)',
      'Patient Care Attendant (পেশেন্ট কেয়ার)',
      'Billing Officer (বিলিং অফিসার)',
    ],
    'Diagnostic Center (ডায়াগনস্টিক সেন্টার)': [
      'All',
      'Lab Technician (ল্যাব টেকনিশিয়ান)',
      'Pathologist (প্যাথলজিস্ট)',
      'X-Ray Technologist (এক্স-রে টেকনোলজিস্ট)',
      'Ultrasonography (আল্ট্রাসনোগ্রাফি)',
      'Lab Assistant (ল্যাব অ্যাসিস্ট্যান্ট)',
      'Phlebotomist (রক্ত সংগ্রহকারী)',
      'Marketing Officer (মার্কেটিং অফিসার)',
      'Sample Collector (স্যাম্পল কালেক্টর)',
      'Ecogardiographer (ইকোকার্ডিওগ্রাফার)',
    ],
    'Pharmaceuticals (ফার্মাসিউটিক্যালস)': [
      'All',
      'Scientific Officer (সায়েন্টিফিক অফিসার)',
      'Medical Promotion Officer - MPO (এমপিও)',
      'Quality Assurance - QA (কোয়ালিটি অ্যাসুরেন্স)',
      'Product Executive (প্রোডাক্ট এক্সিকিউটিভ)',
      'Production Chemist (প্রোডাকশন কেমিস্ট)',
      'Microbiologist (মাইক্রোবায়োলজিস্ট)',
      'Pharmacist (ফার্মাসিস্ট)',
      'R&D Scientist (গবেষণা ও উন্নয়ন)',
      'Medical Advisor (মেডিক্যাল অ্যাডভাইজর)',
      'Regulatory Affairs (রেগুলেটরি অ্যাফেয়ার্স)',
    ],
  };

  String? selectedStep1, selectedStep2, selectedStep3, selectedStep4;
  bool isGovtJob = true;

  // --- Controllers ---
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _totalPostCtrl = TextEditingController();
  final TextEditingController _companyCtrl = TextEditingController();
  final TextEditingController _publishDateCtrl = TextEditingController(); // New
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

  // --- Date Picker Logic ---
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
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
              Text("পাবলিশ তারিখ: ${_publishDateCtrl.text}"),
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
      // 1. Process Circular Images
      List<String> base64Images = [];
      for (var file in _selectedImages) {
        List<int> imageBytes = await file.readAsBytes();
        String base64String = base64Encode(imageBytes);
        base64Images.add(base64String);
      }

      // 2. Process Logo Image (Moved inside try block and before fullData)
      String? logoBase64;
      if (_selectedLogo != null) {
        List<int> logoBytes = await _selectedLogo!.readAsBytes();
        logoBase64 = base64Encode(logoBytes);
      }

      // 3. Process Positions
      List<Map<String, dynamic>> positionData = positions
          .map(
            (p) => {
              'name': p['name']!.text,
              'post': p['post']!.text,
              'salary_grade': p['salary']!.text,
            },
          )
          .toList();

      // 4. Organize Data (Logo included here)
      Map<String, dynamic> fullData = {
        'title': _titleCtrl.text,
        'company': _companyCtrl.text,
        'logo': logoBase64 ?? "", // Adding logo to database
        'images': base64Images,
        'positions': positionData,
        'total_posts': _totalPostCtrl.text,
        'publish_date': _publishDateCtrl.text,
        'start_date': _startDateCtrl.text,
        'end_date': _endDateCtrl.text,
        'apply_link': _linkCtrl.text,
        'description': _descCtrl.text,
        'is_govt': isGovtJob,
        'timestamp': FieldValue.serverTimestamp(),
        'step1': selectedStep1,
        'step2': selectedStep2,
        'step3': selectedStep3,
        'step4': selectedStep4,
      };

      // 5. Send to Firebase
      await _firebaseService.saveCircular(
        step1: selectedStep1!,
        step2: selectedStep2!,
        step3: selectedStep3,
        step4: selectedStep4,
        circularData: fullData,
      );

      // 6. Reset Form
      setState(() {
        _selectedImages.clear();
        _selectedLogo = null; // Clear logo after publish
        _titleCtrl.clear();
        _companyCtrl.clear();
        _publishDateCtrl.clear();
        _startDateCtrl.clear();
        _endDateCtrl.clear();
        _linkCtrl.clear();
        _descCtrl.clear();
        _totalPostCtrl.clear();
        positions = [
          {
            'name': TextEditingController(),
            'post': TextEditingController(),
            'salary': TextEditingController(),
          },
        ];
        _isPublishing = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("সফলভাবে পাবলিশ হয়েছে!")));
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
          _buildSingleLogoPicker(),
          _buildSectionCard("ডাটাবেস টেবিল সিলেকশন", [
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
                "ধাপ ৪: সুনির্দিষ্ট বিভাগ",
                selectedStep4,
                _step4Final[selectedStep3]!,
                (val) => setState(() => selectedStep4 = val),
              ),
          ]),
          _buildSectionCard("পদ ও বিস্তারিত তথ্য", [
            _buildInputField(
              "সার্কুলার টাইটেল",
              Icons.title,
              "টাইটেল লিখুন",
              _titleCtrl,
            ),
            SwitchListTile(
              title: Text("সরকারি চাকরি?"),
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
            _buildDateField(
              "সার্কুলার পাবলিশ তারিখ",
              Icons.event_available,
              _publishDateCtrl,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    "আবেদন শুরুর তারিখ",
                    Icons.calendar_today,
                    _startDateCtrl,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildDateField(
                    "আবেদন শেষ তারিখ",
                    Icons.timer_off_outlined,
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

  // --- Helper Widgets ---
  Widget _buildDateField(
    String label,
    IconData icon,
    TextEditingController ctrl,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        readOnly: true,
        onTap: () => _selectDate(context, ctrl),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: Colors.blueAccent),
          suffixIcon: Icon(Icons.calendar_month, size: 20, color: Colors.grey),
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
            ),
            child: _isCompressing
                ? Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, color: Colors.blueAccent),
                      SizedBox(width: 10),
                      Text(
                        "ইমেজ যোগ করুন",
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
          label: Text("নতুন পদ যোগ করুন"),
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

  // logo
  Future<void> _pickAndCompressLogo() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() => _isLogoCompressing = true);

      final dir = await path_provider.getTemporaryDirectory();
      final targetPath =
          "${dir.absolute.path}/logo_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // লোগো সাইজ একদম কমিয়ে (KB-তে) আনার জন্য স্পেশাল কমপ্রেশন
      var result = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        targetPath,
        quality: 5, // কোয়ালিটি অনেক কম যাতে সাইজ ছোট হয়
        minWidth: 150, // লোগোর জন্য ১৫০ পিক্সেল যথেষ্ট
        minHeight: 150,
      );

      setState(() {
        if (result != null) _selectedLogo = File(result.path);
        _isLogoCompressing = false;
      });
    }
  }

  // build
  Widget _buildSingleLogoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "প্রতিষ্ঠানের লোগো (সিঙ্গেল)",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickAndCompressLogo,
          child: Container(
            height: 120, // ইমেজ পিকারের মতো বড় করা হয়েছে
            width: double.infinity, // পুরো স্ক্রিন জুড়ে থাকবে
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.blueAccent.withOpacity(0.2),
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            child: _isLogoCompressing
                ? const Center(child: CircularProgressIndicator())
                : _selectedLogo != null
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      // লোগো প্রিভিউ
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedLogo!,
                            fit: BoxFit.contain, // লোগো যেন কেটে না যায়
                          ),
                        ),
                      ),
                      // রিমুভ বাটন
                      Positioned(
                        right: 10,
                        top: 10,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedLogo = null),
                          child: const CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.delete_forever,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_business_rounded,
                        color: Colors.blueAccent.withOpacity(0.6),
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "লোগো সিলেক্ট করুন",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Text(
                        "(বর্গাকার লোগো হলে ভালো দেখাবে)",
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
          ),
        ),
      ],
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

  Widget _buildLoginScreen() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(35.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  size: 70,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 30),

                _buildInputField("অ্যাডমিন ইমেইল", Icons.email, "", _emailCtrl),
                const SizedBox(height: 15),

                _buildInputField("পাসওয়ার্ড", Icons.lock, "", _passCtrl),
                const SizedBox(height: 30),

                _buildActionButton("লগইন করুন", Colors.indigo, _handleLogin),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManageCircularTab() {
    return AdminSyncPage();
  }

  Widget _buildQuestionBankTab() =>
      Center(child: Text("Question Bank Coming Soon"));
}
