import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/loan_model.dart';
import '../../services/admin/admin_loan_action_service.dart';
import '../notifications/confirm_snackbar.dart';
import '../../widgets/admin_loan_crud/search_dropdown.dart';

class EditPendingLoanSheet extends StatefulWidget {
  final LoanModel loan;

  const EditPendingLoanSheet({super.key, required this.loan});

  @override
  State<EditPendingLoanSheet> createState() => _EditPendingLoanSheetState();
}

class _EditPendingLoanSheetState extends State<EditPendingLoanSheet> {
  late DateTime _startDate;
  late DateTime _endDate;
  late TextEditingController _startDateCtrl;
  late TextEditingController _endDateCtrl;

  late List<LoanDetailModel> selectedDetails;
  List<ItemModel> availableItems = [];
  bool isLoadingItems = true;
  bool showAddItem = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.loan.startDate;
    _endDate = widget.loan.endDate;
    _startDateCtrl = TextEditingController(text: _fmt(_startDate));
    _endDateCtrl = TextEditingController(text: _fmt(_endDate));

    selectedDetails = List.from(widget.loan.details);
    _loadAvailableItems();
  }

  Future<void> _loadAvailableItems() async {
    setState(() => isLoadingItems = true);
    try {
      final items = await LoanActionService.fetchAvailableItems();
      setState(() {
        availableItems = items.where((item) {
          return !selectedDetails.any((d) => d.itemId == item.id);
        }).toList();
        isLoadingItems = false;
      });
    } catch (e) {
      showConfirmSnackBar(context, 'Gagal memuat daftar item: $e');
      setState(() => isLoadingItems = false);
    }
  }

  String _fmt(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (picked != null) {
      final safeDate = DateTime(picked.year, picked.month, picked.day);

      setState(() {
        if (isStart) {
          _startDate = safeDate;
          _startDateCtrl.text = _fmt(safeDate);
        } else {
          _endDate = safeDate;
          _endDateCtrl.text = _fmt(safeDate);
        }
      });
    }
  }

  Future<void> _removeItem(LoanDetailModel detail) async {
    try {
      await LoanActionService.removeItemFromLoan(detail.loanDetailId!);
      setState(() {
        selectedDetails.remove(detail);
      });
      await _loadAvailableItems();
      showConfirmSnackBar(context, 'Item dihapus dari pinjaman');
    } catch (e) {
      showConfirmSnackBar(context, 'Gagal menghapus: $e');
    }
  }

  Future<void> _addItem(ItemModel item) async {
    try {
      await LoanActionService.addItemToLoan(widget.loan.loanId, item.id);
      setState(() {
        selectedDetails.add(
          LoanDetailModel(
            loanDetailId: null,
            itemId: item.id,
            itemName: item.name,
          ),
        );
        showAddItem = false;
      });
      await _loadAvailableItems();
      showConfirmSnackBar(context, '${item.name} ditambahkan');
    } catch (e) {
      showConfirmSnackBar(context, 'Gagal menambahkan: $e');
    }
  }

  Future<void> _save() async {
    try {
      if (_startDate != widget.loan.startDate ||
          _endDate != widget.loan.endDate) {
        await LoanActionService.updateLoanDates(
          widget.loan.loanId,
          startDate: _startDate != widget.loan.startDate ? _startDate : null,
          endDate: _endDate != widget.loan.endDate ? _endDate : null,
        );
      }
      showConfirmSnackBar(context, 'Peminjaman pending berhasil diperbarui');
      Navigator.pop(context, true);
    } catch (e) {
      showConfirmSnackBar(context, 'Gagal menyimpan: $e');
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
                    'Edit Pending Loan',
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

                _label('Items/Tools'),

                ...selectedDetails.map(
                  (detail) => _box(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            detail.itemName ?? 'Item #${detail.itemId}',
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _removeItem(detail),
                        ),
                      ],
                    ),
                  ),
                ),

                if (showAddItem)
                  _box(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: isLoadingItems
                        ? const Center(child: CircularProgressIndicator())
                        : availableItems.isEmpty
                        ? const Text(
                            'Tidak ada item tersedia',
                            style: TextStyle(color: Colors.grey),
                          )
                        : SearchDropdown<ItemModel>(
                            items: availableItems,
                            hint: 'Pilih item',
                            label: (item) => item.name,
                            onSelected: _addItem,
                          ),
                  ),

                const SizedBox(height: 8),

                _addButton(
                  label: 'Tambah Item',
                  onTap: () => setState(() => showAddItem = true),
                ),

                const SizedBox(height: 14),

                _label('Start Date'),
                _dateField(_startDateCtrl, () => _selectDate(true)),

                const SizedBox(height: 14),

                _label('End Date'),
                _dateField(_endDateCtrl, () => _selectDate(false)),

                const SizedBox(height: 14),

                _label('Status'),
                _readonlyField('pending'),

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
                        label: 'Simpan',
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
                icon: const Icon(Icons.edit, color: Colors.redAccent),
                onPressed: onTap,
              ),
            ),
          ),
        ),
      ),
    );
  }

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
