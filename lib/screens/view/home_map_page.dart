import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:projet_flutter/screens/view/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:string_similarity/string_similarity.dart';
import '../../app.dart';
import '../../models/ride.dart';
import '../../services/location_service.dart';
import '../../services/routing_service.dart';
import 'ride_list_page.dart';
import 'publish_ride_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeMapPage extends StatefulWidget {
  const HomeMapPage({super.key, this.showMap = true});
  final bool showMap;

  @override
  State<HomeMapPage> createState() => _HomeMapPageState();
}

class _HomeMapPageState extends State<HomeMapPage> {
  final LocationService _locationService = LocationService();
  final RoutingService _routingService = RoutingService();
  List<String> _regionSuggestions = [];
  MapController? _mapController;
  List<ll.LatLng> _polyline = [];
  List<Marker> _markers = [];
  bool _isSearching = false;

  final TextEditingController _searchController =
      TextEditingController(); // 🔹 AJOUT

  static const double _tunisiaMinLat = 30.2;
  static const double _tunisiaMaxLat = 37.5;
  static const double _tunisiaMinLng = 7.5;
  static const double _tunisiaMaxLng = 11.6;

  final ll.LatLng _tunisiaCenter = const ll.LatLng(
    (30.2 + 37.5) / 2,
    (7.5 + 11.6) / 2,
  );

  @override
  void initState() {
    super.initState();
    if (widget.showMap) _mapController = MapController();
    _loadMyLocation();
  }

  Future<void> _loadMyLocation() async {
    final pos = await _locationService.getCurrentPosition();
    if (!mounted) return;

    if (pos != null) {
      if (!_isWithinTunisiaBounds(pos.latitude, pos.longitude)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Votre position actuelle n\'est pas en Tunisie. La carte est centrée sur la Tunisie.',
            ),
            backgroundColor: Color.fromARGB(255, 148, 117, 70),
          ),
        );
        _mapController?.move(_tunisiaCenter, 6);
        return;
      }

      final app = context.read<AppState>();
      app.origin = LocationPoint(
        latitude: pos.latitude,
        longitude: pos.longitude,
        label: 'Ma position',
      );

      _moveCamera(pos);
      _updateMarkers();
    }
  }

  void _moveCamera(Position pos) {
    _mapController?.move(ll.LatLng(pos.latitude, pos.longitude), 10);
  }

  bool _isWithinTunisiaBounds(double lat, double lng) {
    return lat >= _tunisiaMinLat &&
        lat <= _tunisiaMaxLat &&
        lng >= _tunisiaMinLng &&
        lng <= _tunisiaMaxLng;
  }

  void _onMapTapped(ll.LatLng latLng) async {
    final app = context.read<AppState>();
    if (app.origin == null) return;

    if (!_isWithinTunisiaBounds(latLng.latitude, latLng.longitude)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une destination en Tunisie'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    app.destination = LocationPoint(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      label: 'Destination',
    );
    await _drawRoute();
  }

  Future<void> _drawRoute() async {
    final app = context.read<AppState>();
    final o = app.origin;
    final d = app.destination;
    if (o == null || d == null) return;

    final route = await _routingService.fetchRoute(
      fromLat: o.latitude,
      fromLng: o.longitude,
      toLat: d.latitude,
      toLng: d.longitude,
    );

    if (!mounted || route == null) return;

    setState(() {
      _polyline = route.polyline
          .map((p) => ll.LatLng(p.latitude, p.longitude))
          .toList();
    });
    _updateMarkers();
  }

  void _updateMarkers() {
    final app = context.read<AppState>();
    final markers = <Marker>[];

    if (app.origin != null) {
      markers.add(
        Marker(
          point: ll.LatLng(app.origin!.latitude, app.origin!.longitude),
          width: 50,
          height: 50,
          child: const Icon(Icons.my_location, color: Colors.blue, size: 36),
        ),
      );
    }

    if (app.destination != null) {
      markers.add(
        Marker(
          point: ll.LatLng(
            app.destination!.latitude,
            app.destination!.longitude,
          ),
          width: 50,
          height: 50,
          child: const Icon(Icons.place, color: Colors.red, size: 36),
        ),
      );
    }

    setState(() => _markers = markers);
  }

  final Map<String, ll.LatLng> tunisianRegions = {
    "Tunis": ll.LatLng(36.8065, 10.1815),
    "Ariana": ll.LatLng(36.8665, 10.1647),
    "Ben Arous": ll.LatLng(36.7468, 10.2431),
    "Manouba": ll.LatLng(36.8028, 10.0919),
    "Sousse": ll.LatLng(35.8256, 10.636),
    "Monastir": ll.LatLng(35.777, 10.8262),
    "Mahdia": ll.LatLng(35.5047, 11.0622),
    "Sfax": ll.LatLng(34.7406, 10.7603),
    "Kairouan": ll.LatLng(35.6781, 10.0963),
    "Kasserine": ll.LatLng(35.167, 8.8361),
    "Sidi Bouzid": ll.LatLng(35.0363, 9.4695),
    "Gabès": ll.LatLng(33.8815, 10.0982),
    "Médenine": ll.LatLng(33.3546, 10.5267),
    "Tataouine": ll.LatLng(32.9297, 10.4519),
    "Gafsa": ll.LatLng(34.425, 8.7842),
    "Tozeur": ll.LatLng(33.918, 8.133),
    "Bizerte": ll.LatLng(37.2746, 9.8739),
    "Beja": ll.LatLng(36.7333, 9.1833),
    "Jendouba": ll.LatLng(36.5033, 8.7797),
    "Zaghouan": ll.LatLng(36.4008, 10.1439),
    "Nabeul": ll.LatLng(36.4513, 10.736),
    "Kébili": ll.LatLng(33.7014, 8.9691),
    "Siliana": ll.LatLng(36.0833, 9.3667),
    "Le Kef": ll.LatLng(36.1667, 8.7167),
    "Manouba ": ll.LatLng(36.8, 10.1),
    "Tunis Sud": ll.LatLng(36.78, 10.18),
    "Zarzis": ll.LatLng(33.503, 11.112),
    "Hammamet": ll.LatLng(36.4011, 10.6223),
  };

  List<String> _getFuzzySuggestions(String query, {int maxResults = 5}) {
    final q = query.toLowerCase();
    final scores = <String, double>{};

    for (final region in tunisianRegions.keys) {
      final regionLower = region.toLowerCase();
      if (q.length <= 3 && regionLower.startsWith(q)) {
        scores[region] = 1.0;
      } else {
        final similarity = StringSimilarity.compareTwoStrings(regionLower, q);
        scores[region] = similarity;
      }
    }

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .where((e) => e.value > 0.1)
        .take(maxResults)
        .map((e) => e.key)
        .toList();
  }

  String? _findClosestRegion(String query) {
    final q = query.toLowerCase();
    for (final name in tunisianRegions.keys) {
      if (name.toLowerCase() == q) return name;
    }

    for (final name in tunisianRegions.keys) {
      if (name.toLowerCase().startsWith(q) || name.toLowerCase().contains(q)) {
        return name;
      }
    }

    return null;
  }

  Future<void> _onSearchPressed() async {
    setState(() => _isSearching = true);
    await _searchAddress();
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _isSearching = false);
  }

  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final app = context.read<AppState>();

    try {
      final regionMatch =
          _findClosestRegion(query) ??
          _getFuzzySuggestions(query, maxResults: 1).firstOrNull;

      if (regionMatch != null) {
        final coords = tunisianRegions[regionMatch]!;
        app.destination = LocationPoint(
          latitude: coords.latitude,
          longitude: coords.longitude,
          label: regionMatch,
        );

        if (app.origin != null) {
          final route = await _routingService.fetchRoute(
            fromLat: app.origin!.latitude,
            fromLng: app.origin!.longitude,
            toLat: coords.latitude,
            toLng: coords.longitude,
          );

          if (route != null) {
            setState(() {
              _polyline = route.polyline
                  .map((p) => ll.LatLng(p.latitude, p.longitude))
                  .toList();
            });
          }
        }

        _mapController?.move(coords, 10);
        _updateMarkers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trajet vers "$regionMatch" dessiné ✅')),
        );
        return;
      }

      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$query,Tunisia&limit=1',
      );
      final resp = await http.get(uri, headers: {'User-Agent': 'flutter_app'});
      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          final name = data[0]['display_name'] ?? query;

          app.destination = LocationPoint(
            latitude: lat,
            longitude: lon,
            label: name,
          );

          if (app.origin != null) {
            final route = await _routingService.fetchRoute(
              fromLat: app.origin!.latitude,
              fromLng: app.origin!.longitude,
              toLat: lat,
              toLng: lon,
            );
            if (route != null) {
              setState(() {
                _polyline = route.polyline
                    .map((p) => ll.LatLng(p.latitude, p.longitude))
                    .toList();
              });
            }
          }

          _mapController?.move(ll.LatLng(lat, lon), 10);
          _updateMarkers();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Trajet vers "$query" dessiné ✅')),
          );
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adresse introuvable. Vérifiez l’orthographe.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur réseau : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tunisiaBounds = LatLngBounds.fromPoints([
      ll.LatLng(_tunisiaMinLat, _tunisiaMinLng),
      ll.LatLng(_tunisiaMaxLat, _tunisiaMaxLng),
    ]);

    return Scaffold(
      body: Stack(
        children: [
          widget.showMap
              ? FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _tunisiaCenter,
                    initialZoom: 6,
                    minZoom: 5,
                    maxZoom: 18,
                    cameraConstraint: CameraConstraint.contain(
                      bounds: tunisiaBounds,
                    ),
                    onTap: (_, latlng) => _onMapTapped(latlng),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.projet_flutter',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _polyline,
                          color: Colors.blue,
                          strokeWidth: 4,
                        ),
                      ],
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                )
              : const Center(child: Text('Carte désactivée')),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher une destination...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: _isSearching ? Colors.green : Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (text) {
                          setState(() {
                            _regionSuggestions = _getFuzzySuggestions(text);
                          });
                        },
                        onSubmitted: (_) => _onSearchPressed(),
                      ),
                      ..._regionSuggestions.map(
                        (suggestion) => ListTile(
                          title: Text(suggestion),
                          onTap: () {
                            _searchController.text = suggestion;
                            setState(() => _regionSuggestions = []);
                            _onSearchPressed();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 5,
                          ),
                          onPressed: () => Navigator.pushNamed(
                            context,
                            RideListPage.routeName,
                          ),
                          icon: const Icon(Icons.directions_car),
                          label: const Text(
                            'Choisir un trajet',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 5,
                          ),
                          onPressed: () => Navigator.pushNamed(
                            context,
                            // PublishRidePage.routeName,
                            ProfilePage.routeName,
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text(
                            'Publier un trajet',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
