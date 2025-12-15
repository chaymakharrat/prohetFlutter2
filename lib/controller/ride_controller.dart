import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_flutter/controller/user_controller.dart';
import 'package:projet_flutter/models/dto/reservation_with_user.dart';
import 'package:projet_flutter/models/dto/ride_with_driver_dto.dart';
// import 'package:projet_flutter/models/location.dart';
// import 'package:projet_flutter/models/reservationFire.dart';
// import 'package:projet_flutter/models/rideFire.dart';
// import 'package:projet_flutter/models/user_profile.dart';
import '../models/app_ride_models.dart';

class RideController {
  final CollectionReference _ridesRef = FirebaseFirestore.instance.collection(
    'rides',
  );
  final CollectionReference _usersRef = FirebaseFirestore.instance.collection(
    'users',
  );
  UserController _userProfileController = UserController();

  // ➕ Ajouter un ride
  Future<void> addRide(Ride ride) async {
    await _ridesRef.add({
      'driverId': ride.driverId,
      'origin': ride.origin.toMap(),
      'destination': ride.destination.toMap(),
      'departureTime': Timestamp.fromDate(ride.departureTime),
      'availableSeats': ride.availableSeats,
      'pricePerSeat': ride.pricePerSeat,
      'distanceKm': ride.distanceKm,
      'durationMin': ride.durationMin,
      'reserverSeats': ride.reserverSeats,
      'status': 'active',
    });
  }

  /// Mettre à jour un ride existant
  Future<void> updateRide(Ride ride) async {
    try {
      final docRef = _ridesRef.doc(ride.id);

      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        throw Exception("Le trajet n'existe pas !");
      }

      await docRef.update(ride.toMap());
    } catch (e) {
      print("Erreur updateRide: $e");
      rethrow;
    }
  }

  // suprimer les rides
  Future<void> cancelRide(String rideId) async {
    await _ridesRef.doc(rideId).update({
      'status': 'CANCELLED',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 🔍 Récupérer un ride avec infos du driver qui sont active et ne passe pas le temps
  // Future<RideDTO?> getActiveById(String id) async {
  //   final doc = await _ridesRef.doc(id).get();
  //   if (!doc.exists) return null;

  //   final data = doc.data() as Map<String, dynamic>;

  //   // ✅ Filtrage par status ACTIVE
  //   if (data['status'] != 'active') {
  //     return null;
  //   }

  //   final ride = Ride.fromMap(doc.id, data);

  //   final driverDoc = await _usersRef.doc(ride.driverId).get();
  //   final driver = UserProfile.fromMap(
  //     driverDoc.id,
  //     driverDoc.data() as Map<String, dynamic>,
  //   );

  //   return RideDTO(ride: ride, driver: driver);
  // }

  // 👤 Rides d’un conducteur les rides active et ne passe pas le temps
  Future<List<RideDTO>> getUserRides(String userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      // Filtrer uniquement les trajets dont le status est 'active' et dont la date n'est pas passée
      final snapshot = await _ridesRef
          .where('driverId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .where(
            'departureTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(today),
          )
          .orderBy('departureTime')
          .get();
      final rides = <RideDTO>[];

      for (var doc in snapshot.docs) {
        final ride = Ride.fromMap(doc.id, doc.data() as Map<String, dynamic>);

        final driverDoc = await _usersRef.doc(userId).get();
        final driver = UserProfile.fromMap(
          driverDoc.id,
          driverDoc.data() as Map<String, dynamic>,
        );

        rides.add(RideDTO(ride: ride, driver: driver));
      }

      return rides;
    } catch (e) {
      print("Erreur getUserRides: $e");
      return [];
    }
  }

  // 🔹 Récupérer tous les rides avec infos driver (optionnel pour listing) les drive active et ne passe pas le temps
  Future<List<RideDTO>> listRides({FilterOptions? filter}) async {
    try {
      Query query = _ridesRef.where('status', isEqualTo: 'active');

      // Filtre par prix max si défini
      if (filter?.maxPrice != null) {
        query = query.where(
          'pricePerSeat',
          isLessThanOrEqualTo: filter!.maxPrice,
        );
      }
      //Filtrer uniquement les trajets dont la date n'est pas passée
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      query = query.where(
        'departureTime',
        isGreaterThanOrEqualTo: Timestamp.fromDate(today),
      );
      // Trier par date
      query = query.orderBy('departureTime');

      final snapshot = await query.get();
      final rides = <RideDTO>[];

      for (var doc in snapshot.docs) {
        final ride = Ride.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        final driverDoc = await _usersRef.doc(ride.driverId).get();
        final driver = UserProfile.fromMap(
          driverDoc.id,
          driverDoc.data() as Map<String, dynamic>,
        );
        rides.add(RideDTO(ride: ride, driver: driver));
      }

      return rides;
    } catch (e) {
      print("Erreur listRides: $e");
      return [];
    }
  }

  // Ajoute cette méthode dans ton ReservationController
  Future<RideDTO> getRideById(String rideId) async {
    try {
      // Récupération du document ride
      final doc = await _ridesRef.doc(rideId).get();
      if (!doc.exists) throw Exception("Trajet non trouvé");

      final ride = Ride.fromMap(doc.id, doc.data() as Map<String, dynamic>);

      // Récupération des infos du driver
      final driverDoc = await _usersRef.doc(ride.driverId).get();
      if (!driverDoc.exists) throw Exception("Driver non trouvé");

      final driver = UserProfile.fromMap(
        driverDoc.id,
        driverDoc.data() as Map<String, dynamic>,
      );

      return RideDTO(ride: ride, driver: driver);
    } catch (e) {
      print("Erreur getRideById: $e");
      rethrow;
    }
  }

  /// Récupère toutes les réservations pour un trajet donné
  /// Récupère toutes les réservations pour un trajet donné
  Future<List<Reservation>> getReservationsForRide(String rideId) async {
    try {
      final snapshot = await _ridesRef
          .doc(rideId) // ← juste le doc ici, pas collection('rides') avant
          .collection('reservations')
          .where('status', isEqualTo: 'active') // uniquement actives
          .get();

      final reservations = snapshot.docs
          .map((doc) => Reservation.fromMap(doc.id, doc.data()))
          .toList();

      return reservations;
    } catch (e) {
      print('Erreur getReservationsForRide: $e');
      return [];
    }
  }

  Future<List<ReservationWithUser>> getReservationsWithUsersForRide(
    String rideId,
  ) async {
    // 1️⃣ Récupérer les réservations
    final reservations = await getReservationsForRide(rideId);

    // 2️⃣ Pour chaque réservation → récupérer le profil utilisateur
    return Future.wait(
      reservations.map((reservation) async {
        final user = await _userProfileController.getUserProfile(
          reservation.userId,
        );

        if (user == null) {
          throw Exception('Utilisateur introuvable');
        }

        return ReservationWithUser(reservation: reservation, user: user);
      }),
    );
  }
}
