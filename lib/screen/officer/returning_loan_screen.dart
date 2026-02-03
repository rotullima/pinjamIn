import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/loan_card.dart';
import '../../widgets/returning_loan_sheet.dart';
import '../../models/loan_actions.dart';
import '../../services/auth/user_session.dart';
import '../../models/loan_model.dart';
import '../../services/officer/officer_loan_service.dart';
import '../../widgets/notifications/confirm_snackbar.dart';

class ReturningLoanScreen extends StatefulWidget {
  const ReturningLoanScreen({super.key});

  @override
  State<ReturningLoanScreen> createState() => _ReturningLoanScreenState();
}

class _ReturningLoanScreenState extends State<ReturningLoanScreen> {
  bool isOpen = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  bool _isLoading = true;

  List<LoanModel> _loans = [];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.toLowerCase());
    });
    _fetchLoans();
  }

  void toggleDrawer() => setState(() => isOpen = !isOpen);

  Future<void> _fetchLoans() async {
    try {
      final loans = await OfficerLoanService.fetchAllLoans();
      setState(() {
        _loans = loans.where((l) => l.status == LoanStatus.returning).toList();
        _isLoading = false;
      });
    } catch (e) {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (UserSession.role != 'officer') {
      return const Scaffold(body: Center(child: Text('Access denied')));
    }

    final filtered = _loans.where((l) {
      return _query.isEmpty || l.borrowerName.toLowerCase().contains(_query);
    }).toList();

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
                    title: 'Returning Loan List',
                    onToggle: toggleDrawer,
                  ),
                ),

                SearchField(controller: _searchCtrl),
                const SizedBox(height: 16),

                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final loan = filtered[index];

                            return LoanListCard(
                              data: loan,
                              actions: [
                                LoanAction(
                                  type: LoanActionType.check,
                                  label: 'Check',
                                  onTap: () async {
                                    final result = await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) =>
                                          ReturningLoanSheet(loan: loan),
                                    );

                                    if (result == null) return;

                                    setState(() => _loans.remove(loan));

                                    if (result == 'returned') {
                                      showConfirmSnackBar(
                                        context,
                                        'Loan returned',
                                      );
                                    } else if (result == 'penalty') {
                                      showConfirmSnackBar(
                                        context,
                                        'Marked as penalty',
                                      );
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
}
