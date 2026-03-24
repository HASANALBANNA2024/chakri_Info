// জব মডেল: একটি চাকরির সব তথ্য এখানে থাকবে
class JobBookmark {
  final String title;
  final String company;
  final String category;
  final String deadline;
  final bool isClosingSoon;

  JobBookmark({
    required this.title,
    required this.company,
    required this.category,
    required this.deadline,
    this.isClosingSoon = false,
  });
}

// ডামি ডাটা লজিক (এটি পরবর্তীতে ডাটাবেস থেকে আসবে)
List<JobBookmark> allSavedJobs = [
  JobBookmark(
    title: "সফটওয়্যার ইঞ্জিনিয়ার (ফ্লাটার)",
    company: "টেকনো বিডি লিমিটেড",
    category: "আইটি",
    deadline: "২৮ মার্চ, ২০২৬",
    isClosingSoon: true,
  ),
  JobBookmark(
    title: "সিনিয়র অফিসার",
    company: "সোনালী ব্যাংক পিএলসি",
    category: "ব্যাংক",
    deadline: "০৫ এপ্রিল, ২০২৬",
    isClosingSoon: false,
  ),
  JobBookmark(
    title: "উপ-সহকারী প্রকৌশলী",
    company: "এলজিইডি (LGED)",
    category: "সরকারি",
    deadline: "১০ এপ্রিল, ২০২৬",
    isClosingSoon: false,
  ),
];
