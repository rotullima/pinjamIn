class ToolModel {
  final int itemId;
  final String name;
  final String category;
  final int categoryId;
  final int stockAvailable;
  final int? stockTotal;
  final String statusItem;
  final String? imagePath;
  final bool isActive;

  ToolModel({
    required this.itemId,
    required this.name,
    required this.category,
    required this.categoryId,
    required this.stockAvailable,
    this.stockTotal,
    required this.statusItem,
    this.imagePath,
    required this.isActive,
  });

  factory ToolModel.fromMap(Map<String, dynamic> map) {
    final categoryMap = map['categories'];

    if (categoryMap == null) {
      throw Exception('Category data missing for item: ${map['name']}');
    }

    return ToolModel(
      itemId: map['item_id'] as int,
      name: map['name'] as String? ?? 'Unknown Item',
      category: categoryMap['name'] as String? ?? 'Uncategorized',
      categoryId: categoryMap['category_id'] as int? ?? 0,  // default 0 jika null
      stockAvailable: map['stock_available'] as int? ?? 0,
      stockTotal: map['stock_total'] as int?,              // ← sekarang boleh null
      imagePath: map['image_item'] as String?,
      statusItem: map['status_item'] as String? ?? 'unknown',
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}
