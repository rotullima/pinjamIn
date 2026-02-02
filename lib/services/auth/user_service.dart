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
        'apikey': apiKey,
        'Authorization': 'Bearer $apiKey', 
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
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'apikey': apiKey,
        'Authorization': 'Bearer $apiKey', // Use anon_key like GET
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

  /// PUT update user
  Future<UserModel> updateUser({
    required String id,
    String? name,
    String? role,
    String? email,
  }) async {
    final res = await http.put(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'apikey': apiKey,
        'Authorization': 'Bearer $apiKey', // Use anon_key like GET
      },
      body: jsonEncode({
        'id': id,
        if (name != null) 'name': name,
        if (role != null) 'role': role,
        if (email != null) 'email': email,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update user: ${res.body}');
    }

    final userData = jsonDecode(res.body)['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userData);
  }

  /// Activate user (set is_active = true)
  Future<UserModel> activateUser(String id) async {
    final res = await http.put(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'apikey': apiKey,
        'Authorization': 'Bearer $apiKey', // Use anon_key like GET
      },
      body: jsonEncode({
        'id': id,
        'is_active': true,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to activate user: ${res.body}');
    }

    final userData = jsonDecode(res.body)['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userData);
  }

  /// DELETE (soft) user
  Future<void> deleteUser(String id) async {
    final res = await http.delete(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'apikey': apiKey,
        'Authorization': 'Bearer $apiKey', // Use anon_key like GET
      },
      body: jsonEncode({'id': id}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to delete user: ${res.body}');
    }
  }
}
