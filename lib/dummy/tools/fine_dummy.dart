class FineDummy {
  final String condition;
  final double fineAmount;

  FineDummy({
    required this.condition,
    required this.fineAmount,
  });
}

final List<FineDummy> fineDummies = [
  FineDummy(
    condition: 'Good 0%',
    fineAmount: 0,
  ),
  FineDummy(
    condition: 'Abrasion 10%',
    fineAmount: 20.000,
  ),
  FineDummy(
    condition: 'Abrasion 20%',
    fineAmount: 40.000,
  ),
  FineDummy(
    condition: 'Damage 80%',
    fineAmount: 75.000,
  ),
  FineDummy(
    condition: 'Damage 90%',
    fineAmount: 90.000,
  ),
];