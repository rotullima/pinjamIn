class AppUser {
  final String id;     
  final String name;
  final String role;
  final String email;   

  AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['profile_id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      email: json['email'] ?? 'tidak tersedia', 
    );
  }
}