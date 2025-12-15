class LocationPoint {
  final double latitude;
  final double longitude;
  final String label;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    this.label = '',
  });

  Map<String, dynamic> toMap() {
    return {'lat': latitude, 'lng': longitude, 'label': label};
  }

  factory LocationPoint.fromMap(Map<String, dynamic> map) {
    return LocationPoint(
      latitude: (map['lat'] as num).toDouble(),
      longitude: (map['lng'] as num).toDouble(),
      label: map['label'] ?? '',
    );
  }

  @override
  String toString() => '($latitude,$longitude) $label';
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
