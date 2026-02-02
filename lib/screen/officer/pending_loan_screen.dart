import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/loan_card.dart';
import '../../widgets/confirm_snackbar.dart';
import '../../models/loan_actions.dart';
import '../../services/auth/user_session.dart';
import '../../models/loan_model.dart';
import '../../services/officer_loan_service.dart';

class PendingLoanScreen extends StatefulWidget {
  const PendingLoanScreen({super.key});

  @override
  State<PendingLoanScreen> createState() => _PendingLoanScreenState();
}

class _PendingLoanScreenState extends State<PendingLoanScreen> {
  bool isOpen = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  bool _isLoading = true;

  List<LoanModel> _loans = [];

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
    setState(() => _isLoading = true);
    try {
      final loans = await OfficerLoanService.fetchAllLoans();
      setState(() {
        _loans = loans
            .where((l) => l.status == LoanStatus.pending)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Failed to fetch loans: $e');
    }
  }

  List<LoanModel> get _filteredLoans {
    return _loans.where((loan) {
      return _query.isEmpty ||
          loan.borrowerName.toLowerCase().contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (UserSession.role != 'officer') {
      return const Scaffold(body: Center(child: Text('Access denied')));
    }

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
                    title: 'Pending Loan List',
                    onToggle: toggleDrawer,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchField(controller: _searchCtrl),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredLoans.isEmpty
                          ? const Center(
                              child: Text(
                                'No pending loans',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filteredLoans.length,
                              itemBuilder: (context, index) {
                                final loan = _filteredLoans[index];

                                return LoanListCard(
                                  data: loan,
                                  actions: [
                                    LoanAction(
                                      type: LoanActionType.reject,
                                      label: 'Reject',
                                      onTap: () async {
                                        try {
                                          await OfficerLoanService().updateLoanStatus(
                                            loanId: loan.loanId,
                                            newStatus: LoanStatus.rejected,
                                          );

                                          showConfirmSnackBar(
                                              context, 'Loan rejected!');

                                          setState(() => _loans.remove(loan));
                                        } catch (e) {
                                          showConfirmSnackBar(
                                              context, 'Failed: $e');
                                        }
                                      },
                                    ),
                                    LoanAction(
                                      type: LoanActionType.confirm,
                                      label: 'Confirm',
                                      onTap: () async {
                                        try {
                                          await OfficerLoanService().updateLoanStatus(
                                            loanId: loan.loanId,
                                            newStatus: LoanStatus.approved,
                                          );

                                          showConfirmSnackBar(
                                              context, 'Loan approved!');

                                          setState(() => _loans.remove(loan));
                                        } catch (e) {
                                          showConfirmSnackBar(
                                              context, 'Failed: $e');
                                        }
                                      },
                                    ),
                                  ],
                                );
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
