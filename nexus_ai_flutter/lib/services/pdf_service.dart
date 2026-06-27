import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  // ✅ حفظ PDF مباشرة على الجهاز (بدون مشاركة)
  static Future<String> saveResume({
    required String name,
    required String bio,
    required List<String> skills,
    required List<String> projects,
    required List<String> certificates,
  }) async {
    final pdf = await _generatePdf(
      name: name,
      bio: bio,
      skills: skills,
      projects: projects,
      certificates: certificates,
    );

    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'NexusAI_Resume_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(pdf);

    return filePath;
  }

  // ✅ مشاركة PDF
  static Future<void> shareResume({
    required String name,
    required String bio,
    required List<String> skills,
    required List<String> projects,
    required List<String> certificates,
  }) async {
    final pdf = await _generatePdf(
      name: name,
      bio: bio,
      skills: skills,
      projects: projects,
      certificates: certificates,
    );

    await Printing.sharePdf(
      bytes: pdf,
      filename: 'NexusAI_Resume_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  // ✅ دالة خاصة لتوليد PDF
  static Future<Uint8List> _generatePdf({
    required String name,
    required String bio,
    required List<String> skills,
    required List<String> projects,
    required List<String> certificates,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (context) => [
          // الهيدر
          pw.Container(
            padding: pw.EdgeInsets.only(bottom: 20),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.indigo, width: 3),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  name,
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF1E1B4B),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  bio,
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // المهارات
          _buildSection(
            title: 'المهارات التقنية',
            items: skills,
            icon: '🛠️',
            color: PdfColor.fromInt(0xFF4F46E5),
          ),
          pw.SizedBox(height: 16),

          // المشاريع
          _buildSection(
            title: 'المشاريع',
            items: projects,
            icon: '💼',
            color: PdfColor.fromInt(0xFF7C3AED),
          ),
          pw.SizedBox(height: 16),

          // الشهادات
          _buildSection(
            title: 'الشهادات',
            items: certificates,
            icon: '🎓',
            color: PdfColor.fromInt(0xFF34D399),
          ),
          pw.SizedBox(height: 16),

          // الفوتر
          pw.Container(
            margin: pw.EdgeInsets.only(top: 40),
            padding: pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Center(
              child: pw.Text(
                '✨ تم إنشاؤها بواسطة Nexus AI | One Smart Profile. Endless Opportunities.',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return await pdf.save();
  }

  static pw.Widget _buildSection({
    required String title,
    required List<String> items,
    required String icon,
    required PdfColor color,
  }) {
    if (items.isEmpty) {
      return pw.SizedBox();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text(
              icon,
              style: pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          decoration: pw.BoxDecoration(
            color: PdfColors.grey50,
            borderRadius: pw.BorderRadius.circular(12),
            border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
          ),
          child: pw.Padding(
            padding: pw.EdgeInsets.all(12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: items.map((item) {
                return pw.Padding(
                  padding: pw.EdgeInsets.only(bottom: 6),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '✦',
                        style: pw.TextStyle(
                          color: color,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Text(
                          item,
                          style: pw.TextStyle(fontSize: 11, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}