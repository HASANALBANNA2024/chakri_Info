import 'dart:convert';
import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chakri_info/services/share_service.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailsScreen extends StatelessWidget {
  final JobSyncModel job;

  const JobDetailsScreen({super.key, required this.job});

  // --- NEW: Static entry point for Notification ---
  // This helps to open the screen directly using jobId from Hive
  static Widget fromNotification(String jobId) {
    final box = Hive.box<JobSyncModel>('jobsBox');
    final jobData = box.get(jobId);

    if (jobData == null) {
      return const Scaffold(
        body: Center(child: Text("Circular data not found locally.")),
      );
    }
    return JobDetailsScreen(job: jobData);
  }

  // --- সিঙ্গেল ইমেজ ডাউনলোড ---
  Future<void> _downloadImage(
      String imgStr,
      BuildContext context,
      int index,
      ) async {
    if (imgStr.isEmpty) return;
    try {
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) await Gal.requestAccess();

      String cleanStr = imgStr.trim();
      if (cleanStr.contains(',')) {
        cleanStr = cleanStr.split(',').last;
      }

      Uint8List bytes = base64Decode(cleanStr);

      await Gal.putImageBytes(
        bytes,
        name: "Job_Page_${index + 1}_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("ইমেজ-${index + 1} গ্যালারিতে সেভ হয়েছে!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ডাউনলোড ব্যর্থ হয়েছে!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- সব ইমেজ একসাথে ডাউনলোড ---
  Future<void> _downloadAllImages(
      List<String> images,
      BuildContext context,
      ) async {
    try {
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) await Gal.requestAccess();

      for (int i = 0; i < images.length; i++) {
        String cleanStr = images[i].trim();
        if (cleanStr.contains(',')) cleanStr = cleanStr.split(',').last;

        Uint8List bytes = base64Decode(cleanStr);
        await Gal.putImageBytes(
          bytes,
          name: "Job_Full_${i + 1}_${DateTime.now().millisecondsSinceEpoch}",
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("সবগুলো ইমেজ সেভ হয়েছে!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ডাউনলোড ব্যর্থ হয়েছে!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color subTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final Color borderColor = isDarkMode
        ? Colors.white10
        : Colors.grey.shade300;

    final Color companyColor = isDarkMode
        ? Colors.amber.shade400
        : const Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "নিয়োগ বিজ্ঞপ্তি",
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: Hive.box<JobSyncModel>('bookmarkBox').listenable(),
            builder: (context, Box<JobSyncModel> box, _) {
              final isSaved = box.containsKey(job.id);

              return IconButton(
                onPressed: () {
                  if (isSaved) {
                    box.delete(job.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("বুকমার্ক থেকে সরানো হয়েছে"), duration: Duration(seconds: 1)),
                    );
                  } else {
                    box.put(job.id, job);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("বুকমার্ক করা হয়েছে"), duration: Duration(seconds: 1)),
                    );
                  }
                },
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border_outlined,
                  color: isSaved ? Colors.amber : null,
                ),
              );
            },
          ),
          IconButton(
            onPressed: () async {
              await ShareService.shareJob(
                title: job.title,
                company: job.company,
                applyLink: job.applyLink,
                images: job.circularImage,
                description: job.description,
              );
            },
            icon: const Icon(Icons.share_outlined),
            tooltip: 'শেয়ার করুন',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: borderColor, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: textColor,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            if (job.company.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  job.company,
                  style: TextStyle(
                    fontSize: 17,
                    color: companyColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

            const SizedBox(height: 15),
            Divider(color: borderColor),
            const SizedBox(height: 15),

            Row(
              children: [
                if (job.start.isNotEmpty)
                  _buildDateInfo(
                    "আবেদন শুরু:",
                    job.start,
                    Icons.calendar_month,
                    isDarkMode,
                  ),
                const SizedBox(width: 35),
                if (job.deadline.isNotEmpty)
                  _buildDateInfo(
                    "শেষ তারিখ:",
                    job.deadline,
                    Icons.alarm,
                    isDarkMode,
                  ),
              ],
            ),

            const SizedBox(height: 25),

            if (job.description.trim().isNotEmpty) ...[
              const Text(
                "বিস্তারিত বিবরণ:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                job.description,
                style: TextStyle(
                  fontSize: 14,
                  color: subTextColor,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 25),
            ],

            if (job.applyLink.isNotEmpty) ...[
              const Text(
                "আবেদন লিংক:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () async {
                  final uri = Uri.parse(job.applyLink);
                  if (await canLaunchUrl(uri))
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                child: Text(
                  job.applyLink,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],

            if (job.circularImage.isNotEmpty) ...[
              const Text(
                "অফিসিয়াল সার্কুলার কপি (জুম করতে ডাবল ট্যাপ করুন):",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 12),

              Column(
                children: List.generate(job.circularImage.length, (index) {
                  String currentImg = job.circularImage[index];
                  String cleanBase64 = currentImg.contains(',')
                      ? currentImg.split(',').last
                      : currentImg;

                  return Column(
                    children: [
                      GestureDetector(
                        onLongPress: () =>
                            _downloadImage(currentImg, context, index),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor, width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: InteractiveViewer(
                              minScale: 1.0,
                              maxScale: 5.0,
                              child: Image.memory(
                                base64Decode(cleanBase64.trim()),
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                                errorBuilder: (context, error, stackTrace) =>
                                const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            _downloadImage(currentImg, context, index),
                        icon: const Icon(Icons.download, size: 16),
                        label: Text("Download Circular Image:-${index + 1}"),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }),
              ),

              if (job.circularImage.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _downloadAllImages(job.circularImage, context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.cloud_download),
                      label: const Text(
                        "All Circular Image Download",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 100),
          ],
        ),
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
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo(
      String label,
      String value,
      IconData icon,
      bool isDark,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isDark ? Colors.amber.shade400 : Colors.blue.shade800,
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}