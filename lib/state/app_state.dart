import 'package:flutter/material.dart';
import '../models/app_ride_models.dart';
import '../controller/ride_controller.dart';

/// AppState est un store d’état global pour l’application.
/// Il gère :
/// - l’utilisateur courant (currentUser)
/// - les trajets publiés et réservés
/// - les réservations
/// - les informations de trajet (origine, destination, prix par km)
class AppState extends ChangeNotifier {
  // ========================= UTILISATEUR =========================
  UserProfile? currentUser; // Profil de l’utilisateur connecté
  bool isLoggedIn = false; // Indique si un utilisateur est connecté

  // ========================= TRAJETS =========================
  List<Ride> publishedRides = []; // Trajets publiés par l’utilisateur
  List<Ride> reservedRides = []; // Trajets réservés par l’utilisateur
  RideService rideService =
      RideService(); // Service pour interagir avec Firestore ou backend

  // ========================= TRAJET EN COURS =========================
  LocationPoint? origin; // Point de départ sélectionné
  LocationPoint? destination; // Point d’arrivée sélectionné
  double pricePerKm = 0.25; // Tarif par km pour le calcul du prix
  String? currentUserId; // UID de l’utilisateur (facultatif ici)

  // ========================= MÉTHODES UTILISATEUR =========================

  /// Connecte l’utilisateur
  void login(UserProfile user) {
    currentUser = user;
    isLoggedIn = true;
    notifyListeners(); // Notifie les widgets abonnés pour mettre à jour l’UI
  }

  /// Déconnecte l’utilisateur
  void logout() {
    currentUser = null;
    isLoggedIn = false;
    notifyListeners();
  }

  // ========================= MÉTHODES TRAJETS =========================

  /// Publie un nouveau trajet
  void publishRide(Ride ride) {
    publishedRides.add(ride); // Ajoute à la liste locale
    rideService.addRide(ride); // Ajoute à Firestore ou backend
    notifyListeners(); // Notifie l’UI pour mise à jour
  }

  /// Récupère les réservations pour un trajet spécifique
  List<Reservation> getReservationsForRide(String rideId) {
    return upcomingReservations.where((res) => res.ride.id == rideId).toList();
  }

  /// Charge toutes les réservations de l’utilisateur depuis le service
  void loadUserReservations() {
    if (currentUser == null) return;
    reservedRides = rideService.getUserReservations(currentUser!.id);
    notifyListeners();
  }

  // ========================= RÉSERVATIONS =========================
  List<Reservation> reservations = []; // Toutes les réservations en mémoire

  /// Réserve un trajet
  void reserveRide(Ride ride, int seats) {
    if (currentUser == null) return;

    reservations.add(
      Reservation(
        id: ride.id + currentUser!.id, // ID unique de la réservation
        ride: ride,
        user: currentUser!,
        seatsReserved: seats, // Nombre de places réservées
      ),
    );

    notifyListeners(); // Mise à jour de l’UI
  }

  /// Renvoie uniquement les réservations à venir pour l’utilisateur connecté
  List<Reservation> get upcomingReservations {
    final now = DateTime.now();
    return reservations
        .where(
          (r) =>
              r.user.id == currentUser?.id && r.ride.departureTime.isAfter(now),
        )
        .toList();
  }

  /// Supprime une réservation par l’ID du trajet
  void removeReservation(String rideId) {
    reservations.removeWhere((res) => res.ride.id == rideId);
    notifyListeners();
  }

  /// Supprime toutes les réservations pour un trajet spécifique
  void removeReservationsForRide(String rideId) {
    reservations.removeWhere((r) => r.ride.id == rideId);
    notifyListeners();
  }

  /// Annule une réservation par son ID
  void cancelReservation(String reservationId) {
    final idx = reservations.indexWhere((r) => r.id == reservationId);
    if (idx == -1) return; // Si non trouvé, retourne

    final removed = reservations.removeAt(idx); // Supprime la réservation

    // ========================= MISE À JOUR TRAJET =========================
    final ride = removed.ride;
    try {
      // Met à jour le nombre de places réservées
      // Ici exemple fixe, à adapter selon ton modèle mutable/immutable
      ride.reserverSeats = 3;

      // Met à jour le ride dans le service (Firestore)
      rideService.updateRide(ride);
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du ride: $e');
    }

    notifyListeners(); // Notifie l’UI
  }
}
