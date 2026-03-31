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
  String _subCat = "All";
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Database Sync Manager"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // filter panel
          _buildFilterUI(),

          // Data list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _jobRepo.getFilteredJobs(
                mainCat: _mainCat,
                subCat: _subCat,
                dateRange: _selectedDateRange,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text("Error: ${snapshot.error}"));
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());

                var docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty)
                  return const Center(
                    child: Text("No Data Found in Firestore!"),
                  );

                return ListView.builder(
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

  // Filter Widgets
  Widget _buildFilterUI() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _mainCat,
                  isExpanded: true,
                  items: ["All", "Government", "Bank", "NGO", "Private"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setState(() {
                    _mainCat = val!;
                    _subCat = "All";
                  }),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.date_range),
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null)
                    setState(() => _selectedDateRange = picked);
                },
              ),
              if (_selectedDateRange != null)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: () => setState(() => _selectedDateRange = null),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Job card
  Widget _buildJobCard(DocumentSnapshot doc, Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: (data['images'] != null && data['images'].isNotEmpty)
            ? Image.network(
                data['images'][0],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.work_outline),
        title: Text(
          data['title'] ?? 'No Title',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Text(
          "Deadline: ${data['deadline']}\n${data['mainCategory']} > ${data['subCategory']}",
        ),
        isThreeLine: true,
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

  // Edit Logic
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
                decoration: const InputDecoration(labelText: "Job Title"),
              ),
              const SizedBox(height: 10),
              pickedFile != null
                  ? Image.file(pickedFile!, height: 100)
                  : const Text("No new image selected"),
              TextButton.icon(
                icon: const Icon(Icons.image),
                label: const Text("Change Image"),
                onPressed: () async {
                  final file = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (file != null)
                    setInternalState(() => pickedFile = File(file.path));
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  await _jobRepo.updateJob(doc.reference, {
                    'title': titleCtrl.text,
                  }, pickedFile);
                  Navigator.pop(context);
                },
                child: const Text("Update Database"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
