import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareJob({
    required String title,
    required String company,
    required String applyLink,
    required List<String> images,
    required String description,
  }) async {
    try {
      List<XFile> filesToShare = [];
      final tempDir = await getTemporaryDirectory();

      // লুপ চালিয়ে সবগুলো ইমেজ প্রসেস করা হচ্ছে
      for (int i = 0; i < images.length; i++) {
        String rawBase64 = images[i];

        // Base64 ডাটা ক্লিনিং (যদি কমা থাকে)
        if (rawBase64.contains(',')) {
          rawBase64 = rawBase64.split(',').last;
        }

        try {
          Uint8List bytes = base64Decode(rawBase64.trim());

          // প্রতিটি ইমেজের জন্য আলাদা ইউনিক ফাইল তৈরি
          final file = await File(
            '${tempDir.path}/circular_page_${DateTime.now().millisecondsSinceEpoch}_$i.png',
          ).create();

          await file.writeAsBytes(bytes);
          filesToShare.add(XFile(file.path));
        } catch (e) {
          debugPrint("ইমেজ-$i প্রসেস করতে সমস্যা হয়েছে: $e");
          continue; // কোনো ইমেজ এরর দিলে সেটি স্কিপ করে পরেরটা নিবে
        }
      }

      // শেয়ার মেসেজ ফরম্যাট
      final String message =
          '''
📢 নতুন নিয়োগ বিজ্ঞপ্তি!

💼 পদের নাম: $title
🏢 প্রতিষ্ঠান: $company

📝 বিস্তারিত বিবরণ:
$description

🔗 আবেদন লিংক:
$applyLink

📱 প্রতিদিনের সব চাকরির খবর পেতে আমাদের অ্যাপটি ডাউনলোড করুন।
''';

      if (filesToShare.isNotEmpty) {
        // সবগুলো ফাইল এবং টেক্সট একসাথে শেয়ার
        await Share.shareXFiles(filesToShare, text: message);
      } else {
        // যদি কোনো ইমেজ না থাকে তবে শুধু টেক্সট শেয়ার
        await Share.share(message);
      }
    } catch (e) {
      debugPrint("Share Error: $e");
    }
  }
}
