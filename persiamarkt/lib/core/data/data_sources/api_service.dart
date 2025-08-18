// مسیر: lib/core/data/data_sources/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:persia_markt/core/config/service_locator.dart';
import 'package:persia_markt/core/cubit/locale_cubit.dart';
import 'package:persia_markt/core/data/models/market_data_model.dart'; // ۱. import مدل MarketData اضافه شد
import 'package:persia_markt/core/error/exceptions.dart';

class ApiService {
  final http.Client client;
  // ۲. آدرس پایه سرور دوباره تعریف شد
  final String _baseUrl = 'http://192.168.178.68:3000/api/v1/public';

  ApiService({required this.client});

  Future<MarketData> getMarketData() async {
    try {
      // ۳. زبان فعلی از LocaleCubit خوانده می‌شود
      final currentLocale = sl<LocaleCubit>().state;
      final languageCode = currentLocale.languageCode;

      final response = await client.get(
        Uri.parse('$_baseUrl/market-data'),
        headers: {
          'Content-Type': 'application/json',
          'Accept-Language': languageCode, // هدر زبان به درخواست اضافه شد
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // ۴. پاسخ سرور به مدل MarketData تبدیل می‌شود
        return MarketData.fromJson(data);
      } else {
        throw ServerException('Failed to load market data: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException('Failed to connect to the server: $e');
    }
  }
}