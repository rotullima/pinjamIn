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
