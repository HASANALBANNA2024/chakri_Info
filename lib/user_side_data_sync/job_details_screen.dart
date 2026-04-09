import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';

class JobDetailsScreen extends StatelessWidget {
  final JobSyncModel job;

  const JobDetailsScreen({super.key, required this.job});

  Future<void> _downloadImage(String imgStr, BuildContext context, int index) async {
    if (imgStr.isEmpty) return;
    try {
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) await Gal.requestAccess();

      String cleanStr = imgStr.trim();
      if (cleanStr.contains(',')) cleanStr = cleanStr.split(',').last;
      Uint8List bytes = base64Decode(cleanStr);

      await Gal.putImageBytes(bytes, name: "Job_Circular_${DateTime.now().millisecondsSinceEpoch}_$index");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ইমেজ-${index + 1} সেভ হয়েছে!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ডাউনলোড ব্যর্থ হয়েছে!"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> images = job.circularImage.split(',').where((img) => img.trim().isNotEmpty).toList();
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color subTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final Color borderColor = isDarkMode ? Colors.white10 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
            "নিয়োগ বিজ্ঞপ্তি",
            style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, size: 20), onPressed: () {}),
          IconButton(icon: const Icon(Icons.bookmark_border_rounded, size: 22), onPressed: () {}),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: borderColor, height: 1.0),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), // প্যাডিং কিছুটা কমানো হয়েছে
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- টাইটেল (পুরোটা দেখাবে) ---
                  Text(
                    job.title,
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: textColor, height: 1.3),
                  ),
                  const SizedBox(height: 4), // টাইটেল ও কোম্পানির মাঝে গ্যাপ কমানো হয়েছে

                  // --- কোম্পানি নেম ---
                  if (job.company.isNotEmpty)
                    Text(
                      job.company,
                      style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade800,
                          fontWeight: FontWeight.bold
                      ),
                    ),

                  const SizedBox(height: 12), // কোম্পানির নিচে গ্যাপ কমানো হয়েছে
                  Divider(color: borderColor),
                  const SizedBox(height: 12), // ডিভাইডারের নিচে গ্যাপ কমানো হয়েছে

                  // --- তারিখ সেকশন ---
                  Row(
                    children: [
                      if (job.start.isNotEmpty)
                        _buildDateInfo("আবেদন শুরু:", job.start, Icons.calendar_month, isDarkMode),
                      if (job.start.isNotEmpty && job.deadline.isNotEmpty) const SizedBox(width: 35),
                      if (job.deadline.isNotEmpty)
                        _buildDateInfo("শেষ তারিখ:", job.deadline, Icons.alarm, isDarkMode),
                    ],
                  ),

                  const SizedBox(height: 15), // তারিখ ও ডেসক্রিপশনের মাঝে গ্যাপ অনেক কমানো হয়েছে

                  // --- বিবরণ (পুরোটা দেখাবে, কোনো ওভারফ্লো নেই) ---
                  if (job.description != null && job.description!.trim().isNotEmpty) ...[
                    Text("বিস্তারিত বিবরণ:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                    const SizedBox(height: 4), // হেডিং ও ডেসক্রিপশনের মাঝে গ্যাপ কমানো হয়েছে
                    Text(
                      job.description!,
                      style: TextStyle(fontSize: 14, color: subTextColor, height: 1.5),
                    ),
                    const SizedBox(height: 25),
                  ],

                  // --- আবেদন লিংক ---
                  if (job.applyLink.isNotEmpty) ...[
                    Text("আবেদন করার লিংক:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                    const SizedBox(height: 2),
                    InkWell(
                      onTap: () async {
                        final uri = Uri.parse(job.applyLink);
                        if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      child: Text(
                        job.applyLink,
                        style: const TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // --- সার্কুলার ইমেজ বক্স ---
                  if (images.isNotEmpty) ...[
                    Text("অফিসিয়াল সার্কুলার কপি:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 550,
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
                                border: Border.all(color: borderColor, width: 1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: InteractiveViewer(
                                  minScale: 1.0,
                                  maxScale: 5.0,
                                  child: Image.memory(
                                    base64Decode(images[index].trim().split(',').last),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _downloadImage(images[index], context, index),
                              child: Text(
                                "Download Page-${index + 1}",
                                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomSheet: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: const Center(
          child: Text(
              "AD BANNER HERE",
              style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo(String label, String value, IconData icon, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2), // তারিখের ভেতরের গ্যাপও কমানো হয়েছে
        Row(
          children: [
            Icon(icon, size: 16, color: isDark ? Colors.white70 : Colors.black54),
            const SizedBox(width: 6),
            Text(
                value,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)
            ),
          ],
        ),
      ],
    );
  }
}