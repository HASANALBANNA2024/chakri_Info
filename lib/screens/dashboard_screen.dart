import 'dart:async';

import 'package:chakri_info/controllers/job_controller.dart';
import 'package:chakri_info/main.dart';
import 'package:chakri_info/models/job_model.dart';
import 'package:chakri_info/screens/bookmark_screen.dart';
import 'package:chakri_info/screens/category_screen.dart';
import 'package:chakri_info/widgets/appdrawer.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final JobController _jobController = JobController();
  late List<JobModel> circulars;
  late ScrollController _scrollController;
  late Timer _timer;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    circulars = _jobController.fetchAllCirculars();
    _scrollController = ScrollController();

    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double newPosition = _scrollController.offset + 180;

        if (newPosition >= maxScroll) {
          _scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 800),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.animateTo(
            newPosition,
            duration: Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildCustomAppBar(isDarkMode),
      drawer: AppDrawer(isDarkMode: isDarkMode),

      body: _buildHomeBody(isDarkMode),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) return;
          Widget nextScreen;
          switch (index) {
            case 1:
              nextScreen = CategoryScreen();
              break;
            case 2:
              nextScreen = BookmarkScreen();
              break;
            default:
              return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => nextScreen),
          );
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'হোম'),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'ক্যাটাগরি',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_rounded),
            label: 'সেভ করা',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.quiz_rounded,
              color: Colors.orange[700],
            ), // কুইজকে আলাদা করতে কালার দিতে পারেন
            label: 'কুইজ',
          ),
        ],
      ),
    );
  }

  // --- UI Body (Maximum Space Optimization) ---
  Widget _buildHomeBody(bool isDarkMode) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsSection(isDarkMode),
          _buildSearchSection(isDarkMode),
          _buildFeaturedSlider(),
          _buildCategoryGrid(isDarkMode),
          _buildNoticeBar(isDarkMode), // ১. অপ্টিমাইজড নোটিশ বার
          _buildSectionTitle("সাম্প্রতিক সার্কুলার", isDarkMode),
          _buildJobList(isDarkMode), // ২. অপ্টিমাইজড সাম্প্রতিক সার্কুলার লিস্ট
        ],
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(bool isDarkMode) {
    return AppBar(
      title: Text(
        "চাকরি ইনফো",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: isDarkMode ? Color(0xFF1F1F1F) : Colors.indigo[900],
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: Colors.white,
            size: 26,
          ), // ড্রয়ার ওপেন করার মেনু আইকন
          onPressed: () =>
              Scaffold.of(context).openDrawer(), // ক্লিক করলে ড্রয়ার খুলবে
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode, size: 20),
          onPressed: () => themeNotifier.value = isDarkMode
              ? ThemeMode.light
              : ThemeMode.dark,
        ),
        IconButton(
          icon: Icon(Icons.notifications_none, size: 22, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildStatsSection(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _buildStatCard("১৪ নতুন", "সার্কুলার", Colors.indigo, Icons.bolt),
          SizedBox(width: 8),
          _buildStatCard("৩ শেষ", "ডেডলাইন", Colors.teal, Icons.timer_outlined),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String count,
    String label,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ), // ভার্টিকাল গ্যাপ সামান্য বাড়ানো হয়েছে যাতে ক্লিয়ার মনে হয়
      child: Container(
        height: 44, // ৪২ থেকে বাড়িয়ে ৪৪ করা হয়েছে Better Touch Target এর জন্য
        decoration: BoxDecoration(
          boxShadow: [
            if (!isDarkMode) // লাইট মোডে হালকা শ্যাডো যা প্রিমিয়াম লুক দিবে
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
          ],
        ),
        child: TextField(
          textAlignVertical:
              TextAlignVertical.center, // টেক্সট একদম মাঝখানে থাকবে
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: "সার্চ করুন (যেমন: ব্যাংক, সরকারি...)",
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 20,
              color: Colors.indigo,
            ), // আইকন কালারফুল করা হয়েছে
            // ডানপাশে ফিল্টার আইকন যা চাকুরি খোঁজার জন্য খুব দরকারি
            suffixIcon: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.tune_rounded,
                size: 16,
                color: Colors.indigo,
              ), // ফিল্টার আইকন
            ),

            fillColor: isDarkMode ? Color(0xFF2C2C2C) : Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode
                    ? Colors.transparent
                    : Colors.grey.withOpacity(0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.indigo.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ১. নোটিশ বার অপ্টিমাইজেশন (Ultra Compact)
  Widget _buildNoticeBar(bool isDarkMode) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 2,
      ), // গ্যাপ একদম কমিয়ে ২ করা হয়েছে
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ), // প্যাডিং কমানো হয়েছে
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.campaign, color: Colors.redAccent, size: 16),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              "৪৬তম বিসিএস প্রিলি রেজাল্ট প্রকাশিত হয়েছে...",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 8, color: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildFeaturedSlider() {
    return Container(
      height: 125,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double cardWidth = constraints.maxWidth / 2;
          return ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                width: cardWidth - 12,
                margin: EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage("assets/images/bpsc_image.webp"),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.35),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "৪৭তম বিসিএস",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "১৫ এপ্রিল ডেডলাইন",
                        style: TextStyle(color: Colors.white70, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryGrid(bool isDarkMode) {
    List<Map<String, dynamic>> cats = [
      {'n': 'সরকারি', 'i': Icons.account_balance, 'c': Colors.orange},
      {'n': 'ব্যাংক', 'i': Icons.business, 'c': Colors.blue},
      {'n': 'বেসরকারি', 'i': Icons.apartment, 'c': Colors.purple},
      {'n': 'ডিফেন্স', 'i': Icons.security, 'c': Colors.red},
      {'n': 'এনজিও', 'i': Icons.groups_rounded, 'c': Colors.teal},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ), // সাইড প্যাডিং কমানো হয়েছে
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly, // সমান দূরত্বে ৫টি আইকন বসবে
        children: cats.map((cat) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(7), // প্যাডিং কিছুটা কমানো হয়েছে
                decoration: BoxDecoration(
                  color: cat['c'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  cat['i'],
                  color: cat['c'],
                  size: 19,
                ), // আইকন সাইজ ১৯
              ),
              SizedBox(height: 4),
              Text(
                cat['n'],
                style: TextStyle(
                  fontSize: 9.5, // টেক্সট সাইজ সামান্য কমানো হয়েছে যাতে ৫টি ধরে
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 2), // গ্যাপ কমানো হয়েছে
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ২. সাম্প্রতিক সার্কুলার অপ্টিমাইজেশন (Maximum Data Density)
  Widget _buildJobList(bool isDarkMode) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: circulars.length,
      itemBuilder: (context, index) {
        final job = circulars[index];
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 3,
          ), // ভার্টিকাল গ্যাপ মাত্র ৩
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ), // ভেতরের প্যাডিং কম
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 2),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 38,
                width: 38, // লোগো সাইজ আরও কম
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    job.logo,
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      job.company,
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                      maxLines: 1,
                    ),
                    Text(
                      "ডেডলাইন: ${job.deadline}",
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.remove_red_eye_outlined,
                    size: 12,
                    color: Colors.grey,
                  ),
                  Text(
                    "১৭৫",
                    style: TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
