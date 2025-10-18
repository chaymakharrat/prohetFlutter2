import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../../models/ride.dart';

class RideDetailsPage extends StatelessWidget {
  static const String routeName = '/rideDetails';
  final Ride ride;

  const RideDetailsPage({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Détails du trajet',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF00AEEF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🌍 Carte
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: ll.LatLng(
                  ride.origin.latitude,
                  ride.origin.longitude,
                ),
                initialZoom: 8,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.projet_flutter',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: ll.LatLng(
                        ride.origin.latitude,
                        ride.origin.longitude,
                      ),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.my_location,
                        color: Color(0xFF1976D2),
                        size: 28,
                      ),
                    ),
                    Marker(
                      point: ll.LatLng(
                        ride.destination.latitude,
                        ride.destination.longitude,
                      ),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.place,
                        color: Color(0xFF00AEEF),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 👤 Conducteur
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            shadowColor: Colors.blueGrey.withOpacity(0.1),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFBBDEFB),
                child: Text(
                  ride.driver.name.substring(0, 1),
                  style: const TextStyle(
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                ride.driver.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D47A1),
                ),
              ),
              subtitle: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${ride.driver.rating.toStringAsFixed(1)} / 5',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              trailing: Text(
                '${ride.pricePerSeat.toStringAsFixed(0)} DT',
                style: const TextStyle(
                  color: Color(0xFF1976D2),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 🕓 Détails du trajet
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            shadowColor: Colors.blueGrey.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                children: [
                  _infoRow(Icons.location_on, 'Départ', ride.origin.label),
                  _divider(),
                  _infoRow(Icons.flag, 'Destination', ride.destination.label),
                  _divider(),
                  _infoRow(
                    Icons.access_time,
                    'Heure de départ',
                    '${ride.departureTime.hour.toString().padLeft(2, '0')}:${ride.departureTime.minute.toString().padLeft(2, '0')}',
                  ),
                  _divider(),
                  _infoRow(
                    Icons.route,
                    'Distance',
                    '${ride.distanceKm.toStringAsFixed(1)} km',
                  ),
                  _divider(),
                  _infoRow(
                    Icons.timer,
                    'Durée estimée',
                    '${ride.durationMin.toStringAsFixed(0)} min',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 🔘 Boutons en bas
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1976D2),
                    side: const BorderSide(color: Color(0xFF1976D2)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('Contacter'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1976D2), Color(0xFF00AEEF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.event_seat),
                    label: const Text('Réserver'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0D47A1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() =>
      const Divider(height: 20, thickness: 0.5, indent: 32, endIndent: 8);
}
