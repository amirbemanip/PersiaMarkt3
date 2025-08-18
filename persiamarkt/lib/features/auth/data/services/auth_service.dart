import 'dart:convert';
import 'package:http/http.dart' as http; // <-- اصلاح شد
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = 'https://persia-market-panel.onrender.com';
  final http.Client _client;
  final SharedPreferences _prefs;

  // Key to store the auth token locally
  static const String _tokenKey = 'auth_token';

  AuthService({required http.Client client, required SharedPreferences prefs})
      : _client = client,
        _prefs = prefs;

  Future<String> register({
    required String name,
    required String email,
    required String password,
    String? city,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/user/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'city': city,
      }),
    );

    if (response.statusCode == 201) {
      return 'ثبت‌نام با موفقیت انجام شد.';
    } else {
      final error = json.decode(response.body)['message'];
      throw Exception(error ?? 'خطا در ثبت‌نام');
    }
  }

  Future<String> login({required String email, required String password}) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/user/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['access_token'];
      await _prefs.setString(_tokenKey, token);
      return token;
    } else {
      final error = json.decode(response.body)['message'];
      throw Exception(error ?? 'خطا در ورود');
    }
  }

  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  bool isLoggedIn() {
    return _prefs.containsKey(_tokenKey);
  }
}
