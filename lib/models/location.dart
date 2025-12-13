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

// class FilterOptions {
//   final double? maxDistanceKm;
//   final DateTime? earliestDeparture;
//   final double? maxPrice;

//   const FilterOptions({
//     this.maxDistanceKm,
//     this.earliestDeparture,
//     this.maxPrice,
//   });
// }
