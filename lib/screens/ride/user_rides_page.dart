import 'package:flutter/material.dart';
import 'package:projet_flutter/controller/ride_controller.dart';
import 'package:projet_flutter/models/dto/ride_with_reservation.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import 'package:projet_flutter/models/ride.dart';
import 'publish_ride_page.dart';
import '../chat/chat_details_page.dart';

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
        title: const Text(
          "Mes trajets publiés",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        foregroundColor: Colors.white,
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
                      // --- TIMELINE TRAJET ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Colonne Icônes (Axe)
                          Column(
                            children: [
                              const Icon(
                                Icons.circle,
                                color: Color(0xFF1976D2),
                                size: 14,
                              ),
                              Container(
                                width: 2,
                                height: 30,
                                color: Colors.grey.shade300,
                              ),
                              const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          // Colonne Textes
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rideDTO.ride.origin.label,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  rideDTO.ride.destination.label,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
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
                            '${rideDTO.ride.departureTime.year} '
                            '• ${rideDTO.ride.period.displayName} • '
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
                                  // Asign exact reserved seats count for validation logic
                                  final totalReserved = reservations.fold<int>(
                                    0,
                                    (s, r) => s + r.reservation.seatsReserved,
                                  );
                                  rideDTO.ride.reserverSeats = totalReserved
                                      .toDouble();

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
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                255,
                                                255,
                                                239,
                                                242,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.warning_rounded,
                                              color: Colors.red.shade400,
                                              size: 32,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Annuler le trajet',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      content: const Text(
                                        'Voulez-vous vraiment annuler ce trajet ?\n\nCette action est irréversible et les passagers seront notifiés immédiatement.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                        ),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      actionsPadding: const EdgeInsets.only(
                                        bottom: 24,
                                        left: 24,
                                        right: 24,
                                        top: 10,
                                      ),
                                      actions: [
                                        OutlinedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            side: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            'Retour',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Confirmer',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
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
                                          return Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                // Contenu principal
                                                Column(
                                                  children: [
                                                    const SizedBox(height: 12),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 20,
                                                          backgroundColor:
                                                              const Color(
                                                                0xFF1976D2,
                                                              ),
                                                          child: Text(
                                                            passenger
                                                                .user
                                                                .name[0]
                                                                .toUpperCase(),
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Text(
                                                          passenger.user.name,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                  0xFF0D47A1,
                                                                ),
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 16),
                                                    // Infos
                                                    _passengerInfoRow(
                                                      Icons.phone,
                                                      passenger.user.phone,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    _passengerInfoRow(
                                                      Icons.email,
                                                      passenger.user.email,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    _passengerInfoRow(
                                                      Icons.event_seat,
                                                      "${passenger.reservation.seatsReserved} place(s)",
                                                    ),
                                                  ],
                                                ),
                                                // Bouton Chat en haut à gauche
                                                Positioned(
                                                  left: 0,
                                                  top: 0,
                                                  child: InkWell(
                                                    onTap: () {
                                                      final app = context
                                                          .read<AppState>();
                                                      if (app.currentUser ==
                                                          null) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              'Erreur: Utilisateur non connecté',
                                                            ),
                                                          ),
                                                        );
                                                        return;
                                                      }
                                                      Navigator.pop(
                                                        context,
                                                      ); // Close dialog
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              ChatDetailsPage(
                                                                peerId:
                                                                    passenger
                                                                        .user
                                                                        .id,
                                                                peerName:
                                                                    passenger
                                                                        .user
                                                                        .name,
                                                                currentUserId: app
                                                                    .currentUser!
                                                                    .id,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.blue,
                                                          width: 1,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                Colors.black12,
                                                            blurRadius: 4,
                                                            offset: Offset(
                                                              0,
                                                              2,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      child: const Icon(
                                                        Icons
                                                            .chat_bubble_outline,
                                                        size: 18,
                                                        color: Color(
                                                          0xFF1976D2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
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

  Widget _passengerInfoRow(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
