import '../app_ride_models.dart';

class ReservationWithUser {
  final Reservation reservation;
  final UserProfile user;

  ReservationWithUser({required this.reservation, required this.user});
}
