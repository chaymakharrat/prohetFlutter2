import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_flutter/controller/reservation_controller.dart';
import 'package:projet_flutter/controller/ride_controller.dart';
import 'package:projet_flutter/models/dto/ride_with_driver_dto.dart';
import 'package:projet_flutter/state/app_state.dart';
import '../../models/app_ride_models.dart';

// Future<void> testAddRide() async {
//   try {
//     final ride = Ride(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       driverId: 'hPilSNcM1JPdEPalsPSwhJxHOfy2',
//       origin: LocationPoint(latitude: 36.8, longitude: 10.2, label: 'Sousse'),
//       destination: LocationPoint(
//         latitude: 36.9,
//         longitude: 10.1,
//         label: 'tataouine',
//       ),
//       departureTime: DateTime.now().add(const Duration(hours: 1)),
//       availableSeats: 3,
//       pricePerSeat: 15,
//     );

//     print('Ride ready to add: ${ride.toMap()}');

//     final docRef = await FirebaseFirestore.instance
//         .collection('rides')
//         .add(ride.toMap());

//     print('Ride ajouté avec ID : ${docRef.id}');
//   } catch (e) {
//     print('Erreur ajout ride: $e');
//   }
// }
// Future<void> testReservation() async {
//   try {
//     final reservationController = ReservationController();

//     const rideId = 'hAGerlJyz61VN4ebZotS';

//     final reservation = Reservation(
//       id: '', // ❗ pas utilisé car Firestore génère l’ID
//       userId: 'USER_TEST_123',
//       seatsReserved: 1,
//       createdAt: DateTime.now(),
//       rideId: ''
//     );

//     await reservationController.addReservation(rideId, reservation);

//     print('Réservation ajoutée avec succès');
//   } catch (e) {
//     print('Erreur ajout reservation: $e');
//   }
// }
// Future<void> loadReservations() async {
//   try {
//     // 1. Récupérer l'userId depuis AppState
//     //final appState = context.read<AppState>();
//     final userId = 'hPilSNcM1JPdEPalsPSwhJxHOfy2';

//     // 2. Récupérer les réservations actives
//     final reservationController = ReservationController();
//     final activeReservations = await reservationController
//         .getActiveReservationsForUser(userId);

//     // 3. Créer un RideController
//     final rideController = RideController();

//     // 4. Charger tous les rides associés aux réservations
//     final List<Future<RideDTO>> rideFutures = activeReservations.map((
//       res,
//     ) async {
//       final rideDTO = await rideController.getRideById(
//         res.rideId,
//       ); // ⚡ méthode à créer
//       return rideDTO;
//     }).toList();

//     final rides = await Future.wait(rideFutures);

//     // 5. Créer un mapping réservation -> rideDTO pour un accès facile
//     final Map<String, RideDTO> ridesMap = {
//       for (int i = 0; i < activeReservations.length; i++)
//         activeReservations[i].id: rides[i],
//     };

//     // // 6. Mise à jour de l'état
//     // setState(() {
//     //   reservations = activeReservations;
//     //   _ridesMap = ridesMap;
//     //   isLoading = false;
//     // });

//     // 7. Afficher dans la console
//     for (var res in activeReservations) {
//       final rideDTO = ridesMap[res.id]!;
//       print(
//         'Réservation ${res.id}: ${rideDTO.ride.origin.label} → ${rideDTO.ride.destination.label}, conducteur: ${rideDTO.driver.name}',
//       );
//     }
//     print('Réservations chargées avec succès');
//   } catch (e) {
//     print("Erreur _loadReservations: $e");
//   }
// }
//  final NotificationController _notificationController =
//       NotificationController();
//     List<NotificationWithUsers> _notifications = [];
//      Future<void> _loadNotifications() async {
//     final app = context.read<AppState>();
//     final userId = app.currentUser?.id;
//     if (userId == null) {
//       setState(() => _isLoading = false);
//       return;
//     }

//     final notifs = await _notificationController.getUserNotifications("hPilSNcM1JPdEPalsPSwhJxHOfy2");
//     if (mounted) {
//       setState(() {
//         _notifications = notifs;
//         _isLoading = false;
//       });
//     }
//   }

