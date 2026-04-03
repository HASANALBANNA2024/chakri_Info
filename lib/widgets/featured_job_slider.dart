import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:chakri_info/user_side_data_sync/job_details_screen.dart';

class FeaturedJobSlider extends StatefulWidget {
  final dynamic jobProvider;
  const FeaturedJobSlider({super.key, required this.jobProvider});

  @override
  State<FeaturedJobSlider> createState() => _FeaturedJobSliderState();
}

class _FeaturedJobSliderState extends State<FeaturedJobSlider> {
  late PageController _pageController;
  Timer? _autoSlideTimer;
  late Stream<List<JobSyncModel>> _jobStream;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85); // একটু বড় করা হয়েছে
    _jobStream = widget.jobProvider.getJobStream();

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page?.toInt() ?? 0) + 1;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutQuart,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _toBN(String n) {
    const en = ['0','1','2','3','4','5','6','7','8','9'],
        bn = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
    for (int i=0; i<10; i++) n = n.replaceAll(en[i], bn[i]);
    return n;
  }

  String _fmtBN(String d) {
    if (d.isEmpty || d == "null") return "চলমান";
    try {
      DateTime dt = DateTime.parse(d);
      const m = ['জানু','ফেব্রু','মার্চ','এপ্রিল','মে','জুন','জুলাই','আগস্ট','সেপ্টে','অক্টো','নভে','ডিসে'];
      return "${_toBN(dt.day.toString())} ${m[dt.month-1]}";
    } catch (e) { return d; }
  }

  Widget _buildImg(String s) {
    if (s.isEmpty) return const Icon(Icons.business, size: 40, color: Colors.grey);
    try {
      return s.startsWith('http')
          ? Image.network(s, fit: BoxFit.contain, errorBuilder: (c,e,s)=>const Icon(Icons.broken_image))
          : Image.memory(base64Decode(s), fit: BoxFit.contain);
    } catch (e) { return const Icon(Icons.error_outline); }
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // কালার স্কিম
    final cardBgColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0);
    final titleTextColor = isDark ? Colors.white : Colors.black87;
    final dateTextColor = isDark ? Colors.white70 : Colors.black54;
    final dateBgColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    return StreamBuilder<List<JobSyncModel>>(
      stream: _jobStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();

        final validJobs = snapshot.data!.where((job) {
          if (job.isGovt != true) return false;
          if (job.deadline.isEmpty || job.deadline == "null") return true;
          DateTime? dDate = DateTime.tryParse(job.deadline);
          return dDate == null || dDate.isAfter(today) || dDate.isAtSameMomentAs(today);
        }).toList();

        return SizedBox(
          height: 190, // টাইটেল ৩ লাইন হতে পারে তাই হাইট সামান্য বাড়ানো হয়েছে
          child: PageView.builder(
            controller: _pageController,
            itemBuilder: (context, index) {
              final job = validJobs[index % validJobs.length];
              DateTime? dDate = DateTime.tryParse(job.deadline);
              int diff = dDate != null ? dDate.difference(today).inDays : -1;
              bool isUrgent = diff >= 0 && diff <= 3;

              return GestureDetector(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (context) => JobDetailsScreen(job: job))
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                        blurRadius: 12, offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Stack(
                      children: [
                        if (isUrgent)
                          Positioned(
                            top: 0, right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: const BoxDecoration(
                                color: Colors.deepOrangeAccent,
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15)),
                              ),
                              child: Text(
                                diff == 0 ? "আজ শেষ" : "বাকি ${_toBN(diff.toString())} দিন",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.only(top: 2, left: 10, right: 10, bottom: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center, // সবকিছু মাঝখানে থাকবে
                            children: [
                              // লোগো সেকশন
                              Container(
                                height: 72, width: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4, spreadRadius: 1,
                                    )
                                  ],
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: ClipOval(child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: _buildImg(job.logo),
                                )),
                              ),

                              const SizedBox(height: 4), // লোগোর নিচের গ্যাপ কমানো হয়েছে

                              // টাইটেল সেকশন - ২ বা ৩ লাইন পর্যন্ত জায়গা নিবে
                              Flexible(
                                child: Text(
                                  job.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 3, // ৩ লাইন পর্যন্ত দেখাবে
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15.0,
                                    color: titleTextColor,
                                    height: 1.1,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 4), // টাইটেল ও ডেট সেকশনের গ্যাপ কমানো হয়েছে

                              // ডেট সেকশন
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: dateBgColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _dateInfo("শুরু: ${_fmtBN(job.start)}", Icons.calendar_today, dateTextColor),
                                    _dateInfo("শেষ: ${_fmtBN(job.deadline)}", Icons.timer_outlined, dateTextColor),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _dateInfo(String text, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.red),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
              color: Colors.red,
              fontSize: 11.5,
              fontWeight: FontWeight.bold
          ),
        ),
      ],
    );
  }
}
