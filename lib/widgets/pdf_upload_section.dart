import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // kIsWeb এর জন্য প্রয়োজন
import 'package:flutter/material.dart';

class PdfUploadSection extends StatefulWidget {
  final Function(File? file, String? fileName, Uint8List? fileBytes) onFileSelected;

  const PdfUploadSection({Key? key, required this.onFileSelected}) : super(key: key);

  @override
  _PdfUploadSectionState createState() => _PdfUploadSectionState();
}

class _PdfUploadSectionState extends State<PdfUploadSection> {
  String? _pdfFileName;
  Uint8List? _pdfBytes;
  File? _selectedPDF;

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // ওয়েবে ডাটা রিড করার জন্য এটি অবশ্যই true হতে হবে
      );

      if (result != null) {
        PlatformFile pickedFile = result.files.single;

        setState(() {
          _pdfFileName = pickedFile.name;
          _pdfBytes = pickedFile.bytes; // এটিই প্রিভিউ এবং আপলোডের মূল ডাটা

          // যদি মোবাইল প্ল্যাটফর্ম হয় তবে ফাইল অবজেক্ট তৈরি হবে
          if (!kIsWeb && pickedFile.path != null) {
            _selectedPDF = File(pickedFile.path!);
          } else {
            _selectedPDF = null; // ওয়েবে ফাইল পাথ থাকে না
          }
        });

        // মেইন পেজের কলব্যাক ফাংশনে ডাটা পাঠানো
        widget.onFileSelected(_selectedPDF, _pdfFileName, _pdfBytes);
      }
    } catch (e) {
      debugPrint("PDF Pick Error: $e");
    }
  }

  void _removeFile() {
    setState(() {
      _pdfFileName = null;
      _pdfBytes = null;
      _selectedPDF = null;
    });
    widget.onFileSelected(null, null, null);
  }

  @override
  Widget build(BuildContext context) {
    bool isSelected = _pdfFileName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "সরাসরি PDF ফাইল আপলোড",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[700],
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: _pickPDF,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green.withOpacity(0.08) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.green : Colors.grey[300]!,
                width: 1.5,
              ),
              boxShadow: isSelected ? [
                BoxShadow(color: Colors.green.withOpacity(0.1), blurRadius: 4, offset: Offset(0, 2))
              ] : [],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.picture_as_pdf,
                  color: isSelected ? Colors.green : Colors.redAccent,
                  size: 26,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pdfFileName ?? "ফোন থেকে PDF ফাইল সিলেক্ট করুন",
                        style: TextStyle(
                          color: isSelected ? Colors.black87 : Colors.black54,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isSelected && _pdfBytes != null)
                        Text(
                          "${(_pdfBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB • Ready to upload",
                          style: TextStyle(fontSize: 11, color: Colors.green[700]),
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red[400], size: 22),
                    onPressed: _removeFile,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  )
                else
                  Icon(Icons.cloud_upload_outlined, color: Colors.indigo[300], size: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}