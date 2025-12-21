import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_flutter/models/location.dart';

enum RideStatus { active, cancelled }

enum RidePeriod { matin, apresmidi, soir, nuit }

extension RidePeriodExtension on RidePeriod {
  String get displayName {
    switch (this) {
      case RidePeriod.matin:
        return "Matin";
      case RidePeriod.apresmidi:
        return "Après-midi";
      case RidePeriod.soir:
        return "Soir";
      case RidePeriod.nuit:
        return "Nuit";
    }
  }
}

class Ride {
  final String id;
  final String driverId;
  final LocationPoint origin;
  final LocationPoint destination;
  final DateTime departureTime;
  final RidePeriod period; // ✅ ajouté correctement
  final int availableSeats;
  final double pricePerSeat;
  final double distanceKm;
  final double durationMin;
  double reserverSeats;
  final RideStatus status;

  Ride({
    required this.id,
    required this.driverId,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.period, // ✅ ici
    required this.availableSeats,
    required this.pricePerSeat,
    this.distanceKm = 0,
    this.durationMin = 0,
    this.reserverSeats = 0,
    this.status = RideStatus.active,
  });

  // 🔁 Firestore
  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'origin': origin.toMap(),
      'destination': destination.toMap(),
      'departureTime': Timestamp.fromDate(departureTime),
      'period': period.name, // ✅ sauvegarde
      'availableSeats': availableSeats,
      'pricePerSeat': pricePerSeat,
      'distanceKm': distanceKm,
      'durationMin': durationMin,
      'reserverSeats': reserverSeats,
      'status': status.name,
    };
  }

  factory Ride.fromMap(String id, Map<String, dynamic> map) {
    return Ride(
      id: id,
      driverId: map['driverId'] ?? '',
      origin: LocationPoint.fromMap(map['origin']),
      destination: LocationPoint.fromMap(map['destination']),
      departureTime: (map['departureTime'] as Timestamp).toDate(),
      period: RidePeriod.values.firstWhere(
        (e) => e.name == map['period'],
        orElse: () => RidePeriod.matin,
      ),
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

  Ride copyWith({RideStatus? status, RidePeriod? period}) {
    return Ride(
      id: id,
      driverId: driverId,
      origin: origin,
      destination: destination,
      departureTime: departureTime,
      period: period ?? this.period,
      availableSeats: availableSeats,
      pricePerSeat: pricePerSeat,
      distanceKm: distanceKm,
      durationMin: durationMin,
      reserverSeats: reserverSeats,
      status: status ?? this.status,
    );
  }
}
