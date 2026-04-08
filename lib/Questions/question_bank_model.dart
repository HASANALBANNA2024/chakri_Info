import 'package:hive/hive.dart';

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

  // factory method টি এভাবে আপডেট করুন
  factory QuestionBankModel.fromJson(
    Map<String, dynamic> json,
    String examTitle,
    String examType,
  ) {
    return QuestionBankModel(
      title: examTitle,
      question: (json['q'] ?? '').toString(),
      // options যদি নাল হয় বা লিস্ট না হয় তবে খালি লিস্ট পাঠিয়ে দিবে
      options: json['options'] is List
          ? List<String>.from(json['options'].map((item) => item.toString()))
          : [],
      answer: (json['ans'] ?? '').toString(),
      explanation: (json['exp'] ?? '').toString(),
      type: examType,
    );
  }
}
