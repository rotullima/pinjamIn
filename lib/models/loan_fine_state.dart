class LoanFineState {
  final int lateDays;
  final int lateFine;
  final int conditionFine;
  final int totalFine;

  const LoanFineState({
    required this.lateDays,
    required this.lateFine,
    required this.conditionFine,
    required this.totalFine,
  });
}
