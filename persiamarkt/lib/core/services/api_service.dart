import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:persia_markt/core/models/market_data.dart';

class ApiService {
  static const String dataUrl = 'https://cdn.jsdelivr.net/gh/amirbemanip/PersiaMarkt@main/data.json';
  
  final http.Client _client;

  ApiService({required http.Client client}) : _client = client;

  Future<MarketData> fetchMarketData() async {
    final response = await _client.get(Uri.parse(dataUrl));
    if (response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      return MarketData.fromJson(jsonData);
    } else {
      throw Exception('Failed to load from API with status code: ${response.statusCode}');
    }
  }
}