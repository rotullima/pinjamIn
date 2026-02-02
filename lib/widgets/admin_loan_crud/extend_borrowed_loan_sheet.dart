import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/loan_model.dart';
import '../../services/admin/admin_loan_action_service.dart';
import '../notifications/confirm_snackbar.dart';

class ExtendBorrowedLoanSheet extends StatefulWidget {
  final LoanModel loan;

  const ExtendBorrowedLoanSheet({super.key, required this.loan});

  @override
  State<ExtendBorrowedLoanSheet> createState() =>
      _ExtendBorrowedLoanSheetState();
}

class _ExtendBorrowedLoanSheetState extends State<ExtendBorrowedLoanSheet> {
  late DateTime _endDate;
  late TextEditingController _endDateCtrl;

  @override
  void initState() {
    super.initState();
    _endDate = widget.loan.endDate;
    _endDateCtrl = TextEditingController(text: _fmt(_endDate));
  }

  String _fmt(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  Future<void> _selectDate() async {
    DateTime initial = _endDate;
    final today = DateTime.now();

    if (initial.isBefore(today)) {
      initial = DateTime(today.year, today.month, today.day);
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final safePicked = DateTime(picked.year, picked.month, picked.day);

      setState(() {
        _endDate = safePicked;
        _endDateCtrl.text = _fmt(safePicked);
      });
    }
  }

  Future<void> _save() async {
    final today = DateTime.now();

    if (_endDate.isBefore(today)) {
      showConfirmSnackBar(context, 'the return date cannot be in the past');
      return;
    }

    try {
      await LoanActionService.extendLoan(widget.loan.loanId, _endDate);
      showConfirmSnackBar(context, 'borrowed loan extended');
      Navigator.pop(context, true);
    } catch (e) {
      showConfirmSnackBar(context, 'Fail extend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.88,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Extend Borrowed Loans',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _label('Borrower'),
                _readonlyField(widget.loan.borrowerName),

                const SizedBox(height: 14),

                _label('Tools'),
                ...widget.loan.details.map(
                  (detail) => _box(
                    child: Text(
                      detail.itemName ?? 'Item #${detail.itemId}',
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                _label('Start date'),
                _readonlyField(_fmt(widget.loan.startDate)),

                const SizedBox(height: 14),

                _label('End date'),
                _dateField(_endDateCtrl, _selectDate),

                const SizedBox(height: 14),

                _label('Status'),
                _readonlyField('borrowed'),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        label: 'Cancel',
                        icon: Icons.close,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionButton(
                        label: 'Done',
                        icon: Icons.check,
                        onTap: _save,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(color: AppColors.primary)),
  );

  Widget _readonlyField(String value) => _box(child: Text(value));

  Widget _dateField(TextEditingController ctrl, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: Container(
          width: double.infinity,
          decoration: _boxDeco(),
          child: TextField(
            controller: ctrl,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_month, color: Colors.redAccent),
                onPressed: onTap,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _box({required Widget child}) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: _boxDeco(),
    child: child,
  );

  BoxDecoration _boxDeco() => BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.15),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) => SizedBox(
    height: 42,
    child: ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: AppColors.background),
      label: Text(label, style: const TextStyle(color: AppColors.background)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
