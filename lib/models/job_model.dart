// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class JobModel {
//   final String id;
//   final String title;
//   final String company;
//   final String location;
//   final String salary;
//   final String deadline;
//   final String logo; // Logo URL
//   final String category;
//   final String description; // Circular Image URL or Text
//   final DateTime? createdAt; // নতুন যোগ করা হয়েছে (সর্টিং এর জন্য)
//
//   JobModel({
//     required this.id,
//     required this.title,
//     required this.company,
//     required this.location,
//     required this.salary,
//     required this.deadline,
//     required this.logo,
//     required this.category,
//     required this.description,
//     this.createdAt,
//   });
//
//   // ফায়ারবেস থেকে ডেটা পাওয়ার জন্য
//   factory JobModel.fromMap(Map<String, dynamic> data, String documentId) {
//     return JobModel(
//       id: documentId,
//       title: data['title'] ?? 'শিরোনামহীন',
//       company: data['company'] ?? 'অজানা কোম্পানি',
//       location: data['location'] ?? 'বাংলাদেশ',
//       salary: data['salary'] ?? 'আলোচনা সাপেক্ষে',
//       deadline: data['deadline'] ?? '',
//       logo: data['logo'] ?? '',
//       category: data['category'] ?? 'অন্যান্য',
//       description: data['description'] ?? '',
//       // ফায়ারবেস টাইমস্ট্যাম্পকে ডাDateTime এ কনভার্ট করা
//       createdAt: data['createdAt'] != null
//           ? (data['createdAt'] as Timestamp).toDate()
//           : DateTime.now(),
//     );
//   }
//
//   // ফায়ারবেসে ডেটা পাঠানোর জন্য (ভবিষ্যতে অ্যাডমিন প্যানেল করলে কাজে লাগবে)
//   Map<String, dynamic> toMap() {
//     return {
//       'title': title,
//       'company': company,
//       'location': location,
//       'salary': salary,
//       'deadline': deadline,
//       'logo': logo,
//       'category': category,
//       'description': description,
//       'createdAt': createdAt ?? FieldValue.serverTimestamp(),
//     };
//   }
// }

class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String deadline;
  final String logo;
  final String category;
  final String description; // এখানে সার্কুলার ইমেজের লিঙ্ক থাকবে

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.deadline,
    required this.logo,
    required this.category,
    required this.description,
  });

  // এই মেথডটি পরে ফায়ারবেস কানেক্ট করলে কাজে লাগবে
  factory JobModel.fromMap(Map<String, dynamic> data, String documentId) {
    return JobModel(
      id: documentId,
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      location: data['location'] ?? '',
      salary: data['salary'] ?? '',
      deadline: data['deadline'] ?? '',
      logo: data['logo'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
    );
  }
}
