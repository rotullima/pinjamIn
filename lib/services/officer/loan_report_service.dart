import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoanReportService {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<void> printLoanReport() async {
    final pdf = pw.Document();

    // ambil data loans beserta details
    final loans = await _client.from('loans').select('''
  *,
  borrower:profiles!loans_borrower_id_fkey(name),
  officer:profiles!loans_officer_id_fkey(name),
  loan_details(*, items(name), damage_fine(condition, fine_amount))
''').order('created_at', ascending: false) as List<dynamic>;

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return [
            pw.Text(
              'Laporan Peminjaman',
              style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            ...loans.map((loan) {
              final details = loan['loan_details'] as List<dynamic>? ?? [];
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Peminjaman #${loan['loan_number']}',
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text('Peminjam: ${loan['borrower']?['name'] ?? '-'}'),
                        pw.Text('Petugas: ${loan['officer']?['name'] ?? '-'}'),
                        pw.Text('Status: ${loan['status_loan'] ?? '-'}'),
                        pw.Text('Tanggal Pinjam: ${loan['start_date'] ?? '-'}'),
                        pw.Text('Tanggal Kembali: ${loan['end_date'] ?? '-'}'),
                        pw.Text('Denda Keterlambatan: ${loan['late_fine'] ?? 0}'),
                        pw.Text('Catatan: ${loan['note'] ?? '-'}'),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Daftar Barang:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Table.fromTextArray(
                          headers: [
                            'Nama Barang',
                            'Kondisi Kembali',
                            'Denda Rusak',
                          ],
                          cellAlignment: pw.Alignment.centerLeft,
                          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          data: details.map((d) {
                            final item = d['items'] ?? {};
                            final fine = d['damage_fine'] ?? {};
                            return [
                              item['name'] ?? '-',
                              d['return_condition'] ?? '-',
                              fine['condition'] != null
                                  ? '${fine['condition']} (${fine['fine_amount'] ?? 0})'
                                  : '-',
                            ];
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 16),
                ],
              );
            }).toList(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}