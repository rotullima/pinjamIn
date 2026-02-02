import 'package:supabase_flutter/supabase_flutter.dart';

class UserSession {
  static String id = '';
  static String role = '';
  static String name = '';

  static bool get isLoggedIn => id.isNotEmpty;

  static void set({
    required String id,
    required String role,
    required String name,
  }) {
    UserSession.id = id;
    UserSession.role = role;
    UserSession.name = name;
  }

  static void clear() {
    id = '';
    role = '';
    name = '';
  }

  // Restore session from Supabase auth state
  static Future<bool> restoreSession() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session?.user != null) {
        final user = session!.user;
        
        final profile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('profile_id', user.id)
            .single();
        
        set(
          id: user.id,
          role: profile['role'] as String,
          name: profile['name'] as String,
        );
        
        return true;
      }
      return false;
    } catch (e) {
      clear();
      return false;
    }
  }
}
