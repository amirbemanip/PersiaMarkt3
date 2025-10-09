import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  late final String _baseUrl;
  final http.Client _client;
  final FlutterSecureStorage _secureStorage;

  // Key to store the auth token securely
  static const String _tokenKey = 'auth_token';

  AuthService({
    required http.Client client,
    required FlutterSecureStorage secureStorage,
  })  : _client = client,
        _secureStorage = secureStorage {
    // Initialize _baseUrl from .env, similar to ApiService
    String envUrl = dotenv.env['API_BASE_URL'] ?? 'https://persia-market-panel.onrender.com';
    if (!envUrl.endsWith('/api/v1')) {
      envUrl = '$envUrl/api/v1';
    }
    _baseUrl = envUrl;
  }

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
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/user/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    final responseBody = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final token = responseBody['access_token'];
      await _secureStorage.write(key: _tokenKey, value: token);
      return token;
    } else {
      throw Exception(responseBody['message'] ?? 'خطا در ورود');
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}