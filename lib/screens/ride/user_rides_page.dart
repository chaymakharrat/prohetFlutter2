import 'package:flutter/material.dart';
import 'package:projet_flutter/controller/ride_controller.dart';
import 'package:projet_flutter/models/dto/ride_with_reservation.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import 'publish_ride_page.dart';

class UserRidesPage extends StatefulWidget {
  static const String routeName = '/userRides';

  const UserRidesPage({super.key});

  @override
  State<UserRidesPage> createState() => _UserRidesPageState();
}

class _UserRidesPageState extends State<UserRidesPage> {
  final RideController controller = RideController();
  late Future<List<RideWithReservations>> ridesWithReservationsFuture;

  @override
  void initState() {
    super.initState();
    ridesWithReservationsFuture = _loadRidesWithReservations();
  }

  Future<List<RideWithReservations>> _loadRidesWithReservations() async {
    final app = context.read<AppState>();
    final userId = app.currentUser!.id;

    final rides = await controller.getUserRides(userId);

    final ridesWithReservations = await Future.wait(
      rides.map((rideDTO) async {
        final reservations = await controller.getReservationsWithUsersForRide(
          rideDTO.ride.id,
        );

        return RideWithReservations(
          rideDTO: rideDTO,
          reservations: reservations,
        );
      }),
    );

    return ridesWithReservations;
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<List<RideWithReservations>>(
        future: ridesWithReservationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Vous n\'avez publié aucun trajet pour le moment.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            );
          }

          final ridesWithReservations = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ridesWithReservations.length,
            itemBuilder: (context, index) {
              final rideWithRes = ridesWithReservations[index];
              final rideDTO = rideWithRes.rideDTO;
              final reservations = rideWithRes.reservations;

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
                              '${rideDTO.ride.origin.label} → ${rideDTO.ride.destination.label}',
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
                            '${rideDTO.ride.departureTime.day.toString().padLeft(2, '0')}/'
                            '${rideDTO.ride.departureTime.month.toString().padLeft(2, '0')}/'
                            '${rideDTO.ride.departureTime.year}  '
                            '${rideDTO.ride.departureTime.hour.toString().padLeft(2, '0')}:'
                            '${rideDTO.ride.departureTime.minute.toString().padLeft(2, '0')}',
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
                            '${rideDTO.ride.distanceKm.toStringAsFixed(1)} km',
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
                            '${rideDTO.ride.availableSeats} places',
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
                          'Réservées : ${reservations.fold<int>(0, (s, r) => s + r.reservation.seatsReserved)} / ${rideDTO.ride.availableSeats}',
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
                          Row(
                            children: [
                              IconButton(
                                tooltip: 'Modifier',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PublishRidePage(
                                        rideToEdit: rideDTO.ride,
                                      ),
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
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 28,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Annuler le trajet'),
                                      content: const Text(
                                        'Voulez-vous vraiment annuler ce trajet ? Les passagers seront notifiés.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Non'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text('Oui, annuler'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm != true) return;

                                  try {
                                    // Annulation côté backend
                                    await context
                                        .read<AppState>()
                                        .rideController
                                        .cancelRide(rideDTO.ride.id);

                                    // Rafraîchir la liste
                                    setState(() {
                                      ridesWithReservationsFuture =
                                          _loadRidesWithReservations();
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Trajet annulé avec succès',
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Erreur lors de l’annulation : $e',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
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
                                          final passenger = reservations[index];
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
                                                  "Places réservées: ${passenger.reservation.seatsReserved}",
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
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
          );
        },
      ),
    );
  }
}
