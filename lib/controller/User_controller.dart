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
  Future<void> addUserRating(String uid, double newRating, String comment) async {
    final docRef = _db.collection('users').doc(uid);
    final doc = await docRef.get();
    
    if (!doc.exists) return; // Or create? For now only update existing.
    
    final data = doc.data()!;
    final currentRating = (data['rating'] ?? 4.5).toDouble();
    final count = (data['ratingCount'] ?? 0) as int;

    // Calculate new average
    // If count is 0, we can weigh the initial 4.5 or just start fresh. 
    // Let's assume the initial 4.5 is a "starter" value if count is 0, so we can override strict math or just mix it.
    // Standard approach: weighted average.
    
    double updatedRating;
    if (count == 0) {
       updatedRating = newRating; // First real rating overrides default
    } else {
       updatedRating = ((currentRating * count) + newRating) / (count + 1);
    }

    await docRef.update({
      'rating': updatedRating,
      'ratingCount': count + 1,
      'feedback': comment, // Storing latest feedback
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
