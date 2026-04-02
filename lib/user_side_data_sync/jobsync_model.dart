class JobSyncModel {
  final String id;
  final String title;
  final String company;
  final String start;
  final String deadline;
  final String logo;          // প্রতিষ্ঠানের গোল লোগো
  final String circularImage;  // মেইন বিজ্ঞপ্তির ছবি
  final bool isGovt;
  final String step1;
  final String step2;
  final String? step3;
  final String? step4;

  JobSyncModel({
    required this.id, required this.title, required this.company, required this.start,
    required this.deadline, required this.logo, required this.circularImage,
    required this.isGovt, required this.step1, required this.step2,
    this.step3, this.step4,
  });

  factory JobSyncModel.fromMap(Map<String, dynamic> data, String documentId) {
    return JobSyncModel(
      id: documentId,
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      deadline: data['end_date'] ?? '',
      start: data['start_date']??'',
      logo: data['logo'] ?? '',

      // images লিস্টের প্রথম ছবিটিকে মেইন সার্কুলার ইমেজ হিসেবে নেওয়া হচ্ছে
      circularImage: (data['images'] != null && (data['images'] as List).isNotEmpty)
          ? data['images'][0]
          : '',
      isGovt: data['is_govt'] ?? false,
      step1: data['step1'] ?? '',
      step2: data['step2'] ?? '',
      step3: data['step3'],
      step4: data['step4'],
    );
  }
}