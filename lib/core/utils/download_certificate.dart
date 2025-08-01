import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> downloadCertificateToPhone({
  required BuildContext context,
  required Map<String, dynamic> certificateData,
}) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Container(
              width: 56,
              height: 56,
              decoration: pw.BoxDecoration(
                color: PdfColors.orange700,
                shape: pw.BoxShape.circle,
              ),
              child: pw.Center(
                child: pw.Text(
                  'MR',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ),
            pw.SizedBox(height: 40),
            pw.Text('Certificate of Completion', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('This certifies that', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 10),
            pw.Text(certificateData['userName'] ?? '', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('has completed the course', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 10),
            pw.Text(certificateData['courseName'] ?? '', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Score: ${certificateData['score']}%', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 10),
            pw.Text('Date: ${certificateData['completionDate'].toString().split('T')[0]}', style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 20),
            pw.Text('${certificateData['certificateId']}', style: pw.TextStyle(fontSize: 14)),
          ],
        ),
      ),
    ),
  );

  try {
    // Get directory
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/certificate_${certificateData['certificateId']}.pdf';
    final File file = File(filePath);

    await file.writeAsBytes(await pdf.save());

    // Share the generated PDF file
    await SharePlus.instance.share(
      ShareParams(
        text: 'Certificate of Completion',
        files: [XFile(file.path)],
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving certificate: $e'), backgroundColor: AppColors.error),
    );
  }
}
