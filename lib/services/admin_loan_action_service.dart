import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/loan_model.dart';

class LoanService {
  final _supabase = Supabase.instance.client;

  Future<List<LoanModel>> fetchLoans({
    String? status,
    String? search,
  }) async {
    final query = _supabase
        .from('loans')
        .select('''
          loan_id,
          status_loan,
          start_date,
          end_date,
          profiles (
            name
          )
        ''');

    if (status != null && status != 'all') {
      query.eq('status_loan', status);
    }

    if (search != null && search.isNotEmpty) {
      query.ilike('profiles.name', '%$search%');
    }

    final res = await query.order('created_at', ascending: false);

    return (res as List)
        .map((e) => LoanModel.fromMap(e))
        .toList();
  }

  Future<void> deleteLoan(int loanId) async {
    await _supabase.from('loans').delete().eq('loan_id', loanId);
  }

  Future<void> updateStatus(int loanId, String status) async {
    await _supabase
        .from('loans')
        .update({'status_loan': status})
        .eq('loan_id', loanId);
  }
}
