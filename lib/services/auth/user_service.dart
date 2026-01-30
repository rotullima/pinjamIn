import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final String baseUrl = '${dotenv.env['SUPABASE_URL']}/functions/v1/crud-user';
  final String apiKey = dotenv.env['SUPABASE_ANON_KEY']!;

  /// GET all users
  Future<List<UserModel>> fetchUsers() async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) throw Exception('User not logged in');

    final res = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'apikey': apiKey, // opsional
        'Authorization': 'Bearer $apiKey', // JWT user login
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch users: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final users = (data['users'] as List)
        .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
        .toList();
    return users;
  }

  /// POST create user
  Future<UserModel> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) throw Exception('User not logged in');

    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'apikey': apiKey,
        'Authorization': 'Bearer $token', // JWT user login
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'role': role,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to create user: ${res.body}');
    }

    final userData = jsonDecode(res.body)['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userData);
  }

  /// DELETE (soft) user
  Future<void> deleteUser(String id) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) throw Exception('User not logged in');

    final res = await http.delete(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'apikey': apiKey,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'id': id}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to delete user: ${res.body}');
    }
  }
}
