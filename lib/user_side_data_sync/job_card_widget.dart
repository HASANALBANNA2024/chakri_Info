import 'dart:convert';
import 'dart:typed_data';
import 'package:chakri_info/user_side_data_sync/job_details_screen.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:flutter/material.dart';

class JobCardWidget extends StatelessWidget {
  final JobSyncModel job;
  const JobCardWidget({super.key, required this.job});

  Widget _buildImage(String imageStr) {
    if (imageStr.isEmpty) return Icon(Icons.business_rounded, color: Colors.blue.shade200, size: 28);
    try {
      if (!imageStr.startsWith('http')) {
        Uint8List bytes = base64Decode(imageStr);
        return Image.memory(bytes, fit: BoxFit.cover);
      }
      return Image.network(
        imageStr,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => const Icon(Icons.broken_image_rounded, color: Colors.redAccent, size: 20),
      );
    } catch (e) {
      return const Icon(Icons.image_not_supported_rounded, color: Colors.grey, size: 20);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isJobCircular = job.step1.trim() == "Job Circular";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JobDetailsScreen(job: job)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.08)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              if (isJobCircular)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: job.isGovt
                            ? [const Color(0xFF004E92), const Color(0xFF000428)]
                            : [const Color(0xFF434343), const Color(0xFF000000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(job.isGovt ? Icons.account_balance : Icons.bolt, color: Colors.white, size: 9),
                        const SizedBox(width: 6),
                        Text(
                          job.isGovt ? "GOVERNMENT" : "PRIVATE",
                          style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                        ),
                      ],
                    ),
                  ),
                ),

              Padding(
                padding: EdgeInsets.fromLTRB(14, isJobCircular ? 32 : 10, 12, 8),
                child: Column(
                  children: [
                    // --- Row 1: Logo + Title/Company + Chevron ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.blue.shade50, width: 2),
                          ),
                          child: ClipOval(child: _buildImage(job.logo)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(height: 1.2, fontWeight: FontWeight.w800, fontSize: 14.5, color: Color(0xFF232631)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                job.company,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFE0E0E0), size: 14),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // --- Row 2: Date Badges (Start & End) ---
                    Row(
                      children: [
                        Expanded(
                          child: _dateBadge(
                            Icons.calendar_today_outlined,
                            "Start: ${job.start}",
                            Colors.green.shade800,
                            Colors.green.shade50.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _dateBadge(
                            Icons.alarm_on_outlined,
                            "End: ${job.deadline}",
                            Colors.red.shade800,
                            Colors.red.shade50.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateBadge(IconData icon, String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 9.5, color: textColor, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}