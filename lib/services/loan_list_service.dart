import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/loan_model.dart';

class LoanListService {
  static final SupabaseClient _client = SupabaseConfig.client;

  static Future<List<LoanModel>> fetchLoans({
  String borrowerNameQuery = '',
}) async {
  try {
    final response = await _client
        .from('loans')
        .select('''
          *,
          profiles!loans_borrower_id_fkey (name),
          loan_details (
            *,
            items!loan_details_item_id_fkey (name)
          )
        ''')
        .order('created_at', ascending: false);

    final loans = (response as List<dynamic>)
        .map((json) => LoanModel.fromJson(json))
        .toList();

    // Filter hanya berdasarkan nama borrower, kalau query ada
    final filtered = borrowerNameQuery.isNotEmpty
        ? loans
            .where(
              (l) => l.borrowerName.toLowerCase().contains(
                borrowerNameQuery.toLowerCase(),
              ),
            )
            .toList()
        : loans;

    return filtered; // semua keluar, ga dibatasi 5
  } catch (e) {
    throw Exception('Failed to fetch loans for dashboard: $e');
  }
}
static Future<void> updateLoanStatus({
  required int loanId,
  required LoanStatus newStatus,
}) async {
  try {
    await _client
        .from('loans')
        .update({'status_loan': newStatus.name}) // enum → string
        .eq('loan_id', loanId);
  } catch (e) {
    throw Exception('Failed to update loan status: $e');
  }
}

}
