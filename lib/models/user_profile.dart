class UserProfile {
  final String id;
  final String name;
  final double rating; // 0..5
  final String phone;
  String email;

  UserProfile({
    required this.id,
    required this.name,
    this.email = "chayma@gmail.com",
    required this.phone,
    this.rating = 4.5,
  });
}
