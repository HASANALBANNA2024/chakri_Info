class JobSyncModel {
  final String id;
  final String title;
  final String company;
  final String start;
  final String deadline;
  final String applyLink;
  final String logo; // প্রতিষ্ঠানের গোল লোগো
  final String circularImage; // মেইন বিজ্ঞপ্তির ছবি
  final String totalpost;
  final bool isGovt;
  final String step1;
  final String step2;
  final String? step3;
  final String? step4;

  JobSyncModel({
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
    required this.step1,
    required this.step2,
    this.step3,
    this.step4,
  });

  factory JobSyncModel.fromMap(Map<String, dynamic> data, String documentId) {
    // ১. total_posts হ্যান্ডেল করা (সংখ্যা বা লেখা যাই হোক স্ট্রিং এ রূপান্তর)
    String postCount = (data['total_posts'] ?? '0').toString();

    // ২. is_govt চেক (বুলিয়ান বা স্ট্রিং "true" যাই হোক হ্যান্ডেল করবে)
    bool govStatus = false;
    if (data['is_govt'] != null) {
      if (data['is_govt'] is bool) {
        govStatus = data['is_govt'];
      } else {
        govStatus = data['is_govt'].toString().toLowerCase() == 'true';
      }
    }

    // ৩. ইমেজ লিস্ট হ্যান্ডেল করা
    String mainImage = '';
    if (data['images'] != null &&
        data['images'] is List &&
        (data['images'] as List).isNotEmpty) {
      mainImage = data['images'][0].toString();
    }

    return JobSyncModel(
      id: documentId,
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      // logic to deadline to parse end_date
      deadline: data['end_date'] ?? '',
      start: data['start_date'] ?? '',
      logo: data['logo'] ?? '',
      applyLink: data['apply_link'] ?? '',
      totalpost: postCount,
      circularImage: mainImage,
      isGovt: govStatus,
      step1: data['step1'] ?? '',
      step2: data['step2'] ?? '',
      step3: data['step3'],
      step4: data['step4'],
    );
  }
}
