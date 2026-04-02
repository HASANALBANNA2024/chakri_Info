import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';

class JobCardWidget extends StatelessWidget {
  final JobSyncModel job;
  const JobCardWidget({super.key, required this.job});

  Widget _buildImage(String imageStr, {bool isCircle = false}) {
    if (imageStr.isEmpty) return const Icon(Icons.image, color: Colors.grey);
    try {
      Uint8List bytes = imageStr.startsWith('http') ? Uint8List(0) : base64Decode(imageStr);

      return imageStr.startsWith('http')
          ? Image.network(imageStr, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image))
          : Image.memory(bytes, fit: BoxFit.cover);
    } catch (e) {
      return const Icon(Icons.image_not_supported);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Stack(
        children: [
          // Govt/Non-Govt Badge
          Positioned(
            top: 0, left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: job.isGovt ? Colors.blue.shade800 : Colors.blueGrey.shade500,
                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(10)),
              ),
              child: Text(
                job.isGovt ? "GOVT" : "PRIVATE",
                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 22, 12, 12),
            child: Row(
              children: [
                // লোগো
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
                  child: ClipOval(child: _buildImage(job.logo)),
                ),
                const SizedBox(width: 12),
                // তথ্য
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(job.company, style: TextStyle(fontSize: 11, color: Colors.blue.shade700)),
                      const SizedBox(height: 5),
                      Text("Deadline: ${job.deadline}", style: const TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // সার্কুলার ইমেজের ছোট প্রিভিউ
                if (job.circularImage.isNotEmpty)
                  Container(
                    width: 45, height: 55,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.grey.shade300)),
                    child: ClipRRect(borderRadius: BorderRadius.circular(4), child: _buildImage(job.circularImage)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}