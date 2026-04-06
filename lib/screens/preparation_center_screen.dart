import 'package:flutter/material.dart';

class PreparationCenterScreen extends StatelessWidget {
  const PreparationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> categories = [
      {
        'title': 'ভর্তি প্রস্তুতি',
        'icon': Icons.school_outlined,
        'color': Colors.blue,
      },
      {
        'title': 'Job Preparation',
        'icon': Icons.work_outline,
        'color': Colors.orange,
      },
      {
        'title': 'Bank Preparation',
        'icon': Icons.account_balance_outlined,
        'color': Colors.teal,
      },
      {
        'title': 'Medical Job',
        'icon': Icons.medical_services_outlined,
        'color': Colors.red,
      },
      {
        'title': 'কৃষি ও মৎস্য',
        'icon': Icons.agriculture_outlined,
        'color': Colors.green,
      },
      {
        'title': 'Technical Job',
        'icon': Icons.precision_manufacturing_outlined,
        'color': Colors.purple,
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
      body: SingleChildScrollView(
        // overflow protector
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "ক্যাটাগরি সমূহ",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            //
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  // AspectRatio
                  childAspectRatio: 1.15,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryCard(categories[index], isDarkMode);
                },
              ),
            ),

            //
            const SizedBox(height: 12),

            // quiz banner
            _buildQuizBanner(isDarkMode),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat, bool isDarkMode) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1B263B) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withOpacity(0.05)
                : cat['color'].withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(cat['icon'], size: 28, color: cat['color']),
            const SizedBox(height: 8),
            Text(
              cat['title'],
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'শুরু করুন',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white54 : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // quiz banner
  Widget _buildQuizBanner(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(15),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "ফ্রি মডেল টেস্ট",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "বিসিএস, ব্যাংক ও সকল সরকারি চাকরির প্রস্তুতির জন্য কুইজ দিন",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[800],
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text(
                      "শুরু করুন",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.quiz_rounded,
            size: 55,
            color: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}
