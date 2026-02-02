enum LoanStatus {
  pending,
  approved,
  rejected,
  borrowed,
  returning,
  penalty,
  returned,
}

enum ItemStatus { good, inRepair }

class LoanModel {
  final int loanId;
  final String borrowerId;
  final String borrowerName;
  final String? officerId;
  final DateTime startDate;
  final DateTime endDate;
  LoanStatus status;
  final DateTime? returnDate;
  final double? lateFine;
  final String? note;
  final DateTime createdAt;
  final int loanNumber;
  final List<LoanDetailModel> details;

  LoanModel({
    required this.loanId,
    required this.borrowerId,
    required this.borrowerName,
    this.officerId,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.returnDate,
    this.lateFine,
    this.note,
    required this.createdAt,
    required this.loanNumber,
    required this.details,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      loanId: json['loan_id'] as int,
      borrowerId: json['borrower_id'] as String,
      borrowerName: json['profiles']['name'] as String,
      officerId: json['officer_id'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: LoanStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status_loan'],
        orElse: () => LoanStatus.pending,
      ),
      returnDate: json['return_date'] != null
          ? DateTime.parse(json['return_date'] as String)
          : null,
      lateFine: (json['late_fine'] as num?)?.toDouble(),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      loanNumber: json['loan_number'] as int,
      details: (json['loan_details'] as List<dynamic>? ?? [])
          .map((d) => LoanDetailModel.fromJson(d))
          .toList(),
    );
  }
}

class LoanDetailModel {
  final int? loanDetailId;
  final int itemId;
  final String? itemName;
  final String? returnCondition;
  final int? damageFine;

  LoanDetailModel({
    this.loanDetailId,
    required this.itemId,
    this.itemName,
    this.returnCondition,
    this.damageFine,
  });

  factory LoanDetailModel.fromJson(Map<String, dynamic> json) {
    final itemJson = json['items'] as Map<String, dynamic>?;
    return LoanDetailModel(
      loanDetailId: json['loan_detail_id'] as int?,
      itemId: json['item_id'] as int,
      itemName: itemJson?['name'] as String?,
      returnCondition: json['return_condition'] as String?,
      damageFine: json['damage_fine'] as int?,
    );
  }
}

class BorrowerModel {
  final String id;
  final String name;

  BorrowerModel({required this.id, required this.name});

  factory BorrowerModel.fromJson(Map<String, dynamic> json) {
    return BorrowerModel(
      id: json['profile_id'] as String,
      name: json['name'] as String,
    );
  }
}

class ItemModel {
  final int id;
  final String name;
  final int stockAvailable;

  ItemModel({
    required this.id,
    required this.name,
    required this.stockAvailable,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['item_id'] as int,
      name: json['name'] as String,
      stockAvailable: json['stock_available'] as int,
    );
  }
}
