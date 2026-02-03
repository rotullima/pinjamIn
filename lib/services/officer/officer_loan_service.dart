import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/loan_model.dart';
import '../../models/tools/fine_model.dart';
import '../auth/user_session.dart';

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
            .where(
              (l) => l.borrowerName.toLowerCase().contains(query.toLowerCase()),
            )
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

  Future<void> pickupLoan(int loanId) =>
      updateLoanStatus(loanId: loanId, newStatus: LoanStatus.borrowed);

  Future<void> rejectedLoanWithOfficer({required int loanId}) async {
    final officerId = UserSession.id;

    if (officerId.isEmpty) {
      throw Exception('User not logged in');
    }

    try {
      await _client
          .from('loans')
          .update({'status_loan': 'rejected', 'officer_id': officerId})
          .eq('loan_id', loanId);
    } catch (e) {
      throw Exception('Failed to reject loan: $e');
    }
  }

  Future<void> approveLoanWithOfficer({required int loanId}) async {
    final officerId = UserSession.id;

    try {
      await _client
          .from('loans')
          .update({'status_loan': 'approved', 'officer_id': officerId})
          .eq('loan_id', loanId);
    } catch (e) {
      throw Exception('Failed to approve loan: $e');
    }
  }

  Future<void> returnLoan({
  required int loanId,
  required DateTime returnDate,
  required Map<int, ({ReturnCondition condition, int? fineId})> itemReturns,
  required double lateFine,
  required String officerId,
}) async {
  try {
    await _client
        .from('loans')
        .update({
          'status_loan': 'returned',
          'return_date': returnDate.toIso8601String(),
          'late_fine': lateFine,
          'officer_id': officerId,
        })
        .eq('loan_id', loanId);

    for (final entry in itemReturns.entries) {
      final loanDetailId = entry.key;
      final condition = entry.value.condition;
      final fineId = entry.value.fineId;

      await _client
          .from('loan_details')
          .update({
            'return_condition': condition.name, 
            'damage_fine': fineId,
          })
          .eq('loan_detail_id', loanDetailId);
    }
  } catch (e) {
    throw Exception('Failed to return loan: $e');
  }
}

Future<void> returnLoanWithPenalty({
  required int loanId,
  required DateTime returnDate,
  required double lateFine,
  required String officerId,
  required Map<int, ({ReturnCondition condition, int? fineId})> itemReturns,
}) async {
  try {
    // update loan -> penalty
    await _client
        .from('loans')
        .update({
          'status_loan': 'penalty',
          'return_date': returnDate.toIso8601String(),
          'late_fine': lateFine,
          'officer_id': officerId,
        })
        .eq('loan_id', loanId);

    // update detail items
    for (final entry in itemReturns.entries) {
      await _client
          .from('loan_details')
          .update({
            'return_condition':
                entry.value.condition.name, // good / abrasion / damage
            'damage_fine': entry.value.fineId,
          })
          .eq('loan_detail_id', entry.key);
    }
  } catch (e) {
    throw Exception('Failed to return loan with penalty: $e');
  }
}

Future<void> payPenaltyLoan({
  required int loanId,
  required String officerId,
}) async {
  try {
    await _client
        .from('loans')
        .update({
          'status_loan': 'returned',
          'officer_id': officerId,
        })
        .eq('loan_id', loanId);
  } catch (e) {
    throw Exception('Failed to pay penalty: $e');
  }
}

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
