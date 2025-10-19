import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// A simple in-memory cache to store fetched boundaries
final Map<String, CityBoundary> _boundaryCache = {};

class CityBoundary {
  final String name;
  // A city can be represented by multiple disjoint polygons.
  final List<List<LatLng>> polygons;

  CityBoundary({required this.name, required this.polygons});
}

class MapBoundaryService {
  final http.Client _client;
  final String _baseUrl = 'https://nominatim.openstreetmap.org';

  MapBoundaryService({required http.Client client}) : _client = client;

  Future<List<CityBoundary>> getBoundariesForCities(List<String> cities) async {
    final List<CityBoundary> boundaries = [];
    for (final city in cities) {
      if (_boundaryCache.containsKey(city)) {
        boundaries.add(_boundaryCache[city]!);
        continue;
      }
      try {
        final boundary = await _fetchBoundaryForCity(city);
        if (boundary != null) {
          boundaries.add(boundary);
          _boundaryCache[city] = boundary;
        }
      } catch (e) {
        print('Could not fetch boundary for $city: $e');
      }
    }
    return boundaries;
  }

  Future<CityBoundary?> _fetchBoundaryForCity(String cityName) async {
    // URL-encode the city name to handle spaces and special characters
    final encodedCityName = Uri.encodeComponent(cityName);
    final searchUri = Uri.parse(
        '$_baseUrl/search?q=$encodedCityName, Germany&format=jsonv2&limit=1&featuretype=city');
    final searchResponse = await _client.get(searchUri, headers: {'User-Agent': 'PersiaMarktApp/1.0'});

    if (searchResponse.statusCode != 200 || searchResponse.body.isEmpty) return null;

    final searchData = json.decode(searchResponse.body);
    if (searchData.isEmpty) return null;

    final place = searchData[0];
    final osmId = place['osm_id'];
    final osmType = place['osm_type'];

    if (osmId == null || osmType == null) return null;

    final typePrefix = osmType.toString().toUpperCase()[0];

    final lookupUri = Uri.parse(
        '$_baseUrl/lookup?osm_ids=$typePrefix$osmId&format=jsonv2&polygon_geojson=1');
    final lookupResponse = await _client.get(lookupUri, headers: {'User-Agent': 'PersiaMarktApp/1.0'});

    if (lookupResponse.statusCode != 200 || lookupResponse.body.isEmpty) return null;

    final lookupData = json.decode(lookupResponse.body);
    if (lookupData.isEmpty || lookupData[0]['geojson'] == null) return null;

    final geojson = lookupData[0]['geojson'];
    final List<List<LatLng>> allPolygons = [];

    if (geojson['type'] == 'Polygon') {
      final coordinates = geojson['coordinates'][0] as List;
      final List<LatLng> points = [];
      for (final coord in coordinates) {
        points.add(LatLng(coord[1], coord[0]));
      }
      if (points.isNotEmpty) {
        allPolygons.add(points);
      }
    } else if (geojson['type'] == 'MultiPolygon') {
      final polygons = geojson['coordinates'] as List;
      for (final polygonCoords in polygons) {
        final coordinates = polygonCoords[0] as List;
        final List<LatLng> points = [];
        for (final coord in coordinates) {
          points.add(LatLng(coord[1], coord[0]));
        }
        if (points.isNotEmpty) {
          allPolygons.add(points);
        }
      }
    }

    if (allPolygons.isEmpty) return null;

    return CityBoundary(name: cityName, polygons: allPolygons);
  }
}