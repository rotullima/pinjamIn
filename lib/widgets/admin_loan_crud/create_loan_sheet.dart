import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/loan_model.dart';
import '../../services/admin/admin_loan_action_service.dart';
import '../notifications/confirm_snackbar.dart';
import '../../widgets/admin_loan_crud/search_dropdown.dart';

class AdminCreateLoanSheet extends StatefulWidget {
  const AdminCreateLoanSheet({super.key});

  @override
  State<AdminCreateLoanSheet> createState() => _AdminCreateLoanSheetState();
}

class _AdminCreateLoanSheetState extends State<AdminCreateLoanSheet> {
  BorrowerModel? selectedBorrower;
  List<BorrowerModel> borrowers = [];
  bool isLoadingBorrowers = true;

  late DateTime _startDate;
  late DateTime _endDate;
  late TextEditingController _startDateCtrl;
  late TextEditingController _endDateCtrl;

  List<ItemModel> selectedItems = [];
  List<ItemModel> availableItems = [];
  bool isLoadingItems = true;
  bool showAddItem = false;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 7)); 
    _startDateCtrl = TextEditingController(text: _fmt(_startDate));
    _endDateCtrl = TextEditingController(text: _fmt(_endDate));

    _loadBorrowers();
    _loadAvailableItems();
  }

  Future<void> _loadBorrowers() async {
    setState(() => isLoadingBorrowers = true);
    try {
      final list = await LoanActionService.fetchBorrowers();
      setState(() {
        borrowers = list;
        isLoadingBorrowers = false;
      });
    } catch (e) {
      showConfirmSnackBar(context, 'Gagal memuat daftar borrower: $e');
      setState(() => isLoadingBorrowers = false);
    }
  }

  Future<void> _loadAvailableItems() async {
    setState(() => isLoadingItems = true);
    try {
      final items = await LoanActionService.fetchAvailableItems();
      setState(() {
        availableItems = items;
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
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

  Future<void> _removeItem(ItemModel item) async {
    setState(() {
      selectedItems.remove(item);
    });
  }

  Future<void> _addItem(ItemModel item) async {
    setState(() {
      selectedItems.add(item);
      showAddItem = false;
    });
  }

  Future<void> _submit() async {
    if (selectedBorrower == null) {
      showConfirmSnackBar(context, 'Pilih borrower terlebih dahulu');
      return;
    }
    if (selectedItems.isEmpty) {
      showConfirmSnackBar(context, 'Pilih minimal satu item');
      return;
    }
    if (_endDate.isBefore(_startDate)) {
      showConfirmSnackBar(context, 'Tanggal akhir tidak boleh sebelum tanggal mulai');
      return;
    }

    try {
      final itemIds = selectedItems.map((i) => i.id).toList();

      await LoanActionService.createLoan(
        borrowerId: selectedBorrower!.id,
        startDate: _startDate,
        endDate: _endDate,
        itemIds: itemIds,
        note: null, 
      );

      showConfirmSnackBar(context, 'Loan berhasil dibuat');
      Navigator.pop(context, true); 
    } catch (e) {
      showConfirmSnackBar(context, 'Gagal membuat loan: $e');
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: isLoadingBorrowers
                      ? const Center(child: CircularProgressIndicator())
                      : borrowers.isEmpty
                          ? const Text('Tidak ada borrower tersedia', style: TextStyle(color: Colors.grey))
                          : SearchDropdown<BorrowerModel>(
                              items: borrowers,
                              hint: 'Pilih borrower',
                              label: (b) => b.name,
                              onSelected: (b) {
                                setState(() => selectedBorrower = b);
                              },
                            ),
                ),

                const SizedBox(height: 14),

                _label('Items/Tools'),

                ...selectedItems.map((item) => _box(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(color: AppColors.primary),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.redAccent),
                            onPressed: () => _removeItem(item),
                          ),
                        ],
                      ),
                    )),

                if (showAddItem)
                  _box(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: isLoadingItems
                        ? const Center(child: CircularProgressIndicator())
                        : availableItems.isEmpty
                            ? const Text('Tidak ada item tersedia', style: TextStyle(color: Colors.grey))
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
                        onTap: _submit,
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
