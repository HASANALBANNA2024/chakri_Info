import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:chakri_info/widgets/featured_job_slider.dart';
import 'package:chakri_info/controllers/job_controller.dart';
import 'package:chakri_info/main.dart';
import 'package:chakri_info/models/job_model.dart';
import 'package:chakri_info/screens/bookmark_screen.dart';
import 'package:chakri_info/screens/category_screen.dart';
import 'package:chakri_info/user_side_data_sync/job_details_screen.dart';
import 'package:chakri_info/user_side_data_sync/joblist_screen.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_provider.dart';
import 'package:chakri_info/user_side_data_sync/sliding_notice_bar.dart';
import 'package:chakri_info/widgets/appdrawer.dart';
import 'package:chakri_info/user_side_data_sync/job_card_widget.dart';
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
    // Data Sync
    jobProvider.startRealTimeSync();

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
            ), // quiz difference color
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
          FeaturedJobSlider(jobProvider: jobProvider),
          _buildCategoryGrid(isDarkMode),
          _buildNoticeSection(), //optimization notice bar
          _buildSectionTitle("সাম্প্রতিক সার্কুলার", isDarkMode),
          _buildJobList(isDarkMode), // optimization circular bar
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
              Scaffold.of(context).openDrawer(), // to click open drawer
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
// stats section
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
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    count,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: color,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                      letterSpacing: 0.2,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // states section end


  Widget _buildSearchSection(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.2)
                  : Colors.indigo.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            fontSize: 13,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: "সার্চ করুন (যেমন: ব্যাংক, সরকারি...)",
            hintStyle: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 18,
              color: Colors.indigo,
            ),
            suffixIcon: Container(
              margin: const EdgeInsets.all(7),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.tune_rounded,
                size: 14,
                color: Colors.indigo,
              ),
            ),
            fillColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: isDarkMode
                    ? Colors.white10
                    : Colors.indigo.withOpacity(0.05),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Colors.indigo.withOpacity(0.3),
                width: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // notice bar (Ultra Compact)
  Widget _buildNoticeSection() {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();

    return StreamBuilder<List<JobSyncModel>>(
      stream: jobProvider.getJobStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final allJobs = snapshot.data!;

        // ফিল্টারিং লজিক আপডেট
        final noticeJobs = allJobs.where((job) {
          // পদ সংখ্যা বের করা (যদি খালি থাকে তবে ০ ধরবে)
          String postStr = job.totalpost.replaceAll(RegExp(r'[^0-9]'), '');
          int postCount = postStr.isNotEmpty ? int.parse(postStr) : 0;

          // ডেডলাইন চেক
          bool isNotExpired = true;
          if (job.deadline.isNotEmpty && job.deadline != "null") {
            DateTime? deadlineDate = DateTime.tryParse(job.deadline);
            if (deadlineDate != null) {
              // ডেডলাইন আজকের বা ভবিষ্যতের হলে ট্রু হবে
              isNotExpired = deadlineDate.isAfter(today.subtract(const Duration(days: 1)));
            }
          }

          // আপনার প্রয়োজন অনুযায়ী এখানে পদ সংখ্যা ৬০ এর বদলে কমিয়ে বা বাড়িয়ে চেক করতে পারেন
          return job.isGovt == true && postCount >= 10 && isNotExpired;
        }).toList();

        if (noticeJobs.isEmpty) return const SizedBox.shrink();

        // নোটিশ বারটি একটু প্যাডিং দিয়ে রিটার্ন করা যাতে স্পষ্ট হয়
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SlidingNoticeBar(
            jobs: noticeJobs,
            isDarkMode: isDarkMode,
            onTap: (clickedJob) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobDetailsScreen(job: clickedJob),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryGrid(bool isDarkMode) {
    List<Map<String, dynamic>> cats = [
      {
        'e': 'BCS',
        'b': 'বিসিএস',
        'n': 'BCS (বিসিএস)',
        'i': Icons.stars,
        'c': Colors.amber[800],
      },
      {
        'e': 'Govt',
        'b': 'সরকারি',
        'n': 'Government (সরকারি)',
        'i': Icons.account_balance,
        'c': Colors.orange[900],
      },
      {
        'e': 'Bank',
        'b': 'ব্যাংক',
        'n': 'Bank (ব্যাংক)',
        'i': Icons.business,
        'c': Colors.blue[800],
      },
      {
        'e': 'Private',
        'b': 'বেসরকারি',
        'n': 'Private (বেসরকারি)',
        'i': Icons.apartment,
        'c': Colors.purple,
      },
      {
        'e': 'Defense',
        'b': 'ডিফেন্স',
        'n': 'Defense (ডিফেন্স)',
        'i': Icons.security,
        'c': Colors.redAccent,
      },
      {
        'e': 'NGO',
        'b': 'এনজিও',
        'n': 'NGO (এনজিও)',
        'i': Icons.groups_rounded,
        'c': Colors.teal,
      },
      {
        'e': 'Teacher',
        'b': 'শিক্ষক নিয়োগ',
        'n': 'Teacher (শিক্ষক নিয়োগ)',
        'i': Icons.school,
        'c': Colors.lightGreen,
      },
      {
        'e': 'Admission',
        'b': 'ভর্তি পরীক্ষা',
        'n': 'Admission (ভর্তি পরীক্ষা)',
        'i': Icons.history_edu,
        'c': Colors.indigo,
      },
      {
        'e': 'Notice',
        'b': 'নোটিশ',
        'n': 'Notice or Result (নোটিশ ও রেজাল্ট)',
        'i': Icons.assignment_turned_in,
        'c': Colors.cyan[700],
      },
      {
        'e': 'Medical',
        'b': 'মেডিক্যাল',
        'n': 'Medical (মেডিক্যাল)',
        'i': Icons.medical_services,
        'c': Colors.teal,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 0,
          crossAxisSpacing: 4,
          mainAxisExtent: 70, // Increased from 75 to 95 to prevent overflow
        ),
        itemCount: cats.length,
        itemBuilder: (context, index) {
          var cat = cats[index];
          return InkWell(
            borderRadius: BorderRadius.circular(10),

            onTap: () {
              String clickedName = cat['n'];

              List<JobSyncModel> results = jobProvider.getJobsByFilter(
                clickedName,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      JobListScreen(title: clickedName, jobs: results),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6), // Slightly reduced padding
                  decoration: BoxDecoration(
                    color: cat['c'].withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(cat['i'], color: cat['c'], size: 22),
                ),
                const SizedBox(height: 1),
                // Wrapped in Expanded or Flexible to prevent vertical overflow
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cat['e'],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        cat['b'],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w400,
                          height: 1.1,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Recent  (Maximum Data Density)
  Widget _buildJobList(bool isDarkMode) {
    final today = DateTime.now();
    // active job checker
    final currentDay = DateTime(today.year, today.month, today.day);

    return StreamBuilder<List<JobSyncModel>>(
      stream: jobProvider.getJobStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        // ১. Filter & Sort Logic
        List<JobSyncModel> filteredJobs = snapshot.data!.where((job) {
          // deadline not over then show the recent ok
          if (job.deadline.isEmpty || job.deadline == "null") return true;

          try {
            DateTime deadlineDate = DateTime.parse(job.deadline);
            final compareDeadline = DateTime(deadlineDate.year, deadlineDate.month, deadlineDate.day);

            // Ajker din ba bhabishyoter deadline hole show korbe
            return compareDeadline.isAtSameMomentAs(currentDay) || compareDeadline.isAfter(currentDay);
          } catch (e) {
            return true; // Date format vul thakle safe thakar jonno show korbe
          }
        }).toList();

        // Newest Upload First (Sorting by ID or any timestamp)
        filteredJobs.sort((a, b) => b.id.compareTo(a.id));

        if (filteredJobs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("এই মুহূর্তে কোন সক্রিয় সার্কুলার নেই"),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredJobs.length,
          itemBuilder: (context, index) {
            final job = filteredJobs[index];
            // Apnar dewa Ultra Modern JobCardWidget ekhane call kora holo
            return JobCardWidget(job: job);
          },
        );
      },
    );
  }

}
