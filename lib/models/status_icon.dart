import 'package:flutter/material.dart';

IconData loanStatusIcon(String status) {
  switch (status) {
    case 'pending':
      return Icons.access_time;

    case 'borrowed':
      return Icons.outbond;

    case 'approved':
      return Icons.event_available; 

    case 'returning':
      return Icons.south_west; 

    case 'penalty':
      return Icons.attach_money;

    case 'returned':
      return Icons.check_circle;

    default:
      return Icons.help_outline;
  }
}
