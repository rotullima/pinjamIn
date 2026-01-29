import 'package:flutter/material.dart';
import 'package:pinjamln/constants/app_colors.dart';
import 'package:pinjamln/widgets/app_header.dart';
import 'package:pinjamln/widgets/app_search_field.dart';
import 'package:pinjamln/dummy/tools/tools_dummy.dart';
import '../../services/auth/user_session.dart';
import '../../widgets/app_drawer.dart';
import 'loan_summary_screen.dart';

class ToolBorrowScreen extends StatefulWidget {
  const ToolBorrowScreen({super.key});

  @override
  State<ToolBorrowScreen> createState() => _ToolBorrowScreenState();
}

class _ToolBorrowScreenState extends State<ToolBorrowScreen> {
  bool isOpen = false;
  final TextEditingController _searchCtrl = TextEditingController();
  late List<ToolDummy> tools;
  String query = '';

  final List<ToolDummy> _cart = [];

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

  void _addToCart(ToolDummy tool) {
    if (tool.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tool.name} sedang kosong (stok 0)')),
      );
      return;
    }

    final exists = _cart.any((t) => t.id == tool.id);
    if (exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sudah ada di keranjang')));
      return;
    }

    setState(() {
      _cart.add(tool);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${tool.name} ditambahkan ke keranjang'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (UserSession.role != 'borrower') {
      return const Scaffold(body: Center(child: Text('Acces denied')));
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
                  child: AppHeader(title: 'Tool List', onToggle: toggleDrawer),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchField(controller: _searchCtrl),
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
              ],
            ),

            Positioned(
              right: 25,
              bottom: 50,
              child: FloatingActionButton.extended(
                onPressed: _cart.isEmpty
                    ? null
                    : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LoanSummaryScreen(cart: _cart),
                          ),
                        );

                        if (result == true) {
                          setState(() {});
                        }
                      },

                backgroundColor: AppColors.secondary,
                icon: const Icon(Icons.inventory_2, color: Colors.white),
                label: Text(
                  '${_cart.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                isExtended: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
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

  Widget _toolCard(ToolDummy tool) {
    final bool outOfStock = tool.stock <= 0;

    return GestureDetector(
      onTap: outOfStock ? null : () => _addToCart(tool),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(3, 3),
            ),
          ],
          border: outOfStock
              ? Border.all(color: Colors.red.shade300, width: 1.5)
              : null,
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: outOfStock ? Colors.grey : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tool.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: outOfStock ? Colors.grey : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Available: ${tool.stock}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: outOfStock ? Colors.red : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (outOfStock)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(
                    'in repair',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}
