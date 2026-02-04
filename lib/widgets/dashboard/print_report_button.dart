import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/officer/loan_report_service.dart';
import '../../services/officer/data_report_service.dart';

class PrintReportButton extends StatelessWidget {
  const PrintReportButton({super.key});

  void _showReportOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Pilih Laporan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.list_alt, color: AppColors.background),
              title: const Text('Laporan Peminjaman', style: TextStyle(color: AppColors.background),),
              onTap: () {
                Navigator.pop(context);
                LoanReportService.printLoanReport();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              tileColor: AppColors.secondary,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.storage, color: AppColors.background),
              title: const Text('Laporan Master Data', style: TextStyle(color: AppColors.background),),
              onTap: () {
                Navigator.pop(context);
                DataReportService.printDataReport();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              tileColor: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 150,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showReportOptions(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.insert_drive_file, size: 18, color: AppColors.background),
              SizedBox(width: 6),
              Text(
                'Print report',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.background,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
