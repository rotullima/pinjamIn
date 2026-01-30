class ToolModel {
  final int id;
  final String name;
  final String category;
  final int categoryId;
  final int stockAvailable;
  final String? imagePath;
  final String statusItem;

  ToolModel({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryId,
    required this.stockAvailable,
    required this.statusItem,
    this.imagePath,
  });

  factory ToolModel.fromMap(Map<String, dynamic> map) {
    final category = map['categories'];

    return ToolModel(
      id: map['item_id'] as int,
      name: map['name'] as String,
      category: category['name'] as String,
      categoryId: category['category_id'] as int,
      stockAvailable: map['stock_available'] as int,
      imagePath: map['image_item'] as String?,
      statusItem: map['status_item'] as String,
    );
  }
}
