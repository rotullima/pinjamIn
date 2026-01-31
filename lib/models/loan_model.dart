class LoanModel {
  final int loanId;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final String borrowerName;

  LoanModel({
    required this.loanId,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.borrowerName,
  });

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    return LoanModel(
      loanId: map['loan_id'] as int,
      status: map['status_loan'] as String,
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      borrowerName: map['profiles']['name'] as String,
    );
  }
}
