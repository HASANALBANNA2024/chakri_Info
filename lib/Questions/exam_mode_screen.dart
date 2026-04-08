import 'dart:async';

import 'package:chakri_info/Questions/exam_result_screen.dart';
import 'package:chakri_info/Questions/question_bank_model.dart';
import 'package:flutter/material.dart';

class ExamModeScreen extends StatefulWidget {
  final List<QuestionBankModel> questions;
  final bool isDarkMode;

  const ExamModeScreen({
    super.key,
    required this.questions,
    required this.isDarkMode,
  });

  @override
  State<ExamModeScreen> createState() => _ExamModeScreenState();
}

class _ExamModeScreenState extends State<ExamModeScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  Map<int, int> selectedAnswers = {};

  // টাইমার ভেরিয়েবল
  Timer? _timer;
  int _remainingSeconds = 60; // প্রতি প্রশ্নের জন্য ৬০ সেকেন্ড

  @override
  void initState() {
    super.initState();
    _startTimer(); // স্ক্রিন লোড হলেই টাইমার শুরু হবে
  }

  @override
  void dispose() {
    _timer?.cancel(); // মেমোরি লিক আটকাতে টাইমার বন্ধ করা
    _pageController.dispose();
    super.dispose();
  }

  // টাইমার শুরু করার ফাংশন
  void _startTimer() {
    _timer?.cancel(); // আগের টাইমার থাকলে বন্ধ করা
    setState(() => _remainingSeconds = 60); // রিসেট

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _goToNextQuestion(); // সময় শেষ হলে পরের প্রশ্নে যাওয়া
      }
    });
  }

  void _goToNextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startTimer(); // পরের প্রশ্নের জন্য নতুন করে টাইমার শুরু
    } else {
      _timer?.cancel();
      _showResult(); // শেষ প্রশ্ন হলে রেজাল্ট দেখানো
    }
  }

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
      backgroundColor: widget.isDarkMode
          ? const Color(0xFF0F172A)
          : Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "মডেল টেস্ট",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: widget.isDarkMode
            ? const Color(0xFF1E293B)
            : Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          // উপরে টাইমার শো করা
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: _remainingSeconds <= 10
                  ? Colors.redAccent
                  : Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, size: 16, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  _toBanglaNumber(_remainingSeconds),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ✅ ফিক্সড বটম অ্যাড ব্যানার
      bottomNavigationBar: _buildFixedAdBanner(),

      body: Column(
        children: [
          LinearProgressIndicator(
            value: (currentIndex + 1) / widget.questions.length,
            backgroundColor: Colors.grey[300],
            color: Colors.orangeAccent,
            minHeight: 5,
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics:
                  const NeverScrollableScrollPhysics(), // টাইমার যেহেতু আছে, ইউজার নিজে সোয়াইপ করতে পারবে না (ইচ্ছলে এটা রাখতে পারেন)
              onPageChanged: (index) {
                setState(() => currentIndex = index);
              },
              itemCount: widget.questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionPage(widget.questions[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(QuestionBankModel q, int qIndex) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "প্রশ্ন ${_toBanglaNumber(qIndex + 1)}",
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              q.question,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            if (q.options != null)
              ...List.generate(q.options!.length, (optIndex) {
                bool isSelected = selectedAnswers[qIndex] == optIndex;
                return _buildOptionTile(
                  qIndex,
                  optIndex,
                  q.options![optIndex],
                  isSelected,
                );
              }),
          ],
        ),
      ),
    );
  }

  // ১. অপশন সিলেক্ট করলে যা হবে
  Widget _buildOptionTile(
    int qIndex,
    int optIndex,
    String text,
    bool isSelected,
  ) {
    List<String> labels = ["ক", "খ", "গ", "ঘ"];

    // ডার্ক মোড কালার ফিক্স
    Color labelBgColor = isSelected
        ? Colors.orangeAccent
        : (widget.isDarkMode
              ? Colors.indigoAccent.withOpacity(0.2)
              : Colors.grey[300]!);
    Color labelTextColor = isSelected
        ? Colors.black
        : (widget.isDarkMode ? Colors.white : Colors.black87);
    Color tileBorderColor = isSelected
        ? Colors.orangeAccent
        : (widget.isDarkMode ? Colors.white24 : Colors.grey.withOpacity(0.3));

    return GestureDetector(
      onTap: () {
        if (selectedAnswers[qIndex] == null) {
          // যদি আগে সিলেক্ট না করা থাকে
          setState(() {
            selectedAnswers[qIndex] = optIndex;
          });

          // ✅ অপশন সিলেক্ট করার ১ সেকেন্ড পর অটোমেটিক পরের প্রশ্নে যাবে
          Future.delayed(const Duration(milliseconds: 500), () {
            _goToNextQuestion();
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.indigo.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tileBorderColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            // ✅ ক, খ, গ, ঘ এর ডিজাইন যা ডার্ক মোডে ক্লিয়ার বোঝা যাবে
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: labelBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  labels[optIndex],
                  style: TextStyle(
                    color: labelTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.orangeAccent,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedAdBanner() {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.white10 : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          "FIXED AD BANNER",
          style: TextStyle(color: Colors.grey, fontSize: 10),
        ),
      ),
    );
  }

  void _showResult() {
    _timer?.cancel(); // টাইমার বন্ধ করা

    showDialog(
      context: context,
      barrierDismissible:
          false, // ইউজার যেন বাইরে ক্লিক করে পপ-আপ সরাতে না পারে
      builder: (c) {
        return AlertDialog(
          backgroundColor: widget.isDarkMode
              ? const Color(0xFF1E293B)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Center(
            child: Text(
              "পরীক্ষা সম্পন্ন!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("আপনি সফলভাবে মডেল টেস্টটি শেষ করেছেন।"),
              const SizedBox(height: 20),

              // ১. View Result বাটন
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(c); // পপ-আপ সরানো
                  // রেজাল্ট স্ক্রিনে নিয়ে যাওয়া
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExamResultScreen(
                        questions: widget.questions,
                        userAnswers: selectedAnswers,
                        isDarkMode: widget.isDarkMode,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.bar_chart),
                label: const Text("ফলাফল ও ব্যাখ্যা দেখুন"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ২. Exit বাটন
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(c); // পপ-আপ সরানো
                  Navigator.pop(
                    context,
                  ); // এক্সাম স্ক্রিন থেকে বের হয়ে আগের (Sub Category) স্ক্রিনে যাওয়া
                },
                icon: const Icon(Icons.exit_to_app),
                label: const Text("বেরিয়ে যান"),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  foregroundColor: Colors.redAccent,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ৩. অ্যাড ব্যানার কার্ড (Fixed)
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.isDarkMode ? Colors.white10 : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "SPONSORED AD",
                        style: TextStyle(fontSize: 8, color: Colors.grey),
                      ),
                      Icon(Icons.ads_click, color: Colors.grey, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
