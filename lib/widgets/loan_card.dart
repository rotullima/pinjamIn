import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/loan_actions.dart';
import '../models/loan_model.dart';

class LoanListCard extends StatelessWidget {
  final LoanModel data;
  final List<LoanAction> actions;

  const LoanListCard({
    super.key,
    required this.data,
    this.actions = const [],
  });

  String _formatDate(DateTime d) =>
      DateFormat('dd MMM yyyy').format(d);

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
        title: Text(
          data.borrowerName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.primary,
          ),
        ),
        subtitle: Text(
          '${_formatDate(data.startDate)} • ${data.status}',
          style: const TextStyle(fontSize: 12),
        ),
        children: [
          _row('Borrower', data.borrowerName),
          _row('Start Date', _formatDate(data.startDate)),
          _row('End Date', _formatDate(data.endDate)),
          _row('Status', data.status),

          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: actions.map((a) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: a.onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        a.label.toLowerCase(),
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
          ],
        ],
      ),
    );
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
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
