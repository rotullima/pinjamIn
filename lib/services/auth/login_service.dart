import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_session.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = res.user;
    if (user == null) {
      throw Exception('Login gagal');
    }

    final profile = await _client
        .from('profiles')
        .select()
        .eq('profile_id', user.id)
        .single();

    UserSession.set(
      id: user.id,
      role: profile['role'],
      name: profile['name'],
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    UserSession.clear();
  }
}
