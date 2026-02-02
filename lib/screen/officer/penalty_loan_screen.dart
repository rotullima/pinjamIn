// import 'package:flutter/material.dart';
// import '../../constants/app_colors.dart';
// import '../../widgets/app_header.dart';
// import '../../widgets/app_drawer.dart';
// import '../../widgets/app_search_field.dart';
// import '../../widgets/loan_card.dart';
// import '../../widgets/returning_loan_sheet.dart';
// import '../../dummy/loan_dummy.dart';
// import '../../models/loan_actions.dart';
// import '../../services/auth/user_session.dart';

// class PenaltyLoanScreen extends StatefulWidget {
//   const PenaltyLoanScreen({super.key});

//   @override
//   State<PenaltyLoanScreen> createState() => _PenaltyLoanScreenState();
// }

// class _PenaltyLoanScreenState extends State<PenaltyLoanScreen> {
//   bool isOpen = false;
//   final TextEditingController _searchCtrl = TextEditingController();
//   String _query = '';

//   @override
//   void initState() {
//     super.initState();
//     _searchCtrl.addListener(() {
//       setState(() {
//         _query = _searchCtrl.text.toLowerCase().trim();
//       });
//     });
//   }

//   void toggleDrawer() => setState(() => isOpen = !isOpen);

//   List<LoanDummy> get _penaltyLoans {
//     return loanDummies.where((l) {
//       final matchStatus = l.status == 'penalty';
//       final matchSearch =
//           _query.isEmpty || l.borrower.toLowerCase().contains(_query);
//       return matchStatus && matchSearch;
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//    if (UserSession.role != 'officer') {
//       return const Scaffold(body: Center(child: Text('Access denied')));
//     }
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: AppHeader(
//                     title: 'Penalty Loan List',
//                     onToggle: toggleDrawer,
//                   ),
//                 ),

//                 SearchField(controller: _searchCtrl),

//                 const SizedBox(height: 16),

//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     itemCount: _penaltyLoans.length,
//                     itemBuilder: (context, index) {
//                       final loan = _penaltyLoans[index];

//                       return LoanListCard(
//                         data: loan,
//                         actions: [
//                           LoanAction(
//                             type: LoanActionType.pay,
//                             label: 'Pay',
//                             onTap: () async {
//                               final result = await showModalBottomSheet(
//                                 context: context,
//                                 isScrollControlled: true,
//                                 backgroundColor: Colors.transparent,
//                                 builder: (_) {
//                                   return ReturningLoanSheet(loan: loan);
//                                 },
//                               );

//                               if (result == null) return;

//                               setState(() => loanDummies.remove(loan));
//                             },
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),

//             AppDrawer(
//               isOpen: isOpen,
//               onToggle: toggleDrawer,
//               role: UserSession.role,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
