import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubCategoryExamScreen extends StatefulWidget {
  final String categoryName; // এখানে ভ্যারিয়েবলটি ডিক্লেয়ার থাকতে হবে
  final bool isDarkMode;

  const SubCategoryExamScreen({
    super.key,
    required this.categoryName,
    required this.isDarkMode,
  });

  @override
  State<SubCategoryExamScreen> createState() => _SubCategoryExamScreenState();
}

class _SubCategoryExamScreenState extends State<SubCategoryExamScreen> {
  // আপনার সেই ফাংশনটি এখন এখানে থাকবে
  Widget _buildExamStream(String selectedType) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('All_Question')
          .doc(widget.categoryName) // এখন আর লাল দাগ থাকবে না
          .collection(selectedType)
          .doc('Exams')
          .collection('All_Exams')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text("$selectedType সেকশনে কোনো ডাটা পাওয়া যায়নি"),
          );
        }

        final List<Map<String, dynamic>> freshData = snapshot.data!.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        // সরাসরি এখানেই লিস্টভিউ রিটার্ন করুন যাতে আলাদা ফাংশনের ঝামেলা না থাকে
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: freshData.length,
          itemBuilder: (context, index) {
            final data = freshData[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(
                  data['title']?.toString().toUpperCase() ?? 'NO TITLE',
                ),
                subtitle: Text("Questions: ${data['total_questions'] ?? 0}"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // এখানে ক্লিক করলে ডিটেইলসে যাবে
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = ['MCQ', 'Written', 'Viva'];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.categoryName),
          bottom: TabBar(tabs: tabs.map((t) => Tab(text: t)).toList()),
        ),
        body: TabBarView(
          children: tabs.map((type) => _buildExamStream(type)).toList(),
        ),
      ),
    );
  }
}
