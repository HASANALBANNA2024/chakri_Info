import 'dart:convert';

import 'package:chakri_info/services/admin_sync_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminSyncPage extends StatefulWidget {
  const AdminSyncPage({super.key});

  @override
  State<AdminSyncPage> createState() => _AdminSyncPageState();
}

class _AdminSyncPageState extends State<AdminSyncPage> {
  final JobRepository _jobRepo = JobRepository();

  // --- সিলেকশন স্টেট (আপনার AdminPanelScreen অনুযায়ী) ---
  String selectedStep1 = "All";
  String? selectedStep2, selectedStep3, selectedStep4;

  final List<String> _step1Main = [
    'All',
    'Job Circular',
    'Question Bank',
    'Admission',
    'Notice or Result',
  ];

  final Map<String, List<String>> _step2Sub = {
    'Job Circular': [
      'All',
      'Government',
      'Engineering',
      'Defense',
      'Bank',
      'Medical',
      'Others',
    ],
    'Question Bank': ['All', 'Job Questions', 'Admission Questions'],
    'Admission': ['All', 'University', 'Engineering', 'Medical'],
    'Notice or Result': ['All', 'Job Result', 'Exam Notice'],
  };

  final Map<String, List<String>> _step3Specific = {
    'Engineering': ['All', 'BSc Engineering', 'Diploma Engineering'],
    'Government': ['All', 'Ministry', 'Railway', 'Teacher'],
    'Defense': ['All', 'Forces', 'Security'],
    'Bank': ['All', 'Govt Bank', 'Private Bank'],
  };

  final Map<String, List<String>> _step4Final = {
    'BSc Engineering': [
      'All',
      'Computer',
      'Civil',
      'Electrical',
      'Mechanical',
      'Textile',
    ],
    'Diploma Engineering': [
      'All',
      'Computer (Dip)',
      'Civil (Dip)',
      'Electrical (Dip)',
    ],
    'Forces': ['All', 'Army', 'Navy', 'Air Force'],
    'Security': ['All', 'Police', 'Ansar', 'BGB'],
    'Ministry': [
      'All',
      'Education Ministry',
      'Health Ministry',
      'Railway Ministry',
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
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "ইনডেক্স এরর! ফায়ারবেস কনসোলে এই কুয়েরির জন্য ইনডেক্স তৈরি করুন।\nError: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Text("এই ক্যাটাগরিতে কোনো ডাটা পাওয়া যায়নি।"),
                  );
                }

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

  // --- ৪-ধাপের ফিল্টার প্যানেল ---
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
                child: _buildSyncDropdown("ধাপ ১", selectedStep1, _step1Main, (
                  val,
                ) {
                  setState(() {
                    selectedStep1 = val!;
                    selectedStep2 = selectedStep3 = selectedStep4 = null;
                  });
                }),
              ),
              if (selectedStep1 != "All" &&
                  _step2Sub.containsKey(selectedStep1)) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSyncDropdown(
                    "ধাপ ২",
                    selectedStep2,
                    _step2Sub[selectedStep1]!,
                    (val) {
                      setState(() {
                        selectedStep2 = val == "All" ? null : val;
                        selectedStep3 = selectedStep4 = null;
                      });
                    },
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
                    (val) {
                      setState(() {
                        selectedStep3 = val == "All" ? null : val;
                        selectedStep4 = null;
                      });
                    },
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
                      (val) {
                        setState(
                          () => selectedStep4 = val == "All" ? null : val,
                        );
                      },
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

  // --- জব কার্ড UI ---
  Widget _buildJobCard(DocumentSnapshot doc, Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildLeadingImage(data['images']),
        ),
        title: Text(
          data['title'] ?? 'No Title',
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Text(
          "Deadline: ${data['end_date'] ?? 'N/A'}\n${data['company'] ?? ''}",
          style: const TextStyle(fontSize: 11),
        ),
        trailing: PopupMenuButton(
          onSelected: (val) {
            if (val == 'edit') _showEditSheet(doc, data);
            if (val == 'delete') _jobRepo.deleteJob(doc.reference);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text("Edit")),
            const PopupMenuItem(
              value: 'delete',
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingImage(dynamic images) {
    if (images != null && images is List && images.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(images[0]),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        );
      } catch (e) {
        return Image.network(
          images[0],
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.image),
        );
      }
    }
    return const Icon(Icons.work_outline);
  }

  // --- এডিট শীট ---
  void _showEditSheet(DocumentSnapshot doc, Map<String, dynamic> data) {
    final titleCtrl = TextEditingController(text: data['title']);
    final companyCtrl = TextEditingController(text: data['company']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "সার্কুলার এডিট করুন",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: "টাইটেল",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: companyCtrl,
              decoration: const InputDecoration(
                labelText: "প্রতিষ্ঠান",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                onPressed: () async {
                  await _jobRepo.updateJob(doc.reference, {
                    'title': titleCtrl.text,
                    'company': companyCtrl.text,
                  }, null);
                  Navigator.pop(context);
                },
                child: const Text(
                  "আপডেট নিশ্চিত করুন",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
