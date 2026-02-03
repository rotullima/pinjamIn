class ToolModel {
  final int itemId;
  final String name;
  final String category;
  final int categoryId;
  final int stockAvailable;
  final int stockTotal;
  final String statusItem;
  final String? imagePath;
  final bool isActive;

  ToolModel({
    required this.itemId,
    required this.name,
    required this.category,
    required this.categoryId,
    required this.stockAvailable,
    required this.stockTotal,
    required this.statusItem,
    this.imagePath,
    required this.isActive,
  });

  factory ToolModel.fromMap(Map<String, dynamic> map) {
    final category = map['categories'];

    return ToolModel(
      itemId: map['item_id'] as int,
      name: map['name'] as String,
      category: category['name'] as String,
      categoryId: category['category_id'] as int,
      stockTotal: map['stock_total'] as int,
      stockAvailable: map['stock_available'] as int,
      imagePath: map['image_item'] as String?,
      statusItem: map['status_item'] as String,
      isActive: map['is_active'] as bool,
    );
  }
}
