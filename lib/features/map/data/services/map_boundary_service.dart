import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// A simple in-memory cache to store fetched boundaries
final Map<String, CityBoundary> _boundaryCache = {};

class CityBoundary {
  final String name;
  final List<LatLng> points;

  CityBoundary({required this.name, required this.points});
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
        // Log error or handle it as needed, but don't block other cities
        print('Could not fetch boundary for $city: $e');
      }
    }
    return boundaries;
  }

  Future<CityBoundary?> _fetchBoundaryForCity(String cityName) async {
    // 1. Search for the city to get its OSM ID
    final searchUri = Uri.parse(
        '$_baseUrl/search?q=$cityName, Germany&format=jsonv2&limit=1&featuretype=city');
    final searchResponse = await _client.get(searchUri, headers: {'User-Agent': 'PersiaMarktApp/1.0'});

    if (searchResponse.statusCode != 200 || searchResponse.body.isEmpty) return null;

    final searchData = json.decode(searchResponse.body);
    if (searchData.isEmpty) return null;

    final place = searchData[0];
    final osmId = place['osm_id'];
    final osmType = place['osm_type'];

    if (osmId == null || osmType == null) return null;

    // The API requires a type prefix (R for relation, W for way, N for node)
    final typePrefix = osmType.toString().toUpperCase()[0];

    // 2. Lookup the OSM ID to get the GeoJSON polygon
    final lookupUri = Uri.parse(
        '$_baseUrl/lookup?osm_ids=$typePrefix$osmId&format=jsonv2&polygon_geojson=1');
    final lookupResponse = await _client.get(lookupUri, headers: {'User-Agent': 'PersiaMarktApp/1.0'});

    if (lookupResponse.statusCode != 200 || lookupResponse.body.isEmpty) return null;

    final lookupData = json.decode(lookupResponse.body);
    if (lookupData.isEmpty || lookupData[0]['geojson'] == null) return null;

    final geojson = lookupData[0]['geojson'];

    // The coordinates can be a Polygon or MultiPolygon
    final List<LatLng> points = [];
    if (geojson['type'] == 'Polygon') {
      final coordinates = geojson['coordinates'][0] as List;
      for (final coord in coordinates) {
        points.add(LatLng(coord[1], coord[0]));
      }
    } else if (geojson['type'] == 'MultiPolygon') {
        // For MultiPolygon, we take the largest polygon as a simplification
        final polygons = geojson['coordinates'] as List;
        List<dynamic> largestPolygon = [];
        for (final polygon in polygons) {
            if(polygon[0].length > largestPolygon.length) {
                largestPolygon = polygon[0];
            }
        }
        for (final coord in largestPolygon) {
            points.add(LatLng(coord[1], coord[0]));
        }
    }

    if (points.isEmpty) return null;

    return CityBoundary(name: cityName, points: points);
  }
}