import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../dummy/tools/fine_dummy.dart';

class FineFormSheet extends StatefulWidget {
  final FineDummy? fine;

  const FineFormSheet({super.key, this.fine});

  @override
  State<FineFormSheet> createState() => _FineFormSheetState();
}

class _FineFormSheetState extends State<FineFormSheet> {
  late TextEditingController conditionCtrl;
  late TextEditingController fineAmountCtrl;

  @override
  void initState() {
    super.initState();
    conditionCtrl = TextEditingController(
      text: widget.fine?.condition ?? '',
    );
    fineAmountCtrl = TextEditingController(
      text: widget.fine?.fineAmount.toStringAsFixed(3) ?? '',
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
                  isUpdate ? 'Add/Update New Fine' : 'Add/Update New Fine',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (!isUpdate) _input('Condition:', conditionCtrl),
              _input('Fine amount:', fineAmountCtrl, number: true),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      label: 'Kembali',
                      icon: Icons.refresh,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionButton(
                      label: 'Selesai',
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
                        
                        Navigator.pop(
                          context,
                          FineDummy(
                            condition: condition,
                            fineAmount: double.tryParse(
                                    fineAmountCtrl.text.trim()) ??
                                0,
                          ),
                        );
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
    TextEditingController ctrl, {
    bool number = false,
  }) {
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
              keyboardType: number ? TextInputType.number : TextInputType.text,
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