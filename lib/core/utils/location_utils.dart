import 'package:latlong2/latlong.dart';

class LocationUtils {
  /// Checks if a given point is inside a polygon.
  ///
  /// Uses the ray-casting algorithm to determine if the point is inside the polygon.
  /// [point]: The LatLng point to check.
  /// [polygon]: A list of LatLng points that form the polygon.
  static bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.isEmpty) {
      return false;
    }

    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      if (_rayCastIntersect(point, polygon[j], polygon[j + 1])) {
        intersectCount++;
      }
    }
    // Check the last segment connecting the last and first points
    if (_rayCastIntersect(point, polygon[polygon.length - 1], polygon[0])) {
      intersectCount++;
    }

    return (intersectCount % 2) == 1; // Odd number of intersections means inside.
  }

  static bool _rayCastIntersect(LatLng point, LatLng vertA, LatLng vertB) {
    double pointLat = point.latitude;
    double pointLng = point.longitude;
    double vertALat = vertA.latitude;
    double vertALng = vertA.longitude;
    double vertBLat = vertB.latitude;
    double vertBLng = vertB.longitude;

    if ((vertALng > pointLng && vertBLng > pointLng) ||
        (vertALng < pointLng && vertBLng < pointLng) ||
        (vertALat < pointLat && vertBLat < pointLat)) {
      return false;
    }

    if (vertALat > pointLat && vertBLat > pointLat) return false;

    double lngIntersection =
        (pointLat - vertALat) * (vertBLng - vertALng) / (vertBLat - vertALat) +
            vertALng;

    if (lngIntersection > pointLng) {
      return true;
    } else {
      return false;
    }
  }
}