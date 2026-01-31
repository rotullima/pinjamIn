import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/user_model.dart'; // <-- import AppUser

class UserFormSheet extends StatefulWidget {
  final UserModel? user; // <-- Ganti ke AppUser

  const UserFormSheet({super.key, this.user});

  @override
  State<UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends State<UserFormSheet> {
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController passwordCtrl;
  String selectedRole = 'officer'; // Default untuk add new (bukan 'admin')

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.user?.name ?? '');
    emailCtrl = TextEditingController(text: widget.user?.email ?? '');
    passwordCtrl = TextEditingController(); // Password kosong kalau edit (tidak bisa ubah lewat form ini)

    // Pre-fill role kalau edit, pastikan nilai valid
    final userRole = widget.user?.role;
    selectedRole = (userRole == 'admin' || userRole == 'officer' || userRole == 'borrower') 
        ? userRole! 
        : 'officer';
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  isEdit ? 'Update User' : 'Add New User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _input('Name', nameCtrl),

              _roleDropdown(),

              // Email: bisa diubah untuk edit
              _input(
                'Email',
                emailCtrl,
              ),

              // Password: hanya wajib untuk add new, kosong/hidden kalau edit
              if (!isEdit)
                _input('Password', passwordCtrl, obscureText: true),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      label: 'Back',
                      icon: Icons.close,
                      outlined: true,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionButton(
                      label: isEdit ? 'Update' : 'Done',
                      icon: Icons.check,
                      onTap: () {
                        // Validasi minimal
                        if (nameCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nama wajib diisi!')),
                          );
                          return;
                        }

                        // Validasi email
                        final email = emailCtrl.text.trim();
                        if (email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Email wajib diisi!')),
                          );
                          return;
                        }

                        // Validasi format email
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Format email tidak valid!')),
                          );
                          return;
                        }

                        // Untuk add new: password wajib
                        if (!isEdit && passwordCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password wajib diisi!')),
                          );
                          return;
                        }

                        Navigator.pop(
                          context,
                          {
                            'name': nameCtrl.text.trim(),
                            'role': selectedRole,
                            'email': emailCtrl.text.trim(),
                            if (!isEdit) 'password': passwordCtrl.text.trim(), // Password hanya untuk add new
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController ctrl, {
    bool readOnly = false,
    bool obscureText = false,
    String? hint,
    bool enabled = true, // Tambah parameter enabled
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TextField(
              controller: ctrl,
              readOnly: readOnly,
              enabled: enabled, // Tambah enabled
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'As',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedRole,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'officer', child: Text('Officer')),
                  DropdownMenuItem(value: 'borrower', child: Text('Borrower')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: AppColors.background),
        label: Text(
          label,
          style: TextStyle(
            color: AppColors.background,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          elevation: 12,
          shadowColor: Colors.black.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}