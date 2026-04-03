import 'dart:async';
import 'package:flutter/material.dart';
import '../user_side_data_sync/jobsync_model.dart'; // আপনার পাথ অনুযায়ী দিন

class SlidingNoticeBar extends StatefulWidget {
  final List<JobSyncModel> jobs;
  final Function(JobSyncModel) onTap;
  final bool isDarkMode;

  const SlidingNoticeBar({
    super.key,
    required this.jobs,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  State<SlidingNoticeBar> createState() => _SlidingNoticeBarState();
}

class _SlidingNoticeBarState extends State<SlidingNoticeBar> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.jobs.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_pageController.hasClients) {
          _currentIndex++;
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // আপনার দেওয়া স্ট্যাটিক ডিজাইনের হুবহু কালার কোড
    final Color accentColor = Colors.redAccent;
    final Color bgColor = accentColor.withOpacity(0.08);

    return Container(
      // আপনার দেওয়া মার্জিন এবং প্যাডিং
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6), // ৬ পিক্সেল রেডিয়াস
      ),
      child: Row(
        children: [
          // আইকন সাইজ ১৬ আপনার দেওয়া কোড অনুযায়ী
          Icon(Icons.campaign, color: accentColor, size: 16),
          const SizedBox(width: 6),

          Expanded(
            child: SizedBox(
              height: 18, // টেক্সট লাইনের উচ্চতা অনুযায়ী ফিক্সড হাইট
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  final job = widget.jobs[index % widget.jobs.length];
                  print(job);
                  return GestureDetector(
                    onTap: () => widget.onTap(job),
                    child: Text(
                      job.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11, // আপনার দেওয়া ফন্ট সাইজ ১১
                        color: accentColor,
                        fontWeight: FontWeight.w600, // Semi-bold স্টাইল
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // শেষের অ্যারো আইকন সাইজ ৮ আপনার দেওয়া কোড অনুযায়ী
          Icon(Icons.arrow_forward_ios, size: 8, color: accentColor),

        ],
      ),
    );
  }
}