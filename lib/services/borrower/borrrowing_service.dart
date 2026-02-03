import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';
import '../../models/tools/tool_model.dart';
import '../../services/admin/activity_log_service.dart';           // ← tambahkan import ini
import '../../models/activity_log_model.dart';

class LoanService {
  static final SupabaseClient _client = SupabaseConfig.client;
  final ActivityLogService _logService = ActivityLogService();

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
        .select('loan_id, loan_number')
        .single();
        print('Loan response setelah insert: $loanRes');

    final int loanId = loanRes['loan_id'];
    final int? loanNumber = loanRes['loan_number'] as int?;

    for (final tool in items) {
      await _client.from('loan_details').insert({
        'loan_id': loanId,
        'item_id': tool.itemId,
      });
    }
    await _logService.createActivityLog(
      userId: borrowerId,  
      action: ActionEnum.borrow,
      entity: EntityEnum.loan,
      entityId: loanNumber ?? loanId,
    );
  } 
}