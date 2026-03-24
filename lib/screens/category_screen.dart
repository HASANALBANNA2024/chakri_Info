import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _isExpanded = false;
  // all category
  final List<Map<String, dynamic>> _allCategories = [
    // --- ১. টপ ও সরকারি জবস (Most Searched) ---
    {'name': 'বিসিএস (BCS)', 'icon': Icons.stars, 'color': Colors.amber[800]},
    {
      'name': 'সরকারি চাকরি',
      'icon': Icons.account_balance,
      'color': Colors.orange[900],
    },
    {
      'name': 'ব্যাংক ও ফিন্যান্স',
      'icon': Icons.business,
      'color': Colors.blue[800],
    },
    {
      'name': 'ডিফেন্স ও পুলিশ',
      'icon': Icons.security,
      'color': Colors.redAccent,
    },
    {'name': 'রেলওয়ে জবস', 'icon': Icons.train, 'color': Colors.deepPurple},

    // --- ২. শিক্ষা ও গবেষণা ---
    {'name': 'শিক্ষক নিয়োগ', 'icon': Icons.school, 'color': Colors.green},
    {
      'name': 'এডুকেশন ও ট্রেনিং',
      'icon': Icons.menu_book,
      'color': Colors.lightGreen,
    },
    {
      'name': 'বিশ্ববিদ্যালয় ভর্তি',
      'icon': Icons.history_edu,
      'color': Colors.indigo,
    },
    {
      'name': 'পরীক্ষার রেজাল্ট',
      'icon': Icons.assignment_turned_in,
      'color': Colors.cyan[700],
    },

    // --- ৩. মেডিকেল ও স্বাস্থ্য ---
    {
      'name': 'মেডিকেল ও নার্সিং',
      'icon': Icons.medical_services,
      'color': Colors.teal,
    },
    {
      'name': 'হেলথকেয়ার ও ফার্মা',
      'icon': Icons.medication,
      'color': Colors.deepOrange,
    },
    {
      'name': 'নার্স (Nurse)',
      'icon': Icons.person_add_alt_1,
      'color': Colors.tealAccent[700],
    },
    {
      'name': 'ফার্মাসিউটিক্যালস',
      'icon': Icons.biotech,
      'color': Colors.pink[400],
    },

    // --- ৪. আইটি ও টেকনিক্যাল ---
    {
      'name': 'IT ও টেলিকম',
      'icon': Icons.on_device_training,
      'color': Colors.blue,
    },
    {
      'name': 'ইঞ্জিনিয়ারিং',
      'icon': Icons.engineering,
      'color': Colors.blueGrey,
    },
    {
      'name': 'ডেটা এন্ট্রি',
      'icon': Icons.keyboard,
      'color': Colors.blueGrey[400],
    },
    {
      'name': 'প্রোডাকশন',
      'icon': Icons.settings_suggest,
      'color': Colors.indigo[300],
    },

    // --- ৫. কর্পোরেট ও কমার্শিয়াল ---
    {
      'name': 'অ্যাকাউন্টিং ও ফিন্যান্স',
      'icon': Icons.account_balance_wallet,
      'color': Colors.blueGrey,
    },
    {'name': 'অ্যাডমিন ও সেলস', 'icon': Icons.campaign, 'color': Colors.orange},
    {
      'name': 'কমার্শিয়াল',
      'icon': Icons.business_center,
      'color': Colors.brown,
    },
    {
      'name': 'গার্মেন্টস ও টেক্সটাইল',
      'icon': Icons.dry_cleaning,
      'color': Colors.pink,
    },

    // --- ৬. কৃষি ও এনজিও ---
    {
      'name': 'এগ্রো (উদ্ভিদ/প্রাণী)',
      'icon': Icons.agriculture,
      'color': Colors.green[800],
    },
    {
      'name': 'মৎস্য (Fisheries)',
      'icon': Icons.phishing,
      'color': Colors.lightBlue,
    },
    {
      'name': 'এনজিও (NGO)',
      'icon': Icons.volunteer_activism,
      'color': Colors.indigo,
    },

    // --- ৭. অন্যান্য ---
    {'name': 'বেসরকারি চাকরি', 'icon': Icons.apartment, 'color': Colors.purple},
    {
      'name': 'অন্যান্য (Others)',
      'icon': Icons.more_horiz,
      'color': Colors.grey,
    },
  ];

  // popular list for future database update ok
  final List<Map<String, dynamic>> _popularCategories = [
    {
      'name': 'সরকারি\nচাকরি',
      'icon': Icons.account_balance,
      'color': Color(0xFF1A237E),
    },
    {
      'name': 'ব্যাংক\nজবস',
      'icon': Icons.business_center,
      'color': Color(0xFF00796B),
    },
    {
      'name': 'প্রাইভেট\nকোম্পানি',
      'icon': Icons.apartment,
      'color': Color(0xFF7B1FA2),
    },
    {
      'name': 'আইটি &\nসফটওয়্যার',
      'icon': Icons.computer,
      'color': Color(0xFF1976D2),
    },
  ];

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Color(0xFFF5F7FA),
      appBar: _buildAppBar(isDarkMode),
      body: SingleChildScrollView(
        // ওভারফ্লো রোধ করতে স্ক্রল ব্যবহার করা হয়েছে
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ১. সার্চবার সেকশন
            _buildSearchBar(isDarkMode),

            // ২. জনপ্রিয় বিভাগসমূহ (Horizontal)
            _buildTitle("জনপ্রিয় বিভাগসমূহ", isDarkMode),
            _buildPopularSection(),

            // ৩. সব ক্যাটাগরি (Grid)
            _buildTitle("সব ক্যাটাগরি", isDarkMode),
            _buildAllCategoryGrid(isDarkMode),
            // নিচের দিকে একটু গ্যাপ রাখার জন্য
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
    // ১. বর্তমান থিম চেক করা
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemCount: _popularCategories.length,
        itemBuilder: (context, i) {
          final cat = _popularCategories[i];

          Color cardColor = isDarkMode
              ? Theme.of(context)
                    .cardColor //
              : cat['color'];

          Color iconColor = isDarkMode ? cat['color'] : Colors.white;

          return Container(
            width: 105,
            margin: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.transparent,
              ),
              boxShadow: [
                if (!isDarkMode)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // আইকন কন্টেইনার
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? cat['color'].withOpacity(0.1)
                        : Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(cat['icon'], color: iconColor, size: 28),
                ),
                SizedBox(height: 10),
                Text(
                  cat['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.9)
                        : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllCategoryGrid(bool isDarkMode) {
    // প্রথমে মাত্র ৯টি ক্যাটাগরি দেখাবে, 'See More' ক্লিক করলে সব দেখাবে।
    int itemCount = _isExpanded ? _allCategories.length : 4;

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

        // ৪. কুইজ প্রমোশন ব্যানার (এখন এটি সহজেই দেখা যাবে)
        _buildTitle("প্রস্তুতি শুরু করুন", isDarkMode),
        _buildQuizBanner(isDarkMode),

        // ৫. কন্টাক্ট বা রিকোয়েস্ট কার্ড
        _buildTitle("সহযোগিতা", isDarkMode),
        _buildContactCard(isDarkMode),

        SizedBox(height: 30),
      ],
    );
  }

  // আইটেম ডিজাইন আলাদা ফাংশনে নিয়ে আসা হয়েছে কোড ক্লিন রাখার জন্য
  Widget _buildCategoryItem(Map<String, dynamic> cat, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cat['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(cat['icon'], color: cat['color'], size: 26),
          ),
          SizedBox(height: 8),
          Text(
            cat['name'],
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ১. কুইজ প্রমোশন ব্যানার
  Widget _buildQuizBanner(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // ডার্ক মোডে কালো না হয়ে যেন একটা প্রিমিয়াম ডার্ক ব্লু/গ্রে শেড থাকে
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  const Color(0xFF2C3E50), // ডার্ক মোডের জন্য কালচে নীল শেড
                  const Color(
                    0xFF000000,
                  ).withOpacity(0.8), // কিছুটা ডার্ক গভীরতা
                ]
              : [Colors.indigo[800]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        // বর্ডারের চারপাশ দিয়ে হালকা একটি বর্ডার দিলে ডার্ক মোডে জিনিসটা ফুটে ওঠে
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
                  onPressed: () {
                    // এখানে কুইজ স্ক্রিনে যাওয়ার লজিক থাকবে
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .orange[800], // ডার্ক মোডে একটু উজ্জ্বল অরেঞ্জ ভালো দেখায়
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
          // আইকনটিকে ডার্ক মোডে আরও একটু সফট লুক দেওয়ার জন্য Opacity কমানো হয়েছে
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

  // ২. কন্টাক্ট বা রিকোয়েস্ট কার্ড
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
