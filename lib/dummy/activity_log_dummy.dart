enum ActionEnum { create, edit, delete, approve, reject, borrow, returnLoan }

enum EntityEnum { item, loan, fine, category, profile }

class ActivityLogDummy {
  final int id;
  final String userName;
  final String role;
  final ActionEnum action;
  final EntityEnum entity;
  final int entityId;
  final String entityName;
  final String fieldName;
  final String? oldValue;
  final String? newValue;
  final DateTime createdAt;

  ActivityLogDummy({
    required this.id,
    required this.userName,
    required this.role,
    required this.action,
    required this.entity,
    required this.entityId,
    required this.entityName,
    required this.fieldName,
    this.oldValue,
    this.newValue,
    required this.createdAt,
  });
}

final activityLogDummies = <ActivityLogDummy>[
  ActivityLogDummy(
    id: 1,
    userName: 'Admin Utama',
    role: 'admin',
    action: ActionEnum.create,
    entity: EntityEnum.item,
    entityId: 12,
    entityName: 'Multimeter Digital',
    fieldName: 'item',
    oldValue: null,
    newValue: 'created',
    createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
  ),

  ActivityLogDummy(
    id: 2,
    userName: 'Melati',
    role: 'borrower',
    action: ActionEnum.borrow,
    entity: EntityEnum.loan,
    entityId: 21,
    entityName: 'LN-20260128-001',
    fieldName: 'loan',
    oldValue: null,
    newValue: 'pending',
    createdAt: DateTime.now().subtract(const Duration(minutes: 7)),
  ),

  ActivityLogDummy(
    id: 3,
    userName: 'Officer Budi',
    role: 'officer',
    action: ActionEnum.approve,
    entity: EntityEnum.loan,
    entityId: 21,
    entityName: 'LN-20260128-001',
    fieldName: 'status',
    oldValue: 'pending',
    newValue: 'approved',
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
  ),

  ActivityLogDummy(
    id: 4,
    userName: 'Admin Utama',
    role: 'admin',
    action: ActionEnum.edit,
    entity: EntityEnum.profile,
    entityId: 5,
    entityName: 'melati',
    fieldName: 'role',
    oldValue: 'borrower',
    newValue: 'borrower',
    createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
  ),

  ActivityLogDummy(
    id: 5,
    userName: 'Officer Budi',
    role: 'officer',
    action: ActionEnum.returnLoan,
    entity: EntityEnum.loan,
    entityId: 21,
    entityName: 'LN-20260128-001',
    fieldName: 'status',
    oldValue: 'borrowed',
    newValue: 'returned',
    createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
  ),
];
