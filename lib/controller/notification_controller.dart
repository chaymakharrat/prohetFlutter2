import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_flutter/controller/user_controller.dart';
import 'package:projet_flutter/models/dto/notification_with_users.dart';
import 'package:projet_flutter/models/notification.dart';

class NotificationController {
  final CollectionReference _notificationsRef = FirebaseFirestore.instance
      .collection('notifications');

  final UserController _userController = UserController();

  /// 🔔 Envoyer une notification
  Future<void> sendNotification({
    required String senderId,
    required String receiverId,
    required String rideId,
    required String title,
    required String body,
    required String type,
  }) async {
    final docRef = _notificationsRef.doc();

    final notification = AppNotification(
      id: docRef.id,
      senderId: senderId,
      receiverId: receiverId,
      rideId: rideId,
      type: type,
      title: title,
      body: body,
      isRead: false,
      createdAt: DateTime.now(),
    );

    await docRef.set(notification.toMap());
  }

  /// 📥 Notifications d'un utilisateur + users
  Future<List<NotificationWithUsers>> getUserNotifications(
    String userId,
  ) async {
    try {
      final snapshot = await _notificationsRef
          .where('receiverId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final List<NotificationWithUsers> result = [];

      for (var doc in snapshot.docs) {
        final notification = AppNotification.fromDoc(doc);

        final sender = await _userController.getUserProfile(
          notification.senderId,
        );
        final receiver = await _userController.getUserProfile(
          notification.receiverId,
        );

        if (sender != null && receiver != null) {
          result.add(
            NotificationWithUsers(
              notification: notification,
              sender: sender,
              receiver: receiver,
            ),
          );
        }
      }

      return result;
    } catch (e) {
      print("❌ getUserNotifications: $e");
      return [];
    }
  }

  /// 👁️ Marquer comme lue
  Future<void> markAsRead(String notificationId) async {
    await _notificationsRef.doc(notificationId).update({'isRead': true});
  }
}
