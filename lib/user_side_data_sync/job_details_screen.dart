import 'dart:convert';
import 'dart:typed_data';

import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailsScreen extends StatelessWidget {
  final JobSyncModel job;

  const JobDetailsScreen({super.key, required this.job});

  // Check if the application deadline has passed (Format: DD-MM-YYYY)
  bool _isDeadlineOver(String deadlineStr) {
    try {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);

      // Split string by hyphen to get day, month, and year
      List<String> parts = deadlineStr.split('-');
      DateTime expiryDate = DateTime(
        int.parse(parts[2]), // Year
        int.parse(parts[1]), // Month
        int.parse(parts[0]), // Day
      );

      return today.isAfter(expiryDate);
    } catch (e) {
      return false; // Fallback to active if parsing fails
    }
  }

  // Save image to local storage
  Future<void> _downloadImage(
    String imageStr,
    BuildContext context,
    int index,
  ) async {
    try {
      // ১. গ্যালারিতে সেভ করার পারমিশন চেক করা
      // Gal এর নিজস্ব এক্সেস চেক মেথড আছে
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      Uint8List bytes;

      // ২. Base64 কনভার্ট এবং ক্লিনিং
      if (imageStr.contains(',')) {
        imageStr = imageStr.split(',').last;
      }

      // ৩. স্ট্রিং থেকে বাইট তৈরি করা
      if (!imageStr.startsWith('http')) {
        bytes = base64Decode(imageStr.trim());
      } else {
        // URL ডাউনলোডের জন্য আলাদা লজিক প্রয়োজন
        return;
      }

      // ৪. সরাসরি গ্যালারিতে সেভ করা
      // Gal.putImageBytes সব ম্যানেজ করবে (পাথ বা মিডিয়া স্ক্যান)
      await Gal.putImageBytes(
        bytes,
        name: "Circular_${DateTime.now().millisecondsSinceEpoch}_$index",
      );

      // ৫. সাকসেস মেসেজ (বাংলায়)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("সাকসেস! ইমেজটি গ্যালারিতে সেভ করা হয়েছে।"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("Download Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ডাউনলোড ব্যর্থ হয়েছে! দয়া করে আবার চেষ্টা করুন।"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Image widget builder handling both Base64 and URL
  Widget _buildImage(String imageStr, {BoxFit fit = BoxFit.contain}) {
    if (imageStr.isEmpty) {
      return const Icon(
        Icons.image_not_supported,
        size: 100,
        color: Colors.grey,
      );
    }
    try {
      if (!imageStr.startsWith('http')) {
        Uint8List bytes = base64Decode(imageStr);
        return Image.memory(bytes, fit: fit);
      }
      return Image.network(
        imageStr,
        fit: fit,
        errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 100),
      );
    } catch (e) {
      return const Icon(Icons.error);
    }
  }

  // Open external browser for application link
  Future<void> _launchURL(String url, BuildContext context) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open the link")));
    }
  }

  // Show alert if the user tries to apply after the deadline
  void _showExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 10),
            Text("সময় শেষ!", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("এই সার্কুলারটির আবেদনের সময়সীমা শেষ হয়ে গেছে।"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("বুঝেছি"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isExpired = _isDeadlineOver(job.deadline);

    // Split images if multiple strings are stored as comma-separated
    List<String> images = job.circularImage.split(',');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Circular Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Company Logo and Title
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade900,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ClipOval(child: _buildImage(job.logo)),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          job.company,
                          style: TextStyle(
                            color: Colors.blue.shade100,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Date Information Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoCard(
                    "শুরুর তারিখ",
                    job.start,
                    Icons.calendar_month,
                    Colors.green,
                    context,
                  ),
                  _infoCard(
                    "শেষ তারিখ",
                    job.deadline,
                    Icons.timer,
                    Colors.red,
                    context,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Official Circular Images:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            // Scrollable Image List to avoid Overflow
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: images.length,
              itemBuilder: (context, index) {
                String imgPath = images[index].trim();
                if (imgPath.isEmpty) return const SizedBox();

                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 5.0,
                          child: _buildImage(imgPath),
                        ),
                      ),
                    ),
                    // Download Button per image
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: TextButton.icon(
                        onPressed: () =>
                            _downloadImage(imgPath, context, index),
                        icon: const Icon(
                          Icons.file_download_outlined,
                          color: Colors.blue,
                        ),
                        label: const Text(
                          "Download Image",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 120), // Bottom padding for FAB/Sheet
          ],
        ),
      ),

      // Fixed Bottom Action Button
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () => isExpired
              ? _showExpiredDialog(context)
              : _launchURL(job.applyLink, context),
          style: ElevatedButton.styleFrom(
            backgroundColor: isExpired
                ? Colors.red.shade700
                : Colors.blue.shade900,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isExpired ? Icons.event_busy : Icons.send_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text(
                isExpired ? "Deadline Expired" : "Apply Now / Details Link",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Small reusable card for Start/Deadline dates
  Widget _infoCard(
    String title,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Container(
      width: (MediaQuery.of(context).size.width / 2) - 30,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
