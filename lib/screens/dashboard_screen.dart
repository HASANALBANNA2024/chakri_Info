import 'dart:async';

import 'package:chakri_info/controllers/job_controller.dart';
import 'package:chakri_info/main.dart';
import 'package:chakri_info/models/job_model.dart';
import 'package:chakri_info/screens/bookmark_screen.dart';
import 'package:chakri_info/screens/category_screen.dart';
import 'package:chakri_info/user_side_data_sync/job_card_widget.dart';
import 'package:chakri_info/user_side_data_sync/job_details_screen.dart';
import 'package:chakri_info/user_side_data_sync/joblist_screen.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_provider.dart';
import 'package:chakri_info/user_side_data_sync/sliding_notice_bar.dart';
import 'package:chakri_info/widgets/appdrawer.dart';
import 'package:chakri_info/widgets/global_search_delegate.dart';
import 'package:chakri_info/widgets/job_stats_widget.dart';
import 'package:chakri_info/widgets/prep_center_banner.dart';
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
  // Widget _buildHomeBody(bool isDarkMode) {
  //   return StreamBuilder<List<JobSyncModel>>(
  //     stream: jobProvider.getJobStream(),
  //     builder: (context, snapshot) {
  //       final allJobs = snapshot.data ?? [];
  //
  //       return SingleChildScrollView(
  //         physics: const BouncingScrollPhysics(),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             JobStatsWidget(isDarkMode: isDarkMode, allJobs: allJobs),
  //             buildGlobalSearchSection(
  //               context,
  //               isDarkMode,
  //               jobProvider.allJobs,
  //             ),
  //             // FeaturedJobSlider(jobProvider: jobProvider),
  //             _buildCategoryGrid(isDarkMode),
  //             PrepCenterBanner(),
  //             _buildNoticeSection(),
  //             _buildSectionTitle("সাম্প্রতিক সার্কুলার", isDarkMode),
  //             _buildJobList(isDarkMode),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // home end

  Widget _buildHomeBody(bool isDarkMode) {
    return StreamBuilder<List<JobSyncModel>>(
      stream: jobProvider.getJobStream(),
      builder: (context, snapshot) {
        final allJobs = snapshot.data ?? [];

        return RefreshIndicator(
          displacement: 20,
          color: Colors.indigo,
          backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,

          // ঠিক এখানে আপনার দেওয়া কোডটুকু বসবে
          onRefresh: () async {
            // এটি ডাটাবেস ভার্সন চেক করবে, নতুন ডাটা থাকলে তবেই রিড করবে
            await jobProvider.checkUpdateAndSync();

            // ইউজারকে একটু সময় দেওয়ার জন্য ১ সেকেন্ড ডিলে
            await Future.delayed(const Duration(seconds: 1));
          },

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // অ্যাপবারের ঠিক নিচেই প্রগ্রেস বার (ডাটা সিঙ্ক হওয়ার সময় দেখাবে)
                if (snapshot.connectionState == ConnectionState.waiting)
                  const LinearProgressIndicator(
                    minHeight: 2,
                    color: Colors.orange,
                    backgroundColor: Colors.transparent,
                  ),

                JobStatsWidget(isDarkMode: isDarkMode, allJobs: allJobs),
                buildGlobalSearchSection(
                  context,
                  isDarkMode,
                  allJobs,
                ),

                _buildCategoryGrid(isDarkMode),
                const PrepCenterBanner(),
                _buildNoticeSection(),
                _buildSectionTitle("সাম্প্রতিক সার্কুলার", isDarkMode),
                _buildJobList(isDarkMode),
              ],
            ),
          ),
        );
      },
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
          ), // drawer open
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

  // notice bar (Ultra Compact)
  Widget _buildNoticeSection() {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();

    return StreamBuilder<List<JobSyncModel>>(
      stream: jobProvider.getJobStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final allJobs = snapshot.data!;

        // filtering logic
        final noticeJobs = allJobs.where((job) {
          // পদ সংখ্যা বের করা
          String postStr = job.totalpost.replaceAll(RegExp(r'[^0-9]'), '');
          int postCount = postStr.isNotEmpty ? int.parse(postStr) : 0;

          // ডেডলাইন চেক (আগের মতোই থাকবে)
          bool isNotExpired = true;
          if (job.deadline.isNotEmpty &&
              job.deadline.toLowerCase() != "null" &&
              !job.deadline.contains("চলমান")) {
            try {
              DateTime deadlineDate = DateTime.parse(job.deadline);
              isNotExpired = deadlineDate.isAfter(
                today.subtract(const Duration(days: 1)),
              );
            } catch (e) {
              isNotExpired = true;
            }
          }

          // condition 50+ posts
          return postCount >= 50 && isNotExpired;
        }).toList();

        if (noticeJobs.isEmpty) return const SizedBox.shrink();

        // notice bar padding
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

  // category item
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
        'e': 'Result',
        'b': 'রেজাল্ট',
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

  // section title
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
        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        // ১. Filter & Sort Logic
        List<JobSyncModel> filteredJobs = snapshot.data!.where((job) {
          // deadline not over then show the recent ok
          if (job.deadline.isEmpty || job.deadline == "null") return true;

          try {
            DateTime deadlineDate = DateTime.parse(job.deadline);
            final compareDeadline = DateTime(
              deadlineDate.year,
              deadlineDate.month,
              deadlineDate.day,
            );

            // Ajker din ba bhabishyoter deadline hole show korbe
            return compareDeadline.isAtSameMomentAs(currentDay) ||
                compareDeadline.isAfter(currentDay);
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
