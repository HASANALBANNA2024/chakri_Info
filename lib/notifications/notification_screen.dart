import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart'; // অ্যাডমোব থাকলে এটি আনকমেন্ট করবেন

import 'notification_model.dart';
import 'notification_settings_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: "Clear All",
            onPressed: () => _showDeleteDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: "Settings",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<NotificationModel>('notifications').listenable(),
        builder: (context, Box<NotificationModel> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                "No notifications yet!",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final notifications = box.values.toList().reversed.toList();

          return ListView.builder(
            // ৫টি পর পর ১টি অ্যাড এর জন্য itemCount বাড়ানো হয়েছে
            itemCount: notifications.length + (notifications.length ~/ 5),
            itemBuilder: (context, index) {
              // প্রতি ৫টি কার্ডের পর (অর্থাৎ ৬ নাম্বার পজিশনে) অ্যাড দেখাবে
              if (index != 0 && (index + 1) % 6 == 0) {
                return _buildBannerAd(); // অ্যাড উইজেট
              }

              // আসল ইনডেক্স বের করা (অ্যাড বাদ দিয়ে)
              final actualIndex = index - (index ~/ 6);
              final item = notifications[actualIndex];

              return Card(
                elevation: 0,
                color: item.isRead ? null : Colors.indigo.withOpacity(0.08),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: _getDynamicCategoryColor(item.category),
                    child: const Icon(Icons.notifications_active_outlined, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('dd MMM, hh:mm a').format(item.dateTime),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () {
                    item.isRead = true;
                    item.save();
                    // আপনার জব ডিটেইলস নেভিগেশন লজিক এখানে থাকবে
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- অ্যাড ব্যানার উইজেট ---
  Widget _buildBannerAd() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      height: 60, // স্ট্যান্ডার্ড ব্যানার সাইজ
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "Ad Banner Placeholder", // এখানে Admob এর AdWidget বসবে
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  Color _getDynamicCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'government': return Colors.orange[900]!;
      case 'bank': return Colors.blue[800]!;
      case 'defense': return Colors.redAccent;
      case 'medical': return Colors.teal;
      case 'bcs': return Colors.amber[800]!;
      case 'teacher': return Colors.green[700]!;
      case 'ngo': return Colors.indigo;
      case 'admission': return Colors.indigo[900]!;
      case 'question': return Colors.brown;
      case 'result': return Colors.cyan[800]!;
      default: return Colors.indigo;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear All?"),
        content: const Text("সব নোটিফিকেশন ডিলিট করতে চান?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () {
              Hive.box<NotificationModel>('notifications').clear();
              Navigator.pop(context);
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}