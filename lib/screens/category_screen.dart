import 'package:chakri_info/user_side_data_sync/joblist_screen.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_provider.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _isExpanded = false;
  final List<Map<String, dynamic>> _allCategories = [
    // --- 1. Job Circular Sections ---
    {
      'e': 'Government',
      'b': 'সরকারি',
      'name': 'Government (সরকারি)',
      'icon': Icons.account_balance,
      'color': Colors.orange[900],
    },
    {
      'e': 'Engineering',
      'b': 'ইঞ্জিনিয়ারিং',
      'name': 'Engineering (ইঞ্জিনিয়ারিং)',
      'icon': Icons.engineering,
      'color': Colors.blueGrey,
    },
    {
      'e': 'Bank',
      'b': 'ব্যাংক',
      'name': 'Bank (ব্যাংক)',
      'icon': Icons.business,
      'color': Colors.blue[800],
    },
    {
      'e': 'Defense',
      'b': 'ডিফেন্স',
      'name': 'Defense (ডিফেন্স)',
      'icon': Icons.security,
      'color': Colors.redAccent,
    },
    {
      'e': 'Medical',
      'b': 'মেডিক্যাল',
      'name': 'Medical (মেডিক্যাল)',
      'icon': Icons.medical_services,
      'color': Colors.teal,
    },
    {
      'e': 'Private',
      'b': 'বেসরকারি',
      'name': 'Private (বেসরকারি)',
      'icon': Icons.apartment,
      'color': Colors.purple,
    },
    // --- 2. Special & Popular Sub-Categories ---
    {
      'e': 'BCS',
      'b': 'বিসিএস',
      'name': 'BCS (বিসিএস)',
      'icon': Icons.stars,
      'color': Colors.amber[800],
    },
    {
      'e': 'Teacher',
      'b': 'শিক্ষক নিয়োগ',
      'name': 'Teacher (শিক্ষক নিয়োগ)',
      'icon': Icons.school,
      'color': Colors.green[700],
    },
    {
      'e': 'Pharma',
      'b': 'ফার্মাসিউটিক্যালস',
      'name': 'Pharmaceuticals (ফার্মাসিউটিক্যালস)',
      'icon': Icons.medication,
      'color': Colors.deepOrange,
    },
    {
      'e': 'NGO',
      'b': 'এনজিও',
      'name': 'NGO (এনজিও)',
      'icon': Icons.volunteer_activism,
      'color': Colors.indigo,
    },
    {
      'e': 'IT & Soft',
      'b': 'আইটি ও সফটওয়্যার',
      'name': 'IT & Software (আইটি ও সফটওয়্যার)',
      'icon': Icons.computer,
      'color': Colors.blue,
    },

    // --- 3. Admission & Questions ---
    {
      'e': 'Admission',
      'b': 'ভর্তি পরীক্ষা',
      'name': 'Admission (ভর্তি পরীক্ষা)',
      'icon': Icons.history_edu,
      'color': Colors.indigo[900],
    },
    {
      'e': 'Question',
      'b': 'প্রশ্ন ব্যাংক',
      'name': 'Question Bank (প্রশ্ন ব্যাংক)',
      'icon': Icons.collections_bookmark,
      'color': Colors.brown,
    },
    {
      'e': 'Result',
      'b': 'নোটিশ ও রেজাল্ট',
      'name': 'Notice or Result (নোটিশ ও রেজাল্ট)',
      'icon': Icons.assignment_turned_in,
      'color': Colors.cyan[800],
    },
    {
      'e': 'Others',
      'b': 'অন্যান্য',
      'name': 'Others (অন্যান্য)',
      'icon': Icons.more_horiz,
      'color': Colors.grey[700],
    },
  ];

  // --- ৪. Popular Grid  ---
  final List<Map<String, dynamic>> _popularCategories = [
    {
      'e': 'Govt',
      'b': 'সরকারি',
      'name': 'Government (সরকারি)',
      'icon': Icons.account_balance,
      'color': const Color(0xFF1A237E),
    },
    {
      'e': 'Bank',
      'b': 'ব্যাংক',
      'name': 'Bank (ব্যাংক)',
      'icon': Icons.business_center,
      'color': const Color(0xFF00796B),
    },
    {
      'e': 'Engineering',
      'b': 'ইঞ্জিনিয়ারিং',
      'name': 'Engineering (ইঞ্জিনিয়ারিং)',
      'icon': Icons.engineering,
      'color': const Color(0xFF1976D2),
    },
    {
      'e': ' Medical',
      'b': 'মেডিক্যাল',
      'name': 'Medical (মেডিক্যাল)',
      'icon': Icons.medical_services,
      'color': const Color(0xFFD81B60),
    },
  ];

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Color(0xFFF5F7FA),
      appBar: _buildAppBar(isDarkMode),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(isDarkMode),
            _buildTitle("জনপ্রিয় বিভাগসমূহ", isDarkMode),
            _buildPopularSection(),
            _buildTitle("সব ক্যাটাগরি", isDarkMode),
            _buildAllCategoryGrid(isDarkMode),
          ],
        ),
      ),
    );
  }

  // --- UI Widgets ---

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      title: Text(
        "ক্যাটাগরি",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: isDarkMode ? Color(0xFF1F1F1F) : Colors.indigo[900],
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
      color: isDarkMode ? Color(0xFF1F1F1F) : Colors.indigo[900],
      child: TextField(
        decoration: InputDecoration(
          hintText: "ক্যাটাগরি খুঁজুন...",
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          fillColor: isDarkMode ? Color(0xFF2C2C2C) : Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  //  (Horizontal Scroll)
  Widget _buildPopularSection() {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemCount: _popularCategories.length,
        itemBuilder: (context, i) {
          final cat = _popularCategories[i];
          return InkWell(
            child: Container(
              width: 105,
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: isDarkMode ? Theme.of(context).cardColor : cat['color'],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat['icon'], color: Colors.white, size: 28),
                  const SizedBox(height: 6),

                  // English Text
                  Text(
                    cat['e'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 1),

                  //Bangla Language text
                  Text(
                    cat['b'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 8.5,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllCategoryGrid(bool isDarkMode) {
    int itemCount = _isExpanded ? _allCategories.length : 3;

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 110,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            final cat = _allCategories[index];
            return _buildCategoryItem(cat, isDarkMode);
          },
        ),

        // --- See More / See Less Button ---
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            icon: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.indigo,
            ),
            label: Text(
              _isExpanded ? "কম দেখুন" : "আরও দেখুন",
              style: TextStyle(
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        _buildTitle("প্রস্তুতি শুরু করুন", isDarkMode),
        _buildQuizBanner(isDarkMode),
        _buildTitle("সহযোগিতা", isDarkMode),
        _buildContactCard(isDarkMode),

        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> cat, bool isDarkMode) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),

      onTap: () {
        // key default value
        final String? clickedName = cat['name']?.toString();

        if (clickedName == null || clickedName.isEmpty) {
          print("Error: Category name ('n') missing in data!");
          // User Message show
          return;
        }

        // filter check
        List<JobSyncModel> results = jobProvider.getJobsByFilter(clickedName);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JobListScreen(title: clickedName, jobs: results),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Section
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cat['color'].withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(cat['icon'], color: cat['color'], size: 24),
            ),
            const SizedBox(height: 6),

            // English Name (Top)
            Text(
              cat['e'],
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // Safe against overflow
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                height: 1.1,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 1), // Tiny gap for better readability
            // Bangla Name (Bottom)
            Text(
              cat['b'],
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // Safe against overflow
              style: TextStyle(
                fontSize: 8.5,
                fontWeight:
                    FontWeight.w600, // Adjusted weight to avoid being too bold
                height: 1.1,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizBanner(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  const Color(0xFF2C3E50),
                  const Color(0xFF000000).withOpacity(0.8),
                ]
              : [Colors.indigo[800]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.4)
                : Colors.indigo.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ফ্রি মডেল টেস্ট দিন",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "বিসিএস, ব্যাংক ও সরকারি চাকরির প্রস্তুতির জন্য কুইজে অংশ নিন।",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "কুইজ শুরু করুন",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.quiz_rounded,
            size: 70,
            color: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange.withOpacity(0.1),
            child: const Icon(
              Icons.help_outline_rounded,
              color: Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Text(
              "পছন্দের ক্যাটাগরি খুঁজে পাচ্ছেন না? আমাদের জানান।",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              "মেইল করুন",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
