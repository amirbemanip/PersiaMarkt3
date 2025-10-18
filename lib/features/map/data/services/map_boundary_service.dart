import 'package:latlong2/latlong.dart';

class CityBoundary {
  final String name;
  final List<LatLng> points;

  CityBoundary({required this.name, required this.points});
}

class MapBoundaryService {
  // In a real app, this would fetch data from an API.
  // Here, we're returning mock data.
  Future<List<CityBoundary>> getCityBoundaries() async {
    return Future.delayed(const Duration(milliseconds: 300), () {
      return [
        // Data from data.europa.eu for Berlin (simplified rectangle)
        CityBoundary(
          name: 'Berlin',
          points: const [
            LatLng(52.6856, 13.0044),
            LatLng(52.6856, 13.7721),
            LatLng(52.3244, 13.7721),
            LatLng(52.3244, 13.0044),
          ],
        ),
        // Mock data for Hamburg
        CityBoundary(
          name: 'Hamburg',
          points: const [
            LatLng(53.7, 9.7),
            LatLng(53.7, 10.3),
            LatLng(53.4, 10.3),
            LatLng(53.4, 9.7),
          ],
        ),
        // Mock data for Munich
        CityBoundary(
          name: 'Munich',
          points: const [
            LatLng(48.25, 11.4),
            LatLng(48.25, 11.7),
            LatLng(48.0, 11.7),
            LatLng(48.0, 11.4),
          ],
        ),
      ];
    });
  }
}