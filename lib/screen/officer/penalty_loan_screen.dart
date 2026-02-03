import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/loan_card.dart';
import '../../widgets/penalty_loan_sheet.dart';
import '../../models/loan_model.dart';
import '../../models/loan_actions.dart';
import '../../services/auth/user_session.dart';
import '../../services/officer/officer_loan_service.dart';

class PenaltyLoanScreen extends StatefulWidget {
  const PenaltyLoanScreen({super.key});

  @override
  State<PenaltyLoanScreen> createState() => _PenaltyLoanScreenState();
}

class _PenaltyLoanScreenState extends State<PenaltyLoanScreen> {
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

Future<void> _fetchLoans() async {
  final data = await OfficerLoanService.fetchAllLoans();
  setState(() {
    _loans = data.where((l) => l.status == LoanStatus.penalty).toList();
    _isLoading = false;
  });
}

  void toggleDrawer() => setState(() => isOpen = !isOpen);

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
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: AppHeader(
                          title: 'Penalty Loan List',
                          onToggle: toggleDrawer,
                        ),
                      ),

                      SearchField(controller: _searchCtrl),

                      const SizedBox(height: 16),

                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _loans.length,
                          itemBuilder: (context, index) {
                            final loan = _loans[index];

                            return LoanListCard(
                              data: loan,
                              actions: [
                                LoanAction(
                                  type: LoanActionType.pay,
                                  label: 'Pay',
                                  onTap: () async {
                                    final result = await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => PenaltyLoanSheet(loan: loan),
                                    );

                                    if (result == 'paid') {
                                      setState(() => _loans.remove(loan));
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
