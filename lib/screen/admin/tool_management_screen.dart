import 'package:flutter/material.dart';
import 'package:pinjamln/screen/admin/category_management_screen.dart';
import 'package:pinjamln/screen/admin/fine_management_screen.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_drawer.dart';
import '../../services/auth/user_session.dart';
import '../../dummy/tools/tools_dummy.dart';
import '../../widgets/tools/tool_form_sheet.dart';

class ToolManagementScreen extends StatefulWidget {
  const ToolManagementScreen({super.key});

  @override
  State<ToolManagementScreen> createState() => _ToolManagementScreenState();
}

class _ToolManagementScreenState extends State<ToolManagementScreen> {
  bool isOpen = false;
  final TextEditingController _searchCtrl = TextEditingController();
  late List<ToolDummy> tools;
  String query = '';

  @override
  void initState() {
    super.initState();
    tools = List.from(toolDummies);
    _searchCtrl.addListener(() {
      setState(() {
        query = _searchCtrl.text.toLowerCase().trim();
      });
    });
  }

  void toggleDrawer() => setState(() => isOpen = !isOpen);

  @override
  Widget build(BuildContext context) {
    if (UserSession.role != 'admin') {
      return const Scaffold(body: Center(child: Text('Access denied')));
    }

    final filtered = tools.where((t) {
      return t.name.toLowerCase().contains(query) ||
          t.category.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppHeader(
                    title: 'Tool Management',
                    onToggle: toggleDrawer,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        height: 38,
                        width: 220,
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'search...',
                            hintStyle: TextStyle(color: AppColors.background),
                            filled: true,
                            fillColor: AppColors.secondary,
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.background,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: AppColors.background),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(right: 80),
                      child: _addButton(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tool = filtered[index];
                      return _toolCard(tool);
                    },
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      top: 10,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(4, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CategoryManagementScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          icon: const Icon(
                            Icons.list,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            "Categories",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const FineManagementScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          icon: const Icon(
                            Icons.attach_money,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            "Fine Amount",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            AppDrawer(
              isOpen: isOpen,
              onToggle: toggleDrawer,
              role: UserSession.role,
            ),
          ],
        ),
      ),
    );
  }

  Widget _addButton() {
    return Container(
      height: 38,
      width: 38,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.secondary, width: 1.5),
      ),
      child: IconButton(
        icon: const Icon(Icons.add, size: 20),
        color: AppColors.secondary,
        onPressed: () => _openForm(null),
      ),
    );
  }

  Widget _toolCard(ToolDummy tool) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(tool.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tool.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(tool.category, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    'Available: ${tool.stock}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: AppColors.secondary,
                  onPressed: () => _openForm(tool),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: AppColors.secondary,
                  onPressed: () {
                    setState(() => tools.remove(tool));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openForm(ToolDummy? tool) async {
    final result = await showModalBottomSheet<ToolDummy>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ToolFormSheet(tool: tool),
    );

    if (result == null) return;

    setState(() {
      if (tool == null) {
        tools.add(result);
      } else {
        final i = tools.indexOf(tool);
        tools[i] = result;
      }
    });
  }
}
