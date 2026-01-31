import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_search_field.dart';
import '../widgets/dashboard/print_report_button.dart';
import '../widgets/dashboard/stat_card.dart';
import '../widgets/loan_card.dart';
import '../services/auth/user_session.dart';
import '../services/dashboard_service.dart';
import '../models/loan_model.dart';
import '../dummy/loan_dummy.dart';
import '../services/print_report_service.dart';

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
  final String currentBorrowerId = UserSession.id;
  final String currentBorrowerName = UserSession.name;

  List<DashboardStatModel> _stats = [];
  List<LoanModel> _displayedLoans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
      _filterLoans();
    });
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);

    try {
      final stats = await DashboardService.fetchStats(
        currentRole,
        borrowerId: currentRole == 'borrower' ? currentBorrowerId : null,
      );

      final loans = await DashboardService.fetchAllLoans(
        query: currentRole == 'borrower' ? currentBorrowerName : '',
      );

      setState(() {
        _stats = stats;
        _displayedLoans = loans;
      });
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterLoans() {
    if (_searchQuery.isEmpty || currentRole == 'borrower') return;

    final filtered = _displayedLoans
        .where((loan) => loan.borrowerName.toLowerCase().contains(_searchQuery))
        .toList();

    setState(() {
      _displayedLoans = filtered;
    });
  }

  void toggleDrawer() => setState(() => isOpen = !isOpen);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
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
                                    icon: _iconForStat(stat.title),
                                    title: stat.title,
                                    value: stat.value,
                                    subtitle: stat.subtitle,
                                  );
                                },
                              ),
                              const SizedBox(height: 24),

                              Row(
                                children: [
                                  Expanded(
                                    child: SearchField(
                                      controller: _searchController,
                                    ),
                                  ),
                                  if (currentRole == 'officer')
                                    PrintReportButton(
                                      onTap: () async {
                                        await PrintReportService.printFullReport();
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              Expanded(
                                child: _displayedLoans.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No loan data',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.only(
                                          bottom: 120,
                                        ),
                                        itemCount: _displayedLoans.length,
                                        itemBuilder: (context, index) {
                                          final loan = _displayedLoans[index];
                                          return LoanListCard(
                                            data: _adaptToDummy(loan),
                                          );
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

  IconData _iconForStat(String title) {
    switch (title.toLowerCase()) {
      case 'tools':
        return Icons.build_outlined;
      case 'users':
        return Icons.group_outlined;
      case 'borrowed':
        return Icons.outbond;
      case 'penalty':
        return Icons.attach_money;
      case 'pending':
        return Icons.access_time;
      case 'approved':
        return Icons.calendar_month;
      default:
        return Icons.info_outline;
    }
  }

  LoanDummy _adaptToDummy(LoanModel loan) {
    final items = loan.details.isNotEmpty
        ? loan.details
              .map(
                (d) => LoanItemDummy(name: d.itemName ?? 'Item #${d.itemId}'),
              )
              .toList()
        : [LoanItemDummy(name: 'No items')];

    return LoanDummy(
      borrower: loan.borrowerName,
      startDate: loan.startDate,
      endDate: loan.endDate,
      items: items,
      status: loan.status.toString().split('.').last,
      conditionNote: null,
      fineAmount: loan.lateFine?.toInt(),
      penaltyDays: null,
      isPaid: null,
    );
  }
}
