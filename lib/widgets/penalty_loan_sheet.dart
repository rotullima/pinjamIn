import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/loan_model.dart';
import '../services/officer/officer_loan_service.dart';
import '../services/auth/user_session.dart';
import '../widgets/notifications/confirm_snackbar.dart';
import '../models/tools/fine_model.dart';

class PenaltyLoanSheet extends StatefulWidget {
  final LoanModel loan;

  const PenaltyLoanSheet({super.key, required this.loan});

  @override
  State<PenaltyLoanSheet> createState() => _PenaltyLoanSheetState();
}

class _PenaltyLoanSheetState extends State<PenaltyLoanSheet> {
  final OfficerLoanService _service = OfficerLoanService();
  final TextEditingController payCtrl = TextEditingController();
  List<FineModel> fines = [];
  int conditionFine = 0;
  int totalFine = 0;
  @override
  void initState() {
    super.initState();
    _loadFinesAndCalculate();
  }

  Future<void> _loadFinesAndCalculate() async {
    final fineList = await _service.fetchFines();

    int conditionTotal = 0;

    for (final d in widget.loan.details) {
      if (d.damageFine == null) continue;

      final fine = fineList.where((f) => f.id == d.damageFine).isNotEmpty
          ? fineList.firstWhere((f) => f.id == d.damageFine)
          : null;

      if (fine != null) {
        conditionTotal += fine.fineAmount.toInt();
      }
    }

    setState(() {
      fines = fineList;
      conditionFine = conditionTotal;
      totalFine = (widget.loan.lateFine ?? 0).toInt() + conditionTotal;
    });
  }

  final NumberFormat _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _formatRp(num v) => _rupiah.format(v);

  @override
  Widget build(BuildContext context) {
    final payAmount =
        int.tryParse(payCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final canConfirm = payAmount == totalFine;

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
                  'Penalty Payment',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Late return fine',
                style: const TextStyle(color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              _readonly(_formatRp(widget.loan.lateFine ?? 0)),

              const SizedBox(height: 14),
              const SizedBox(height: 14),
              const Text(
                'Condition per item',
                style: TextStyle(color: AppColors.primary),
              ),
              const SizedBox(height: 8),

              Column(
                children: widget.loan.details.map((d) {
                  final FineModel? fine = fines.cast<FineModel?>().firstWhere(
                    (f) => f?.id == d.damageFine,
                    orElse: () => null,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextField(
                      readOnly: true,
                      decoration: _boxDeco().copyWith(
                        hintText: '${d.itemName} - ${fine?.condition ?? '-'}',
                      ),
                    ),
                  );
                }).toList(),
              ),
 
              const SizedBox(height: 8),
              const Text(
                'Total Fine',
                style: TextStyle(color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              _readonly(_formatRp(totalFine)),
              const SizedBox(height: 8),

              const Text(
                'Pay amount',
                style: TextStyle(color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              _input(payCtrl),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: canConfirm
                      ? () async {
                          await _service.payPenaltyLoan(
                            loanId: widget.loan.loanId,
                            officerId: UserSession.id,
                          );

                          if (!mounted) return;
                          showConfirmSnackBar(context, 'Penalty paid');
                          Navigator.pop(context, 'paid');
                        }
                      : null,
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                  label: const Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    disabledBackgroundColor: AppColors.secondary.withOpacity(
                      0.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _readonly(String value) =>
      _input(TextEditingController(text: value), readOnly: true);

  Widget _input(TextEditingController ctrl, {bool readOnly = false}) {
    return TextField(
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: TextInputType.number,
      decoration: _boxDeco(),
      style: const TextStyle(color: AppColors.primary),
      onChanged: readOnly
          ? null
          : (v) {
              final n = v.replaceAll(RegExp(r'[^0-9]'), '');
              if (n.isEmpty) return ctrl.clear();
              final val = int.parse(n);
              ctrl.value = TextEditingValue(
                text: _formatRp(val),
                selection: TextSelection.collapsed(
                  offset: _formatRp(val).length,
                ),
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
