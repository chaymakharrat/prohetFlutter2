import 'package:flutter/foundation.dart';
import 'app_ride_models.dart';

class LocationPoint {
  final double latitude;
  final double longitude;
  final String label;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    this.label = '',
  });

  @override
  String toString() => '($latitude,$longitude) $label';
}

// class UserProfile {
//   final String id;
//   final String name;
//   final double rating; // 0..5
//   final String avatarUrl;
//   final String phone;

//   const UserProfile({
//     required this.id,
//     required this.name,
//     this.rating = 4.5,
//     this.avatarUrl = '',
//     this.phone = '',
//   });
// }

@immutable
class Ride {
  final String id;
  final UserProfile driver;
  final LocationPoint origin;
  final LocationPoint destination;
  final DateTime departureTime;
  final int availableSeats;
  final double pricePerSeat;
  final double distanceKm; // optional precomputed distance
  final double durationMin; // optional precomputed duration
  double reserverSeats;

  Ride({
    required this.id,
    required this.driver,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.availableSeats,
    required this.pricePerSeat,
    this.distanceKm = 0,
    this.durationMin = 0,
    this.reserverSeats = 0,
  });

  Ride copyWith({
    int? availableSeats,
    double? distanceKm,
    double? durationMin,
    double? pricePerSeat,
  }) {
    return Ride(
      id: id,
      driver: driver,
      origin: origin,
      destination: destination,
      departureTime: departureTime,
      availableSeats: availableSeats ?? this.availableSeats,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMin: durationMin ?? this.durationMin,
    );
  }
}

class FilterOptions {
  final double? maxDistanceKm;
  final DateTime? earliestDeparture;
  final double? maxPrice;

  const FilterOptions({
    this.maxDistanceKm,
    this.earliestDeparture,
    this.maxPrice,
  });
}
