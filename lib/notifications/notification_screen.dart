import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'notification_model.dart';
import 'notification_settings_screen.dart'; // আপনার সেটিংস স্ক্রিনটি ইমপোর্ট করুন

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          // all delete icon
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: "Clear All",
            onPressed: () => _showDeleteDialog(context),
          ),
          // settings button
          IconButton(
            icon: const Icon(Icons.tune_rounded), // modern filter icon
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
        valueListenable: Hive.box<NotificationModel>(
          'notifications',
        ).listenable(),
        builder: (context, Box<NotificationModel> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                "No notifications yet!",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          // তারিখ অনুযায়ী নতুনগুলো উপরে রাখা
          final notifications = box.values.toList().reversed.toList();

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];

              return Card(
                elevation: 0,
                color: item.isRead ? null : Colors.indigo.withOpacity(0.08),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: _getDynamicCategoryColor(item.category),
                    child: const Icon(
                      Icons.notifications_active_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: item.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
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
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // পঠিত হিসেবে সেভ করা
                    item.isRead = true;
                    item.save();

                    // টাইপ অনুযায়ী ন্যাভিগেশন লজিক
                    if (item.type == 'single' && item.jobId != null) {
                      // আপনার জব ডিটেইলস স্ক্রিনে পাঠান
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetails(jobId: item.jobId)));
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ৩. ডাইনামিক ক্যাটাগরি কালার (আপনার লিস্ট অনুযায়ী)
  Color _getDynamicCategoryColor(String category) {
    // ফায়ারবেস থেকে পাঠানো string এর সাথে ম্যাচ করবে
    switch (category.toLowerCase()) {
      case 'government':
        return Colors.orange[900]!;
      case 'bank':
        return Colors.blue[800]!;
      case 'defense':
        return Colors.redAccent;
      case 'medical':
        return Colors.teal;
      case 'bcs':
        return Colors.amber[800]!;
      case 'teacher':
        return Colors.green[700]!;
      case 'ngo':
        return Colors.indigo;
      case 'admission':
        return Colors.indigo[900]!;
      case 'question':
        return Colors.brown;
      case 'result':
        return Colors.cyan[800]!;
      default:
        return Colors.indigo;
    }
  }

  // ডিলিট করার আগে কনফার্মেশন ডায়ালগ
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear All?"),
        content: const Text("সব নোটিফিকেশন ডিলিট করতে চান?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
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
