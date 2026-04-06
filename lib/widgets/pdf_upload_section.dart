import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class PdfUploadSection extends StatefulWidget {
  final Function(File? file, String? fileName) onFileSelected;

  const PdfUploadSection({Key? key, required this.onFileSelected})
    : super(key: key);

  @override
  _PdfUploadSectionState createState() => _PdfUploadSectionState();
}

class _PdfUploadSectionState extends State<PdfUploadSection> {
  File? _selectedPDF;
  String? _pdfFileName;

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedPDF = File(result.files.single.path!);
        _pdfFileName = result.files.single.name;
      });
      widget.onFileSelected(_selectedPDF, _pdfFileName);
    }
  }

  void _removeFile() {
    setState(() {
      _selectedPDF = null;
      _pdfFileName = null;
    });
    widget.onFileSelected(null, null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "সরাসরি PDF ফাইল আপলোড",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        SizedBox(height: 6),
        InkWell(
          onTap: _pickPDF,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: _selectedPDF != null
                  ? Colors.green.withOpacity(0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _selectedPDF != null ? Colors.green : Colors.grey[300]!,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.picture_as_pdf,
                  color: _selectedPDF != null ? Colors.green : Colors.redAccent,
                  size: 22,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _pdfFileName ?? "ফোন থেকে PDF ফাইল সিলেক্ট করুন",
                    style: TextStyle(
                      color: _selectedPDF != null
                          ? Colors.black87
                          : Colors.black54,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_selectedPDF != null)
                  GestureDetector(
                    onTap: _removeFile,
                    child: Icon(Icons.cancel, color: Colors.red, size: 20),
                  )
                else
                  Icon(
                    Icons.file_upload_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
