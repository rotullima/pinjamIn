import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pinjamln/models/loan_model.dart';
import '../constants/app_colors.dart';
import '../models/loan_actions.dart';

class LoanListCard extends StatelessWidget {
  final LoanModel data;
  final List<LoanAction> actions;

  const LoanListCard({super.key, required this.data, this.actions = const []});

  String _formatDate(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Icon(
  _iconForStatus(data.status),
  color: AppColors.secondary,
),

        title: Text(
  data.borrowerName,
  style: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: AppColors.primary,
  ),
),

        subtitle: Text(
  '${_formatDate(data.startDate)} • ${data.status.name}',
  style: const TextStyle(fontSize: 12),
),

        children: [
          _row('Borrower', data.borrowerName),
          _row('Start Date', _formatDate(data.startDate)),
          _row('End Date', _formatDate(data.endDate)),

          const SizedBox(height: 8),
          const Text(
            'Items',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),

          Column(
  children: data.details.map((detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              detail.itemName ?? 'Unknown Item',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }).toList(),
),


          const SizedBox(height: 16),

          if (actions.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions.map((a) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: a.onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        a.label,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.background,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

IconData _iconForStatus(LoanStatus status) {
  switch (status) {
    case LoanStatus.pending:
      return Icons.access_time;
    case LoanStatus.approved:
      return Icons.calendar_month;
    case LoanStatus.rejected:
      return Icons.close;
    case LoanStatus.borrowed:
      return Icons.outbond;
    case LoanStatus.returning:
      return Icons.keyboard_return;
    case LoanStatus.penalty:
      return Icons.attach_money;
    case LoanStatus.returned:
      return Icons.check_circle_outline;
  }
}

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
