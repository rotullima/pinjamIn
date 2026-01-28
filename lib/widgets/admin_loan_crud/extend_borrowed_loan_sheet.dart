import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../dummy/loan_dummy.dart';
import '../../dummy/tools/tools_dummy.dart';
import '../confirm_snackbar.dart';

class ExtendBorrowedLoanSheet extends StatefulWidget {
  final LoanDummy loan;

  const ExtendBorrowedLoanSheet({super.key, required this.loan});

  @override
  State<ExtendBorrowedLoanSheet> createState() =>
      _ExtendBorrowedLoanSheetState();
}

class _ExtendBorrowedLoanSheetState extends State<ExtendBorrowedLoanSheet> {
  late DateTime _startDate;
  late DateTime _endDate;

  late TextEditingController _startDateCtrl;
  late TextEditingController _endDateCtrl;

  late List<LoanItemDummy> selectedItems;
  bool showAddTool = false;
  ToolDummy? selectedTool;

  @override
  void initState() {
    super.initState();

    _startDate = widget.loan.startDate;
    _endDate = widget.loan.endDate;

    _startDateCtrl = TextEditingController(text: _fmt(_startDate));
    _endDateCtrl = TextEditingController(text: _fmt(_endDate));

    selectedItems = List.from(widget.loan.items);
  }

  String _fmt(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/"
      "${d.month.toString().padLeft(2, '0')}/"
      "${d.year}";

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateCtrl.text = _fmt(picked);
        } else {
          _endDate = picked;
          _endDateCtrl.text = _fmt(picked);
        }
      });
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
                    'Update Loans',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _label('Name'),
                _readonlyField(widget.loan.borrower),

                const SizedBox(height: 14),

                _label('Tools'),

                ...selectedItems.map(
                  (e) => _box(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.name,
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const SizedBox(height: 14),

                _label('Start date'),
                _readonlyField(_startDateCtrl.text),

                const SizedBox(height: 14),

                _label('End date'),
                _dateField(_endDateCtrl, () => _selectDate(false)),

                const SizedBox(height: 14),

                _label('Status'),
                _readonlyField(widget.loan.status),

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
                        onTap: () {
                          showConfirmSnackBar(
                            context,
                            'borrowed loan extended',
                          );

                          Navigator.pop(context, {
                            'items': selectedItems,
                            'startDate': _startDate,
                            'endDate': _endDate,
                          });
                        },
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
