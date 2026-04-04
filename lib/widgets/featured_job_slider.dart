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
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: 'serif',

    );

    final alphabets = [
      // --- সব বাংলা বর্ণ (স্বরবর্ণ) ---
      'অ', 'আ', 'ই', 'ঈ', 'উ', 'ঊ', 'ঋ', 'এ', 'ঐ', 'ও', 'ঔ',

      // --- সব বাংলা বর্ণ (ব্যঞ্জনবর্ণ) ---
      'ক', 'খ', 'গ', 'ঘ', 'ঙ', 'চ', 'ছ', 'জ', 'ঝ', 'ঞ',
      'ট', 'ঠ', 'ড', 'ঢ', 'ণ', 'ত', 'থ', 'দ', 'ধ', 'ন',
      'প', 'ফ', 'ব', 'ভ', 'ম', 'য', 'র', 'ল', 'শ', 'ষ',
      'স', 'হ', 'ড়', 'ঢ়', 'য়', 'ৎ', 'ঃ', 'ং', 'ঁ',

      // --- জাতীয় সংগীতের শব্দ ও বাক্য ---
      'আমার সোনার বাংলা',
      'আমি তোমায় ভালোবাসি',
      'চিরদিন তোমার আকাশ',
      'তোমার বাতাস',
      'আমার প্রাণে বাজায় বাঁশি',
      'সোনার বাংলা',
      'মা',
      'অমলিন',
      'সুধা',
      'মা তোর বদনখানি',
      'নয়নজলে ভাসি',
    ];
    for (int i = 0; i < 18; i++) {
      final char = alphabets[random.nextInt(alphabets.length)];
      final textPainter = TextPainter(
        text: TextSpan(text: char, style: textStyle.copyWith(color: color)),
        textDirection: TextDirection.ltr,
      )..layout();

      // Random position
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;

      // design background rotation logic
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(random.nextDouble() * 0.2);

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
    _pageController = PageController(viewportFraction: 0.97);
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
          : Image.memory(base64Decode(s), fit: BoxFit.cover);
    } catch (e) { return const Icon(Icons.error_outline); }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    //card main background
    // Light Mode blue shade
    final cardBgColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC);

    // ২. title text color
    final titleTextColor = isDark ? Colors.white : const Color(0xFF1E293B);

    // alphabet color
    final alphabetAlpha = isDark ? 0.25 : 0.20;

// alphabet color
    final alphabetColor = (isDark
        ? Colors.white.withOpacity(alphabetAlpha)
        : const Color(0xFF475569).withOpacity(alphabetAlpha));

    // border color
    final borderColor = isDark ? Colors.white10 : Colors.blue.withOpacity(0.1);
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
          height: 142,
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
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // logo
                              Container(
                                height: 55, width: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                  border: Border.all(color: isDark ? Colors.grey[800]! : Colors.white, width: 2),
                                ),
                                child: SizedBox.expand(
                                  child: ClipOval(
                                    child: _buildImg(
                                      job.logo,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 4),

                              // টাইটেল
                              Flexible(
                                child: Text(
                                  job.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12.5,
                                    color: titleTextColor,
                                    height: 1.1,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 4),

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
              fontSize: 10.0,
              fontWeight: FontWeight.bold
          ),
        ),
      ],
    );
  }
}