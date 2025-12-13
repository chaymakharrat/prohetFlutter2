import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_profile.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  Future<void> saveUserProfile(UserProfile profile) async {
    await _db.collection("users").doc(profile.id).set({
      "name": profile.name,
      "email": profile.email,
      "phone": profile.phone,
      "rating": profile.rating,
    });
  }

  Future<UserProfile?> getUserProfile(String id) async {
    final doc = await _db.collection("users").doc(id).get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    return UserProfile(
      id: id,
      name: data["name"],
      email: data["email"],
      phone: data["phone"],
      rating: (data["rating"] ?? 4.5).toDouble(),
    );
  }
}
