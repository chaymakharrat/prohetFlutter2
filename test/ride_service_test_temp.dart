import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter/controller/ride_service.dart';
import 'package:projet_flutter/models/app_ride_models.dart';

void main() {
  test('RideService updateRide and getUserRides verification', () {
    final service = RideService();
    
    // Test getUserRides with default seed (u0 should have some rides)
    final user0Rides = service.getUserRides('u0');
    // We expect some rides for u0 because of the seed loop (8 iterations, user id 'u$i')
    // Wait, the seed loop creates user 'u$i' for ride 'r$i'. So 'u0' should have ride 'r0'.
    
    expect(user0Rides.isNotEmpty, true, reason: 'u0 should have rides from seed');
    expect(user0Rides.first.driver.id, 'u0');

    // Test getUserRides('me') which we mocked to return 'u0' rides
    final meRides = service.getUserRides('me');
    expect(meRides.length, user0Rides.length);
    expect(meRides.first.id, user0Rides.first.id);
    
    // Test updateRide
    final rideToUpdate = user0Rides.first;
    final newPrice = rideToUpdate.pricePerSeat + 10.0;
    
    // Create a copy or modify if mutable (Ride is likely immutable or we modify fields directly if not const)
    // Looking at the file content earlier, Ride class definition wasn't fully shown but inferred.
    // Let's assume we can modify it or create a new one with same ID.
    // If Ride is immutable we'd need a copyWith, but let's try modifying a property if it's mutable 
    // or creating a new Ride object with same ID.
    
    // To be safe regarding mutability without seeing Ride class fully, let's create a new Ride instance with same ID
    final updatedRide = Ride(
        id: rideToUpdate.id,
        driver: rideToUpdate.driver,
        origin: rideToUpdate.origin,
        destination: rideToUpdate.destination,
        departureTime: rideToUpdate.departureTime,
        availableSeats: rideToUpdate.availableSeats,
        pricePerSeat: newPrice,
        distanceKm: rideToUpdate.distanceKm,
        durationMin: rideToUpdate.durationMin,
    );
    
    service.updateRide(updatedRide);
    
    final fetchedRide = service.getById(rideToUpdate.id);
    expect(fetchedRide?.pricePerSeat, newPrice, reason: 'Ride price should be updated');
    
    // Test getUserReservations
    final userReservations = service.getUserReservations('u0');
    expect(userReservations.isNotEmpty, true, reason: 'u0 should have seeded reservations');
    
  });
}
