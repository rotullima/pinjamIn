import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../dummy/loan_dummy.dart';
import '../../dummy/tools/fine_dummy.dart';
import '../../models/loan_fine_state.dart';
import '../../widgets/confirm_snackbar.dart';

class LoanReturnSheet extends StatefulWidget {
  final LoanDummy loan;

  const LoanReturnSheet({super.key, required this.loan});

  @override
  State<LoanReturnSheet> createState() => _LoanReturnSheetState();
}

class _LoanReturnSheetState extends State<LoanReturnSheet> {
  FineDummy? selectedFine;
  final TextEditingController payCtrl = TextEditingController();

  late LoanFineState fineState;

  @override
  void initState() {
    super.initState();

    final bool isPenalty = widget.loan.status == 'penalty';

    if (isPenalty) {
      fineState = LoanFineState(
        lateDays: widget.loan.penaltyDays ?? 0,
        lateFine: (widget.loan.penaltyDays ?? 0) * 2500,
        conditionFine: (widget.loan.fineAmount ?? 0).toInt(),
        totalFine:
            ((widget.loan.penaltyDays ?? 0) * 2500) +
            (widget.loan.fineAmount ?? 0).toInt(),
      );

      if (widget.loan.conditionNote != null) {
        selectedFine = fineDummies.firstWhere(
          (f) => f.condition == widget.loan.conditionNote,
          orElse: () => fineDummies.first,
        );
      }
    } else {
      fineState = _calculateLateFine(widget.loan.endDate);
    }
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

  @override
  Widget build(BuildContext context) {
    final bool isPenalty = widget.loan.status == 'penalty';
    final int payAmount = int.tryParse(payCtrl.text) ?? 0;
    final bool canConfirm = payAmount >= fineState.totalFine && payAmount > 0;

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
              Center(
                child: Text(
                  isPenalty ? 'Pay Form' : 'Return Form',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Late return: ${fineState.lateDays} days x 2500',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 10),
              _readonlyField(fineState.lateFine.toString()),

              const SizedBox(height: 14),
              const Text(
                'Condition',
                style: TextStyle(color: AppColors.primary),
              ),
              const SizedBox(height: 6),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<FineDummy>(
                  value: selectedFine,
                  items: fineDummies
                      .map(
                        (f) => DropdownMenuItem(
                          value: f,
                          child: Text(
                            f.condition,
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: isPenalty
                      ? null
                      : (v) {
                          setState(() {
                            selectedFine = v;
                            final conditionFineAmount = (v?.fineAmount ?? 0)
                                .toInt();
                            fineState = LoanFineState(
                              lateDays: fineState.lateDays,
                              lateFine: fineState.lateFine,
                              conditionFine: conditionFineAmount,
                              totalFine:
                                  fineState.lateFine + conditionFineAmount,
                            );
                          });
                        },
                  decoration: _boxDeco(),
                ),
              ),

              const SizedBox(height: 14),
              const Text(
                'Fine amount',
                style: TextStyle(color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              _readonlyField(fineState.totalFine.toString()),

              const SizedBox(height: 14),
              const Text(
                'Pay amount',
                style: TextStyle(color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              _input(payCtrl, enabled: true),

              const SizedBox(height: 20),

              Row(
                children: [
                  if (!isPenalty)
                    Expanded(
                      child: _actionButton(
                        label: 'Pay Later',
                        icon: Icons.close,
                        onTap: () {
                          showConfirmSnackBar(context, 'pay later loan fine');

                          final penaltyData = {
                            'status': 'penalty',
                            'penaltyDays': fineState.lateDays,
                            'conditionNote': selectedFine?.condition,
                            'fineAmount': selectedFine?.fineAmount ?? 0,
                          };
                          Navigator.pop(context, penaltyData);
                        },
                      ),
                    ),

                  if (!isPenalty) const SizedBox(width: 12),

                  Expanded(
                    child: _actionButton(
                      label: 'Confirm',
                      icon: Icons.check,
                      enabled: canConfirm,
                      onTap: canConfirm
                          ? () {
                              showConfirmSnackBar(context, 'loan returned!');

                              final paymentData = {
                                'status': 'returned',
                                'payAmount': int.tryParse(payCtrl.text) ?? 0,
                                'penaltyDays': fineState.lateDays,
                                'conditionNote': selectedFine?.condition,
                                'fineAmount': fineState.totalFine,
                                'isPaid': true,
                              };
                              Navigator.pop(context, paymentData);
                            }
                          : null,
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

  Widget _readonlyField(String value) {
    return _input(TextEditingController(text: value), enabled: false);
  }

  Widget _input(TextEditingController ctrl, {bool enabled = true}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: ctrl,
        enabled: enabled,
        keyboardType: enabled ? TextInputType.number : null,
        onChanged: enabled
            ? (value) {
                setState(() {});
              }
            : null,
        decoration: _boxDeco(),
        style: TextStyle(color: AppColors.primary),
      ),
    );
  }

  InputDecoration _boxDeco() => InputDecoration(
    filled: true,
    fillColor: Colors.transparent,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  );

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    bool enabled = true,
  }) {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: enabled ? onTap : null,
        icon: Icon(icon, size: 18, color: AppColors.background),
        label: Text(label, style: TextStyle(color: AppColors.background)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          disabledBackgroundColor: AppColors.secondary.withOpacity(0.4),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
