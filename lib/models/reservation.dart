import 'package:cloud_firestore/cloud_firestore.dart';

enum ReservationStatus { active, cancelled }

class Reservation {
  final String id;
  final String rideId; // ← nouveau champ
  final String userId;
  final int seatsReserved;
  final DateTime createdAt;
  final ReservationStatus status;

  Reservation({
    required this.id,
    required this.rideId, // ← obligatoire maintenant
    required this.userId,
    required this.seatsReserved,
    required this.createdAt,
    this.status = ReservationStatus.active,
  });

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId, // ← sauvegarder dans Firestore
      'userId': userId,
      'seatsReserved': seatsReserved,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
    };
  }

  factory Reservation.fromMap(String id, Map<String, dynamic> map) {
    return Reservation(
      id: id,
      rideId: map['rideId'] ?? '', // ← récupérer depuis Firestore
      userId: map['userId'] ?? '',
      seatsReserved: map['seatsReserved'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: map['status'] == 'cancelled'
          ? ReservationStatus.cancelled
          : ReservationStatus.active,
    );
  }
}
