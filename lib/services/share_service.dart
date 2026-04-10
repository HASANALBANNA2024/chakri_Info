import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareJob(BuildContext context, dynamic job) async {
    // স্ক্রিনে প্রসেসিং মেসেজ দেখানো
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("শেয়ার করার জন্য প্রস্তুত হচ্ছে..."),
        duration: Duration(seconds: 2),
      ),
    );

    List<XFile> imageFiles = [];

    // ১. আপনার দেওয়া সরাসরি প্রপার্টি অনুযায়ী টেক্সট মেসেজ তৈরি
    final String shareText =
        '''
🔥 ${job.title ?? ''}

📝 বিস্তারিত: ${job.description ?? ''}
📅 আবেদনের শেষ তারিখ: ${job.deadline ?? ''}

📲 আরও বিস্তারিত জানতে অ্যাপটি ডাউনলোড করুন:
🔗 https://play.google.com/store/apps/details?id=your.package.name
''';

    try {
      // ২. ইমেজ ইউআরএল হ্যান্ডেল করা (সিঙ্গেল বা লিস্ট যাই হোক)
      List<String> imageUrls = [];
      if (job.circularImage is List) {
        imageUrls = List<String>.from(job.circularImage);
      } else if (job.circularImage != null &&
          job.circularImage.toString().isNotEmpty) {
        imageUrls = [job.circularImage.toString()];
      }

      // ৩. ইমেজ ডাউনলোড প্রসেস (টাইমআউট ৫ সেকেন্ড)
      if (imageUrls.isNotEmpty) {
        final temp = await getTemporaryDirectory();

        for (int i = 0; i < imageUrls.length; i++) {
          try {
            String url = imageUrls[i].trim();
            if (url.startsWith('http')) {
              final response = await http
                  .get(Uri.parse(url))
                  .timeout(const Duration(seconds: 5));

              if (response.statusCode == 200) {
                final String fileName =
                    'job_share_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
                final File file = File('${temp.path}/$fileName');
                await file.writeAsBytes(response.bodyBytes);
                imageFiles.add(XFile(file.path));
              }
            }
          } catch (e) {
            debugPrint("ইমেজ ডাউনলোড হয়নি ($i): $e");
          }
        }
      }

      // ৪. শেয়ার কমান্ড এক্সিকিউট করা
      if (imageFiles.isNotEmpty) {
        // ইমেজসহ শেয়ার
        await Share.shareXFiles(imageFiles, text: shareText);
      } else {
        // কোনো কারণে ইমেজ না পেলে শুধু টেক্সট শেয়ার হবে
        await Share.share(shareText);
      }
    } catch (e) {
      debugPrint("পুরো শেয়ার প্রসেসে ত্রুটি: $e");
      // একদম শেষে সেফটি হিসেবে শুধু টেক্সট শেয়ার করার চেষ্টা
      await Share.share(shareText);
    }
  }
}
