import 'package:projet_flutter/models/dto/reservation_with_user.dart';
import 'package:projet_flutter/models/dto/ride_with_driver_dto.dart';

class RideWithReservations {
  final RideDTO rideDTO;
  final List<ReservationWithUser> reservations;

  RideWithReservations({required this.rideDTO, required this.reservations});
}
