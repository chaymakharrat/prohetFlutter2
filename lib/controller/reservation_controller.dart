import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_ride_models.dart'; // ton modèle Reservation

class ReservationController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Ajouter une réservation à un ride
  Future<void> addReservation(String rideId, Reservation reservation) async {
    final ref = _db
        .collection('rides')
        .doc(rideId)
        .collection('reservations')
        .doc(); // ✅ auto ID

    await ref.set(reservation.toMap());

    final rideRef = _db.collection('rides').doc(rideId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(rideRef);
      final currentReserved = snapshot.get('reserverSeats') ?? 0;

      transaction.update(rideRef, {
        'reserverSeats': currentReserved + reservation.seatsReserved,
      });
    });
  }

  // Récupérer toutes les réservations pour un ride
  Future<List<Reservation>> getReservationsForRide(String rideId) async {
    final snapshot = await _db
        .collection('rides')
        .doc(rideId)
        .collection('reservations')
        .get();

    return snapshot.docs
        .map((doc) => Reservation.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Supprimer une réservation
  Future<void> cancelReservation(
    String rideId,
    String reservationId,
    int seats,
  ) async {
    final resRef = _db
        .collection('rides')
        .doc(rideId)
        .collection('reservations')
        .doc(reservationId);

    await resRef.delete();

    final rideRef = _db.collection('rides').doc(rideId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(rideRef);
      final currentReserved = snapshot.get('reserverSeats') ?? 0;
      transaction.update(rideRef, {'reserverSeats': currentReserved - seats});
    });
  }
  /// Récupère toutes les réservations actives d'un utilisateur dont le trajet n'est pas encore passé
  Future<List<Reservation>> getActiveReservationsForUser(String userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Récupère toutes les réservations actives de l'utilisateur
      final snapshot = await _db
          .collectionGroup('reservations')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .get();

      final reservations = <Reservation>[];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final rideId = data['rideId'] as String?;
        if (rideId == null) continue;

        // Récupère le ride correspondant
        final rideDoc = await _db.collection('rides').doc(rideId).get();
        if (!rideDoc.exists) continue;

        final rideData = rideDoc.data()!;
        final departureTimestamp = rideData['departureTime'] as Timestamp?;
        if (departureTimestamp == null) continue;

        final rideDate = DateTime(
          departureTimestamp.toDate().year,
          departureTimestamp.toDate().month,
          departureTimestamp.toDate().day,
        );

        // Ne garde que les rides dont la date de départ n'est pas passée
        if (!rideDate.isBefore(today)) {
          reservations.add(Reservation.fromMap(doc.id, data));
        }
      }

      return reservations;
    } catch (e) {
      print("Erreur getActiveReservationsForUser: $e");
      return [];
    }
  }
}
