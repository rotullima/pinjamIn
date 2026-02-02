import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_session.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> signIn({
  required String email,
  required String password,
}) async {
  try {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = res.user;
    if (user == null) {
      throw Exception('Email atau password salah');
    }

    final profile = await _client
        .from('profiles')
        .select()
        .eq('profile_id', user.id)
        .maybeSingle();

    if (profile == null) {
      throw Exception('Akun tidak terdaftar di sistem');
    }

    UserSession.set(
      id: user.id,
      role: profile['role'],
      name: profile['name'],
    );
  } on AuthException catch (e) {
    if (e.message.contains('Invalid login credentials')) {
      throw Exception('Email atau password salah');
    }
    throw Exception(e.message);
  } catch (e) {
    throw Exception('Terjadi kesalahan, coba lagi');
  }
}


  Future<void> signOut() async {
    await _client.auth.signOut();
    UserSession.clear();
  }
}
