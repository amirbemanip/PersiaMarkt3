import 'dart:convert'; // FIXED: Corrected the import statement
import 'package:http/http.dart' as http;
import 'dart:async'; // For timeout

/// A service class for handling all network requests to the PersiaMarkt API.
/// It is optimized to fetch initial data concurrently and handles server cold starts.
class ApiService {
  final String _baseUrl = 'https://persia-market-panel.onrender.com';
  final http.Client _client;
  // Increased timeout to handle server cold starts on free hosting tiers.
  final _timeoutDuration = const Duration(seconds: 90);

  ApiService({required http.Client client}) : _client = client;

  Future<Map<String, dynamic>> fetchMarketDataAsJson() async {
    try {
      print("Fetching market data... This might take a minute on the first load.");
      
      // 1. Fetch stores and categories concurrently with an extended timeout.
      final responses = await Future.wait([
        _client.get(Uri.parse('$_baseUrl/stores')).timeout(_timeoutDuration),
        _client.get(Uri.parse('$_baseUrl/categories')).timeout(_timeoutDuration),
      ]);

      final storesResponse = responses[0];
      final categoriesResponse = responses[1];

      // 2. Validate responses.
      if (storesResponse.statusCode != 200) {
        throw Exception('Failed to load stores: ${storesResponse.body}');
      }
      if (categoriesResponse.statusCode != 200) {
        throw Exception('Failed to load categories: ${categoriesResponse.body}');
      }

      final List<dynamic> storesJson = json.decode(utf8.decode(storesResponse.bodyBytes));
      final List<dynamic> categoriesJson = json.decode(utf8.decode(categoriesResponse.bodyBytes));

      if (storesJson.isEmpty) {
         print("Warning: No stores found from API.");
         return { 'stores': [], 'products': [], 'categories': categoriesJson };
      }

      // 3. Fetch products for each store concurrently.
      final productFutures = storesJson.map((storeJson) {
        final storeId = storeJson['id'];
        return _client.get(Uri.parse('$_baseUrl/stores/$storeId/products'))
            .timeout(_timeoutDuration)
            .then((response) {
          if (response.statusCode == 200) {
            final List<dynamic> productsJson = json.decode(utf8.decode(response.bodyBytes));
            for (var productJson in productsJson) {
              productJson['storeID'] = storeId.toString();
            }
            return productsJson;
          }
          print('Warning: Failed to load products for store ID $storeId');
          return <dynamic>[];
        });
      }).toList();

      final List<List<dynamic>> productsByStore = await Future.wait(productFutures);
      final List<dynamic> allProductsJson = productsByStore.expand((products) => products).toList();

      print("Market data fetched successfully!");
      return {
        'stores': storesJson,
        'products': allProductsJson,
        'categories': categoriesJson,
      };
    } on TimeoutException {
        print("Error: The request to the server timed out. This can happen on the first load.");
        throw Exception('سرور پاسخ نمی‌دهد. لطفاً چند لحظه بعد دوباره تلاش کنید.');
    } catch (e) {
      print('Error fetching market data: $e');
      throw Exception('خطا در اتصال به سرور. لطفاً از اتصال اینترنت خود مطمئن شوید.');
    }
  }
}
