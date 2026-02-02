import 'package:pinjamln/models/loan_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';
import '../auth/user_session.dart';

class LoanActionService {
  static final SupabaseClient _client = SupabaseConfig.client;

  static Future<List<LoanModel>> fetchLoans({
    required String status,
    String query = '',
  }) async {
    try {
      var response = await _client
          .from('loans')
          .select('''
          *,
          profiles!loans_borrower_id_fkey (name),
          loan_details (
            *,
            items!loan_details_item_id_fkey (name)
          )
        ''')
          .eq('status_loan', status)
          .ilike('profiles.name', '%$query%')
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => LoanModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch loans: $e');
    }
  }

  static Future<List<BorrowerModel>> fetchBorrowers() async {
    try {
      final response = await _client
          .from('profiles')
          .select('profile_id, name')
          .eq('role', 'borrower')
          .order('name');

      return (response as List<dynamic>)
          .map((json) => BorrowerModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch borrowers: $e');
    }
  }

  static Future<List<ItemModel>> fetchAvailableItems() async {
    try {
      final response = await _client
          .from('items')
          .select('item_id, name, stock_available')
          .gt('stock_available', 0)
          .eq('is_active', true)
          .order('name');

      return (response as List<dynamic>)
          .map((json) => ItemModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  static Future<void> createLoan({
    required String borrowerId,
    required DateTime startDate,
    required DateTime endDate,
    required List<int> itemIds,
    String? note,
  }) async {
    try {
      final officerId = UserSession.id;

      final loanResponse = await _client
          .from('loans')
          .insert({
            'borrower_id': borrowerId,
            'officer_id': officerId,
            'start_date': startDate.toIso8601String(),
            'end_date': endDate.toIso8601String(),
            'status_loan': 'pending',
            'note': note,
          })
          .select('loan_id');

      final loanId = loanResponse[0]['loan_id'] as int;

      for (var itemId in itemIds) {
        await _client.from('loan_details').insert({
          'loan_id': loanId,
          'item_id': itemId,
        });
      }
    } catch (e) {
      throw Exception('Failed to create loan: $e');
    }
  }

  static Future<void> deleteLoan(int loanId) async {
    try {
      await _client.from('loan_details').delete().eq('loan_id', loanId);
      await _client.from('loans').delete().eq('loan_id', loanId);
    } catch (e) {
      throw Exception('Failed to delete loan: $e');
    }
  }

  static Future<void> updateLoanStatus(int loanId, LoanStatus newStatus) async {
    try {
      await _client
          .from('loans')
          .update({'status_loan': newStatus.toString().split('.').last})
          .eq('loan_id', loanId);
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }

  static Future<void> updateLoanDates(
    int loanId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (startDate != null) {
        final dateStr =
            "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
        data['start_date'] = dateStr;
      }
      if (endDate != null) {
        final dateStr =
            "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
        data['end_date'] = dateStr;
      }

      if (data.isNotEmpty) {
        await _client.from('loans').update(data).eq('loan_id', loanId);
      }
    } catch (e) {
      throw Exception('Gagal update tanggal: $e');
    }
  }

  static Future<void> extendLoan(int loanId, DateTime newEndDate) async {
    try {
      await _client
          .from('loans')
          .update({'end_date': newEndDate.toIso8601String()})
          .eq('loan_id', loanId)
          .eq('status_loan', 'borrowed');
    } catch (e) {
      throw Exception('Failed to extend loan: $e');
    }
  }

  static Future<void> addItemToLoan(int loanId, int itemId) async {
    try {
      await _client.from('loan_details').insert({
        'loan_id': loanId,
        'item_id': itemId,
      });
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
  }

  static Future<void> removeItemFromLoan(int loanDetailId) async {
    try {
      await _client
          .from('loan_details')
          .delete()
          .eq('loan_detail_id', loanDetailId);
    } catch (e) {
      throw Exception('Failed to remove item: $e');
    }
  }

  static Future<void> forceReturnFromPenalty(int loanId) async {
    try {
      await _client
          .from('loans')
          .update({'status_loan': 'returned', 'late_fine': 0})
          .eq('loan_id', loanId)
          .eq('status_loan', 'penalty');
    } catch (e) {
      throw Exception('Failed to force return: $e');
    }
  }
}
