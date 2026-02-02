import 'package:pinjamln/models/loan_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<List<DashboardStatModel>> fetchStats(
    String role, {
    String? borrowerId,
  }) async {
    final stats = <DashboardStatModel>[];

    if (role == 'admin') {
      final toolsList =
          (await _client.from('items').select('item_id, status_item'))
              as List<dynamic>;
      final toolsCount = toolsList.length;
      final damagedCount = toolsList
          .where((e) => e['status_item'] != 'good')
          .length;

      final usersCount =
          (await _client.from('profiles').select('profile_id')).length;

      final borrowedCount =
          (await _client.from('loans').select('loan_id').filter(
            'status_loan',
            'in',
            ['borrowed', 'returning', 'penalty'],
          )).length;

      final penaltyCount =
          (await _client
                  .from('loans')
                  .select('loan_id')
                  .eq('status_loan', 'penalty'))
              .length;

      stats.addAll([
        DashboardStatModel(
          title: 'Tools',
          value: toolsCount,
          subtitle: '$damagedCount damaged',
        ),
        DashboardStatModel(title: 'Users', value: usersCount, subtitle: ''),
        DashboardStatModel(
          title: 'Borrowed',
          value: borrowedCount,
          subtitle: '',
        ),
        DashboardStatModel(title: 'Penalty', value: penaltyCount, subtitle: ''),
        DashboardStatModel(
          title: 'Borrowed',
          value: borrowedCount,
          subtitle: '',
        ),
        DashboardStatModel(title: 'Penalty', value: penaltyCount, subtitle: ''),
      ]);
    } else {
      var query = _client.from('loans').select('loan_id, status_loan');

      if (role == 'borrower' && borrowerId != null) {
        query = query.eq('borrower_id', borrowerId);
      }

      final loansList = (await query) as List<dynamic>;
      stats.addAll([
        DashboardStatModel(
          title: 'Pending',
          value: loansList.where((e) => e['status_loan'] == 'pending').length,
          subtitle: '',
        ),
        DashboardStatModel(
          title: 'Approved',
          value: loansList.where((e) => e['status_loan'] == 'approved').length,
          subtitle: '',
        ),
        DashboardStatModel(
          title: 'Borrowed',
          value: loansList.where((e) => e['status_loan'] == 'borrowed').length,
          subtitle: '',
        ),
        DashboardStatModel(
          title: 'Penalty',
          value: loansList.where((e) => e['status_loan'] == 'penalty').length,
          subtitle: '',
        ),
      ]);
    }

    return stats;
  }

  static Future<List<LoanModel>> fetchAllLoans({String query = ''}) async {
    try {
      final response = await _client
          .from('loans')
          .select('''
          *,
          profiles!loans_borrower_id_fkey (name),
          loan_details (
            * ,
            items!loan_details_item_id_fkey (name)
          )
        ''')
          .order('created_at', ascending: false);

      final loans = (response as List<dynamic>)
          .map((json) => LoanModel.fromJson(json))
          .toList();

      final filtered = query.isNotEmpty
          ? loans
                .where(
                  (l) => l.borrowerName.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList()
          : loans;

      return filtered.take(5).toList();
    } catch (e) {
      throw Exception('Failed to fetch loans: $e');
    }
  }
}

class DashboardStatModel {
  final String title;
  final int value;
  final String subtitle;
  DashboardStatModel({
    required this.title,
    required this.value,
    required this.subtitle,
  });
}
