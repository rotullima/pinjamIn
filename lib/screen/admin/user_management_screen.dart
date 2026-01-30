import 'package:flutter/material.dart';
import 'package:pinjamln/widgets/confirm_delete_dialog.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_search_field.dart';
import '../../models/user_model.dart'; // <-- pastikan import ini
import '../../widgets/user/user_form_sheet.dart';
import '../../services/auth/user_session.dart';
import '../../services/auth/user_service.dart'; // <-- service create user

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  bool isOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late List<UserModel> users;
  bool _isLoading = true; // untuk loading state

  // Service
  late UserService _userService;

  @override
void initState() {
  super.initState();

  users = [];
  _userService = UserService(); // langsung pakai default baseUrl & apiKey dari env

  _fetchUsers();

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

  Future<void> _fetchUsers() async {
  setState(() => _isLoading = true);
  try {
    final fetchedUsers = await _userService.fetchUsers();
    setState(() {
      users = fetchedUsers;
      _isLoading = false;
    });
  } catch (e) {
    print('Error fetch users: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat daftar user: $e')),
      );
    }
    setState(() {
      users = [];
      _isLoading = false;
    });
  }
}

  void toggleDrawer() => setState(() => isOpen = !isOpen);

  @override
  Widget build(BuildContext context) {
    if (UserSession.role != 'admin') {
      return const Scaffold(body: Center(child: Text('Access denied')));
    }

    final filteredUsers = users.where((user) {
      final name = user.name ?? '';
      final role = user.role ?? '';
      return name.toLowerCase().contains(_searchQuery) ||
          role.toLowerCase().contains(_searchQuery);
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
                    title: 'User Registration',
                    onToggle: toggleDrawer,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SearchField(controller: _searchController),
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredUsers.isEmpty
                      ? const Center(child: Text('Belum ada user'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: Offset(4, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.name ?? '',
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'As ${user.role}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Email opsional kalau kamu fetch terpisah
                                          // Text('email: ${user.email ?? 'tidak tersedia'}', style: ...),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          color: AppColors.secondary,
                                          onPressed: () => _openForm(user),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: AppColors.secondary,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) =>
                                                  ConfirmDeleteDialog(
                                                    message:
                                                        'Yakin hapus user ini?',
                                                    onConfirm: () async {
                                                      Navigator.pop(
                                                        context,
                                                      ); // tutup dialog dulu
                                                      await _deleteUser(user);
                                                    },
                                                  ),
                                            );
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

  Future<void> _deleteUser(UserModel user) async {
    try {
      await _userService.deleteUser(user.id);
      setState(() {
        users.removeWhere((u) => u.id == user.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ${user.name} berhasil dinonaktifkan')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal hapus user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openForm(UserModel? user) async {
    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Edit user belum diimplementasikan')),
      );
      return;
    }

    // Add new user
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const UserFormSheet(user: null),
    );

    if (result == null) return;

    try {
      final newUser = await _userService.createUser(
        email: result['email'] as String,
        password: result['password'] as String,
        name: result['name'] as String,
        role: result['role'] as String,
      );

      // Tambahkan ke list langsung atau refresh
      setState(
        () => users.insert(
          0,
          UserModel(
            id: newUser.id,
            name: newUser.name ?? '',
            role: newUser.role ?? 'borrower',
            email: newUser.email,
            isActive: newUser.isActive,
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User berhasil dibuat! ID: ${newUser.id}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
