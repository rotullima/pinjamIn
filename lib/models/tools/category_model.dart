class CategoryModel {
  final int id;
  final String name;
  final int toolCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.toolCount,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['category_id'],
      name: map['name'],
      toolCount: map['items'] != null ? (map['items'] as List).length : 0,
    );
  }

  Map<String, dynamic> toInsert() {
    return {'name': name};
  }

  Map<String, dynamic> toUpdate() {
    return {'name': name};
  }
}
