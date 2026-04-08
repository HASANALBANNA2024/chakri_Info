import 'package:hive/hive.dart';

// আপনার ফাইলের নাম যদি question_bank_model.dart হয়, তবে নিচের লাইনটি ঠিক আছে।
part 'question_bank_model.g.dart';

@HiveType(typeId: 1)
class QuestionBankModel extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String question;

  @HiveField(2)
  final List<String>? options;

  @HiveField(3)
  final String answer;

  @HiveField(4)
  final String? explanation;

  @HiveField(5)
  final String type;

  QuestionBankModel({
    required this.title,
    required this.question,
    this.options,
    required this.answer,
    this.explanation,
    required this.type,
  });

  /// [examTitle] এবং [examType] প্যারামিটার দুটি আমরা বাইরে (Fetch করার সময়) থেকে পাস করবো।
  factory QuestionBankModel.fromJson(
    Map<String, dynamic> json,
    String examTitle,
    String examType,
  ) {
    return QuestionBankModel(
      title: examTitle,

      // ১. প্রশ্ন: 'q' অথবা 'question' কি-তে ডাটা খুঁজতে পারবে
      question: (json['q'] ?? json['question'] ?? '').toString(),

      // ২. অপশন: যদি লিস্ট না হয় বা না থাকে, তবে খালি লিস্ট দিবে।
      // Written/Viva এর ক্ষেত্রে এটি অটোমেটিক খালি থাকবে।
      options: (json['options'] != null && json['options'] is List)
          ? List<String>.from(json['options'].map((item) => item.toString()))
          : [],

      // ৩. উত্তর: 'ans' অথবা 'answer' অথবা 'ans_text' যাই থাকুক
      answer: (json['ans'] ?? json['answer'] ?? json['ans_text'] ?? '')
          .toString(),

      // ৪. ব্যাখ্যা: 'exp' অথবা 'explanation'
      explanation: (json['exp'] ?? json['explanation'] ?? '').toString(),

      // ৫. টাইপ: এটি সরাসরি আর্গুমেন্ট থেকে আসবে (MCQ/Written/Viva)
      type: examType,
    );
  }

  /// ম্যাপে রূপান্তর করার জন্য (যেমন Hive বা Firebase এ সেভ করতে)
  Map<String, dynamic> toJson() {
    return {
      'q': question,
      'options': options,
      'ans': answer,
      'exp': explanation,
      'type': type,
      'title': title,
    };
  }
}
