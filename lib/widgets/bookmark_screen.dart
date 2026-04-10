import 'package:chakri_info/user_side_data_sync/job_details_screen.dart';
import 'package:chakri_info/user_side_data_sync/jobsync_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chakri_info/user_side_data_sync/job_card_widget.dart'; // আপনার কার্ড উইজেট

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  // সবগুলো বুকমার্ক একসাথে ডিলিট করার কনফার্মেশন ডায়ালগ
  void _clearAllBookmarks(BuildContext context, Box<JobSyncModel> box) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("সব ডিলিট করবেন?"),
        content: const Text("আপনি কি নিশ্চিত যে আপনার জমানো সব বুকমার্ক মুছে ফেলতে চান?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("না", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              box.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("সব বুকমার্ক মুছে ফেলা হয়েছে")),
              );
            },
            child: const Text("হ্যাঁ, সব মুছুন", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hive বক্সটি কল করা হচ্ছে
    final Box<JobSyncModel> bookmarkBox = Hive.box<JobSyncModel>('bookmarkBox');

    return Scaffold(
      appBar: AppBar(
        title: const Text("বুকমার্ক লিস্ট", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          // যদি বুকমার্ক থাকে তবেই 'সব ডিলিট' বাটন দেখাবে
          ValueListenableBuilder(
            valueListenable: bookmarkBox.listenable(),
            builder: (context, box, _) {
              if (box.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                onPressed: () => _clearAllBookmarks(context, bookmarkBox),
                tooltip: "সব ক্লিয়ার করুন",
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: bookmarkBox.listenable(),
        builder: (context, Box<JobSyncModel> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 80, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 10),
                  const Text(
                    "কোনো বিজ্ঞপ্তি বুকমার্ক করা নেই!",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // বুকমার্ক লিস্ট (নতুনগুলো আগে দেখানোর জন্য reversed করা হয়েছে)
          final List<JobSyncModel> bookmarks = box.values.toList().reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final job = bookmarks[index];

              return Stack(
                alignment: Alignment.topRight,
                children: [
                  // আপনার অরিজিনাল কার্ড উইজেটটি এখানে কল করা হয়েছে
                  JobCardWidget(job: job),

                  // কার্ডের উপরে ডান কোণায় সিঙ্গেল ডিলিট বাটন
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 8),
                    child: InkWell(
                      onTap: () {
                        box.delete(job.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("বুকমার্ক থেকে সরানো হয়েছে")),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}