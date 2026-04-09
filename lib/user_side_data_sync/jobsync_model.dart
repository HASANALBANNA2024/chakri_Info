import 'package:hive/hive.dart';


part 'jobsync_model.g.dart';

@HiveType(typeId: 0)
class JobSyncModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String company;
  @HiveField(3)
  final String start;
  @HiveField(4)
  final String deadline;
  @HiveField(5)
  final String applyLink;
  @HiveField(6)
  final String logo;
  @HiveField(7)
  final String circularImage;
  @HiveField(8)
  final String totalpost;
  @HiveField(9)
  final bool isGovt;
  @HiveField(10)
  final String step1;
  @HiveField(11)
  final String step2;
  @HiveField(12)
  final String? step3;
  @HiveField(13)
  final String? step4;
  @HiveField(14)
  final String? publishDate;
  @HiveField(15)
  final List<dynamic>? positions;
  @HiveField(16)
  final List<String>? education;
  @HiveField(17)
  final String description;

  JobSyncModel({
    this.education,
    required this.id,
    required this.title,
    required this.company,
    required this.start,
    required this.applyLink,
    required this.deadline,
    required this.logo,
    required this.totalpost,
    required this.circularImage,
    required this.isGovt,
    required this.description,
    required this.step1,
    required this.step2,
    this.step3,
    this.step4,
    this.publishDate,
    this.positions,
  });

  factory JobSyncModel.fromMap(Map<String, dynamic> data, String documentId) {
    String mainImage = '';
    if (data['images'] != null && data['images'] is List && (data['images'] as List).isNotEmpty) {
      mainImage = data['images'][0].toString();
    }

    return JobSyncModel(
      id: documentId,
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      deadline: data['end_date'] ?? '', // ডাটাবেস অনুযায়ী
      start: data['start_date'] ?? '',
      publishDate: data['publish_date'] ?? '',
      logo: data['logo'] ?? '',
      applyLink: data['apply_link'] ?? '',
      totalpost: (data['total_posts'] ?? '0').toString(),
      description: data['description'],
      circularImage: mainImage,
      isGovt: data['is_govt'] ?? false,
      step1: data['step1'] ?? '',
      step2: data['step2'] ?? '',
      step3: data['step3']?.toString(),
      step4: data['step4']?.toString(),
      positions: data['positions'] as List<dynamic>?,
      education: (data['education'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }
}