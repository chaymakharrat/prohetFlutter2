import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../models/app_ride_models.dart';
import '../../models/reservation.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingPage extends StatelessWidget {
  static const String routeName = '/booking';

  const BookingPage({super.key});

  Widget _driverInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF1565C0), size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final showUserReservations =
        args != null && args['showUserReservations'] == true;

    final appState = context.watch<AppState>();
    final reservations = showUserReservations
        ? appState.upcomingReservations
        : <Reservation>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text("Mes réservations"),
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

      // =============================
      //          AUCUN RÉSULTAT
      // =============================
      body: reservations.isEmpty
          ? const Center(
              child: Text(
                "Aucune réservation future",
                style: TextStyle(fontSize: 17, color: Colors.black54),
              ),
            )
          // =============================
          //            LISTE
          // =============================
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final res = reservations[index];
                final ride = res.ride;

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
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TITRE TRAJET
                        Text(
                          "${ride.origin.label} → ${ride.destination.label}",
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // DATE
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Départ : ${DateFormat('dd/MM/yyyy HH:mm').format(ride.departureTime)}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // PLACES
                        Row(
                          children: [
                            const Icon(Icons.event_seat, color: Colors.teal),
                            const SizedBox(width: 8),
                            Text(
                              "Places réservées : ${res.seatsReserved}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // PRIX
                        Text(
                          "Prix total : ${(res.seatsReserved * ride.pricePerSeat).toStringAsFixed(2)} DT",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // =============================
                        //      BOUTONS D'ACTION
                        // =============================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Bouton voir conducteur
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: const Color(0xFF1976D2),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    title: Row(
                                      children: [
                                        const Icon(
                                          Icons.person,
                                          color: Color(0xFF1976D2),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          ride.driver.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0D47A1),
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _driverInfoRow(
                                          Icons.email,
                                          ride.driver.email,
                                        ),
                                        const SizedBox(height: 10),
                                        _driverInfoRow(
                                          Icons.phone,
                                          ride.driver.phone,
                                        ),
                                        const SizedBox(height: 10),
                                        _driverInfoRow(
                                          Icons.star,
                                          "${ride.driver.rating.toStringAsFixed(1)} / 5",
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Fermer"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Conducteur",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),

                            // Bouton annuler
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () async {
                                final app = context.read<AppState>();

                                final Uri whatsappUri = Uri.parse(
                                  "https://wa.me/${ride.driver.phone}?text=${Uri.encodeComponent('Bonjour ${ride.driver.name}, je souhaite annuler ma réservation pour le trajet ${ride.origin.label} → ${ride.destination.label} du ${DateFormat('dd/MM/yyyy HH:mm').format(ride.departureTime)}.')}",
                                );

                                if (await canLaunchUrl(whatsappUri)) {
                                  await launchUrl(whatsappUri);
                                }

                                app.cancelReservation(res.id);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Réservation annulée."),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Annuler",
                                style: TextStyle(color: Colors.white),
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
