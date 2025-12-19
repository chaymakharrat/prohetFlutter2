import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:projet_flutter/controller/reservation_controller.dart';
import 'package:projet_flutter/models/dto/ride_with_driver_dto.dart';
import '../chat/chat_details_page.dart';
import '../../models/app_ride_models.dart';
import 'booking_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

class RideDetailsPage extends StatefulWidget {
  static const String routeName = '/rideDetails';
  final RideDTO rideDTO;

  const RideDetailsPage({super.key, required this.rideDTO});

  @override
  State<RideDetailsPage> createState() => _RideDetailsPageState();
}

class _RideDetailsPageState extends State<RideDetailsPage> {
  int seats = 1; // compteur de sièges
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final ride = widget.rideDTO.ride;

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

          const SizedBox(height: 12),

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
                  widget.rideDTO.driver.name.substring(0, 1),
                  style: const TextStyle(
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                widget.rideDTO.driver.name,
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
                    '${widget.rideDTO.driver.rating.toStringAsFixed(1)} / 5',
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
                    dateFormat.format(ride.departureTime),
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

          const SizedBox(height: 12),

          // 🔘 Nombre de sièges
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            shadowColor: Colors.blueGrey.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nombre de sièges :',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: seats > 1
                            ? () => setState(() => seats--)
                            : null,
                      ),
                      Text(
                        seats.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed:
                            (ride.availableSeats - ride.reserverSeats > 0 &&
                                seats <
                                    ride.availableSeats - ride.reserverSeats)
                            ? () => setState(() => seats++)
                            : null, // Désactivé si plus de places
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Bouton Contacter
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
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        builder: (context) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 24),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 1. Avatar & Name
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: const Color(0xFFE3F2FD),
                                    child: Text(
                                      widget.rideDTO.driver.name[0]
                                          .toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1976D2)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.rideDTO.driver.name,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0D47A1),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.star_rounded,
                                                color: Colors.amber, size: 20),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${widget.rideDTO.driver.rating.toStringAsFixed(1)} / 5',
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // 2. Contact Info Group
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F9FC),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: const Color(0xFFE1F5FE)),
                                ),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.email_outlined,
                                          color: Color(0xFF1976D2)),
                                      title: Text(
                                        widget.rideDTO.driver.email,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black87),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    Divider(
                                        height: 1,
                                        color: Colors.grey.withOpacity(0.1)),
                                    ListTile(
                                      leading: const Icon(Icons.phone_outlined,
                                          color: Color(0xFF1976D2)),
                                      title: Text(
                                        widget.rideDTO.driver.phone,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black87),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // 3. Action Button
                              InkWell(
                                onTap: () {
                                  final app = context.read<AppState>();
                                  if (app.currentUser == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Veuillez vous connecter pour envoyer un message.'),
                                      ),
                                    );
                                    return;
                                  }
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatDetailsPage(
                                        peerId: widget.rideDTO.driver.id,
                                        peerName: widget.rideDTO.driver.name,
                                        currentUserId: app.currentUser!.id,
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1976D2),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF1976D2)
                                            .withOpacity(0.25),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Envoyer un message",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_outlined, color: Colors.white),
                    label: const Text(
                      'Contacter',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Bouton Réserver
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: (ride.availableSeats - ride.reserverSeats > 0)
                        ? const LinearGradient(
                            colors: [Color(0xFF1976D2), Color(0xFF00AEEF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: (ride.availableSeats - ride.reserverSeats > 0)
                        ? null
                        : Colors.grey, // gris si complet
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
                    onPressed: (ride.availableSeats - ride.reserverSeats > 0)
                        ? () async {
                            try {
                              final appState = context.read<AppState>();
                              final currentUser = appState
                                  .currentUser; // récupère l'utilisateur connecté

                              if (currentUser == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Utilisateur non connecté !'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              final reservationController =
                                  ReservationController();

                              // Créer la réservation
                              final reservation = Reservation(
                                id: '',
                                userId: currentUser.id,
                                seatsReserved: seats,
                                createdAt: DateTime.now(),
                                rideId: ride.id,
                              );

                              // Ajouter la réservation
                              await reservationController.addReservation(
                                ride.id,
                                reservation,
                              );

                              // Mettre à jour l'affichage localement
                              setState(() {
                                ride.reserverSeats += seats;
                              });

                              // Confirmation
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '$seats place(s) réservée(s) avec succès !',
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );

                              // Redirection vers la page des réservations
                              Navigator.pushNamed(
                                context,
                                BookingPage.routeName,
                                arguments: {'showUserReservations': true},
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Erreur lors de la réservation : $e',
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        : null,

                    // désactivé si complet
                    icon: const Icon(Icons.event_seat, color: Colors.white),
                    label: Text(
                      (ride.availableSeats - ride.reserverSeats > 0)
                          ? 'Réserver'
                          : 'Complet',
                      style: const TextStyle(color: Colors.white),
                    ),
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
