import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sentimento_app/backend/tables/entradas_humor.dart';

class PdfService {
  Future<void> generateAndShareEntryPdf(EntradasHumorRow entry) async {
    final pdf = pw.Document();

    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(entry.criadoEm);
    final moodScore = entry.nota ?? 0;

    // Map mood score to text/emoji (simplified)
    String getMoodLabel(int score) {
      if (score >= 4) return 'Muito Bem 😄';
      if (score == 3) return 'Bem 🙂';
      if (score == 2) return 'Neutro 😐';
      if (score == 1) return 'Mal 😔';
      return 'Muito Mal 😢';
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'Diário de Sentimentos',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Data: $dateStr',
                  style: const pw.TextStyle(fontSize: 18),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Humor: ${getMoodLabel(moodScore)}',
                  style: const pw.TextStyle(fontSize: 18),
                ),

                if (entry.tags.isNotEmpty) ...[
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Tags:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Wrap(
                    spacing: 5,
                    children: entry.tags
                        .map(
                          (t) => pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.grey),
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            child: pw.Text(t),
                          ),
                        )
                        .toList(),
                  ),
                ],

                if (entry.notaTexto != null && entry.notaTexto!.isNotEmpty) ...[
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Notas:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Paragraph(text: entry.notaTexto!),
                ],

                pw.Spacer(),
                pw.Divider(),
                pw.Text(
                  'Gerado pelo Sentimento App',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'sentimento_entry_${entry.id}.pdf',
    );
  }
}
