// مسیر: lib/features/auth/data/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ==================== اصلاح اصلی اینجاست ====================
  // آدرس پایه به آدرس اصلی سرور بدون هیچ پیشوند اضافی تغییر کرد.
  final String _baseUrl = 'https://persia-market-panel.onrender.com';
  // ==========================================================

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
    // مسیر کامل و صحیح برای ثبت‌نام کاربر
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/user/register'), // <<<--- اصلاح شد
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'city': city ?? '',
      }),
    );

    final responseBody = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return 'ثبت‌نام با موفقیت انجام شد.';
    } else {
      throw Exception(responseBody['message'] ?? 'خطا در ثبت‌نام');
    }
  }

  Future<String> login({required String email, required String password}) async {
    // مسیر کامل و صحیح برای ورود کاربر
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/user/login'), // <<<--- اصلاح شد
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    final responseBody = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final token = responseBody['access_token'];
      await _prefs.setString(_tokenKey, token);
      return token;
    } else {
      throw Exception(responseBody['message'] ?? 'خطا در ورود');
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