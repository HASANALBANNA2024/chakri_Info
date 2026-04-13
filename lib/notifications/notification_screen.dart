import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'notification_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          // Clear all notifications
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () =>
                Hive.box<NotificationModel>('notifications').clear(),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<NotificationModel>(
          'notifications',
        ).listenable(),
        builder: (context, Box<NotificationModel> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("No notifications yet!"));
          }

          // Sort by date (newest first)
          final notifications = box.values.toList().reversed.toList();

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];

              return Card(
                color: item.isRead ? null : Colors.indigo.withOpacity(0.1),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(item.category),
                    child: const Icon(Icons.notifications, color: Colors.white),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.body),
                      const SizedBox(height: 5),
                      Text(
                        DateFormat('dd MMM, hh:mm a').format(item.dateTime),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Mark as read
                    item.isRead = true;
                    item.save();

                    // Logic for Navigation based on type
                    if (item.type == 'single' && item.jobId != null) {
                      // Navigate to Job Details Screen using jobId
                      // Navigator.push(...);
                    } else {
                      // Stay here or show more info
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

  // Helper function for category colors
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'bcs':
        return Colors.orange;
      case 'bank':
        return Colors.green;
      case 'govt':
        return Colors.blue;
      case 'question':
        return Colors.purple;
      default:
        return Colors.indigo;
    }
  }
}
