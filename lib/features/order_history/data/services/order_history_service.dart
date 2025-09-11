// lib/features/order_history/data/services/order_history_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:persia_markt/core/models/order.dart';
import 'package:persia_markt/features/auth/data/services/auth_service.dart';

class OrderHistoryService {
  final String _baseUrl = 'https://persia-market-panel.onrender.com/api/v1';
  final http.Client _client;
  final AuthService _authService;

  OrderHistoryService({required http.Client client, required AuthService authService})
      : _client = client,
        _authService = authService;

  Future<List<Order>> fetchOrders() async {
    final token = _authService.getToken();
    if (token == null) {
      throw Exception('کاربر احراز هویت نشده است');
    }

    final response = await _client.get(
      Uri.parse('$_baseUrl/my-orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('خطا در دریافت تاریخچه سفارشات');
    }
  }
}