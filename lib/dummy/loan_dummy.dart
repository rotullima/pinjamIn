import 'package:flutter/material.dart';
import '../models/status_icon.dart';

class LoanDummy {
  final String borrower;
  final DateTime startDate;
  final DateTime endDate;
  final List<LoanItemDummy> items;
  final String status;
  final String? conditionNote;
  final int? fineAmount;
  final int? penaltyDays;
  final bool? isPaid;

  const LoanDummy({
    required this.borrower,
    required this.startDate,
    required this.endDate,
    required this.items,
    required this.status,
    this.conditionNote,
    this.fineAmount,
    this.penaltyDays,
    this.isPaid,
  });

  IconData get icon => loanStatusIcon(status);
}

class LoanItemDummy {
  final String name;
  final int qty;

  LoanItemDummy({required this.name, required this.qty});
}

final loanDummies = [
  LoanDummy(
    borrower: 'melati',
    startDate: DateTime(2026, 1, 10),
    endDate: DateTime(2026, 1, 12),
    status: 'pending',
    items: [LoanItemDummy(name: 'Test Pen', qty: 1)],
  ),
  LoanDummy(
    borrower: 'indra',
    startDate: DateTime(2026, 1, 11),
    endDate: DateTime(2026, 1, 13),
    status: 'pending',
    items: [LoanItemDummy(name: 'Terminal Block', qty: 2)],
  ),

  LoanDummy(
    borrower: 'melati',
    startDate: DateTime(2026, 1, 12),
    endDate: DateTime(2026, 1, 15),
    status: 'approved',
    items: [LoanItemDummy(name: 'Test Pen', qty: 2)],
  ),
  LoanDummy(
    borrower: 'amel',
    startDate: DateTime(2026, 1, 13),
    endDate: DateTime(2026, 1, 16),
    status: 'approved',
    items: [LoanItemDummy(name: 'Terminal Block', qty: 1)],
  ),

  LoanDummy(
    borrower: 'melati',
    startDate: DateTime(2026, 1, 10),
    endDate: DateTime(2026, 1, 12),
    status: 'borrowed',
    items: [LoanItemDummy(name: 'Test Pen', qty: 2)],
  ),
  LoanDummy(
    borrower: 'rizky',
    startDate: DateTime(2026, 1, 9),
    endDate: DateTime(2026, 1, 11),
    status: 'borrowed',
    items: [LoanItemDummy(name: 'Terminal Block', qty: 3)],
  ),

  LoanDummy(
    borrower: 'melati',
    startDate: DateTime(2026, 1, 21),
    endDate: DateTime(2026, 1, 25),
    status: 'returning',
    items: [LoanItemDummy(name: 'Test Pen', qty: 1)],
  ),
  LoanDummy(
    borrower: 'dika',
    startDate: DateTime(2026, 1, 20),
    endDate: DateTime(2026, 1, 24),
    status: 'returning',
    items: [LoanItemDummy(name: 'Terminal Block', qty: 1)],
  ),

  LoanDummy(
    borrower: 'melati',
    startDate: DateTime(2026, 1, 21),
    endDate: DateTime(2026, 1, 24),
    status: 'penalty',
    items: [LoanItemDummy(name: 'Test Pen', qty: 2)],
    conditionNote: 'Abrasion 20%',
    fineAmount: 50000,
    penaltyDays: 1,
    isPaid: false,
  ),
  LoanDummy(
    borrower: 'bayu',
    startDate: DateTime(2026, 1, 18),
    endDate: DateTime(2026, 1, 20),
    status: 'penalty',
    items: [LoanItemDummy(name: 'Terminal Block', qty: 1)],
    conditionNote: 'Abrasion 20%',
    fineAmount: 50000,
    penaltyDays: 5,
    isPaid: false,
  ),

  LoanDummy(
    borrower: 'melati',
    startDate: DateTime(2026, 1, 21),
    endDate: DateTime(2026, 1, 24),
    status: 'returned',
    items: [LoanItemDummy(name: 'Test Pen', qty: 2)],
    conditionNote: 'Abrasion 20%',
    fineAmount: 50000,
    penaltyDays: 1,
    isPaid: false,
  ),
  LoanDummy(
    borrower: 'bayu',
    startDate: DateTime(2026, 1, 18),
    endDate: DateTime(2026, 1, 20),
    status: 'returned',
    items: [LoanItemDummy(name: 'Terminal Block', qty: 1)],
    conditionNote: 'Abrasion 20%',
    fineAmount: 50000,
    penaltyDays: 5,
    isPaid: false,
  ),
];
