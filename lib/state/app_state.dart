import 'package:flutter/material.dart';
import '../models/app_ride_models.dart';
//import '../controller/ride_controller.dart';
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
  RideController rideController = RideController();

  // ========================= TRAJET EN COURS =========================
  LocationPoint? origin; // Point de départ sélectionné
  LocationPoint? destination; // Point d’arrivée sélectionné
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

  /////////////////////
}
