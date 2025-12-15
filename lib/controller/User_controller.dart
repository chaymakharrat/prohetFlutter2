import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_profile.dart';

class UserController {
  final _db = FirebaseFirestore.instance;

  Future<void> createUserProfile(UserProfile profile) async {
    await _db.collection("users").doc(profile.id).set(profile.toMap());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data()!;

    return UserProfile.fromMap(doc.id, data);
  }
}
