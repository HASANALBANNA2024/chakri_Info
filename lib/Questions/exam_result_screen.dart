import 'package:chakri_info/Questions/question_bank_model.dart';
import 'package:flutter/material.dart';

class ExamResultScreen extends StatelessWidget {
  final List<QuestionBankModel> questions;
  final Map<int, int> userAnswers;
  final bool isDarkMode;

  const ExamResultScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.isDarkMode,
  });

  // ইংরেজি সংখ্যাকে বাংলায় রূপান্তর
  String _toBanglaNumber(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bangla = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String input = number.toString();
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], bangla[i]);
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = isDarkMode ? const Color(0xFF020617) : Colors.grey[100]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "ফলাফল ও ব্যাখ্যা",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        // after 3 question display to add banner
        itemCount: questions.length + (questions.length ~/ 3),
        itemBuilder: (context, index) {
          // ad banner position to 4
          if ((index + 1) % 4 == 0) {
            return _buildInlineAdCard();
          }

          // right question add index
          final int questionIndex = index - (index ~/ 4);
          if (questionIndex >= questions.length) return const SizedBox.shrink();

          final q = questions[questionIndex];
          final userSelection = userAnswers[questionIndex];

          // to search right question index .
          final correctIndex = q.options?.indexWhere(
            (opt) => opt.trim() == q.answer.trim(),
          );

          return _buildResultCard(
            q,
            questionIndex,
            userSelection,
            correctIndex,
          );
        },
      ),
    );
  }

  // প্রশ্নের কার্ড ডিজাইন
  Widget _buildResultCard(
    QuestionBankModel q,
    int qIndex,
    int? userSelection,
    int? correctIndex,
  ) {
    bool isCorrect = userSelection == correctIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: userSelection == null
              ? Colors.grey.withOpacity(0.3)
              : (isCorrect
                    ? Colors.green.withOpacity(0.5)
                    : Colors.red.withOpacity(0.5)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ব্যাজ এবং নম্বর
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "প্রশ্ন ${_toBanglaNumber(qIndex + 1)}",
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildStatusBadge(userSelection, isCorrect),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            q.question,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // অপশন লিস্ট
          if (q.options != null)
            ...List.generate(q.options!.length, (optIndex) {
              return _buildResultOption(
                optIndex,
                q.options![optIndex],
                optIndex == correctIndex, // সঠিক কি না
                optIndex == userSelection, // ইউজার সিলেক্ট করেছিল কি না
              );
            }),

          // ব্যাখ্যা (Study Mode UI)
          if (q.explanation != null && q.explanation!.isNotEmpty) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: const Border(
                  left: BorderSide(color: Colors.orangeAccent, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ব্যাখ্যা:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    q.explanation!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // সঠিক/ভুল ব্যাজ
  Widget _buildStatusBadge(int? userSelection, bool isCorrect) {
    if (userSelection == null)
      return const Text(
        "উত্তর দেননি",
        style: TextStyle(color: Colors.grey, fontSize: 11),
      );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect ? Icons.check_circle_outline : Icons.highlight_off,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            isCorrect ? "সঠিক" : "ভুল",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // অপশন ডিজাইন (আইকন সহ)
  Widget _buildResultOption(
    int index,
    String text,
    bool isCorrect,
    bool isUserSelected,
  ) {
    List<String> labels = ["ক", "খ", "গ", "ঘ"];

    Color borderColor = Colors.transparent;
    Color bgColor = isDarkMode
        ? Colors.white.withOpacity(0.05)
        : Colors.grey[50]!;
    Widget? trailingIcon;

    if (isCorrect) {
      borderColor = Colors.green;
      bgColor = Colors.green.withOpacity(0.1);
      trailingIcon = const Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 18,
      );
    } else if (isUserSelected && !isCorrect) {
      borderColor = Colors.red;
      bgColor = Colors.red.withOpacity(0.1);
      trailingIcon = const Icon(Icons.cancel, color: Colors.red, size: 18);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isUserSelected || isCorrect
              ? borderColor
              : (isDarkMode ? Colors.white10 : Colors.grey.shade300),
          width: isUserSelected || isCorrect ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            "${labels[index]}. ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
          if (trailingIcon != null) trailingIcon,
        ],
      ),
    );
  }

  // ৩টি প্রশ্ন পর পর অ্যাড কার্ড
  Widget _buildInlineAdCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 90,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.ads_click, color: Colors.orangeAccent, size: 24),
            const SizedBox(height: 5),
            Text(
              "SPONSORED AD",
              style: TextStyle(
                fontSize: 9,
                color: isDarkMode ? Colors.white30 : Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
