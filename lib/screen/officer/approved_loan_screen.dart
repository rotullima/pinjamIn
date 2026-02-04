import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/loan_card.dart';
import '../../models/loan_actions.dart';
import '../../services/auth/user_session.dart';
import '../../models/loan_model.dart';
import '../../services/officer/officer_loan_service.dart';
import '../../widgets/notifications/app_toast.dart';

class ApprovedLoanScreen extends StatefulWidget {
  const ApprovedLoanScreen({super.key});

  @override
  State<ApprovedLoanScreen> createState() => _ApprovedLoanScreenState();
}

class _ApprovedLoanScreenState extends State<ApprovedLoanScreen> {
  bool isOpen = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  bool _isLoading = true;
  List<LoanModel> _loans = [];

  final OfficerLoanService _service = OfficerLoanService();

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
      final allLoans = await OfficerLoanService.fetchAllLoans();
      setState(() {
        _loans = allLoans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Failed to fetch loans: $e');
    }
  }

  List<LoanModel> get _approvedLoans {
    return _loans.where((l) {
      final matchStatus = l.status == LoanStatus.approved;
      final matchSearch =
          _query.isEmpty || l.borrowerName.toLowerCase().contains(_query);
      return matchStatus && matchSearch;
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
                    title: 'Approved Loan List',
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
                      : _approvedLoans.isEmpty
                      ? const Center(
                          child: Text(
                            'No approved loans',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _approvedLoans.length,
                          itemBuilder: (context, index) {
                            final loan = _approvedLoans[index];

                            List<LoanAction> actions = [
                              LoanAction(
                                type: LoanActionType.pickup,
                                label: 'Pick Up',
                                onTap: () async {
                                  try {
                                    await _service.pickupLoan(loan.loanId);

                                    setState(() {
                                      final i = _loans.indexOf(loan);
                                      _loans[i] = LoanModel(
                                        loanId: loan.loanId,
                                        borrowerId: loan.borrowerId,
                                        borrowerName: loan.borrowerName,
                                        officerId: loan.officerId,
                                        startDate: loan.startDate,
                                        endDate: loan.endDate,
                                        status: LoanStatus.borrowed,
                                        returnDate: loan.returnDate,
                                        lateFine: loan.lateFine,
                                        note: loan.note,
                                        createdAt: loan.createdAt,
                                        loanNumber: loan.loanNumber,
                                        details: loan.details,
                                      );
                                    });

                                    showToast(
                                      context,
                                      'Loan status changed to borrowed',
                                    );
                                  } catch (e) {
                                    showToast(
                                      context,
                                      'Failed to update status: $e',
                                    );
                                  }
                                },
                              ),
                            ];

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
