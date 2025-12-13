import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_ride_models.dart';
import '../../models/reservation.dart';
import '../../state/app_state.dart';
import 'ride_details_page.dart';
import 'publish_ride_page.dart';
import 'package:url_launcher/url_launcher.dart';

class UserRidesPage extends StatelessWidget {
  static const String routeName = '/userRides';

  const UserRidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final List<Ride> myRides = app.rideService.getUserRides('me');

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text('Mes trajets publiés'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: myRides.isEmpty
          ? const Center(
              child: Text(
                'Vous n\'avez publié aucun trajet pour le moment.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myRides.length,
              itemBuilder: (context, index) {
                final ride = myRides[index];
                final reservations = app.getReservationsForRide(ride.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TITRE DU TRAJET
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFF1976D2),
                              size: 26,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${ride.origin.label} → ${ride.destination.label}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // DATE & HEURE
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${ride.departureTime.day.toString().padLeft(2, '0')}/'
                              '${ride.departureTime.month.toString().padLeft(2, '0')}/'
                              '${ride.departureTime.year}  '
                              '${ride.departureTime.hour.toString().padLeft(2, '0')}:'
                              '${ride.departureTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // DISTANCE & PLACES
                        Row(
                          children: [
                            const Icon(
                              Icons.navigation,
                              color: Colors.teal,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${ride.distanceKm.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Icon(
                              Icons.event_seat,
                              color: Colors.indigo,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${ride.availableSeats} places',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // PLACES RÉSERVÉES
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Réservées : ${reservations.fold<int>(0, (s, r) => s + r.seatsReserved)} / ${ride.availableSeats}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // BOUTONS ACTIONS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Boutons à gauche
                            Row(
                              children: [
                                IconButton(
                                  tooltip: 'Modifier',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PublishRidePage(rideToEdit: ride),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Color(0xFF1976D2),
                                    size: 28,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Supprimer',
                                  onPressed: () async {
                                    // ... ta logique de suppression ...
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),

                            // Voir passagers
                            // Voir passagers
                            if (reservations.isNotEmpty)
                              ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      title: const Text(
                                        "Liste des passagers",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          itemCount: reservations.length,
                                          separatorBuilder: (context, index) =>
                                              const Divider(
                                                height: 12,
                                                color: Colors.grey,
                                              ),
                                          itemBuilder: (context, index) {
                                            final passenger =
                                                reservations[index];
                                            return ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor: const Color(
                                                  0xFF1976D2,
                                                ),
                                                child: Text(
                                                  passenger.user.name[0]
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              title: Text(passenger.user.name),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Téléphone: ${passenger.user.phone}",
                                                  ),
                                                  Text(
                                                    "Email: ${passenger.user.email}",
                                                  ),
                                                  Text(
                                                    "placé reservés: ${passenger.seatsReserved}",
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text(
                                            "Fermer",
                                            style: TextStyle(
                                              color: Color(0xFF1976D2),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.people, size: 20),
                                label: const Text("Passagers"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00AEEF),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
