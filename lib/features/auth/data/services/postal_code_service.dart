import 'dart:convert';
import 'package:http/http.dart' as http;

class PostalCodeService {
  final String _baseUrl = 'https://api.zippopotam.us';
  final http.Client _client;

  PostalCodeService({required http.Client client}) : _client = client;

  /// Validates a postal code for a given city in Germany.
  /// Returns true if the city name matches one of the place names for the postal code.
  Future<bool> validatePostalCode(String postalCode, String cityName) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/de/$postalCode'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final places = data['places'] as List<dynamic>;
        // Check if any of the place names for this postal code match the selected city.
        // We use a case-insensitive comparison for robustness.
        return places.any((place) =>
            (place['place name'] as String).toLowerCase() == cityName.toLowerCase());
      } else {
        // The postal code is not valid or not found.
        return false;
      }
    } catch (e) {
      // Network error or other exceptions.
      return false;
    }
  }
}