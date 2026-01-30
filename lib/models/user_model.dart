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

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        email: json['email'],
        name: json['name'],
        role: json['role'],
        isActive: json['is_active'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
        'is_active': isActive,
      };
}