import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/loan_card.dart';
import '../../models/loan_actions.dart';
import '../../services/auth/user_session.dart';
import '../../models/loan_model.dart';
import '../../services/borrower/loan_list_service.dart';

class LoanListScreen extends StatefulWidget {
  const LoanListScreen({super.key});

  @override
  State<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends State<LoanListScreen> {
  bool isOpen = false;
  final TextEditingController _searchCtrl = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  String _query = '';
  String _selectedStatus = 'borrowed';

  List<LoanModel> _loans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _searchCtrl.addListener(() {
      setState(() {
        _query = _searchCtrl.text.toLowerCase().trim();
      });
    });

    _fetchLoans();
  }

  void toggleDrawer() => setState(() => isOpen = !isOpen);

  Future<void> _fetchLoans() async {
    try {
      final loans = await LoanListService.fetchLoans(
        borrowerNameQuery: '', 
      );
      final filteredByUser = loans.where(
        (loan) =>
            loan.borrowerName.toLowerCase() == UserSession.name.toLowerCase(),
      );
      setState(() {
        _loans = filteredByUser.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Failed to fetch loans: $e');
    }
  }

  List<LoanModel> get _filteredLoans {
    return _loans.where((loan) {
      final matchSearch =
          _query.isEmpty || loan.borrowerName.toLowerCase().contains(_query);

      final matchStatus =
          _selectedStatus == 'all' ||
          loan.status.toString().split('.').last == _selectedStatus;

      return matchSearch && matchStatus;
    }).toList();
  }

  Widget _buildFilterButton() {
    return PopupMenuButton<String>(
      initialValue: _selectedStatus,
      onSelected: (value) {
        setState(() => _selectedStatus = value);
      },
      offset: const Offset(0, 44),
      elevation: 6,
      color: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        _popupItem(
          value: 'borrowed',
          icon: Icons.arrow_forward,
          label: 'Borrowed',
        ),
        _popupItem(
          value: 'penalty',
          icon: Icons.attach_money,
          label: 'Penalty',
        ),
        _popupItem(
          value: 'returned',
          icon: Icons.keyboard_return,
          label: 'Returned',
        ),
      ],
      child: const Icon(
        Icons.filter_alt_outlined,
        color: AppColors.secondary,
        size: 28,
      ),
    );
  }

  PopupMenuItem<String> _popupItem({
    required String value,
    required IconData icon,
    required String label,
  }) {
    final bool isActive = value == _selectedStatus;

    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isActive
              ? AppColors.secondary.withOpacity(0.15)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.secondary),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.background,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (UserSession.role != 'borrower') {
      return const Scaffold(body: Center(child: Text('Access denied')));
    }

    return Scaffold(
      key: _scaffoldMessengerKey,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppHeader(title: 'Loan List', onToggle: toggleDrawer),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: SearchField(controller: _searchCtrl)),
                      _buildFilterButton(),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredLoans.isEmpty
                      ? const Center(
                          child: Text(
                            'No loan data',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredLoans.length,
                          itemBuilder: (context, index) {
                            final loan = _filteredLoans[index];

                            List<LoanAction> actions = [];

                            if (loan.status == LoanStatus.borrowed) {
                              actions.add(
                                LoanAction(
  type: LoanActionType.returning,
  label: 'Return',
  onTap: () async {
    setState(() {
      loan.status = LoanStatus.returning;
    });

    try {
      await LoanListService.updateLoanStatus(
        loanId: loan.loanId,
        newStatus: LoanStatus.returning,
      );

      if (!mounted) return;
      _scaffoldMessengerKey.currentState?.showSnackBar(
  SnackBar(content: Text('Loan status updated to returning')),
);
    } catch (e) {
      if (!mounted) return;
      _scaffoldMessengerKey.currentState?.showSnackBar(
  SnackBar(content: Text('Failed to update status: $e')),

      );
      setState(() {
        loan.status = LoanStatus.borrowed;
      });
    }
  },
)

                              );
                            }

                            return LoanListCard(data: loan, actions: actions);
                          },
                        ),
                ),
              ],
            ),

            AppDrawer(
              isOpen: isOpen,
              onToggle: toggleDrawer,
              role: UserSession.role,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}
