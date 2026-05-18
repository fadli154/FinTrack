import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  static final NumberFormat _currencyFormat = NumberFormat.decimalPattern('id');

  static String _formatCurrency(int value) {
    return 'Rp ${_currencyFormat.format(value.abs())}';
  }

  static String _formatSignedCurrency(int value) {
    if (value > 0) return '+ ${_formatCurrency(value)}';
    if (value < 0) return '- ${_formatCurrency(value)}';
    return 'Rp 0';
  }

  static Future<Uint8List> generateLaporanPdf({
    required int totalIncome,
    required int totalExpense,
    required List<Map<String, dynamic>> categorySummary,
    required String periodLabel,
    DateTime? reportDate,
    String title = 'LAPORAN KEUANGAN',
  }) async {
    final pdf = pw.Document();

    final now = reportDate ?? DateTime.now();
    final balance = totalIncome - totalExpense;

    final sortedCategories = [...categorySummary]
      ..sort((a, b) => (b['amount'] as int).compareTo(a['amount'] as int));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),

        /// HEADER
        header: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 4),

              pw.Text(
                'Periode: $periodLabel',
                style: const pw.TextStyle(fontSize: 10),
              ),

              pw.Text(
                DateFormat('dd MMMM yyyy', 'id').format(now),
                style: const pw.TextStyle(fontSize: 10),
              ),

              pw.SizedBox(height: 12),

              pw.Divider(thickness: 1, color: PdfColors.grey600),
            ],
          );
        },

        /// FOOTER
        footer: (context) {
          return pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Halaman ${context.pageNumber} dari ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          );
        },

        build: (context) {
          return [
            /// RINGKASAN
            pw.Text(
              'Ringkasan Keuangan',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 10),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.7),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableHeader('Keterangan'),
                    _tableHeader('Jumlah'),
                  ],
                ),

                pw.TableRow(
                  children: [
                    _tableCell('Total Pemasukan'),
                    _tableAmountCell(
                      '+ ${_formatCurrency(totalIncome)}',
                      PdfColors.green700,
                    ),
                  ],
                ),

                pw.TableRow(
                  children: [
                    _tableCell('Total Pengeluaran'),
                    _tableAmountCell(
                      '- ${_formatCurrency(totalExpense)}',
                      PdfColors.red700,
                    ),
                  ],
                ),

                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _tableCellBold('Saldo Akhir'),
                    _tableAmountCell(
                      _formatSignedCurrency(balance),
                      balance >= 0 ? PdfColors.blue700 : PdfColors.orange700,
                      bold: true,
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 24),

            /// RINGKASAN KATEGORI
            pw.Text(
              'Ringkasan Kategori',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 10),

            if (sortedCategories.isEmpty)
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Text(
                  'Tidak terdapat data kategori.',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              )
            else
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 0.7,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      _tableHeader('Kategori'),
                      _tableHeader('Jenis'),
                      _tableHeader('Jumlah'),
                    ],
                  ),

                  ...sortedCategories.map((e) {
                    final type = (e['type'] ?? 'pengeluaran').toString();

                    final amount = e['amount'] as int;

                    final isIncome = type == 'pemasukan';

                    return pw.TableRow(
                      children: [
                        _tableCell(e['name'].toString()),

                        _tableCell(isIncome ? 'Pemasukan' : 'Pengeluaran'),

                        _tableAmountCell(
                          isIncome
                              ? '+ ${_formatCurrency(amount)}'
                              : '- ${_formatCurrency(amount)}',
                          isIncome ? PdfColors.green700 : PdfColors.red700,
                        ),
                      ],
                    );
                  }),
                ],
              ),

            pw.SizedBox(height: 40),

            /// TANDA TANGAN
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  children: [
                    pw.Text(
                      'Mengetahui,',
                      style: const pw.TextStyle(fontSize: 10),
                    ),

                    pw.SizedBox(height: 50),

                    pw.Text(
                      '(___________________)',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.5),
      ),
    );
  }

  static pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }

  static pw.Widget _tableCellBold(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _tableAmountCell(
    String text,
    PdfColor color, {
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
