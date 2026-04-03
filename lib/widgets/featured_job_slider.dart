import 'dart:async';
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:chakri_info/user_side_data_sync/job_details_screen.dart';

// offset paper art painter
class AlphabetPainter extends CustomPainter {
  final Color color;
  AlphabetPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random();
    const textStyle = TextStyle(
      fontSize: 22, // ১. বর্ণমালা বড় করা হয়েছে
      fontWeight: FontWeight.w900, // আরও স্পষ্ট করা হয়েছে
      fontFamily: 'serif',
    );

    final alphabets = ['অ', 'আ', 'ই', 'ঈ', 'উ', 'ঋ', 'এ', 'ঐ', 'ও', 'ঔ', 'ক', 'খ', 'গ', 'ঘ', 'ঙ', 'চ', 'ছ', 'জ', 'ঝ', 'ঞ', 'ট', 'ঠ', 'ড', 'ঢ', 'ণ'];

    for (int i = 0; i < 30; i++) { // কতগুলো বর্ণ থাকবে তা এখানে নিয়ন্ত্রণ করুন
      final char = alphabets[random.nextInt(alphabets.length)];
      final textPainter = TextPainter(
        text: TextSpan(text: char, style: textStyle.copyWith(color: color)),
        textDirection: TextDirection.ltr,
      )..layout();

      // ২. এলোমেলো পজিশন (Random Position)
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;

      // ৩. বাঁকা-তেরা করার লজিক (Rotation)
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(random.nextDouble() * 0.5); // হালকা বাঁকা হবে (০.৫ রেডিয়ান)

      textPainter.paint(canvas, const Offset(0, 0));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

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
    _pageController = PageController(viewportFraction: 0.85);
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
    if (s.isEmpty) return const Icon(Icons.business, size: 35, color: Colors.grey);
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

    // offset paper logic
    // light and dark mode background
    final cardBgColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFF9F0);
    final titleTextColor = isDark ? Colors.white : const Color(0xFF2D2D2D);
    final alphabetAlpha = isDark ? 0.15 : 0.25; // ডার্ক মোডে আরও আবছা
    final alphabetColor = (isDark ? Colors.white : const Color(0xFF8B7355)).withOpacity(alphabetAlpha);

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
          height: 175,
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
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white10 : const Color(0xFFE8DFD0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                        blurRadius: 8, offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // background bornomala art
                        Positioned.fill(
                          child: CustomPaint(
                            painter: AlphabetPainter(color: alphabetColor),
                          ),
                        ),

                        if (isUrgent)
                          Positioned(
                            top: 0, right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12)),
                              ),
                              child: Text(
                                diff == 0 ? "আজ শেষ" : "বাকি ${_toBN(diff.toString())} দিন",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9),
                              ),
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // logo
                              Container(
                                height: 65, width: 65,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                  border: Border.all(color: isDark ? Colors.grey[800]! : Colors.white, width: 2),
                                ),
                                child: ClipOval(child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: _buildImg(job.logo),
                                )),
                              ),

                              const SizedBox(height: 6),

                              // টাইটেল
                              Flexible(
                                child: Text(
                                  job.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14.5,
                                    color: titleTextColor,
                                    height: 1.1,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Date Section
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _dateInfo("শুরু: ${_fmtBN(job.start)}", Icons.calendar_today, isDark),
                                    _dateInfo("শেষ: ${_fmtBN(job.deadline)}", Icons.timer_outlined, isDark),
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

  Widget _dateInfo(String text, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 11, color: Colors.redAccent),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 12.0,
              fontWeight: FontWeight.bold
          ),
        ),
      ],
    );
  }
}