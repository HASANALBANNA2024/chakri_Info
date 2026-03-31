import 'package:chakri_info/models/bookmark_model.dart';
import 'package:flutter/material.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  String _selectedFilter = "সবগুলো";
  final List<String> _filters = ["সবগুলো", "সরকারি", "ব্যাংক", "আইটি", "এনজিও"];

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    //  bookmark filter and list
    List<JobBookmark> filteredJobs = _selectedFilter == "সবগুলো"
        ? allSavedJobs
        : allSavedJobs.where((job) => job.category == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      appBar: _buildAppBar(isDarkMode),
      body: Column(
        children: [
          _buildFilterBar(isDarkMode),
          Expanded(
            child: filteredJobs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) =>
                        _buildJobCard(filteredJobs[index], isDarkMode),
                  ),
          ),
        ],
      ),
    );
  }

  // --- UI Widgets ---

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      title: const Text(
        "সেভ করা চাকরি",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      centerTitle: true,
      backgroundColor: isDarkMode
          ? const Color(0xFF1F1F1F)
          : Colors.indigo[900],
      elevation: 0,
      // back to screen
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildFilterBar(bool isDarkMode) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedFilter == _filters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_filters[index]),
              selected: isSelected,
              onSelected: (val) =>
                  setState(() => _selectedFilter = _filters[index]),
              selectedColor: Colors.indigo,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.white70 : Colors.black87),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobCard(JobBookmark job, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: job.isClosingSoon
              ? Colors.red.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // logo section
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.business_center, color: Colors.indigo),
          ),
          const SizedBox(width: 12),
          // তথ্য সেকশন
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  job.company,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  "শেষ সময়: ${job.deadline}",
                  style: TextStyle(
                    color: job.isClosingSoon ? Colors.red : Colors.grey[700],
                    fontSize: 11,
                    fontWeight: job.isClosingSoon
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          // Remove button
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("কোনো সেভ করা চাকরি নেই।"));
  }
}
