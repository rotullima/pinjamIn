class UserDummy {
  final String name;
  final String role;
  final String email;
  final String password;

  UserDummy({
    required this.name,
    required this.role,
    required this.email,
    required this.password,
  });
}

List<UserDummy> userDummies = [
  UserDummy(
    name: 'Rotul',
    role: 'admin',
    email: 'rotul@gmail.com',
    password: '552008',
  ),
  UserDummy(
    name: 'Asel',
    role: 'officer',
    email: 'asel@gmail.com',
    password: '011207',
  ),
  UserDummy(
    name: 'Nud',
    role: 'borrower',
    email: 'nadya@gmail.com',
    password: '100108',
  ),
];
