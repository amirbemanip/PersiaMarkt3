import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:persia_markt/core/config/service_locator.dart';
import 'package:persia_markt/core/cubit/locale_cubit.dart';
import 'package:persia_markt/core/error/exceptions.dart';

/// A service class for handling all network requests to the PersiaMarkt API.
class ApiService {
  late final String _baseUrl;
  final http.Client _client;
  final Duration _timeoutDuration = const Duration(seconds: 30);

  ApiService({required http.Client client}) : _client = client {
    String envUrl = dotenv.env['API_BASE_URL'] ?? 'https://persia-market-panel.onrender.com';
    if (!envUrl.endsWith('/api/v1')) {
      envUrl = '$envUrl/api/v1';
    }
    _baseUrl = envUrl;
  }

  /// Fetches all market data (stores, products, categories) in a single API call.
  ///
  /// Throws a [ServerException] for server-side errors (non-200 status codes).
  /// Throws a [NetworkException] for connectivity issues.
  /// Throws a [TimeoutException] if the request times out.
  /// Throws a [ParsingException] if the response JSON is malformed.
  Future<Map<String, dynamic>> fetchMarketDataAsJson() async {
    final Uri url = Uri.parse('$_baseUrl/public/market-data');
    final currentLocale = sl<LocaleCubit>().state;
    final languageCode = currentLocale.languageCode;

    try {
      final response = await _client.get(
        url,
        headers: {'Accept-Language': languageCode},
      ).timeout(_timeoutDuration);

      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException();
    } catch (e) {
      // Fallback for any other unexpected errors during the request.
      throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Processes the HTTP response, parsing the body or throwing an exception.
  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return json.decode(utf8.decode(response.bodyBytes));
      } on FormatException {
        throw ParsingException();
      }
    } else {
      final String message = _extractErrorMessage(response.body);
      throw ServerException(message: message, statusCode: response.statusCode);
    }
  }

  /// Safely extracts an error message from a JSON response body.
  String _extractErrorMessage(String body) {
    try {
      final decodedBody = json.decode(body);
      return decodedBody['message'] ?? 'An unknown server error occurred.';
    } catch (e) {
      return 'Failed to decode server error message.';
    }
  }
}