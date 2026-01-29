import 'package:supabase_flutter/supabase_flutter.dart';

class UserRegistrationService {
  Future<String> createNewUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      print("📤 Creating user: $email with role: $role");

      final before = Supabase.instance.client.auth.currentUser;
      print('BEFORE signup UID: ${before?.id} | email: ${before?.email}');

      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': role},
      );

      final after = Supabase.instance.client.auth.currentUser;
      print('AFTER signup UID: ${after?.id} | email: ${after?.email}');

      final userId = response.user?.id;
      if (userId == null) {
        throw Exception('User creation failed: No user ID returned');
      }

      print("✅ User created successfully: $userId");
      return userId;
    } catch (e) {
      print("❌ Error creating user: $e");
      rethrow;
    }
  }
}
