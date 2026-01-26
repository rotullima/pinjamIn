import 'package:flutter/material.dart';

enum LoanActionType {
  reject,
  confirm,
  pickup,
  check,
  pay,
  returning
}

class LoanAction {
  final LoanActionType type;
  final String label;
  final VoidCallback onTap;

  LoanAction({
    required this.type,
    required this.label,
    required this.onTap,
  });
}
