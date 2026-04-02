import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';

class JobCardWidget extends StatelessWidget {
  final JobSyncModel job;
  const JobCardWidget({super.key, required this.job});

  Widget _buildImage(String imageStr) {
    if (imageStr.isEmpty) return const Icon(Icons.business, color: Colors.grey);
    try {
      if (!imageStr.startsWith('http')) {
        Uint8List bytes = base64Decode(imageStr);
        return Image.memory(bytes, fit: BoxFit.cover);
      }
      return Image.network(imageStr, fit: BoxFit.cover,
          errorBuilder: (c, e, s) => const Icon(Icons.broken_image));
    } catch (e) {
      return const Icon(Icons.image_not_supported);
    }
  }

  @override
  Widget build(BuildContext context) {
    // logic only job circular show the badge ok
    bool isJobCircular = job.step1.trim() == "Job Circular";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // --- Smart Badge only Job circular ar jonno ---
            if (isJobCircular)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: job.isGovt
                          ? [const Color(0xFF0D47A1), const Color(0xFF1976D2)]
                          : [const Color(0xFF455A64), const Color(0xFF78909C)],
                    ),
                    borderRadius: const BorderRadius.only(bottomRight: Radius.circular(15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        job.isGovt ? Icons.account_balance_rounded : Icons.work_rounded,
                        color: Colors.white,
                        size: 11,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        job.isGovt ? "GOVERNMENT" : "PRIVATE",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.fromLTRB(14, isJobCircular ? 34 : 18, 14, 18),
              child: Row(
                children: [
                  // --- Organization Logo---
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ],
                      border: Border.all(color: Colors.blue.withOpacity(0.05), width: 1.5),
                    ),
                    child: ClipOval(child: _buildImage(job.logo)),
                  ),

                  const SizedBox(width: 16),

                  // --- Information Section---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Color(0xFF2D3142),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          job.company,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        // ---Date Section---
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _dateBadge(
                                Icons.calendar_today_rounded,
                                "Start: ${job.start}",
                                Colors.green.shade700,
                                Colors.green.shade50
                            ),
                            const SizedBox(width: 10),
                            _dateBadge(
                                Icons.timer_rounded,
                                "End: ${job.deadline}",
                                Colors.red.shade700,
                                Colors.red.shade50
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Data badge Widget
  Widget _dateBadge(IconData icon, String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 9,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}