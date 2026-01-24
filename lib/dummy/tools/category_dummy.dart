class CategoryDummy {
  final String name;
  final int toolCount;

  CategoryDummy({
    required this.name,
    required this.toolCount,
  });
}

final List<CategoryDummy> categoryDummies = [
  CategoryDummy(
    name: 'Panel & Instalasi',
    toolCount: 1,
  ),
  CategoryDummy(
    name: 'Ukur & Pengujian',
    toolCount: 3,
  ),
  CategoryDummy(
    name: 'Solder & Perakitan',
    toolCount: 5,
  ),
  CategoryDummy(
    name: 'Keselamatan',
    toolCount: 1,
  ),
];