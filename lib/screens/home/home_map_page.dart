import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:projet_flutter/controller/routing_controller.dart';
import 'package:projet_flutter/screens/profile/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:string_similarity/string_similarity.dart';
import '../../models/app_ride_models.dart';
import '../../controller/location_controller.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../state/app_state.dart';
import '../ride/ride_list_page.dart';
import '../ride/publish_ride_page.dart';

class HomeMapPage extends StatefulWidget {
  const HomeMapPage({super.key, this.showMap = true});
  final bool showMap;

  @override
  State<HomeMapPage> createState() => _HomeMapPageState();
}

class _HomeMapPageState extends State<HomeMapPage> {
  final LocationController _locationController = LocationController();
  final RoutingController _routingController = RoutingController();
  MapController? _mapController;
  List<ll.LatLng> _polyline = [];
  List<Marker> _markers = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<String> _regionSuggestions = [];

  static const double _tunisiaMinLat = 30.2;
  static const double _tunisiaMaxLat = 37.5;
  static const double _tunisiaMinLng = 7.5;
  static const double _tunisiaMaxLng = 11.6;

  final ll.LatLng _tunisiaCenter = const ll.LatLng(
    (30.2 + 37.5) / 2,
    (7.5 + 11.6) / 2,
  );

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

  @override
  void initState() {
    super.initState();
    if (widget.showMap) _mapController = MapController();
    _loadMyLocation();
  }

  // ===================== LOCATION =====================
  Future<void> _loadMyLocation() async {
    final pos = await _locationController.getCurrentPosition();
    if (!mounted) return;

    if (pos == null) return;

    if (!_isWithinTunisiaBounds(pos.latitude, pos.longitude)) {
      _showSnack(
        'Votre position n\'est pas en Tunisie. Carte centrée sur la Tunisie.',
        Colors.brown,
      );
      _mapController?.move(_tunisiaCenter, 6);
      return;
    }

    final app = context.read<AppState>();
    final placeName = await _getPlaceNameFromLatLng(
      pos.latitude,
      pos.longitude,
    );
    print('Ma position actuelle : $placeName');
    app.origin = LocationPoint(
      latitude: pos.latitude,
      longitude: pos.longitude,
      label: placeName, // ex: "Sfax"
    );

    _moveCamera(pos);
    _updateMarkers();
  }

  bool _isWithinTunisiaBounds(double lat, double lng) =>
      lat >= _tunisiaMinLat &&
      lat <= _tunisiaMaxLat &&
      lng >= _tunisiaMinLng &&
      lng <= _tunisiaMaxLng;

  void _moveCamera(Position pos) =>
      _mapController?.move(ll.LatLng(pos.latitude, pos.longitude), 10);

  // ===================== MARKERS =====================
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

  // ===================== SEARCH =====================
  List<String> _getFuzzySuggestions(String query, {int maxResults = 5}) {
    final q = query.toLowerCase();
    final scores = <String, double>{};
    for (final region in tunisianRegions.keys) {
      final regionLower = region.toLowerCase();
      if (q.length <= 3 && regionLower.startsWith(q)) {
        scores[region] = 1.0;
      } else {
        scores[region] = StringSimilarity.compareTwoStrings(regionLower, q);
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
    for (final name in tunisianRegions.keys)
      if (name.toLowerCase() == q) return name;
    for (final name in tunisianRegions.keys)
      if (name.toLowerCase().startsWith(q) || name.toLowerCase().contains(q))
        return name;
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
        if (app.origin != null) await _drawRoute();
        _mapController?.move(coords, 10);
        _updateMarkers();
        _showSnack('Trajet vers "$regionMatch" dessiné ✅', Colors.green);
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
          if (app.origin != null) await _drawRoute();
          _mapController?.move(ll.LatLng(lat, lon), 10);
          _updateMarkers();
          _showSnack('Trajet vers "$query" dessiné ✅', Colors.green);
          return;
        }
      }
      _showSnack('Adresse introuvable. Vérifiez l’orthographe.', Colors.red);
    } catch (e) {
      _showSnack('Erreur réseau : $e', Colors.red);
    }
  }

  Future<void> _drawRoute() async {
    final app = context.read<AppState>();
    final o = app.origin;
    final d = app.destination;
    if (o == null || d == null) return;

    final route = await _routingController.fetchRoute(
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
    // ✅ ICI LE LIEN IMPORTANT
    app.distanceKm = route.distanceKm;
    app.durationMin = route.durationMin;
    _updateMarkers();
  }

  Future<String> _getPlaceNameFromLatLng(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json'
        '&lat=$lat'
        '&lon=$lng'
        '&zoom=12'
        '&addressdetails=1'
        '&accept-language=fr',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'com.example.projet_flutter (contact@email.com)',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'];

        final state = address['state']; // région
        final county =
            address['county'] ?? address['municipality']; // mo3tamdia

        if (state != null && county != null) {
          return "$state $county"; // ex: "Mahdia Jam"
        }

        return state ?? county ?? 'Lieu sélectionné';
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return 'Lieu sélectionné';
  }

  void _onMapTapped(ll.LatLng latLng) async {
    final app = context.read<AppState>();

    if (app.origin == null) {
      _showSnack('Position de départ inconnue', Colors.orange);
      return;
    }

    if (!_isWithinTunisiaBounds(latLng.latitude, latLng.longitude)) {
      _showSnack(
        'Veuillez sélectionner une destination en Tunisie',
        Colors.red,
      );
      return;
    }

    final placeName = await _getPlaceNameFromLatLng(
      latLng.latitude,
      latLng.longitude,
    );

    app.destination = LocationPoint(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      label: placeName,
    );

    await _drawRoute();
    _updateMarkers();

    _showSnack('Destination : $placeName', Colors.green);
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  // ===================== BUILD =====================
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tunisiaBounds = LatLngBounds.fromPoints([
      ll.LatLng(_tunisiaMinLat, _tunisiaMinLng),
      ll.LatLng(_tunisiaMaxLat, _tunisiaMaxLng),
    ]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text(
          'Carte',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
        actions: [UserAvatarAction(app)],
      ),
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
              child: MapSearchBar(
                controller: _searchController,
                isSearching: _isSearching,
                suggestions: _regionSuggestions,
                onChanged: (text) => setState(
                  () => _regionSuggestions = _getFuzzySuggestions(text),
                ),
                onSubmitted: (_) => _onSearchPressed(),
                onSuggestionTap: (suggestion) {
                  _searchController.text = suggestion;
                  setState(() => _regionSuggestions = []);
                  _onSearchPressed();
                },
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomActionButtons(),
          ),
        ],
      ),
    );
  }
}

// ===================== WIDGETS =====================
class MapSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSearching;
  final List<String> suggestions;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onSuggestionTap;

  const MapSearchBar({
    super.key,
    required this.controller,
    required this.isSearching,
    required this.suggestions,
    required this.onChanged,
    required this.onSubmitted,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Rechercher une destination...',
            prefixIcon: Icon(
              Icons.search,
              color: isSearching ? Colors.green : Colors.grey,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
        ...suggestions.map(
          (s) => ListTile(title: Text(s), onTap: () => onSuggestionTap(s)),
        ),
      ],
    );
  }
}

class BottomActionButtons extends StatelessWidget {
  const BottomActionButtons({super.key});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                  onPressed: () =>
                      Navigator.pushNamed(context, RideListPage.routeName),
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
                  onPressed: () =>
                      Navigator.pushNamed(context, PublishRidePage.routeName),
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
    );
  }
}

class UserAvatarAction extends StatelessWidget {
  final app;
  const UserAvatarAction(this.app, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () => Navigator.pushNamed(context, ProfilePage.routeName),
        child: Stack(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                app.currentUser?.name[0].toUpperCase() ?? 'U',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
