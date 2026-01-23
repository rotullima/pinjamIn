import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../dummy/loan_dummy.dart';

class LoanListCard extends StatelessWidget {
  final LoanDummy data;

  const LoanListCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(data.icon, size: 50, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('borrower: ${data.borrower}'),
                Text('start: ${data.startDate.toString().split(" ")[0]}'),
                Text('status: ${data.status}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
