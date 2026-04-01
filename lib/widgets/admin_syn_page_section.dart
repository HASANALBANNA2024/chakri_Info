import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:chakri_info/services/admin_sync_page.dart';

class AdminSyncPage extends StatefulWidget {
  const AdminSyncPage({super.key});

  @override
  State<AdminSyncPage> createState() => _AdminSyncPageState();
}

class _AdminSyncPageState extends State<AdminSyncPage> {
  final JobRepository _jobRepo = JobRepository();

  // --- Selection State ---
  String selectedStep1 = "All";
  String? selectedStep2, selectedStep3, selectedStep4;
  // image
  final ImagePicker _picker = ImagePicker();



  final List<String> _step1Main = [
    'All', 'Job Circular', 'Question Bank', 'Admission', 'Notice or Result',
  ];

  final Map<String, List<String>> _step2Sub = {
    'Job Circular': ['All', 'Government', 'Engineering', 'Defense', 'Bank', 'Medical', 'Others'],
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
    'BSc Engineering': ['All', 'Computer', 'Civil', 'Electrical', 'Mechanical', 'Textile'],
    'Diploma Engineering': ['All', 'Computer (Dip)', 'Civil (Dip)', 'Electrical (Dip)'],
    'Forces': ['All', 'Army', 'Navy', 'Air Force'],
    'Security': ['All', 'Police', 'Ansar', 'BGB'],
    'Ministry': ['All', 'Education Ministry', 'Health Ministry', 'Railway Ministry'],
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
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return const Center(child: Text("কোনো ডাটা পাওয়া যায়নি।"));

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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSyncDropdown("ধাপ ১", selectedStep1, _step1Main, (val) {
                  setState(() {
                    selectedStep1 = val!;
                    selectedStep2 = selectedStep3 = selectedStep4 = null;
                  });
                }),
              ),
              if (selectedStep1 != "All" && _step2Sub.containsKey(selectedStep1)) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSyncDropdown("ধাপ ২", selectedStep2, _step2Sub[selectedStep1]!, (val) {
                    setState(() {
                      selectedStep2 = val == "All" ? null : val;
                      selectedStep3 = selectedStep4 = null;
                    });
                  }),
                ),
              ],
            ],
          ),
          if (selectedStep2 != null && _step3Specific.containsKey(selectedStep2)) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildSyncDropdown("ধাপ ৩", selectedStep3, _step3Specific[selectedStep2]!, (val) {
                    setState(() {
                      selectedStep3 = val == "All" ? null : val;
                      selectedStep4 = null;
                    });
                  }),
                ),
                if (selectedStep3 != null && _step4Final.containsKey(selectedStep3)) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSyncDropdown("ধাপ ৪", selectedStep4, _step4Final[selectedStep3]!, (val) {
                      setState(() => selectedStep4 = val == "All" ? null : val);
                    }),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
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
        title: Text(data['title'] ?? 'No Title', maxLines: 1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text("Deadline: ${data['end_date'] ?? 'N/A'}\n${data['company'] ?? ''}", style: const TextStyle(fontSize: 11)),
        trailing: PopupMenuButton(
          onSelected: (val) {
            if (val == 'edit') _showEditSheet(doc, data);
            if (val == 'delete') _jobRepo.deleteJob(doc.reference);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text("Edit")),
            const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingImage(dynamic images) {
    if (images != null && images is List && images.isNotEmpty) {
      try {
        return Image.memory(base64Decode(images[0]), width: 50, height: 50, fit: BoxFit.cover);
      } catch (e) {
        return const Icon(Icons.image);
      }
    }
    return const Icon(Icons.work_outline);
  }

// --- সব ডাটা এবং নতুন ইমেজ যোগ করার সুবিধা সহ ফুল এডিট শীট ---
  void _showEditSheet(DocumentSnapshot doc, Map<String, dynamic> data) {
    final titleCtrl = TextEditingController(text: data['title']);
    final companyCtrl = TextEditingController(text: data['company']);
    final totalPostCtrl = TextEditingController(text: data['total_posts']);
    final publishDateCtrl = TextEditingController(text: data['publish_date']);
    final endDateCtrl = TextEditingController(text: data['end_date']);
    final linkCtrl = TextEditingController(text: data['apply_link']);
    final descCtrl = TextEditingController(text: data['description']);

    // আগের এবং নতুন ইমেজ সব মিলিয়ে একটি লিস্ট
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Center(child: Text("সম্পূর্ণ এডিট ও ইমেজ রিপ্লেস", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo))),
                const SizedBox(height: 20),

                // --- ইমেজ সেকশন (পুরাতন + নতুন যোগ করা) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("ছবিগুলো:", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton.icon(
                        onPressed: () async {
                          // নতুন ইমেজ পিক করার লজিক
                          final List<XFile> pickedFiles = await _picker.pickMultiImage();
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
                        label: const Text("নতুন ছবি যোগ করুন", style: TextStyle(fontSize: 12))
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: currentImages.isEmpty
                      ? const Center(child: Text("কোনো ছবি নেই", style: TextStyle(fontSize: 12, color: Colors.grey)))
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
                            border: Border.all(color: Colors.grey.shade300),
                            image: DecorationImage(
                                image: MemoryImage(base64Decode(currentImages[i])),
                                fit: BoxFit.cover
                            ),
                          ),
                        ),
                        Positioned(top: 0, right: 5, child: GestureDetector(
                          onTap: () => setSheetState(() => currentImages.removeAt(i)),
                          child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 14, color: Colors.white)),
                        )),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                // --- অন্যান্য ইনপুট ফিল্ডস ---
                _editField(titleCtrl, "টাইটেল"),
                _editField(companyCtrl, "প্রতিষ্ঠান"),

                Row(children: [
                  Expanded(child: _editField(totalPostCtrl, "মোট পদ")),
                  const SizedBox(width: 10),
                  Expanded(child: _editField(endDateCtrl, "ডেডলাইন")),
                ]),

                // পজিশন লিস্ট এডিট
                const Text("পদ ও বেতন:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ...posControllers.map((pos) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(children: [
                    Expanded(child: _editField(pos['name']!, "নাম")),
                    const SizedBox(width: 5),
                    Expanded(child: _editField(pos['post']!, "পদ")),
                    const SizedBox(width: 5),
                    Expanded(child: _editField(pos['salary']!, "বেতন")),
                  ]),
                )).toList(),

                _editField(linkCtrl, "অ্যাপ্লাই লিঙ্ক"),
                _editField(descCtrl, "ডেসক্রিপশন", maxLines: 3),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                    onPressed: () async {
                      // ডাটাবেসে আপডেট
                      await doc.reference.update({
                        'title': titleCtrl.text,
                        'company': companyCtrl.text,
                        'total_posts': totalPostCtrl.text,
                        'publish_date': publishDateCtrl.text,
                        'end_date': endDateCtrl.text,
                        'apply_link': linkCtrl.text,
                        'description': descCtrl.text,
                        'is_govt': isGovt,
                        'images': currentImages, // এখানে পুরাতন + নতুন সব ছবি আছে
                        'positions': posControllers.map((p) => {
                          'name': p['name']!.text,
                          'post': p['post']!.text,
                          'salary_grade': p['salary']!.text,
                        }).toList(),
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("সবকিছু সফলভাবে আপডেট হয়েছে!")));
                    },
                    child: const Text("Update Everything", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // টেক্সট ফিল্ড হেল্পার উইজেট
  Widget _editField(TextEditingController ctrl, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
      ),
    );
  }

}