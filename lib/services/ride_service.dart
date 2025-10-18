import 'dart:math';

import '../models/ride.dart';

class RideService {
  RideService() {
    _seed();
  }

  final List<Ride> _rides = <Ride>[];

  List<Ride> listRides({FilterOptions? filter}) {
    Iterable<Ride> results = _rides;
    if (filter != null) {
      if (filter.maxPrice != null) {
        results = results.where((r) => r.pricePerSeat <= filter.maxPrice!);
      }
      if (filter.earliestDeparture != null) {
        results = results.where(
          (r) => r.departureTime.isAfter(filter.earliestDeparture!),
        );
      }
      // maxDistanceKm filtering is ignored in seed data without a reference point
    }
    return results.toList();
  }

  void addRide(Ride ride) {
    _rides.add(ride);
  }

  Ride? getById(String id) => _rides.where((r) => r.id == id).firstOrNull;

  void _seed() {
    final random = Random(1);

    // Villes tunisiennes avec leurs coordonnées
    final cities = [
      {'name': 'Tunis', 'lat': 36.8065, 'lng': 10.1815},
      {'name': 'Sfax', 'lat': 34.7406, 'lng': 10.7603},
      {'name': 'Sousse', 'lat': 35.8256, 'lng': 10.6411},
      {'name': 'Kairouan', 'lat': 35.6711, 'lng': 10.1006},
      {'name': 'Bizerte', 'lat': 37.2744, 'lng': 9.8739},
      {'name': 'Gabès', 'lat': 33.8869, 'lng': 10.0982},
      {'name': 'Ariana', 'lat': 36.8601, 'lng': 10.1933},
      {'name': 'Gafsa', 'lat': 34.4250, 'lng': 8.7842},
      {'name': 'Monastir', 'lat': 35.7771, 'lng': 10.8262},
      {'name': 'Ben Arous', 'lat': 36.7531, 'lng': 10.2189},
    ];

    for (int i = 0; i < 8; i++) {
      final driver = UserProfile(
        id: 'u$i',
        name: 'Conducteur $i',
        rating: 4 + random.nextDouble(),
      );

      // Sélectionner deux villes différentes
      final originCity = cities[random.nextInt(cities.length)];
      final destCities = cities
          .where((city) => city['name'] != originCity['name'])
          .toList();
      final destCity = destCities[random.nextInt(destCities.length)];

      final origin = LocationPoint(
        latitude:
            (originCity['lat'] as double) + (random.nextDouble() - 0.5) * 0.1,
        longitude:
            (originCity['lng'] as double) + (random.nextDouble() - 0.5) * 0.1,
        label: originCity['name'] as String,
      );

      final dest = LocationPoint(
        latitude:
            (destCity['lat'] as double) + (random.nextDouble() - 0.5) * 0.1,
        longitude:
            (destCity['lng'] as double) + (random.nextDouble() - 0.5) * 0.1,
        label: destCity['name'] as String,
      );

      // Calculer la distance approximative entre les villes
      final distance = _calculateDistance(
        origin.latitude,
        origin.longitude,
        dest.latitude,
        dest.longitude,
      );

      final duration = distance / 60 * 60; // minutes à ~60km/h

      _rides.add(
        Ride(
          id: 'r$i',
          driver: driver,
          origin: origin,
          destination: dest,
          departureTime: DateTime.now().add(Duration(hours: i + 1)),
          availableSeats: 3 - (i % 2),
          pricePerSeat: (distance * 0.25).roundToDouble(),
          distanceKm: distance,
          durationMin: duration,
        ),
      );
    }
  }

  // Calcul de distance entre deux points avec la formule de Haversine
  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371; // km

    final double dLat = (lat2 - lat1) * pi / 180;
    final double dLng = (lng2 - lng1) * pi / 180;

    final double radLat1 = lat1 * pi / 180;
    final double radLat2 = lat2 * pi / 180;

    final double a =
        pow(sin(dLat / 2), 2) +
        cos(radLat1) * cos(radLat2) * pow(sin(dLng / 2), 2);

    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }
}

// Extension pour récupérer le premier élément ou null
extension FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
