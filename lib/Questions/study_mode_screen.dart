import 'package:chakri_info/Questions/question_bank_model.dart';
import 'package:flutter/material.dart';

class StudyModeScreen extends StatelessWidget {
  final String title;
  final List<QuestionBankModel> questions;
  final bool isDarkMode;

  const StudyModeScreen({
    super.key,
    required this.title,
    required this.questions,
    required this.isDarkMode,
  });

  // --- ইংরেজি সংখ্যাকে বাংলায় রূপান্তর করার জন্য ছোট ফাংশন ---
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
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.grey[100],
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        cacheExtent: 1000,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        itemCount: questions.length + (questions.length ~/ 3),
        itemBuilder: (context, index) {
          if ((index + 1) % 4 == 0) {
            return _buildInlineAdCard();
          }

          final int questionIndex = index - (index ~/ 4);
          if (questionIndex >= questions.length) return const SizedBox.shrink();

          return _buildQuestionCard(questions[questionIndex], questionIndex);
        },
      ),
    );
  }

  Widget _buildQuestionCard(QuestionBankModel q, int index) {
    bool isMcq = q.type.toUpperCase() == "MCQ";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // প্রশ্ন (বাংলা নম্বরসহ)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${_toBanglaNumber(index + 1)}. ", // এখানে সব সময় বাংলা নম্বর আসবে
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.indigoAccent : Colors.indigo,
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: Text(
                  q.question,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // MCQ অপশন (সব সময় ক, খ, গ, ঘ আসবে)
          if (isMcq && q.options != null && q.options!.isNotEmpty) ...[
            ...List.generate(q.options!.length, (optIndex) {
              String optionText = q.options![optIndex];
              bool isCorrect = optionText.trim() == q.answer.trim();
              return _buildMcqOption(optIndex, optionText, isCorrect);
            }),
          ] else ...[
            _buildWrittenAnswerBox(q.answer),
          ],

          if (q.explanation != null && q.explanation!.trim().isNotEmpty) ...[
            const SizedBox(height: 15),
            _buildExplanationBox(q.explanation!),
          ],
        ],
      ),
    );
  }

  Widget _buildMcqOption(int index, String text, bool isCorrect) {
    // এখানে সব সময় বাংলা লেবেল (ক, খ, গ, ঘ) আসবে
    List<String> labels = ["ক", "খ", "গ", "ঘ"];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withOpacity(0.1)
            : (isDarkMode ? Colors.white.withOpacity(0.02) : Colors.grey[50]),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCorrect
              ? Colors.green.withOpacity(0.5)
              : Colors.grey.withOpacity(0.2),
          width: isCorrect ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "${labels[index < 4 ? index : 0]}. ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
              softWrap: true,
            ),
          ),
          if (isCorrect)
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.check_circle, color: Colors.green, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildWrittenAnswerBox(String answer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "উত্তর:",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationBox(String explanation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Colors.orangeAccent, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
              SizedBox(width: 5),
              Text(
                "ব্যাখ্যা:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineAdCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      height: 100,
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
            const Text(
              "SPONSORED AD",
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.2,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Icon(
              Icons.ads_click,
              color: Colors.grey.withOpacity(0.5),
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
