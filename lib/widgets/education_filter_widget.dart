// import 'package:flutter/material.dart';
// import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
// import 'package:chakri_info/user_side_data_sync/joblist_screen.dart';
//
// class EducationFilterWidget extends StatelessWidget {
//   // ডাটাবেস থেকে পাওয়া মেইন লিস্টটি এখানে আসবে
//   final List<JobSyncModel> allJobs;
//
//   const EducationFilterWidget({super.key, required this.allJobs});
//
//   @override
//   Widget build(BuildContext context) {
//     // শিক্ষার লেভেলের লিস্ট
//     final List<String> eduLevels = [
//       'অষ্টম শ্রেণি পাস', 'JSC / JDC', 'SSC / সমমান', 'HSC / সমমান',
//       'Diploma (ডিপ্লোমা)', 'BSc / Honours (অনার্স)', 'Masters (মাস্টার্স)',
//       'BBA / MBA', 'MBBS / BDS', 'Fazil / Kamil', 'PhD', 'অন্যান্য'
//     ];
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Wrap(
//         spacing: 8,
//         runSpacing: 4,
//         children: eduLevels.map((level) {
//           return ActionChip(
//             label: Text(
//               level,
//               style: const TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.indigo,
//               ),
//             ),
//             backgroundColor: Colors.indigo.withOpacity(0.08),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//               side: BorderSide(color: Colors.indigo.withOpacity(0.2)),
//             ),
//             onPressed: () {
//               // ১. লজিক: এই লেভেল অনুযায়ী ডাটা ফিল্টার করা
//               final List<JobSyncModel> filteredJobs = allJobs.where((job) {
//                 // মডেলের education লিস্ট চেক করা হচ্ছে
//                 return job.education != null && job.education!.contains(level);
//               }).toList();
//
//               // ২. লজিক: যদি কোনো জব না থাকে তবে মেসেজ দেখানো
//               if (filteredJobs.isEmpty) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('$level-এর জন্য বর্তমানে কোনো সার্কুলার নেই'),
//                     backgroundColor: Colors.redAccent,
//                     behavior: SnackBarBehavior.floating,
//                     margin: const EdgeInsets.all(10),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   ),
//                 );
//                 return; // লিস্ট স্ক্রিনে যাবে না
//               }
//
//               // ৩. লজিক: জব থাকলে ড্রয়ার বন্ধ করা
//               Navigator.pop(context);
//
//               // ৪. লজিক: সর্টিং (নতুন আইডি বা টাইমস্ট্যাম্প অনুযায়ী নতুনগুলো আগে)
//               filteredJobs.sort((a, b) => (b.id ?? "").compareTo(a.id ?? ""));
//
//               // ৫. লজিক: সরাসরি ফিল্টার করা ডাটা নিয়ে JobListScreen-এ যাওয়া
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => JobListScreen(
//                     title: level,
//                     jobs: filteredJobs,
//                     educationFilter: level,
//                   ),
//                 ),
//               );
//             },
//           );
//         }).toList(),
//       ),
//     );
//   }
// }