import 'dart:convert';

import 'package:http/http.dart' as http;

class PolylinePoint {
  final double latitude;
  final double longitude;
  const PolylinePoint(this.latitude, this.longitude);
}

class RouteResult {
  final double distanceKm;
  final double durationMin;
  final List<PolylinePoint> polyline;
  const RouteResult({
    required this.distanceKm,
    required this.durationMin,
    required this.polyline,
  });
}

class RoutingController {
  // Uses OSRM demo server; replace with Google Directions if needed.
  Future<RouteResult?> fetchRoute({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/$fromLng,$fromLat;$toLng,$toLat?overview=full&geometries=geojson',
    );
    final response = await http.get(url);
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if ((data['routes'] as List).isEmpty) return null;
    final route = data['routes'][0];
    final distanceKm = (route['distance'] as num) / 1000.0;
    final durationMin = (route['duration'] as num) / 60.0;
    final coords = (route['geometry']['coordinates'] as List)
        .map<List<double>>((e) => (e as List).cast<double>())
        .map((p) => PolylinePoint(p[1], p[0]))
        .toList();
    return RouteResult(
      distanceKm: distanceKm,
      durationMin: durationMin,
      polyline: coords,
    );
  }
}

