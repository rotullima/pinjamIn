import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/activity_log_model.dart';

class ActivityLogService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ActivityLog>> fetchActivityLogs() async {
    try {
      final response = await _supabase
          .from('activity_logs')
          .select('''
            activity_id,
            user_id,
            action,
            entity,
            entity_id,
            field_name,
            old_value,
            new_value,
            created_at,
            profiles (profile_id, name, role)
          ''')
          .order('created_at', ascending: false);

      final List<ActivityLog> logs = [];

      print('=== DEBUG: Total logs fetched: ${logs.length} ===');
      for (var log in logs.take(10)) {
        // tampilkan 10 terbaru
        print(
          'Action: ${log.action.name} | '
          'Entity: ${log.entity.name} | '
          'EntityID: ${log.entityId} | '
          'CreatedAt: ${log.createdAt} | '
          'Field: ${log.fieldName ?? "-"} | '
          'Old: ${log.oldValue ?? "-"} | '
          'New: ${log.newValue ?? "-"}',
        );
      }

      for (var row in response) {
        final profileData = row['profiles'] as Map<String, dynamic>?;

        logs.add(
          ActivityLog(
            activityId: row['activity_id'] as int,
            userId: row['user_id'] as String,
            action: ActivityLog.parseAction(row['action'] as String),
            entity: ActivityLog.parseEntity(row['entity'] as String),
            entityId: row['entity_id'] as int,
            fieldName: row['field_name'] as String?,
            oldValue: row['old_value'] as String?,
            newValue: row['new_value'] as String?,
            createdAt: DateTime.parse(row['created_at'] as String),
            userName: profileData?['name'] as String? ?? 'Unknown User',
            userRole: profileData?['role'] as String? ?? 'borrower',
          ),
        );
      }

      return logs;
    } catch (e) {
      print('Error fetching activity logs: $e');
      rethrow;
    }
  }

  Future<void> createActivityLog({
    required String userId,
    required ActionEnum action,
    required EntityEnum entity,
    required int entityId,
    String? fieldName,
    String? oldValue,
    String? newValue,
  }) async {
    try {
      await _supabase.from('activity_logs').insert({
        'user_id': userId,
        'action': action.name,
        'entity': entity.name,
        'entity_id': entityId,
        'field_name': fieldName,
        'old_value': oldValue,
        'new_value': newValue,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating activity log: $e');
      rethrow;
    }
  }
}
