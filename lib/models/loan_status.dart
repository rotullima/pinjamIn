class LoanStatus {
  static const pending = 'pending';
  static const approved = 'approved';
  static const rejected = 'rejected';
  static const borrowed = 'borrowed';
  static const returning = 'returning';
  static const penalty = 'penalty';
  static const returned = 'returned';

  static const all = [
    pending,
    approved,
    rejected,
    borrowed,
    returning,
    penalty,
    returned,
  ];

  static bool canCrud(String status) {
    return status == pending ||
           status == borrowed ||
           status == penalty;
  }
}
