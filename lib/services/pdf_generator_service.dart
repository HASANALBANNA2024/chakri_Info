import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:chakri_info/Questions/question_bank_model.dart';

class PdfGeneratorService {
  static Future<void> generateJobPdf({
    required String title,
    required List<QuestionBankModel> questions,
    required String type, // 'MCQ' or 'Written'/'Viva'
  }) async {
    final pdf = pw.Document();

    // বাংলা ফন্ট লোড (assets/fonts ফোল্ডারে SolaimanLipi.ttf থাকতে হবে)
    final fontData = await rootBundle.load("assets/fonts/SolaimanLipi.ttf");
    final banglaFont = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        // --- হেডার (সব পেজের উপরে থাকবে) ---
        header: (context) => pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Chakri Info - Smart Job Preparation",
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                pw.Text("Exam: $title",
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, font: banglaFont)),
              ],
            ),
            pw.Divider(thickness: 0.5),
          ],
        ),
        // --- ফুটার (সব পেজের নিচে থাকবে) ---
        footer: (context) => pw.Column(
          children: [
            pw.Divider(thickness: 0.5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Digital Signature: Chakri Info Team",
                    style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, font: banglaFont)),
                pw.Text("Page ${context.pageNumber} of ${context.pagesCount}",
                    style: pw.TextStyle(fontSize: 9)),
                pw.Text("App: Chakri Info",
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ],
        ),
        build: (context) => [
          pw.Stack(
            children: [
              // --- ডায়াগোনাল ওয়াটারমার্ক (সিগনেচার) ---
              pw.Center(
                child: pw.Opacity(
                  opacity: 0.07,
                  child: pw.Transform.rotate(
                    angle: 0.5,
                    child: pw.Text(
                      "CHAKRI INFO APP",
                      style: pw.TextStyle(fontSize: 60, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ),
              ),

              // --- ডাটা রেন্ডারিং ---
              type == 'MCQ'
                  ? _buildMcqLayout(questions, banglaFont)
                  : _buildWrittenLayout(questions, banglaFont),
            ],
          ),
        ],
      ),
    );

    // পিডিএফ প্রিভিউ এবং ডাউনলোড অপশন ওপেন করা
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${title}_chakri_info.pdf',
    );
  }

  // ২. MCQ Layout (Double Column with Middle Line)
  static pw.Widget _buildMcqLayout(List<QuestionBankModel> questions, pw.Font font) {
    return pw.Partitions(
      children: [
        // বাম কলাম
        pw.Partition(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: questions.asMap().entries
                .where((e) => e.key % 2 == 0)
                .map((e) => _mcqItem(e.value, e.key + 1, font)).toList(),
          ),
        ),
        // মাঝখানের লাইন
        pw.Partition(
          width: 20,
          child: pw.VerticalDivider(thickness: 0.5, color: PdfColors.grey400),
        ),
        // ডান কলাম
        pw.Partition(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: questions.asMap().entries
                .where((e) => e.key % 2 != 0)
                .map((e) => _mcqItem(e.value, e.key + 1, font)).toList(),
          ),
        ),
      ],
    );
  }

  // ৩. Written/Viva Layout (Full Width)
  static pw.Widget _buildWrittenLayout(List<QuestionBankModel> questions, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: questions.asMap().entries.map((e) {
        final q = e.value;
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("${e.key + 1}. ${q.question}",
                  style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold, fontSize: 11)),
              pw.SizedBox(height: 4),
              pw.Text("উত্তরঃ ${q.answer}",
                  style: pw.TextStyle(font: font, fontSize: 10)),
              if (q.explanation != null && q.explanation!.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2),
                  child: pw.Text("ব্যাখ্যাঃ ${q.explanation}",
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 8,
                        color: PdfColors.grey800,
                        fontStyle: pw.FontStyle.italic, // ফিক্সড করা হয়েছে
                      )),
                ),
              pw.Divider(thickness: 0.2, color: PdfColors.grey300),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ৪. MCQ Item Design
  static pw.Widget _mcqItem(QuestionBankModel q, int index, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10, right: 5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start, // সঠিক CrossAxis
        children: [
          pw.Text("$index. ${q.question}",
              style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold, fontSize: 9)),

          if (q.options != null && q.options!.length >= 2) ...[
            pw.Text(" (ক) ${q.options![0]}   (খ) ${q.options![1]}",
                style: pw.TextStyle(font: font, fontSize: 8)),
            if (q.options!.length >= 4)
              pw.Text(" (গ) ${q.options![2]}   (ঘ) ${q.options![3]}",
                  style: pw.TextStyle(font: font, fontSize: 8)),
          ],

          pw.Text("সঠিক উত্তরঃ ${q.answer}",
              style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.green900, fontWeight: pw.FontWeight.bold)),

          if (q.explanation != null && q.explanation!.isNotEmpty)
            pw.Text("ব্যাখ্যাঃ ${q.explanation}",
                style: pw.TextStyle(
                  font: font,
                  fontSize: 7,
                  fontStyle: pw.FontStyle.italic, // ফিক্সড করা হয়েছে
                  color: PdfColors.grey700,
                )),

          pw.Divider(thickness: 0.1, color: PdfColors.grey400),
        ],
      ),
    );
  }
}