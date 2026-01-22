import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password
      );
  }

  Future<Map<String, dynamic>> getProfile(String userId) async {
    final data = await _client
      .from('profiles')
      .select()
      .eq('profile_id', userId)
      .single();
    
    return data;
  }

  Future<void> signOut()  async {
    await _client.auth.signOut();
  }
}