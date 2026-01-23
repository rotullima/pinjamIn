import 'package:flutter/material.dart';

class LoanDummy {
  final String borrower;
  final DateTime startDate;
  final String status;
  final IconData icon;

  LoanDummy({
    required this.borrower,
    required this.startDate,
    required this.status,
    required this.icon,
  });
}

final loanDummies = [
  LoanDummy(
    borrower: 'melati',
    startDate: DateTime(2026, 1, 21),
    status: 'borrowed',
    icon: Icons.outbond,
  ),
  LoanDummy(
    borrower: 'melati',
    startDate: DateTime(2026, 1, 10),
    status: 'pending',
    icon: Icons.access_time,
  ),
  LoanDummy(
    borrower: 'kingking',
    startDate: DateTime(2026, 1, 12),
    status: 'approved',
    icon: Icons.calendar_month,
  ),
  LoanDummy(
    borrower: 'asel',
    startDate: DateTime(2026, 1, 13),
    status: 'penalty',
    icon: Icons.attach_money,
  ),
  LoanDummy(
    borrower: 'nip',
    startDate: DateTime(2026, 1, 15),
    status: 'approved',
    icon: Icons.calendar_month,
  ),
];
