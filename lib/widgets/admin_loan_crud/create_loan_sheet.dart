import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../dummy/loan_dummy.dart';
import '../../dummy/tools/tools_dummy.dart';
import '../confirm_snackbar.dart';
import '../../widgets/admin_loan_crud/search_dropdown.dart';

class AdminCreateLoanSheet extends StatefulWidget {
  const AdminCreateLoanSheet({super.key});

  @override
  State<AdminCreateLoanSheet> createState() => _AdminCreateLoanSheetState();
}

class _AdminCreateLoanSheetState extends State<AdminCreateLoanSheet> {
  String? selectedBorrower;

  late DateTime _startDate;
  late DateTime _endDate;
  bool showAddTool = false;

  late TextEditingController _startDateCtrl;
  late TextEditingController _endDateCtrl;

  List<LoanItemDummy> selectedItems = [];

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 1));

    _startDateCtrl = TextEditingController(text: _fmt(_startDate));
    _endDateCtrl = TextEditingController(text: _fmt(_endDate));
  }

  String _fmt(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/"
      "${d.month.toString().padLeft(2, '0')}/"
      "${d.year}";

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked == null) return;

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

  List<ToolDummy> get _availableTools {
    return toolDummies
        .where(
          (t) =>
              t.stock > 0 &&
              t.condition == 'good' &&
              !selectedItems.any((i) => i.name == t.name),
        )
        .toList();
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
                    'Create Loan (Admin)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _label('Borrower'),
                _box(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: SearchDropdown<String>(
                    items: borrowerNames,
                    hint: 'Select borrower',
                    label: (e) => e,
                    onSelected: (v) {
                      setState(() => selectedBorrower = v);
                    },
                  ),
                ),

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
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            setState(() => selectedItems.remove(e));
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                if (showAddTool)
                  _box(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: SearchDropdown<ToolDummy>(
                      items: _availableTools,
                      hint: 'Select tool',
                      label: (t) => t.name,
                      onSelected: (tool) {
                        setState(() {
                          selectedItems.add(LoanItemDummy(name: tool.name));
                          showAddTool = false;
                        });
                      },
                    ),
                  ),

                const SizedBox(height: 8),

                _addButton(
                  label: 'Add tool',
                  onTap: () {
                    setState(() => showAddTool = true);
                  },
                ),

                const SizedBox(height: 14),

                _label('Start date'),
                _dateField(_startDateCtrl, () => _selectDate(true)),

                const SizedBox(height: 14),

                _label('End date'),
                _dateField(_endDateCtrl, () => _selectDate(false)),

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
                        label: 'Submit',
                        icon: Icons.check,
                        onTap: () {
                          showConfirmSnackBar(context, 'loan created');

                          Navigator.pop(context, {
                            'borrower': selectedBorrower,
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

  Widget _addButton({required String label, required VoidCallback onTap}) =>
      SizedBox(
        width: double.infinity,
        height: 42,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.add),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.secondary,
            side: const BorderSide(color: AppColors.secondary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(color: AppColors.primary)),
  );

  Widget _dateField(TextEditingController ctrl, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: Container(
            decoration: _boxDeco(),
            child: TextField(
              controller: ctrl,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.redAccent),
                  onPressed: onTap,
                ),
              ),
            ),
          ),
        ),
      );

  Widget _box({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 12,
    ),
  }) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: padding,
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
