class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? role;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.role,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final metaData = json['raw_user_meta_data'] as Map<String, dynamic>?;
    
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: metaData?['name'] as String? ?? json['name'] as String?,
      role: metaData?['role'] as String? ?? json['role'] as String?,
      isActive: metaData?['is_active'] as bool? ?? json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
        'is_active': isActive,
      };
}