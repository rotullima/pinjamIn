class FineModel {
  final int id;
  final String condition;
  final double fineAmount;
  final DateTime? createdAt;

  FineModel({
    required this.id,
    required this.condition,
    required this.fineAmount,
    this.createdAt,
  });

  factory FineModel.fromJson(Map<String, dynamic> json) => FineModel(
    id: json['fine_id'] as int,
    condition: json['condition'] as String,
    fineAmount: (json['fine_amount'] as num).toDouble(),
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'fine_id': id,
    'condition': condition,
    'fine_amount': fineAmount,
  };
}

extension FineConditionMapper on FineModel {
  ReturnCondition get returnCondition {
    if (fineAmount == 0) return ReturnCondition.good;
    if (fineAmount > 0 && fineAmount < 50000) return ReturnCondition.abrasion;
    return ReturnCondition.damaged;
  }
}

enum ReturnCondition { good, abrasion, damaged }
