import 'package:flutter/material.dart';
import 'package:pinjamln/constants/app_colors.dart';
import 'package:pinjamln/widgets/app_header.dart';
import 'package:pinjamln/widgets/app_search_field.dart';
import '../../services/auth/user_session.dart';
import '../../widgets/app_drawer.dart';
import 'loan_summary_screen.dart';
import '../../models/tools/tool_model.dart';
import '../../services/tools/tool_borrower_service.dart';
import '../../widgets/notifications/app_toast.dart';

class ToolBorrowScreen extends StatefulWidget {
  const ToolBorrowScreen({super.key});

  @override
  State<ToolBorrowScreen> createState() => _ToolBorrowScreenState();
}

class _ToolBorrowScreenState extends State<ToolBorrowScreen> {
  bool isOpen = false;
  final TextEditingController _searchCtrl = TextEditingController();
  late Future<List<ToolModel>> _toolsFuture;
  String query = '';

  final List<ToolModel> _cart = [];
  @override
  void initState() {
    super.initState();
    _toolsFuture = ToolBorrowService().fetchAvailableTools();

    _searchCtrl.addListener(() {
      setState(() {
        query = _searchCtrl.text.toLowerCase().trim();
      });
    });
  }

  void toggleDrawer() => setState(() => isOpen = !isOpen);

  void _addToCart(ToolModel tool) {
    if (tool.stockAvailable <= 0) {
      showToast(context, '${tool.name} is out of stock', isError: true);
      return;
    }

    final exists = _cart.any((t) => t.itemId == tool.itemId);
    if (exists) {
      showToast(context, 'Item already in cart', isError: true);
      return;
    }

    setState(() {
      _cart.add(tool);
    });

    showToast(context, '${tool.name} added to cart');
  }

  @override
  Widget build(BuildContext context) {
    if (UserSession.role != 'borrower') {
      return const Scaffold(body: Center(child: Text('Acces denied')));
    }

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
                  child: FutureBuilder<List<ToolModel>>(
                    future: _toolsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          showToast(
                            context,
                            'Failed to load tools',
                            isError: true,
                          );
                        });
                        return const Center(
                          child: Text('Failed to load tools'),
                        );
                      }

                      final tools = snapshot.data!;
                      final filtered = tools.where((t) {
                        return t.name.toLowerCase().contains(query) ||
                            t.category.toLowerCase().contains(query);
                      }).toList();

                      if (filtered.isEmpty) {
                        return const Center(child: Text('tool not found'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _toolCard(filtered[index]);
                        },
                      );
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
                        final bool? shouldRefresh = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LoanSummaryScreen(cart: _cart),
                          ),
                        );

                        if (shouldRefresh == true) {
                          setState(() {
                            _toolsFuture = ToolBorrowService()
                                .fetchAvailableTools();
                          });
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

  Widget _toolCard(ToolModel tool) {
    final bool outOfStock = tool.stockAvailable <= 0;

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
                    image: tool.imagePath != null
                        ? NetworkImage(tool.imagePath!)
                        : const AssetImage('assets/images/no_image.png')
                              as ImageProvider,

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
                      'Available: ${tool.stockAvailable}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: outOfStock ? Colors.red : AppColors.primary,
                      ),
                    ),
                  ],
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
