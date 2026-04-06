class QuestionBankModel {
  final String title; // নতুন ফিল্ড
  final String question;
  final List<String> options;
  final String answer;
  final String? explanation;

  QuestionBankModel({
    required this.title,
    required this.question,
    required this.options,
    required this.answer,
    this.explanation,
  });

  factory QuestionBankModel.fromJson(
    Map<String, dynamic> json,
    String examTitle,
  ) {
    return QuestionBankModel(
      title: examTitle, // মেইন টাইটেলটি এখানে সেট হবে
      question: json['q'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      answer: json['ans'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title, // ফায়ারবেসে এই কি (key) দিয়ে সেভ হবে
    'q': question,
    'options': options,
    'ans': answer,
    'explanation': explanation,
  };
}
