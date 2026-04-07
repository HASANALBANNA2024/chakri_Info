import 'package:chakri_info/Questions/sub_category_exam_screen.dart';
import 'package:flutter/material.dart';

class PreparationCenterScreen extends StatelessWidget {
  const PreparationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> categories = [
      {
        'title': 'BCS (বিসিএস প্রশ্ন)',
        'icon': Icons.menu_book_rounded,
        'color': Colors.blue.shade700,
      },
      {
        'title': 'Admission',
        'icon': Icons.school_outlined,
        'color': Colors.blue,
      },
      {'title': 'Govt Job', 'icon': Icons.work_outline, 'color': Colors.orange},
      {
        'title': 'Bank Job',
        'icon': Icons.account_balance_outlined,
        'color': Colors.teal,
      },
      {
        'title': 'Medical & Nursing',
        'icon': Icons.medical_services_outlined,
        'color': Colors.red,
      },
      {
        'title': 'কৃষি ও মৎস্য',
        'icon': Icons.agriculture_outlined,
        'color': Colors.green,
      },
      {
        'title': 'Technical (ইঞ্জিনিয়ারিং)',
        'icon': Icons.precision_manufacturing_outlined,
        'color': Colors.purple,
      },
      {
        'title': 'Primary (শিক্ষক)',
        'icon': Icons.school_rounded,
        'color': Colors.orange.shade800,
      },
      {
        'title': 'NTRCA (নিবন্ধন)',
        'icon': Icons.assignment_ind_outlined,
        'color': Colors.green.shade700,
      },
      {
        'title': 'Others (অন্যান্য)',
        'icon': Icons.more_horiz_rounded,
        'color': Colors.blueGrey.shade600,
      },
    ];

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0D1B2A) : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Preparation Cell (প্রস্তুতি সেল)",
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDarkMode ? const Color(0xFF0D1B2A) : Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        // SingleChildScrollView
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "ক্যাটাগরি সমূহ",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // GridView.builder - Expanded
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.6,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryCard(
                    context,
                    categories[index],
                    isDarkMode,
                  );
                },
              ),
            ),
          ),
          // Quiz Banner - হাইট কিছুটা কমিয়ে নিচে ফিক্সড রাখা হয়েছে
          const SizedBox(height: 10),
          _buildQuizBanner(isDarkMode),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    Map<String, dynamic> cat,
    bool isDarkMode,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;

        // ক্যাটাগরির নাম বের করা
        final String s1 = (cat['title'] ?? cat['name'] ?? '').toString().trim();

        if (s1.isEmpty) {
          print("Error: Category name is empty");
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubCategoryExamScreen(
              categoryName: s1, // নিশ্চিত করুন এই নামটাই ক্লাসে আছে
              isDarkMode: isDark,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1B263B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!isDarkMode)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
          ],
          border: Border.all(
            color: isDarkMode
                ? Colors
                      .transparent // Dark mode screen invisible
                : cat['color'].withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(cat['icon'], size: 24, color: cat['color']),
            const SizedBox(height: 6), //
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                cat['title'],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'শুরু করুন',
              style: TextStyle(
                fontSize: 11,
                color: isDarkMode ? Colors.white54 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizBanner(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [const Color(0xFF2C3E50), const Color(0xFF1B263B)]
              : [Colors.indigo[700]!, Colors.blue[500]!],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "ফ্রি মডেল টেস্ট",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "বিসিএস ও সকল চাকরির কুইজ দিন",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "শুরু করুন",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Icon(
            Icons.quiz_rounded,
            size: 45,
            color: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}
