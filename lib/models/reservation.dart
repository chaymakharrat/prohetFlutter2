import 'package:flutter/foundation.dart';
import 'app_ride_models.dart';

@immutable
class Reservation {
  final String id;
  final Ride ride;
  final UserProfile user;
  final int seatsReserved; // nombre de places réservées par cet utilisateur

  const Reservation({
    required this.id,
    required this.ride,
    required this.user,
    this.seatsReserved = 1,
  });
}
