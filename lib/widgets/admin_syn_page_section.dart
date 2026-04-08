import 'dart:convert';

import 'package:chakri_info/services/admin_sync_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminSyncPage extends StatefulWidget {
  const AdminSyncPage({super.key});

  @override
  State<AdminSyncPage> createState() => _AdminSyncPageState();
}

class _AdminSyncPageState extends State<AdminSyncPage> {
  final JobRepository _jobRepo = JobRepository();
  String selectedStep1 = "All";
  String? selectedStep2, selectedStep3, selectedStep4;
  final ImagePicker _picker = ImagePicker();

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
      'BSC Engineering',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: Column(
        children: [
          _buildFilterPanel(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _jobRepo.getAdvancedFilteredJobs(
                step1: selectedStep1,
                step2: selectedStep2,
                step3: selectedStep3,
                step4: selectedStep4,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text("Error: ${snapshot.error}"));
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty)
                  return const Center(child: Text("কোনো ডাটা পাওয়া যায়নি।"));
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    return _buildJobCard(doc, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSyncDropdown(
                  "ধাপ ১",
                  selectedStep1,
                  _step1Main,
                  (val) => setState(() {
                    selectedStep1 = val!;
                    selectedStep2 = selectedStep3 = selectedStep4 = null;
                  }),
                ),
              ),
              if (selectedStep1 != "All" &&
                  _step2Sub.containsKey(selectedStep1)) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSyncDropdown(
                    "ধাপ ২",
                    selectedStep2,
                    _step2Sub[selectedStep1]!,
                    (val) => setState(() {
                      selectedStep2 = val == "All" ? null : val;
                      selectedStep3 = selectedStep4 = null;
                    }),
                  ),
                ),
              ],
            ],
          ),
          if (selectedStep2 != null &&
              _step3Specific.containsKey(selectedStep2)) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildSyncDropdown(
                    "ধাপ ৩",
                    selectedStep3,
                    _step3Specific[selectedStep2]!,
                    (val) => setState(() {
                      selectedStep3 = val == "All" ? null : val;
                      selectedStep4 = null;
                    }),
                  ),
                ),
                if (selectedStep3 != null &&
                    _step4Final.containsKey(selectedStep3)) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSyncDropdown(
                      "ধাপ ৪",
                      selectedStep4,
                      _step4Final[selectedStep3]!,
                      (val) => setState(
                        () => selectedStep4 = val == "All" ? null : val,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items
          .map(
            (s) => DropdownMenuItem(
              value: s,
              child: Text(s, style: const TextStyle(fontSize: 12)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildJobCard(DocumentSnapshot doc, Map<String, dynamic> data) {
    bool isGovt = data['is_govt'] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            //
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isGovt
                      ? Colors.blue.shade700
                      : Colors.blueGrey.shade400,
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Text(
                  isGovt ? "GOVT" : "NON-GOVT",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),

                leading: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.withOpacity(0.1)),
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: _getLogoWidget(data['logo']),
                    ),
                  ),
                ),

                title: Text(
                  data['title'] ?? 'No Title',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data['company'] ?? '',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blueAccent.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Deadline: ${data['end_date'] ?? 'N/A'}",
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                trailing: PopupMenuButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.more_vert,
                    size: 18,
                    color: Colors.grey,
                  ),
                  onSelected: (val) {
                    if (val == 'edit') _showEditSheet(doc, data);
                    if (val == 'delete') _jobRepo.deleteJob(doc.reference);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      height: 35,
                      child: Text("Edit", style: TextStyle(fontSize: 13)),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      height: 35,
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingImage(dynamic logoData) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1.2),
      ),
      child: ClipOval(child: _getLogoWidget(logoData)),
    );
  }

  Widget _getLogoWidget(dynamic logoData) {
    if (logoData != null) {
      try {
        String base64String = "";

        // Handling both List and String types for data safety
        if (logoData is List && logoData.isNotEmpty) {
          base64String = logoData[0];
        } else if (logoData is String && logoData.isNotEmpty) {
          base64String = logoData;
        }

        if (base64String.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(4.0), // Padding inside the circle
            child: Image.memory(
              base64Decode(base64String),
              fit: BoxFit.contain, // Ensuring logo is not cropped
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.business_rounded,
                color: Colors.grey,
                size: 24,
              ),
            ),
          );
        }
      } catch (e) {
        return const Icon(
          Icons.broken_image_outlined,
          color: Colors.grey,
          size: 20,
        );
      }
    }
    return const Icon(
      Icons.work_outline_rounded,
      color: Colors.indigo,
      size: 24,
    );
  }

  void _showEditSheet(DocumentSnapshot doc, Map<String, dynamic> data) {
    final titleCtrl = TextEditingController(text: data['title']);
    final companyCtrl = TextEditingController(text: data['company']);
    final totalPostCtrl = TextEditingController(text: data['total_posts']);
    final publishDateCtrl = TextEditingController(text: data['publish_date']);
    final endDateCtrl = TextEditingController(text: data['end_date']);
    final linkCtrl = TextEditingController(text: data['apply_link']);
    final descCtrl = TextEditingController(text: data['description']);

    List<dynamic> currentImages = List.from(data['images'] ?? []);
    bool isGovt = data['is_govt'] ?? true;

    List<Map<String, TextEditingController>> posControllers = [];
    if (data['positions'] != null) {
      for (var p in data['positions']) {
        posControllers.add({
          'name': TextEditingController(text: p['name']),
          'post': TextEditingController(text: p['post']),
          'salary': TextEditingController(text: p['salary_grade']),
        });
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ), // কিবোর্ডের জন্য প্যাডিং
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      "সম্পূর্ণ এডিট ও ইমেজ রিপ্লেস",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "ছবিগুলো:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final List<XFile> pickedFiles = await _picker
                              .pickMultiImage();
                          if (pickedFiles.isNotEmpty) {
                            for (var file in pickedFiles) {
                              List<int> imageBytes = await file.readAsBytes();
                              setSheetState(() {
                                currentImages.add(base64Encode(imageBytes));
                              });
                            }
                          }
                        },
                        icon: const Icon(Icons.add_a_photo, size: 18),
                        label: const Text(
                          "নতুন ছবি",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: currentImages.isEmpty
                        ? const Center(
                            child: Text(
                              "কোনো ছবি নেই",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: currentImages.length,
                            itemBuilder: (context, i) => Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    image: DecorationImage(
                                      image: MemoryImage(
                                        base64Decode(currentImages[i]),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: () => setSheetState(
                                      () => currentImages.removeAt(i),
                                    ),
                                    child: const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.red,
                                      child: Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  _editField(titleCtrl, "টাইটেল"),
                  _editField(companyCtrl, "প্রতিষ্ঠান"),
                  Row(
                    children: [
                      Expanded(child: _editField(totalPostCtrl, "মোট পদ")),
                      const SizedBox(width: 10),
                      Expanded(child: _editField(endDateCtrl, "ডেডলাইন")),
                    ],
                  ),
                  const Text(
                    "পদ ও বেতন:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  ...posControllers
                      .map(
                        (pos) => Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Expanded(child: _editField(pos['name']!, "নাম")),
                              const SizedBox(width: 5),
                              Expanded(child: _editField(pos['post']!, "পদ")),
                              const SizedBox(width: 5),
                              Expanded(
                                child: _editField(pos['salary']!, "বেতন"),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  _editField(linkCtrl, "অ্যাপ্লাই লিঙ্ক"),
                  _editField(descCtrl, "ডেসক্রিপশন", maxLines: 3),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await doc.reference.update({
                          'title': titleCtrl.text,
                          'company': companyCtrl.text,
                          'total_posts': totalPostCtrl.text,
                          'publish_date': publishDateCtrl.text,
                          'end_date': endDateCtrl.text,
                          'apply_link': linkCtrl.text,
                          'description': descCtrl.text,
                          'is_govt': isGovt,
                          'images': currentImages,
                          'positions': posControllers
                              .map(
                                (p) => {
                                  'name': p['name']!.text,
                                  'post': p['post']!.text,
                                  'salary_grade': p['salary']!.text,
                                },
                              )
                              .toList(),
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("সবকিছু সফলভাবে আপডেট হয়েছে!"),
                          ),
                        );
                      },
                      child: const Text(
                        "Update Everything",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _editField(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
        ),
      ),
    );
  }
}
