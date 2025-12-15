import '../app_ride_models.dart';

class RideDTO {
  final Ride ride;
  final UserProfile driver;

  RideDTO({required this.ride, required this.driver});
}
