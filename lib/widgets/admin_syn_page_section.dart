import 'dart:io';

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
  String _mainCat = "All";
  String _subCat = "All"; // যদি সাব-ক্যাটেগরি ড্রপডাউন থাকে তবে কাজে লাগবে
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Database Sync Manager"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ফিল্টার সেকশন
          _buildFilterUI(),

          // ডাটা লিস্ট সেকশন
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _jobRepo.getFilteredJobs(
                mainCat: _mainCat,
                subCat: _subCat,
                dateRange: _selectedDateRange,
              ),
              builder: (context, snapshot) {
                // ইনডেক্স না থাকলে এখানে এরর মেসেজ এবং লিঙ্ক শো করবে
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Error: ${snapshot.error}\n\nপরামর্শ: ফায়ারবেস কনসোলে ইনডেক্স তৈরি করুন।",
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
                    child: Text("No Data Found! Check internet or index."),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
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

  Widget _buildFilterUI() {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.filter_list, color: Colors.indigo),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButton<String>(
                value: _mainCat,
                isExpanded: true,
                underline: const SizedBox(),
                items: ["All", "Government", "Bank", "NGO", "Private"]
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() {
                  _mainCat = val!;
                }),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.date_range,
                color: _selectedDateRange != null ? Colors.indigo : Colors.grey,
              ),
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _selectedDateRange = picked);
              },
            ),
            if (_selectedDateRange != null)
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.red),
                onPressed: () => setState(() => _selectedDateRange = null),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(DocumentSnapshot doc, Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: (data['images'] != null && (data['images'] as List).isNotEmpty)
              ? Image.network(
                  data['images'][0],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
                ),
        ),
        title: Text(
          data['title'] ?? 'No Title',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          "${data['mainCategory']} | ${data['deadline'] ?? 'No Date'}",
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

  void _showEditSheet(DocumentSnapshot doc, Map<String, dynamic> data) {
    final titleCtrl = TextEditingController(text: data['title']);
    File? pickedFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setInternalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Update Job Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              if (pickedFile != null) Image.file(pickedFile!, height: 80),
              TextButton.icon(
                icon: const Icon(Icons.add_a_photo),
                label: const Text("Change Image"),
                onPressed: () async {
                  final file = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (file != null)
                    setInternalState(() => pickedFile = File(file.path));
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await _jobRepo.updateJob(doc.reference, {
                      'title': titleCtrl.text,
                    }, pickedFile);
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text("Update Database"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
