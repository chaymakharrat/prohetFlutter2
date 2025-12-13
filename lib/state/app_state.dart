import 'package:flutter/material.dart';
import '../models/app_ride_models.dart';
import '../services/ride_service.dart';

class AppState extends ChangeNotifier {
  UserProfile? currentUser;
  bool isLoggedIn = false;

  List<Ride> publishedRides = [];
  List<Ride> reservedRides = [];

  RideService rideService = RideService();

  LocationPoint? origin;
  LocationPoint? destination;
  double pricePerKm = 0.25;
  String? currentUserId;

  void login(UserProfile user) {
    currentUser = user;
    isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    currentUser = null;
    isLoggedIn = false;
    notifyListeners();
  }

  void publishRide(Ride ride) {
    publishedRides.add(ride);
    rideService.addRide(ride);
    notifyListeners();
  }

  List<Reservation> getReservationsForRide(String rideId) {
    return upcomingReservations.where((res) => res.ride.id == rideId).toList();
  }

  // void reserveRide(Ride ride) {
  //   reservedRides.add(ride);
  //   notifyListeners();
  // }
  void loadUserReservations() {
    if (currentUser == null) return;

    reservedRides = rideService.getUserReservations(currentUser!.id);
    notifyListeners();
  }

  List<Reservation> reservations = [];

  void reserveRide(Ride ride, int seats) {
    if (currentUser == null) return;

    reservations.add(
      Reservation(
        id: ride.id + currentUser!.id,
        ride: ride,
        user: currentUser!,
        seatsReserved: seats,
      ),
    );

    notifyListeners();
  }

  List<Reservation> get upcomingReservations {
    final now = DateTime.now();
    return reservations
        .where(
          (r) =>
              r.user.id == currentUser?.id && r.ride.departureTime.isAfter(now),
        )
        .toList();
  }

  void removeReservation(String rideId) {
    reservations.removeWhere((res) => res.ride.id == rideId);
    notifyListeners();
  }

  void removeReservationsForRide(String rideId) {
    reservations.removeWhere((r) => r.ride.id == rideId);
    notifyListeners();
  }

  /// Annule une réservation par son id.
  /// - retire la réservation de la liste
  /// - décrémente ride.reserverSeats (s'il existe)
  /// - met à jour le ride dans le service
  /// - notifie les listeners
  void cancelReservation(String reservationId) {
    final idx = reservations.indexWhere((r) => r.id == reservationId);
    if (idx == -1) return;

    final removed = reservations.removeAt(idx);

    // Mettre à jour le nombre de places réservées sur le ride (si mutable)
    final ride = removed.ride;
    try {
      // sécuriser la décrémentation et ne pas descendre en dessous de 0
      // ride.reserverSeats = (ride.reserverSeats - removed.seatsReserved)
      //     .clamp(0, ride.availableSeats);
      ride.reserverSeats = 3;
      // propager la modification dans le service
      rideService.updateRide(ride);
    } catch (e) {
      // si ton modèle Ride est immuable, il faudra remplacer le ride par une nouvelle instance (voir note après)
      debugPrint('Erreur lors de la mise à jour du ride: $e');
    }

    notifyListeners();
  }
}
