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
    final Color bgColor = widget.isDarkMode
        ? Colors.redAccent.withOpacity(0.15)
        : Colors.redAccent.withOpacity(0.08);
    final Color textColor = widget.isDarkMode
        ? Colors.redAccent.shade100
        : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.campaign, color: textColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 25,
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  final job = widget.jobs[index % widget.jobs.length];
                  return GestureDetector(
                    onTap: () => widget.onTap(job),
                    child: Text(
                      job.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 12, color: textColor),
        ],
      ),
    );
  }
}
