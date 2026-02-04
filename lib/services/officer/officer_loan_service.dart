import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/loan_model.dart';
import '../../models/tools/fine_model.dart';
import '../auth/user_session.dart';
import '../../services/admin/activity_log_service.dart';
import '../../models/activity_log_model.dart';

class OfficerLoanService {
  static final SupabaseClient _client = Supabase.instance.client;
  static final ActivityLogService _logService = ActivityLogService();

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
      final loanData = await _client
          .from('loans')
          .select('loan_number')
          .eq('loan_id', loanId)
          .single();

      final int loanNumber = loanData['loan_number'] as int;

      await _client
          .from('loans')
          .update({'status_loan': 'rejected', 'officer_id': officerId})
          .eq('loan_id', loanId);

      await _logService.createActivityLog(
        userId: officerId,
        action: ActionEnum.reject,
        entity: EntityEnum.loan,
        entityId: loanNumber,
      );
    } catch (e) {
      throw Exception('Failed to reject loan: $e');
    }
  }

  Future<void> approveLoanWithOfficer({required int loanId}) async {
    final officerId = UserSession.id;

    if (officerId.isEmpty) {
      throw Exception('User not logged in');
    }

    try {
      final loanData = await _client
          .from('loans')
          .select('loan_number')
          .eq('loan_id', loanId)
          .single();

      final int loanNumber = loanData['loan_number'] as int;

      await _client
          .from('loans')
          .update({'status_loan': 'approved', 'officer_id': officerId})
          .eq('loan_id', loanId);

      await _logService.createActivityLog(
        userId: officerId,
        action: ActionEnum.approve,
        entity: EntityEnum.loan,
        entityId: loanNumber,
        fieldName: 'status_loan',
        newValue: 'approved',
      );
    } catch (e) {
      throw Exception('Failed to approve loan: $e');
    }
  }

  Future<void> _updateReturnCore({
    required int loanId,
    required String status,
    required DateTime returnDate,
    required double lateFine,
    required String officerId,
    required Map<int, ({ReturnCondition condition, int? fineId})> itemReturns,
  }) async {
    await _client
        .from('loans')
        .update({
          'status_loan': status,
          'return_date': returnDate.toIso8601String().split('T')[0],
          'late_fine': lateFine,
          'officer_id': officerId,
        })
        .eq('loan_id', loanId);

    for (final entry in itemReturns.entries) {
      await _client
          .from('loan_details')
          .update({
            'return_condition': entry.value.condition.name,
            'damage_fine': entry.value.fineId,
          })
          .eq('loan_detail_id', entry.key);
    }
  }

  Future<void> returnLoan({
    required int loanId,
    required DateTime returnDate,
    required Map<int, ({ReturnCondition condition, int? fineId})> itemReturns,
    required double lateFine,
    required String officerId,
  }) async {
    final loanData = await _client
        .from('loans')
        .select('loan_number')
        .eq('loan_id', loanId)
        .single();

    final loanNumber = loanData['loan_number'] as int;

    await _updateReturnCore(
      loanId: loanId,
      status: 'returned',
      returnDate: returnDate,
      lateFine: lateFine,
      officerId: officerId,
      itemReturns: itemReturns,
    );

    await _logService.createActivityLog(
      userId: officerId,
      action: ActionEnum.returned,
      entity: EntityEnum.loan,
      entityId: loanNumber,
      fieldName: 'status_loan',
      newValue: 'returned',
    );
  }

  Future<void> returnLoanWithPenalty({
    required int loanId,
    required DateTime returnDate,
    required double lateFine,
    required String officerId,
    required Map<int, ({ReturnCondition condition, int? fineId})> itemReturns,
  }) async {
    await _updateReturnCore(
      loanId: loanId,
      status: 'penalty',
      returnDate: returnDate,
      lateFine: lateFine,
      officerId: officerId,
      itemReturns: itemReturns,
    );
  }

  Future<void> payPenaltyLoan({
    required int loanId,
    required String officerId,
  }) async {
    try {
      final loanData = await _client
          .from('loans')
          .select('loan_number')
          .eq('loan_id', loanId)
          .single();

      final int loanNumber = loanData['loan_number'] as int;

      await _client
          .from('loans')
          .update({'status_loan': 'returned', 'officer_id': officerId})
          .eq('loan_id', loanId);

      await _logService.createActivityLog(
        userId: officerId,
        action: ActionEnum
            .returned, 
        entity: EntityEnum.loan,
        entityId: loanNumber,
        fieldName: 'status_loan',
        oldValue: 'penalty',
        newValue: 'returned',
      );
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
