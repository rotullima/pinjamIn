import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/loan_model.dart';
import '../models/tools/fine_model.dart';
import '../models/loan_fine_state.dart';
import '../services/officer/officer_loan_service.dart';
import '../services/auth/user_session.dart';
import '../widgets/notifications/confirm_snackbar.dart';
import 'package:intl/intl.dart';

class ReturningLoanSheet extends StatefulWidget {
  final LoanModel loan;

  const ReturningLoanSheet({super.key, required this.loan});

  @override
  State<ReturningLoanSheet> createState() => _ReturningLoanSheetState();
}

class _ReturningLoanSheetState extends State<ReturningLoanSheet> {
  final OfficerLoanService _service = OfficerLoanService();

  final TextEditingController payCtrl = TextEditingController();

  Map<int, ({ReturnCondition condition, int? fineId})> _buildItemReturns() {
    return {
      for (final entry in itemFines.entries)
        entry.key: (
          condition: entry.value?.returnCondition ?? ReturnCondition.good,
          fineId: entry.value?.id,
        ),
    };
  }

  final NumberFormat _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _formatRp(num value) => _rupiah.format(value);

  late LoanFineState fineState;

  List<FineModel> fines = [];

  late Map<int, FineModel?> itemFines;

  @override
  void initState() {
    super.initState();

    itemFines = {
      for (var d in widget.loan.details)
        if (d.loanDetailId != null) d.loanDetailId!: null,
    };

    fineState = _calculateLateFine(widget.loan.endDate);

    _loadFines();
  }

  Future<void> _loadFines() async {
    final data = await _service.fetchFines();
    setState(() => fines = data);
  }

  LoanFineState _calculateLateFine(DateTime endDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    final lateDays = today.isAfter(end) ? today.difference(end).inDays : 0;
    final lateFine = lateDays * 2500;

    return LoanFineState(
      lateDays: lateDays,
      lateFine: lateFine,
      conditionFine: 0,
      totalFine: lateFine,
    );
  }

  void _recalculateFine() {
    final conditionTotal = itemFines.values.fold<int>(
      0,
      (sum, f) => sum + (f?.fineAmount.toInt() ?? 0),
    );

    setState(() {
      fineState = LoanFineState(
        lateDays: fineState.lateDays,
        lateFine: fineState.lateFine,
        conditionFine: conditionTotal,
        totalFine: fineState.lateFine + conditionTotal,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final payAmount =
        int.tryParse(payCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final canConfirm =
        fineState.totalFine == 0 || payAmount == fineState.totalFine;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Return Form',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Late return: ${fineState.lateDays} days x 2500',
                style: const TextStyle(color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              _readonly(_formatRp(fineState.lateFine)),

              const SizedBox(height: 14),
              const Text(
                'Condition per item',
                style: TextStyle(color: AppColors.primary),
              ),

              const SizedBox(height: 8),

              Column(
                children: widget.loan.details.map((detail) {
                  if (detail.loanDetailId == null) return const SizedBox();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DropdownButtonFormField<FineModel>(
                      value: itemFines[detail.loanDetailId],
                      decoration: _boxDeco(),
                      hint: Text(
                        detail.itemName ?? 'Item',
                        style: const TextStyle(color: AppColors.primary),
                      ),
                      items: fines
                          .map(
                            (f) => DropdownMenuItem(
                              value: f,
                              child: Text(
                                f.condition,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        itemFines[detail.loanDetailId!] = v;
                        _recalculateFine();
                      },
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),
              const Text(
                'Total Fine',
                style: TextStyle(color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              _readonly(_formatRp(fineState.totalFine)),

              const SizedBox(height: 14),
              const Text(
                'Pay amount',
                style: TextStyle(color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              _input(payCtrl),

              const SizedBox(height: 20),

              Row(
                children: [
                  // CONFIRM
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: canConfirm
                            ? () async {
                                final itemReturns = _buildItemReturns();

                                await _service.returnLoan(
                                  loanId: widget.loan.loanId,
                                  returnDate: DateTime.now(),
                                  lateFine: fineState.lateFine.toDouble(),
                                  officerId: UserSession.id,
                                  itemReturns: itemReturns,
                                );

                                if (!mounted) return;
                                showConfirmSnackBar(context, 'Loan returned');
                                Navigator.pop(context, true);
                              }
                            : null,
                        icon: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Confirm',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          disabledBackgroundColor: AppColors.secondary
                              .withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // PAY LATER
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final itemReturns = _buildItemReturns();

                          await _service.returnLoanWithPenalty(
                            loanId: widget.loan.loanId,
                            returnDate: DateTime.now(),
                            lateFine: fineState.lateFine.toDouble(),
                            officerId: UserSession.id,
                            itemReturns: itemReturns,
                          );

                          if (!mounted) return;
                          showConfirmSnackBar(context, 'Marked as penalty');
                          Navigator.pop(context, true);
                        },
                        icon: const Icon(
                          Icons.schedule,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Pay Later',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _readonly(String value) => _input(TextEditingController(text: value));

  Widget _input(TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: _boxDeco(),
      style: const TextStyle(color: AppColors.primary),
      onChanged: (value) {
        final numeric = value.replaceAll(RegExp(r'[^0-9]'), '');
        if (numeric.isEmpty) {
          ctrl.clear();
          setState(() {});
          return;
        }

        final number = int.parse(numeric);
        ctrl.value = TextEditingValue(
          text: _formatRp(number),
          selection: TextSelection.collapsed(offset: _formatRp(number).length),
        );
        setState(() {});
      },
    );
  }

  InputDecoration _boxDeco() => InputDecoration(
    filled: true,
    fillColor: AppColors.background,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  );
}
