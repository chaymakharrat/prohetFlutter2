import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projet_flutter/controller/ride_controller.dart';
import 'package:projet_flutter/models/dto/ride_with_driver_dto.dart';
import 'package:projet_flutter/state/app_state.dart';
import 'package:provider/provider.dart';
import '../../models/app_ride_models.dart';
import '../../controller/reservation_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingPage extends StatefulWidget {
  static const String routeName = '/booking';
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final ReservationController reservationController = ReservationController();
  List<Reservation> reservations = [];
  bool isLoading = true;
  Map<String, RideDTO> _ridesMap = {};

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final appState = context.read<AppState>();
    final userId = appState.currentUser!.id;

    // Récupérer les réservations actives
    final activeReservations = await reservationController
        .getActiveReservationsForUser(userId);

    // Créer un controller Ride
    final rideController = RideController();

    // Charger tous les rides associés aux réservations
    final List<Future<RideDTO>> rideFutures = activeReservations
        .map((res) => rideController.getRideById(res.rideId))
        .toList();
    final rides = await Future.wait(rideFutures);

    setState(() {
      reservations = activeReservations;
      _ridesMap = {
        for (int i = 0; i < rides.length; i++) reservations[i].id: rides[i],
      };
      isLoading = false;
    });
  }

  Widget _driverInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1565C0), size: 22),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reservations.isEmpty
          ? const Center(
              child: Text(
                "Aucune réservation active",
                style: TextStyle(fontSize: 17, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final res = reservations[index];
                final ride = _ridesMap[res.id]!;
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
                        Text(
                          "${ride.ride.origin.label} → ${ride.ride.destination.label}",
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Départ : ${DateFormat('dd/MM/yyyy HH:mm').format(ride.ride.departureTime)}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                        Text(
                          "Prix total : ${(res.seatsReserved * ride.ride.pricePerSeat).toStringAsFixed(2)} DT",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                final Uri whatsappUri = Uri.parse(
                                  "https://wa.me/${ride.driver.phone}?text=${Uri.encodeComponent('Bonjour ${ride.driver.name}, je souhaite annuler ma réservation pour le trajet ${ride.ride.origin.label} → ${ride.ride.destination.label} du ${DateFormat('dd/MM/yyyy HH:mm').format(ride.ride.departureTime)}.')}",
                                );
                                if (await canLaunchUrl(whatsappUri)) {
                                  await launchUrl(whatsappUri);
                                }

                                // Appel Firestore pour annuler
                                await reservationController.cancelReservation(
                                  ride.ride.id,
                                  res.id,
                                  res.seatsReserved,
                                );

                                // Mise à jour locale
                                setState(() {
                                  reservations.removeAt(index);
                                });

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
