import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  static Future<Uint8List> generateLaporanPdf({
    required int totalIncome,
    required int totalExpense,
    required Map<String, int> categorySummary,
  }) async {
    final pdf = pw.Document();
    final saldo = totalIncome - totalExpense;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text(
            "Laporan Keuangan",
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            "Tanggal: ${DateFormat('dd MMM yyyy').format(DateTime.now())}",
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Total Pemasukan: Rp ${NumberFormat.decimalPattern('id').format(totalIncome)}",
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  "Total Pengeluaran: Rp ${NumberFormat.decimalPattern('id').format(totalExpense)}",
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  "Saldo: Rp ${NumberFormat.decimalPattern('id').format(saldo)}",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            "Ringkasan Kategori",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['Kategori', 'Jumlah'],
            data: categorySummary.entries.map((e) {
              return [
                e.key,
                "Rp ${NumberFormat.decimalPattern('id').format(e.value)}",
              ];
            }).toList(),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
