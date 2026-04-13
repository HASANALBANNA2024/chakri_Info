import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 2) // Make sure this ID is unique in your project
class NotificationModel extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String body;

  @HiveField(2)
  final DateTime dateTime;

  @HiveField(3)
  final String category; // e.g., 'bcs', 'bank', 'govt', 'private', 'question'

  @HiveField(4)
  final String type; // 'single' (direct to details) or 'list' (notification screen)

  @HiveField(5)
  final String? jobId; // For direct navigation if type is single

  @HiveField(6)
  bool isRead; // To track unread notifications for the badge

  NotificationModel({
    required this.title,
    required this.body,
    required this.dateTime,
    required this.category,
    required this.type,
    this.jobId,
    this.isRead = false,
  });
}
