import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/loan_card.dart';
import '../../widgets/confirm_snackbar.dart';
import '../../dummy/loan_dummy.dart';
import '../../models/loan_actions.dart';
import '../../services/auth/user_session.dart';

class LoanListScreen extends StatefulWidget {
  const LoanListScreen({super.key});

  @override
  State<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends State<LoanListScreen> {
  bool isOpen = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  String _selectedStatus = 'borrowed';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _query = _searchCtrl.text.toLowerCase().trim();
      });
    });
  }

  void toggleDrawer() => setState(() => isOpen = !isOpen);

  List<LoanDummy> get _filteredLoans {
    return loanDummies.where((loan) {
      final matchUser = UserSession.role != 'borrower'
          ? true
          : loan.borrower.toLowerCase() == UserSession.name.toLowerCase();

      final matchSearch =
          _query.isEmpty || loan.borrower.toLowerCase().contains(_query);

      final matchStatus =
          _selectedStatus == 'all' ||
          loan.status.toLowerCase() == _selectedStatus;

      return matchUser && matchSearch && matchStatus;
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
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
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
          Icon(
            icon,
            size: 20,
            color: AppColors.secondary,
          ),
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
    final filteredLoans = _filteredLoans;

    return Scaffold(
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
                  child: filteredLoans.isEmpty
                      ? const Center(
                          child: Text(
                            'No loan data',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredLoans.length,
                          itemBuilder: (context, index) {
                            final loan = filteredLoans[index];

                            List<LoanAction> actions = [];

                            if (loan.status.toLowerCase() == 'borrowed') {
                              actions.add(
                                LoanAction(
                                  type: LoanActionType.returning,
                                  label: 'Return',
                                  onTap: () async {
                                    showConfirmSnackBar(
                                      context,
                                      'Loan has been taken',
                                    );
                                    setState(() => loanDummies.remove(loan));
                                  },
                                ),
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
