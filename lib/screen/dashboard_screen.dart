import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_search_field.dart';
import '../widgets/dashboard/stat_card.dart';
import '../widgets/loan_card.dart';
import '../dummy/dashboard/dashboard_stats_dummy.dart';
import '../dummy/loan_dummy.dart';
import '../services/auth/user_session.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final String currentRole = UserSession.role;
  final String currentBorrowerName = UserSession.name;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void toggleDrawer() => setState(() => isOpen = !isOpen);

  List<DashboardStat> get _stats {
    if (currentRole == 'admin') {
      return adminStatsDummy;
    } else {
      return officerBorrowerStatsDummy;
    }
  }

  List<LoanDummy> get _displayedLoans {
    var loans = loanDummies;

    if (currentRole == 'borrower') {
      loans = loans
          .where(
            (loan) =>
                loan.borrower.toLowerCase() ==
                currentBorrowerName.toLowerCase() &&
                (loan.status == 'pending' || loan.status == 'approved'),
          )
          .toList();
    }

    if (_searchQuery.isNotEmpty && currentRole != 'borrower') {
      loans = loans
          .where((loan) => loan.borrower.toLowerCase().contains(_searchQuery))
          .toList();
    }

    if (loans.length > 5) {
    loans = loans.sublist(0, 5);
  }

    return loans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppHeader(title: _getTitle(), onToggle: toggleDrawer),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _stats.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1.2,
                              ),
                          itemBuilder: (context, index) {
                            final stat = _stats[index];
                            return DashboardStatCard(
                              icon: stat.icon,
                              title: stat.title,
                              value: stat.value,
                              subtitle: stat.subtitle,
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        SearchField(controller: _searchController),

                        const SizedBox(height: 16),

                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 120),
                            itemCount: _displayedLoans.length,
                            itemBuilder: (context, index) {
                              return LoanListCard(data: _displayedLoans[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            AppDrawer(
              isOpen: isOpen,
              onToggle: toggleDrawer,
              role: currentRole,
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (currentRole) {
      case 'admin':
        return 'Admin Dashboard';
      case 'officer':
        return 'Officer Dashboard';
      case 'borrower':
        return 'Borrower Dashboard';
      default:
        return 'Dashboard';
    }
  }
}
