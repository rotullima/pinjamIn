import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_drawer.dart';
import '../../dummy/tools/fine_dummy.dart';
import '../../widgets/tools/fine_form_sheet.dart';
import '../../services/auth/user_session.dart';

class FineManagementScreen extends StatefulWidget {
  const FineManagementScreen({super.key});

  @override
  State<FineManagementScreen> createState() => _FineManagementScreenState();
}

class _FineManagementScreenState extends State<FineManagementScreen> {
  bool isOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late List<FineDummy> fines;

  @override
  void initState() {
    super.initState();
    fines = List.from(fineDummies);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void toggleDrawer() => setState(() => isOpen = !isOpen);

  @override
  Widget build(BuildContext context) {
    if (UserSession.role != 'admin') {
      return const Scaffold(body: Center(child: Text('Access denied')));
    }

    final filteredFines = fines.where((fine) {
      return fine.condition.toLowerCase().contains(_searchQuery) ||
          fine.fineAmount.toString().contains(_searchQuery);
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
                    title: 'Fine Amount List',
                    onToggle: toggleDrawer,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: SizedBox(
                        height: 38,
                        width: 220,
                        child: TextField(
                          controller: _searchController,
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
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(color: AppColors.background),
                          cursorColor: AppColors.background,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 80),
                      child: Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.secondary,
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.add, size: 20),
                          color: AppColors.secondary,
                          onPressed: () => _openForm(null),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredFines.length,
                    itemBuilder: (context, index) {
                      final fine = filteredFines[index];
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
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fine.condition,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Fine amount: ${fine.fineAmount.toStringAsFixed(3)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    color: AppColors.secondary,
                                    iconSize: 20,
                                    onPressed: () => _openForm(fine),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: AppColors.secondary,
                                    iconSize: 20,
                                    onPressed: () {
                                      setState(() {
                                        fines.remove(fine);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
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
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        "Back",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
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

  Future<void> _openForm(FineDummy? fine) async {
    final result = await showModalBottomSheet<FineDummy>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FineFormSheet(fine: fine),
    );

    if (result == null) return;

    setState(() {
      if (fine == null) {
        fines.add(result);
      } else {
        final index = fines.indexOf(fine);
        fines[index] = result;
      }
    });
  }
}