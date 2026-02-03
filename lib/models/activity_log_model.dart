enum ActionEnum { 
  create, 
  edit, 
  delete, 
  approve, 
  reject, 
  borrow, 
  returned 
}

enum EntityEnum { 
  item, 
  loan, 
  fine, 
  category, 
  profile 
}

class ActivityLog {
  final int activityId;
  final String userId;
  final ActionEnum action;
  final EntityEnum entity;
  final int entityId;
  final String? fieldName;
  final String? oldValue;
  final String? newValue;
  final DateTime createdAt;
  
  final String userName;
  final String userRole;

  ActivityLog({
    required this.activityId,
    required this.userId,
    required this.action,
    required this.entity,
    required this.entityId,
    this.fieldName,
    this.oldValue,
    this.newValue,
    required this.createdAt,
    required this.userName,
    required this.userRole,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      activityId: json['activity_id'] as int,
      userId: json['user_id'] as String,
      action: parseAction(json['action'] as String),
      entity: parseEntity(json['entity'] as String),
      entityId: json['entity_id'] as int,
      fieldName: json['field_name'] as String?,
      oldValue: json['old_value'] as String?,
      newValue: json['new_value'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: json['user_name'] as String? ?? 'Unknown User',
      userRole: json['user_role'] as String? ?? 'borrower',
    );
  }

  static ActionEnum parseAction(String action) {
    switch (action.toLowerCase()) {
      case 'create': return ActionEnum.create;
      case 'edit': return ActionEnum.edit;
      case 'delete': return ActionEnum.delete;
      case 'approve': return ActionEnum.approve;
      case 'reject': return ActionEnum.reject;
      case 'borrow': return ActionEnum.borrow;
      case 'return': return ActionEnum.returned;
      default: return ActionEnum.create;
    }
  }

  static EntityEnum parseEntity(String entity) {
    switch (entity.toLowerCase()) {
      case 'item': return EntityEnum.item;
      case 'loan': return EntityEnum.loan;
      case 'fine': return EntityEnum.fine;
      case 'category': return EntityEnum.category;
      case 'profile': return EntityEnum.profile;
      default: return EntityEnum.item;
    }
  }

  String get entityName {
    return entityId.toString();
  }
}