import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:async'; // For timeout
import 'package:persia_markt/core/config/service_locator.dart';
import 'package:persia_markt/core/cubit/locale_cubit.dart';

/// A service class for handling all network requests to the PersiaMarkt API.
/// It is optimized to fetch initial data with a single, efficient request.
class ApiService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://persia-market-panel.onrender.com';
  final String _apiVersion = dotenv.env['API_VERSION'] ?? 'v1';
  
  final http.Client _client;
  final _timeoutDuration = const Duration(seconds: 90);

  ApiService({required http.Client client}) : _client = client;

  /// Fetches all market data (stores, products, categories) in a single API call.
  Future<Map<String, dynamic>> fetchMarketDataAsJson() async {
    // ==================== اصلاح اصلی اینجاست ====================
    // یک پارامتر تصادفی برای جلوگیری از کش شدن درخواست در iOS اضافه شد
  final cacheBuster = DateTime.now().millisecondsSinceEpoch;
  final Uri url = Uri.parse('$_baseUrl/api/$_apiVersion/public/market-data?v=$cacheBuster');
    // ==========================================================
    
    try {
      // ۱. زبان فعلی از LocaleCubit خوانده می‌شود.
      final currentLocale = sl<LocaleCubit>().state;
      final languageCode = currentLocale.languageCode;

      print("Fetching all market data for language: $languageCode from endpoint: $url");
      
      // ۲. زبان در هدر 'Accept-Language' به همراه درخواست ارسال می‌شود.
      final response = await _client.get(
        url,
        headers: {
          'Accept-Language': languageCode,
        },
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print("Market data fetched successfully!");
        return data;
      } else {
        print('Failed to load market data. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('سرور با خطای ${response.statusCode} پاسخ داد.');
      }
    } on TimeoutException {
        print("Error: The request to the server timed out. This can happen on the first load.");
        throw Exception('سرور پاسخ نمی‌دهد. لطفاً چند لحظه بعد دوباره تلاش کنید.');
    } catch (e) {
      print('Error fetching market data: $e');
      throw Exception('خطا در اتصال به سرور. لطفاً از اتصال اینترنت خود مطمئن شوید.');
    }
  }
}
