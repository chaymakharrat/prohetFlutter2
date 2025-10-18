import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Returns the current position or null if permission is denied or an error occurs.
  Future<Position?> getCurrentPosition() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final r = await Geolocator.requestPermission();
        if (r == LocationPermission.denied ||
            r == LocationPermission.deniedForever) {
          return null;
        }
      }
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (_) {
      return null;
    }
  }
}
