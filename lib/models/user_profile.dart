import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String name;
  final double rating; // 0..5
  final String phone;
  String email;
  final String feedback;

  final int ratingCount;

  UserProfile({
    required this.id,
    required this.name,
    this.email = "chayma@gmail.com",
    required this.phone,
    this.rating = 4.5,
    this.ratingCount = 0,
    this.feedback = "",
  });
  // 1️⃣ Convertir un user en Map<String, dynamic>
  // Méthode d’instance
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "rating": rating,
      "ratingCount": ratingCount,
      "feedback": feedback,
      "updatedAt": FieldValue.serverTimestamp(),
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
      ratingCount: (data["ratingCount"] ?? 0) as int,
      feedback: data["feedback"] ?? "",
    );
  }
}
