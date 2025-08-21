import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async'; // For timeout

/// A service class for handling all network requests to the PersiaMarkt API.
/// It is optimized to fetch initial data with a single, efficient request.
class ApiService {
  // ==================== اصلاح اصلی اینجاست ====================
  // آدرس پایه به ریشه API تغییر کرد تا بتوانیم به اندپوینت بهینه دسترسی پیدا کنیم.
  final String _baseUrl = 'https://persia-market-panel.onrender.com';
  // ==========================================================
  
  final http.Client _client;
  // Increased timeout to handle server cold starts on free hosting tiers.
  final _timeoutDuration = const Duration(seconds: 90);

  ApiService({required http.Client client}) : _client = client;

  /// Fetches all market data (stores, products, categories) in a single API call.
  Future<Map<String, dynamic>> fetchMarketDataAsJson() async {
    // ==================== بازنویسی کامل متد ====================
    // این متد اکنون فقط یک درخواست به اندپوینت بهینه‌سازی شده‌ی `market-data` می‌زند.
    final Uri url = Uri.parse('$_baseUrl/api/v1/public/market-data');
    
    try {
      print("Fetching all market data from the optimized endpoint: $url");
      
      final response = await _client.get(url).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        // سرور یک آبجکت JSON کامل شامل 'stores', 'products', 'categories' برمی‌گرداند.
        // ما فقط آن را decode کرده و مستقیماً باز می‌گردانیم.
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print("Market data fetched successfully!");
        return data;
      } else {
        // در صورت بروز خطا، اطلاعات بیشتری چاپ می‌کنیم تا عیب‌یابی راحت‌تر شود.
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
    // ==========================================================
  }
}