import 'package:chakri_info/models/job_model.dart';

class JobController {
  List<JobModel> fetchAllCirculars() {
    return [
      JobModel(
        id: "1",
        title: "অফিসার (সাধারণ)",
        company: "সোনালী ব্যাংক লিমিটেড",
        location: "ঢাকা, বাংলাদেশ",
        salary: "১৬,০০০ - ৩৮,৬৪০/-",
        deadline: "১৫ এপ্রিল ২০২৬",
        logo: "SB",
        category: "ব্যাংক",
        description: "বিস্তারিত সার্কুলার ভেতরে দেখুন...",
        imagePath: "assets/images/bpsc_image.webp",
      ),
      JobModel(
        id: "2",
        title: "উপ-সহকারী প্রকৌশলী",
        company: "এলজিইডি (LGED)",
        location: "সারাদেশ",
        salary: "সরকারি পে-স্কেল অনুযায়ী",
        deadline: "২০ এপ্রিল ২০২৬",
        logo: "LG",
        category: "সরকারি",
        description: "যোগ্যতা: ডিপ্লোমা ইন ইঞ্জিনিয়ারিং...",
        imagePath: "assets/images/bpsc_image.webp", // খালি রাখা যাবে না
      ),
    ];
  }
}
