import 'package:flutter/material.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:chakri_info/user_side_data_sync/job_details_screen.dart';

class GlobalSearchDelegate extends SearchDelegate {
  final List<JobSyncModel> allData;
  final bool isDarkMode;

  GlobalSearchDelegate({required this.allData, required this.isDarkMode});
  //Search screen premium theme
  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.indigo,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white60, fontSize: 16),
        border: InputBorder.none,
      ),
      // typing text color
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  // main search result
  Widget _buildSearchResults(BuildContext context) {
    final List<JobSyncModel> suggestions = allData.where((item) {
      final String searchKey = query.toLowerCase().trim();
      return item.title.toLowerCase().contains(searchKey) ||
          item.company.toLowerCase().contains(searchKey) ||
          item.step1.toLowerCase().contains(searchKey) ||
          item.step2.toLowerCase().contains(searchKey) ||
          (item.step3?.toLowerCase().contains(searchKey) ?? false);
    }).toList();

    final bgColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC);

    if (suggestions.isEmpty) {
      return Container(
        color: bgColor,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              query.isEmpty ? Icons.search_rounded : Icons.sentiment_dissatisfied_rounded,
              size: 80,
              color: isDarkMode ? Colors.white10 : Colors.indigo.withOpacity(0.1),
            ),
            const SizedBox(height: 16),
            Text(
              query.isEmpty ? "নতুন কিছু খুঁজুন..." : "দুঃখিত, কিছুই পাওয়া যায়নি!",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: bgColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final item = suggestions[index];
          return _buildResultCard(context, item);
        },
      ),
    );
  }

  // result card design
  Widget _buildResultCard(BuildContext context, JobSyncModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : Colors.indigo.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JobDetailsScreen(job: item)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // category icon logo
                Container(
                  height: 50, width: 50,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.ads_click_rounded, color: Colors.indigo, size: 24),
                ),
                const SizedBox(width: 12),
                // text section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${item.company} • ${item.step1}",
                        style: TextStyle(
                          fontSize: 11,
                          color: isDarkMode ? Colors.white54 : Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- dashboard search ---
Widget buildGlobalSearchSection(BuildContext context, bool isDarkMode, List<JobSyncModel> allData) {
  return Padding(
    padding: const EdgeInsets.only(left: 14, right: 14, top: 6, bottom: 1),
    child: GestureDetector(
      onTap: () => showSearch(
        context: context,
        delegate: GlobalSearchDelegate(allData: allData, isDarkMode: isDarkMode),
      ),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF262626) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isDarkMode ? Colors.white10 : Colors.indigo.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black26 : Colors.indigo.withOpacity(0.08),
              blurRadius: 15, offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 15),
            const Icon(Icons.search_rounded, size: 20, color: Colors.indigo),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "সার্চ করুন (যেমন: ব্যাংক, এডমিশন...)",
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? Colors.white38 : Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Tune Icon
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tune_rounded, size: 16, color: Colors.indigo),
            ),
          ],
        ),
      ),
    ),
  );
}