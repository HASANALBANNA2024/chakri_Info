import 'dart:convert';
import 'dart:typed_data';
import 'package:chakri_info/user_side_data_sync/job_details_screen.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:flutter/material.dart';

class JobCardWidget extends StatelessWidget {
  final JobSyncModel job;
  const JobCardWidget({super.key, required this.job});

  // Optimized Image Builder with better error handling
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
              // --- Ultra Modern Badge Design ---
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                          child: Icon(
                            job.isGovt ? Icons.account_balance : Icons.bolt,
                            color: Colors.white,
                            size: 9,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          job.isGovt ? "GOVERNMENT" : "PRIVATE",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              Padding(
                padding: EdgeInsets.fromLTRB(14, isJobCircular ? 38 : 16, 12, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Organization Logo with Modern Ring ---
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.blue.shade50, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.05),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipOval(child: _buildImage(job.logo)),
                    ),

                    const SizedBox(width: 14),

                    // --- Information Section ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title: No Line Limit, Dynamic Wrapping
                          Text(
                            job.title,
                            softWrap: true,
                            style: const TextStyle(
                              height: 1.25,
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5, // Refined size for better look
                              color: Color(0xFF232631),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.company,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          // --- Minimalist Date Badges ---
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _dateBadge(
                                Icons.calendar_today_outlined,
                                "Start: ${job.start}",
                                Colors.green.shade800,
                                Colors.green.shade50.withOpacity(0.7),
                              ),
                              _dateBadge(
                                Icons.alarm_on_outlined,
                                "End: ${job.deadline}",
                                Colors.red.shade800,
                                Colors.red.shade50.withOpacity(0.7),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Right Chevron
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFE0E0E0), size: 14),
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

  // Stylish Compact Date Badge
  Widget _dateBadge(IconData icon, String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 9.5,
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}