import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../screen/dasboard_screen.dart';
import '../screen/admin/user_management_screen.dart';

class AppDrawer extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final String role;

  const AppDrawer({
    super.key,
    required this.isOpen,
    required this.onToggle,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      top: 0,
      left: isOpen ? 0 : -270,
      child: Container(
        width: 260,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(4, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: kToolbarHeight,
              padding: const EdgeInsets.only(left: 20),
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 56,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onToggle,
                    child: const Icon(
                      Icons.chevron_left,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            ..._buildMenuItems(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.home_filled,
        'label': 'Dashboard',
        'onTap': () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        },
      },
    ];

    if (role == 'admin') {
      menuItems.addAll([
        {
          'icon': Icons.build_outlined, 
          'label': 'Tools List', 
          'onTap': () {}},
        {
          'icon': Icons.person_outline, 
          'label': 'User', 
          'onTap': () {
            Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserManagementScreen()),
          );
          }},
        {
          'icon': Icons.receipt_long_outlined,
          'label': 'Log Activity',
          'onTap': () {},
        },
        {
          'icon': Icons.list_alt, 
          'label': 'Loan List', 
          'onTap': () {}},
      ]);
    } else if (role == 'officer') {
      menuItems.addAll([
        {
          'icon': Icons.access_time,
          'label': 'Pending Loan List',
          'onTap': () {},
        },
        {
          'icon': Icons.calendar_month,
          'label': 'Approved Loan List',
          'onTap': () {},
        },
        {
          'icon': Icons.outbond, 
          'label': 'Borrowed Loan List', 
          'onTap': () {}},
        {
          'icon': Icons.attach_money,
          'label': 'Penalty Loan List',
          'onTap': () {},
        },
      ]);
    } else if (role == 'borrower') {
      menuItems.addAll([
        {
          'icon': Icons.build_outlined, 
          'label': 'Tool List', 
          'onTap': () {}},
        {
          'icon': Icons.access_time,
          'label': 'Pending Loan List',
          'onTap': () {},
        },
        {
          'icon': Icons.calendar_month,
          'label': 'Approved Loan List',
          'onTap': () {},
        },
        {
          'icon': Icons.outbond, 
          'label': 'Borrowed Loan List', 
          'onTap': () {}},
        {
          'icon': Icons.attach_money,
          'label': 'Penalty Loan List',
          'onTap': () {},
        },
      ]);
    }

    return menuItems.map((item) {
      return _DrawerItem(
        icon: item['icon'] as IconData,
        label: item['label'] as String,
        isOpen: isOpen,
        onTap: item['onTap'] as VoidCallback,
      );
    }).toList();
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOpen;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              if (isOpen) ...[
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.background,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
