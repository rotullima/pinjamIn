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
}
