import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/tools/fine_model.dart';
import 'package:intl/intl.dart';

class FineFormSheet extends StatefulWidget {
  final FineModel? fine;

  const FineFormSheet({super.key, this.fine});

  @override
  State<FineFormSheet> createState() => _FineFormSheetState();
}

class _FineFormSheetState extends State<FineFormSheet> {
  late TextEditingController conditionCtrl;
  late TextEditingController fineAmountCtrl;
  final NumberFormat _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _formatRp(num v) => _rupiah.format(v);

  @override
  void initState() {
    super.initState();
    conditionCtrl = TextEditingController(text: widget.fine?.condition ?? '');
    fineAmountCtrl = TextEditingController(
      text: widget.fine != null ? _formatRp(widget.fine!.fineAmount) : '',
    );
  }

  @override
  void dispose() {
    conditionCtrl.dispose();
    fineAmountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.fine != null;

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
                  isUpdate ? 'Update Fine' : 'Add New Fine',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (!isUpdate) _input('Condition:', conditionCtrl),
              _input('Fine amount:', fineAmountCtrl),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      label: 'Cancel',
                      icon: Icons.refresh,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionButton(
                      label: 'Done',
                      icon: Icons.check_circle_outline,
                      onTap: () {
                        if (fineAmountCtrl.text.trim().isEmpty) {
                          return;
                        }

                        final condition = isUpdate
                            ? widget.fine!.condition
                            : conditionCtrl.text.trim();

                        if (!isUpdate && condition.isEmpty) {
                          return;
                        }

                        Navigator.pop(context, {
                          'condition': condition,
                          'fineAmount': double.parse(
                            fineAmountCtrl.text.replaceAll(
                              RegExp(r'[^0-9]'),
                              '',
                            ),
                          ),
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
    );
  }

  Widget _input(
    String label,
    TextEditingController ctrl,
    ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
            child: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) {
                final n = v.replaceAll(RegExp(r'[^0-9]'), '');
                if (n.isEmpty) return ctrl.clear();

                final val = int.parse(n);
                final text = _formatRp(val);

                ctrl.value = TextEditingValue(
                  text: text,
                  selection: TextSelection.collapsed(offset: text.length),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: AppColors.background),
        label: Text(
          label,
          style: const TextStyle(
            color: AppColors.background,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          elevation: 12,
          shadowColor: Colors.black.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
