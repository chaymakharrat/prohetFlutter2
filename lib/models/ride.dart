import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_flutter/models/location.dart';

enum RideStatus { active, cancelled }

class Ride {
  final String id;
  final String driverId;
  final LocationPoint origin;
  final LocationPoint destination;
  final DateTime departureTime;
  final int availableSeats;
  final double pricePerSeat;
  final double distanceKm;
  final double durationMin;
  double reserverSeats;
  final RideStatus status; // Nouveau champ simple

  Ride({
    required this.id,
    required this.driverId,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.availableSeats,
    required this.pricePerSeat,
    this.distanceKm = 0,
    this.durationMin = 0,
    this.reserverSeats = 0,
    this.status = RideStatus.active, // par défaut actif
  });

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'origin': origin.toMap(),
      'destination': destination.toMap(),
      'departureTime': Timestamp.fromDate(departureTime),
      'availableSeats': availableSeats,
      'pricePerSeat': pricePerSeat,
      'distanceKm': distanceKm,
      'durationMin': durationMin,
      'reserverSeats': reserverSeats,
      'status': status.name, // stocké comme string
    };
  }

  factory Ride.fromMap(String id, Map<String, dynamic> map) {
    return Ride(
      id: id,
      driverId: map['driverId'] ?? '',
      origin: LocationPoint.fromMap(map['origin']),
      destination: LocationPoint.fromMap(map['destination']),
      departureTime: (map['departureTime'] as Timestamp).toDate(),
      availableSeats: map['availableSeats'] ?? 0,
      pricePerSeat: (map['pricePerSeat'] ?? 0).toDouble(),
      distanceKm: (map['distanceKm'] ?? 0).toDouble(),
      durationMin: (map['durationMin'] ?? 0).toDouble(),
      reserverSeats: (map['reserverSeats'] ?? 0).toDouble(),
      status: map['status'] == 'cancelled'
          ? RideStatus.cancelled
          : RideStatus.active,
    );
  }

  Ride copyWith({RideStatus? status}) {
    return Ride(
      id: id,
      driverId: driverId,
      origin: origin,
      destination: destination,
      departureTime: departureTime,
      availableSeats: availableSeats,
      pricePerSeat: pricePerSeat,
      distanceKm: distanceKm,
      durationMin: durationMin,
      reserverSeats: reserverSeats,
      status: status ?? this.status,
    );
  }
}
