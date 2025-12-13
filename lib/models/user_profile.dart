import 'package:cloud_firestore/cloud_firestore.dart';

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
  // 1️⃣ Convertir un user en Map<String, dynamic>
  // Méthode d’instance
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "rating": rating,
      "createdAt": FieldValue.serverTimestamp(),
    };
  }

  factory UserProfile.fromMap(String id, Map<String, dynamic> data) {
    return UserProfile(
      id: id,
      name: data["name"] ?? "",
      email: data["email"] ?? "",
      phone: data["phone"] ?? "",
      rating: (data["rating"] ?? 4.5).toDouble(),
    );
  }
}
