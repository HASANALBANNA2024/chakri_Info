import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/job_model.dart';

class JobDetailsScreen extends StatefulWidget {
  final JobModel job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  Future<void> _downloadImage(String assetPath) async {
    if (assetPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ইমেজের পাথ পাওয়া যায়নি!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/job_circular_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(bytes);

      await Gal.putImage(file.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("সফলভাবে গ্যালারিতে সেভ হয়েছে!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ডাউনলোড ব্যর্থ হয়েছে!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // share option
  void _shareJob() {
    final String text =
        'জব সার্কুলার: ${widget.job.title}\nকোম্পানি: ${widget.job.company}\nবিস্তারিত দেখুন "চাকরি ইনফো" অ্যাপে।';
    Share.share(text, subject: widget.job.title);
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint("URL Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("লিঙ্কটি ওপেন করা সম্ভব হচ্ছে না")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = Colors.indigo[900]!;
    Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          widget.job.category,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bookmark_border_rounded,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // কোম্পানি প্রোফাইল
                Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: widget.job.logo.startsWith('http')
                            ? Image.network(widget.job.logo, fit: BoxFit.cover)
                            : Image.asset(
                                'assets/images/placeholder_logo.png', // এখানে লোগো পাথ দিন
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.business, color: primaryColor),
                              ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.job.company,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.job.location,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  widget.job.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : primaryColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 25),
                _buildQuickFacts(isDarkMode, primaryColor),
                const SizedBox(height: 30),

                Row(
                  children: [
                    Icon(Icons.image_outlined, size: 18, color: primaryColor),
                    const SizedBox(width: 8),
                    const Text(
                      "নিয়োগ বিজ্ঞপ্তি",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "(জুম করে দেখুন)",
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[900] : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: InteractiveViewer(
                            clipBehavior: Clip.none,
                            panEnabled: true,
                            minScale: 1.0,
                            maxScale: 5.0,

                            child: widget.job.imagePath.startsWith('http')
                                ? Image.network(
                                    widget.job.imagePath,
                                    fit: BoxFit.fitWidth,
                                    loadingBuilder:
                                        (context, child, progress) =>
                                            progress == null
                                            ? child
                                            : const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 100,
                                            ),
                                  )
                                : Image.asset(
                                    widget.job.imagePath.isEmpty
                                        ? 'assets/images/bpsc_image.webp'
                                        : widget.job.imagePath,
                                    fit: BoxFit.fitWidth,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 100,
                                            ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      InkWell(
                        onTap: () => _downloadImage(widget.job.imagePath),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.file_download_outlined,
                                color: Colors.blue,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "বিজ্ঞপ্তিটি ডাউনলোড করুন",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl('https://www.google.com'),
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    "আবেদন",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _shareJob,
                  icon: Icon(
                    Icons.share_outlined,
                    color: isDarkMode ? Colors.white : Colors.black87,
                    size: 18,
                  ),
                  label: Text(
                    "শেয়ার",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? Colors.white10
                        : Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFacts(bool isDarkMode, Color primaryColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double itemWidth = (constraints.maxWidth - 15) / 2;
        return Wrap(
          spacing: 15,
          runSpacing: 15,
          children: [
            _buildFactItem(
              itemWidth,
              Icons.monetization_on_outlined,
              "বেতন",
              widget.job.salary,
              primaryColor,
              isDarkMode,
            ),
            _buildFactItem(
              itemWidth,
              Icons.cases_outlined,
              "কাজের ধরণ",
              "ফুল-টাইম",
              primaryColor,
              isDarkMode,
            ),
            _buildFactItem(
              itemWidth,
              Icons.history_edu_outlined,
              "অভিজ্ঞতা",
              "১-২ বছর",
              primaryColor,
              isDarkMode,
            ),
            _buildFactItem(
              itemWidth,
              Icons.alarm_on_rounded,
              "ডেডলাইন",
              widget.job.deadline,
              Colors.redAccent,
              isDarkMode,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFactItem(
    double width,
    IconData icon,
    String label,
    String value,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
