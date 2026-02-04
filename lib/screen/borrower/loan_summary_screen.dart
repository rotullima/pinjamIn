import 'package:flutter/material.dart';
import 'package:pinjamln/constants/app_colors.dart';
import 'package:pinjamln/widgets/notifications/confirm_delete_dialog.dart';
import '../../widgets/app_header.dart';
import '../../services/auth/user_session.dart';
import '../../models/tools/tool_model.dart';
import '../../services/borrower/borrrowing_service.dart';
import '../../widgets/notifications/app_toast.dart';

class LoanSummaryScreen extends StatefulWidget {
  final List<ToolModel> cart;

  const LoanSummaryScreen({super.key, required this.cart});

  @override
  State<LoanSummaryScreen> createState() => _LoanSummaryScreenState();
}

class _LoanSummaryScreenState extends State<LoanSummaryScreen> {
  final TextEditingController _startDateCtrl = TextEditingController();
  final TextEditingController _endDateCtrl = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    super.dispose();
  }

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
          _startDateCtrl.text =
              "${picked.day.toString().padLeft(2, '0')}/"
              "${picked.month.toString().padLeft(2, '0')}/"
              "${picked.year}";
        } else {
          _endDate = picked;
          _endDateCtrl.text =
              "${picked.day.toString().padLeft(2, '0')}/"
              "${picked.month.toString().padLeft(2, '0')}/"
              "${picked.year}";
        }
      });
    }
  }

  void _removeFromCart(int index) {
    setState(() {
      widget.cart.removeAt(index);
    });
    if (widget.cart.isEmpty) {
      Navigator.pop(context, true);
    }
  }

  void _submitLoan() async {
    if (widget.cart.isEmpty) {
      showToast(context, 'Cart is empty', isError: true);

      return;
    }

    if (_startDate == null || _endDate == null) {
      showToast(context, 'Input start date & end date first', isError: true);

      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      showToast(
        context,
        'End date must not be before start date',
        isError: true,
      );

      return;
    }

    try {
      await LoanService().submitLoan(
        borrowerId: UserSession.id,
        startDate: _startDate!,
        endDate: _endDate!,
        items: widget.cart,
      );

      showToast(context, 'Loan application successfully submitted');

      widget.cart.clear();
      Navigator.pop(context, true);
    } catch (e) {
      showToast(context, 'Failed to submit loan', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (UserSession.role != 'borrower') {
      return const Scaffold(body: Center(child: Text('Access denied')));
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: 'Loan Summary', showProfile: false),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item: (${widget.cart.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: widget.cart.isEmpty
                  ? const Center(
                      child: Text(
                        'No item chooses',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.cart.length,
                      itemBuilder: (context, index) {
                        final tool = widget.cart[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 4,
                          color: AppColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: tool.imagePath != null
                                  ? Image.network(
                                      tool.imagePath!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/no_image.png',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            title: Text(
                              tool.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            subtitle: Text(
                              tool.category,
                              style: TextStyle(color: AppColors.primary),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: AppColors.secondary,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => ConfirmDeleteDialog(
                                    message:
                                        'Sure to remove this item from loan?',
                                    onConfirm: () => _removeFromCart(index),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Loan Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _dateField(
                    label: 'Start Date',
                    controller: _startDateCtrl,
                    onTap: () => _selectDate(true),
                  ),
                  const SizedBox(height: 16),

                  _dateField(
                    label: 'End Date',
                    controller: _endDateCtrl,
                    onTap: () => _selectDate(false),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: widget.cart.isEmpty ? null : _submitLoan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  'Apply Loan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.background,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'dd/mm/yyyy',
            suffixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.secondary.withOpacity(0.5),
              ),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.6),
          ),
          onTap: onTap,
        ),
      ],
    );
  }
}
