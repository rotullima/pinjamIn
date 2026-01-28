import 'package:flutter/material.dart';
import 'package:pinjamln/widgets/admin_loan_crud/edit_pending_loan_sheet.dart';
import 'package:pinjamln/widgets/admin_loan_crud/extend_borrowed_loan_sheet.dart';
import 'package:pinjamln/widgets/admin_loan_crud/create_loan_sheet.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/loan_card.dart';
import '../../widgets/confirm_snackbar.dart';
import '../../dummy/loan_dummy.dart';
import '../../models/loan_actions.dart';
import '../../services/auth/user_session.dart';

class AdminLoanListScreen extends StatefulWidget {
  const AdminLoanListScreen({super.key});

  @override
  State<AdminLoanListScreen> createState() => _AdminLoanListScreenState();
}

class _AdminLoanListScreenState extends State<AdminLoanListScreen> {
  bool isOpen = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedStatus = 'pending';

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
      final matchSearch =
          _query.isEmpty || loan.borrower.toLowerCase().contains(_query);

      final matchStatus = loan.status.toLowerCase() == _selectedStatus;

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
        _popupItem('pending', Icons.hourglass_empty, 'Pending'),
        _popupItem('borrowed', Icons.arrow_forward, 'Borrowed'),
        _popupItem('penalty', Icons.attach_money, 'Penalty'),
      ],
      child: const Icon(
        Icons.filter_alt_outlined,
        color: AppColors.secondary,
        size: 28,
      ),
    );
  }

  PopupMenuItem<String> _popupItem(String value, IconData icon, String label) {
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
    final loans = _filteredLoans;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppHeader(
                    title: 'Loan Management',
                    onToggle: toggleDrawer,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: SearchField(controller: _searchCtrl)),
                      const SizedBox(width: 8),
                      _buildFilterButton(),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          size: 30,
                          color: AppColors.secondary,
                        ),
                        onPressed: () async {
                          final result = await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) {
                              return AdminCreateLoanSheet();
                            },
                          );

                          if (result == null) return;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: loans.isEmpty
                      ? const Center(
                          child: Text(
                            'No loan data',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: loans.length,
                          itemBuilder: (context, index) {
                            final loan = loans[index];

                            final actions = _buildAdminActions(context, loan);

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

  List<LoanAction> _buildAdminActions(BuildContext context, LoanDummy loan) {
    switch (loan.status) {
      case 'pending':
        return [
          LoanAction(
            type: LoanActionType.edit,
            label: 'Edit',
            onTap: () async {
              final result = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) {
                  return EditPendingLoanSheet(loan: loan);
                },
              );

              if (result == null) return;

              setState(() => loanDummies.remove(loan));
            },
          ),
          LoanAction(
            type: LoanActionType.delete,
            label: 'Delete',
            onTap: () {
              setState(() => loanDummies.remove(loan));
              showConfirmSnackBar(context, 'loan deleted');
            },
          ),
        ];

      case 'borrowed':
        return [
          LoanAction(
            type: LoanActionType.edit,
            label: 'Extend',
            onTap: () async {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) {
                  return ExtendBorrowedLoanSheet(loan: loan);
                },
              );
            },
          ),
          LoanAction(
            type: LoanActionType.returning,
            label: 'Returning',
            onTap: () {
              showConfirmSnackBar(context, 'return by admin');
              setState(() {
                loanDummies.remove(loan);
              });
            },
          ),
        ];

      case 'penalty':
        return [
          LoanAction(
            type: LoanActionType.returned,
            label: 'Returned',
            onTap: () {
              showConfirmSnackBar(
                context,
                'penalty resolved, force return by admin',
              );
              setState(() {
                loanDummies.remove(loan);
              });
            },
          ),
        ];

      default:
        return [];
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}
