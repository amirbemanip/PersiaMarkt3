// lib/features/checkout/data/services/checkout_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:persia_markt/features/auth/data/services/auth_service.dart';

class CheckoutService {
  final String _baseUrl = 'https://persia-market-panel.onrender.com';
  final http.Client _client;
  final AuthService _authService;

  CheckoutService({required http.Client client, required AuthService authService})
      : _client = client,
        _authService = authService;

  Future<void> placeOrder({
    required Map<String, String> address,
    required List<Map<String, dynamic>> items,
  }) async {
    final token = _authService.getToken();
    if (token == null) {
      throw Exception('برای ثبت سفارش باید ابتدا وارد شوید.');
    }

    final response = await _client.post(
      Uri.parse('$_baseUrl/checkout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'address': address,
        'items': items,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return; // Order placed successfully
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'خطا در ثبت سفارش');
    }
  }
}