import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_header.dart';
import '../../services/auth/user_session.dart';
import '../../services/activity_log_service.dart';
import '../../models/activity_log_model.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  bool isOpen = false;
  bool _isLoading = true;
  List<ActivityLog> _activityLogs = [];
  final ActivityLogService _activityLogService = ActivityLogService();

  @override
  void initState() {
    super.initState();
    _fetchActivityLogs();
  }

  Future<void> _fetchActivityLogs() async {
    try {
      setState(() => _isLoading = true);
      final logs = await _activityLogService.fetchActivityLogs();
      setState(() {
        _activityLogs = logs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading activity logs: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load activity logs: $e')),
        );
      }
    }
  }

  void toggleDrawer() => setState(() => isOpen = !isOpen);

  @override
  Widget build(BuildContext context) {
    if (UserSession.role != 'admin') {
      return const Scaffold(body: Center(child: Text('Access denied')));
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
                  child: AppHeader(
                    title: 'Activity Log',
                    onToggle: toggleDrawer,
                  ),
                ),

                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _activityLogs.isEmpty
                          ? const Center(child: Text('No activity logs found'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _activityLogs.length,
                              itemBuilder: (context, index) {
                                final log = _activityLogs[index];
                                return _ActivityLogCard(log: log);
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
}

class _ActivityLogCard extends StatelessWidget {
  final ActivityLog log;

  const _ActivityLogCard({required this.log});

  String _buildActivityText() {
    String actionText;
    String entityText = log.entity.name.toLowerCase();

    switch (log.action) {
      case ActionEnum.create:
        actionText = 'CREATE';
        entityText = entityText == 'item' ? 'item' : entityText;
        return '$actionText $entityText "${log.entityName}" (${log.newValue ?? 'created'})';

      case ActionEnum.borrow:
        return 'BORROW "${log.entityName}"';

      case ActionEnum.approve:
        return 'APPROVE loan "${log.entityName}"';

      case ActionEnum.reject:
        return 'REJECT loan "${log.entityName}"';

      case ActionEnum.edit:
        if (log.entity == EntityEnum.profile) {
          return 'EDIT profile "${log.userName}" (role: ${log.newValue})';
        } else {
          return 'EDIT ${log.entity.name} "${log.entityName}" (${log.fieldName}: ${log.oldValue} → ${log.newValue})';
        }

      case ActionEnum.returnLoan:
        return 'RETURNED "${log.entityName}"';

      case ActionEnum.delete:
        return 'DELETE ${log.entity.name.toLowerCase()} "${log.entityName}"';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  log.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 15,
                  ),
                ),
              ),
              _RoleChip(role: log.userRole),
            ],
          ),

          const SizedBox(height: 8),

          Text(_buildActivityText(), style: const TextStyle(fontSize: 13)),

          const SizedBox(height: 6),

          Text(
            _fmtTime(log.createdAt),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String role;

  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

String _fmtTime(DateTime t) {
  return '${t.day.toString().padLeft(2, '0')}/'
      '${t.month.toString().padLeft(2, '0')}/'
      '${t.year} '
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';
}
