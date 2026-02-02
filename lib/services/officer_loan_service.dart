import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/loan_model.dart';
import '../models/tools/fine_model.dart';

class OfficerLoanService {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<List<LoanModel>> fetchAllLoans({String query = ''}) async {
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

      if (query.isNotEmpty) {
        return loans
            .where((l) =>
                l.borrowerName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      return loans;
    } catch (e) {
      throw Exception('Failed to fetch loans: $e');
    }
  }

  Future<void> updateLoanStatus({
    required int loanId,
    required LoanStatus newStatus,
  }) async {
    try {
      await _client
          .from('loans')
          .update({'status_loan': newStatus.toString().split('.').last})
          .eq('loan_id', loanId);
    } catch (e) {
      throw Exception('Failed to update loan status: $e');
    }
  }

  Future<void> approveLoan(int loanId) =>
      updateLoanStatus(loanId: loanId, newStatus: LoanStatus.borrowed);
Future<void> returnLoan({
    required int loanId,
    required DateTime returnDate,
    required Map<int, int?> itemDamageFines, 
    required double lateFine,
    required String officerId,
  }) async {
    final batch = _client.from('loans').update({
      'status_loan': 'returned',
      'return_date': returnDate.toIso8601String(),
      'late_fine': lateFine,
      'officer_id': officerId,
    }).eq('loan_id', loanId);

    try {
      // Update loans table
      await batch;

      // Update loan_details per item
      for (final entry in itemDamageFines.entries) {
        final loanDetailId = entry.key;
        final fineId = entry.value; // bisa null kalau ga ada denda

        await _client
            .from('loan_details')
            .update({
              'return_condition': fineId != null ? 'damaged' : 'good',
              'damage_fine': fineId,
            })
            .eq('loan_detail_id', loanDetailId);
      }
    } catch (e) {
      throw Exception('Failed to return loan: $e');
    }
  }

  /// Fetch damage fines dari DB
  Future<List<FineModel>> fetchFines() async {
    try {
      final response = await _client.from('damage_fines').select('*');
      final data = response as List<dynamic>;
      return data.map((json) => FineModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch fines: $e');
    }
  }
}


