import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';
import '../../models/tools/tool_model.dart';

class LoanService {
  static final SupabaseClient _client = SupabaseConfig.client;

  Future<void> submitLoan({
    required String borrowerId,
    required DateTime startDate,
    required DateTime endDate,
    required List<ToolModel> items,
  }) async {
    final loanRes = await _client
        .from('loans')
        .insert({
          'borrower_id': borrowerId,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'status_loan': 'pending',
        })
        .select('loan_id')
        .single();

    final int loanId = loanRes['loan_id'];

    for (final tool in items) {
      await _client.from('loan_details').insert({
        'loan_id': loanId,
        'item_id': tool.itemId,
      });
    }
  }
}
