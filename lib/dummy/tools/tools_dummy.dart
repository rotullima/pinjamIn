class ToolDummy {
  final int id;
  final String name;
  final String category;
  final int stock;
  final String condition;
  final String imagePath;

  ToolDummy({
    required this.id,
    required this.name,
    required this.category,
    required this.stock,
    required this.condition,
    required this.imagePath,
  });
}

final List<ToolDummy> toolDummies = [
  ToolDummy(
    id: 1,
    name: 'Terminal Block',
    category: 'Panel & Instalasi',
    stock: 2,
    condition: 'good',
    imagePath: 'assets/terminal_block.png',
  ),
  ToolDummy(
    id: 2,
    name: 'Test Pen',
    category: 'Ukur & Pengujian',
    stock: 6,
    condition: 'good',
    imagePath: 'assets/test_pen.png',
  ),
  ToolDummy(
    id: 3,
    name: 'Timah Solder',
    category: 'Solder & Perakitan',
    stock: 0,
    condition: 'in repair',
    imagePath: 'assets/timah_solder.png',
  ),
];
