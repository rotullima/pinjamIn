import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataReportService {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<void> printDataReport() async {
    final pdf = pw.Document();

    final categories =
        await _client.from('categories').select('*') as List<dynamic>;
    final items = await _client.from('items').select('*') as List<dynamic>;
    final fines =
        await _client.from('damage_fines').select('*') as List<dynamic>;
    final loans =
        await _client
                .from('loans')
                .select('*, loan_details(*, items(*), damage_fine(*))')
                .order('created_at', ascending: false)
            as List<dynamic>;

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Data Report',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),

              // Categories
              pw.Text(
                'Categories',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: ['ID', 'Name', 'Created At', 'Active'],
                cellAlignment: pw.Alignment.centerLeft,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                data: categories
                    .map(
                      (c) => [
                        c['category_id'].toString(),
                        c['name'] ?? '',
                        c['created_at']?.toString().split('T')[0] ?? '',
                        (c['is_active'] ?? false) ? 'Yes' : 'No',
                      ],
                    )
                    .toList(),
              ),

              pw.SizedBox(height: 16),
              // Items
              pw.Text(
                'Items',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: [
                  'ID',
                  'Name',
                  'Category ID',
                  'Stock Total',
                  'Stock Available',
                  'Active',
                ],
                cellAlignment: pw.Alignment.centerLeft,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                data: items
                    .map(
                      (i) => [
                        i['item_id'].toString(),
                        i['name'] ?? '',
                        i['category_id']?.toString() ?? '',
                        i['stock_total']?.toString() ?? '0',
                        i['stock_available']?.toString() ?? '0',
                        (i['is_active'] ?? false) ? 'Yes' : 'No',
                      ],
                    )
                    .toList(),
              ),

              pw.SizedBox(height: 16),
              // Damage Fines
              pw.Text(
                'Damage Fines',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: ['ID', 'Condition', 'Amount', 'Active', 'Created At'],
                cellAlignment: pw.Alignment.centerLeft,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                data: fines
                    .map(
                      (f) => [
                        f['fine_id'].toString(),
                        f['condition'] ?? '',
                        f['fine_amount']?.toString() ?? '0',
                        (f['is_active'] ?? false) ? 'Yes' : 'No',
                        f['created_at']?.toString().split('T')[0] ?? '',
                      ],
                    )
                    .toList(),
              ),

              pw.SizedBox(height: 16),
              // Loans
              pw.Text(
                'Loans',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              ...loans.map((l) {
                final details = l['loan_details'] as List<dynamic>? ?? [];
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Loan #${l['loan_number']} - Borrower ID: ${l['borrower_id']} - Status: ${l['status_loan']}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Start: ${l['start_date']}, End: ${l['end_date']}, Late Fine: ${l['late_fine'] ?? 0}, Note: ${l['note'] ?? ''}',
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Items:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Table.fromTextArray(
                      headers: [
                        'Item ID',
                        'Name',
                        'Return Condition',
                        'Damage Fine ID',
                        'Damage Amount',
                      ],
                      cellAlignment: pw.Alignment.centerLeft,
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      data: details.map((d) {
                        final item = d['items'] ?? {};
                        final damage = d['damage_fine'] ?? {};
                        return [
                          d['item_id']?.toString() ?? '',
                          item['name'] ?? '',
                          d['return_condition'] ?? '',
                          damage['fine_id']?.toString() ??
                              d['damage_fine']?.toString() ??
                              '',
                          damage['fine_amount']?.toString() ?? '',
                        ];
                      }).toList(),
                    ),
                    pw.SizedBox(height: 12),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
