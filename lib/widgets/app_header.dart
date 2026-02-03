import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/auth/login_service.dart';
import '../services/auth/user_session.dart';
import '../screen/auth/loginscreen.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onToggle;
  final VoidCallback? onProfileTap;
  final bool showProfile;

  const AppHeader({
    super.key,
    required this.title,
    this.onToggle,
    this.onProfileTap,
    this.showProfile = true,
  });

  void _showProfileMenu(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 200,
        kToolbarHeight + MediaQuery.of(context).padding.top + 4,
        40,
        0,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                UserSession.name,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                UserSession.role,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 13,
                ),
              ),
              const Divider(height: 16),
            ],
          ),
        ),

        PopupMenuItem(
          value: 'logout',
          onTap: () async {
            await Future.delayed(const Duration(milliseconds: 120));
            final authService = AuthService();
            await authService.signOut();

            if (!context.mounted) return;

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Logout succesfull'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: const ListTile(
            leading: Icon(Icons.logout, color: Colors.redAccent),
            title: Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent),
            ),
            dense: true,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (onToggle != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: const Icon(
                Icons.chevron_right,
                size: 28,
                color: AppColors.secondary,
              ),
            )
          else
            const SizedBox(width: 4),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),

          if (showProfile)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onProfileTap ?? () => _showProfileMenu(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.secondary,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
